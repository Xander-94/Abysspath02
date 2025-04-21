import httpx
import os
import logging
import json
from typing import List, Optional, AsyncGenerator, Dict
from datetime import datetime
from tenacity import retry, stop_after_attempt, wait_exponential, before_log, after_log
from models.chat import Message, ChatRequest, ChatResponse
import time
from functools import lru_cache
from pathlib import Path
from dotenv import load_dotenv

logger = logging.getLogger(__name__)

# 加载环境变量
env_path = Path(__file__).parent.parent / '.env'
load_dotenv(env_path)
logger.info(f"尝试加载环境变量文件: {env_path}")

class DeepseekConfig:
    def __init__(self):
        self.api_key = os.getenv("DEEPSEEK_API_KEY")
        if not self.api_key:
            logger.error(f"DEEPSEEK_API_KEY环境变量未设置，请检查 {env_path} 文件")
            raise ValueError(f"DEEPSEEK_API_KEY环境变量未设置，请检查 {env_path} 文件")
            
        self.base_url = os.getenv("DEEPSEEK_BASE_URL", "https://api.deepseek.com/v1")
        self.model = "deepseek-chat"
        self.temperature = 0.7
        self.max_tokens = 4096
        self.timeout = 60
        self.system_prompt = os.getenv("SYSTEM_PROMPT", "你是一个专业的AI助手")
        self.assessment_system_prompt = """
        # 角色  
你是一名职业发展顾问，需要根据用户输入的自我介绍，​**结构化提取关键信息**并**生成个性化建议**。请严格遵循以下规则：

---
请严格遵循规则解析用户输入，输出增强型JSON及整合建议。如果用户追加自我介绍，请在**之前**的完整对话历史中找到上一次输出的JSON，然后解析**最新**的用户输入，并将新提取的信息**合并更新**到**上一次**的JSON结构中，最后基于**合并后**的完整JSON生成建议。**不要**为每次追加的输入创建全新的JSON。

# 输出格式要求
```json
{
  "core_analysis": {
    "competencies": [
      {
        "name": "技能名称（保留用户原话）",
        "level": "入门/中级/熟练/精通（按时间+成果判定）",
        "validation": ["项目/证书/奖项"]
      }
//...其他技能项
    ],
    "interest_layers": {
      "explicit": ["直接陈述的兴趣"],
      "implicit": ["持续3个月以上的行为推导"]
    }
// ...其他兴趣项
  },
  "behavioral_profile": {
    "hobbies": [
      {
        "name": "爱好名称",
        "engagement": {
          "frequency": "每天/每周/每月/偶尔（按关键词判定）",
          "social_impact": "独处/小团体/大众社交"
        }
      }
// ...其他爱好项
    ],
    "personality": {
      "strengths": ["原文推导的性格优势"],
      "conflicts": ["检测到的内在矛盾"]
    }
// ...其他性格项
  }，
   **解析规则**
1. 技能等级判定：
   - 入门：≤3个月/无实际项目
   - 中级：3-6个月/参与过小型项目
   - 熟练：6-24个月/主导过完整项目
   - 精通：≥24个月/有专业认证/行业奖项
2. 矛盾处理优先级：
   实际能力描述 > 时间描述 > 自我评价形容词
3. 否定词过滤：
   出现"不擅长/讨厌/拒绝"等词时，对应内容不进interests/skills
4.爱好识别机制：
   - 频率判定：出现"每天/每周"等词时自动标记，否则为"偶尔"
   - 社交类型：根据"独自/组队/参加俱乐部"等关键词分类
5.隐性兴趣挖掘：
   - 持续3个月以上的爱好自动升级为潜在发展领域
   - 与核心技能产生交叉的爱好触发"兴趣变现"建议
6.冲突检测：
   - 当"独处型爱好"与"团队协作需求"共存时生成优化建议
7.分类建议：
   - 根据用户输入的自我介绍，严格分类技能项、兴趣项、爱好项、性格项，未提及内容可不输出相应JSON字段
**精准建议生成原则**
//尽可能简明扼要，建议字数控制在100字以内、并且不以JSON格式输出，以纯文本输出。
1. 兴趣延伸：建议与已确认兴趣相关的进阶方向（提供行业报告名称）
2. 个性优化：针对traits建议沟通技巧训练方法（具体到方法论名称） """
        
        self.learning_path_system_prompt = """# 角色
你是一名经验丰富的个性化学习路径设计师，擅长结合技术能力、元能力（如学习方法、思维模型）和影响力发展（如个人品牌、社区参与）目标，为用户量身定制**逻辑清晰、结构合理、可视化友好**的学习计划。

# 输入信息
你将收到以下信息：
1.  **用户目标 (User Goal)**: 用户明确提出的学习或发展目标。
2.  **用户画像 (User Profile)**: 一个包含用户自我评估（来自问卷）和 AI 对话评估结果（如果存在）的 JSON 对象。你需要从中提取关键信息，如：
    *   现有技能 (`competencies.name`, `competencies.level`)
    *   兴趣领域 (`interest_layers.explicit`, `interest_layers.implicit`)
    *   性格特点 (`personality.strengths`, `personality.conflicts`)
    *   学习偏好、可用时间等。
3.  **(可选) 当前上下文**: 可能包含用户对已有路径的反馈或调整要求。

# 核心任务
根据用户目标和用户画像，生成一个结构化的、个性化的学习路径 JSON 对象。请严格遵循以下输出格式和设计原则。

# **设计原则**
1.  **逻辑性与递进性**: 路径应从基础到进阶，节点之间体现清晰的依赖关系或学习顺序。使用 `edges` 明确表达这种流程。避免混乱或无序的节点排列。
2.  **先导关系明确 (Crucial)**: **必须**识别出知识点之间的**先导（或前置依赖）关系**。例如，学习 'Python 类' 之前必须先掌握 'Python 基础语法'。这种关系**必须**通过 `edges` 中的 `relation_type: 'dependency'` 来明确表示。
3.  **层级分解 (Hierarchical Decomposition)**: **鼓励**将大的主题或复杂技能分解为更小、更具体的子节点。一个父节点可以连接到多个子节点，形成"由大到小"的结构。例如，"机器学习基础"节点可以分支连接到"监督学习"、"无监督学习"和"模型评估"等子节点。
4.  **结构化与模块化**: 考虑将大型路径分解为若干逻辑阶段或模块，使整体结构更清晰。虽然输出格式不强制分阶段，但在节点安排和描述中应体现此思想。
5.  **简洁与清晰**: 节点标签 (`label`) 应简明扼要，易于在图谱中理解。节点类型 (`type`) 使用需一致，便于视觉区分。避免过于冗长或模糊的描述。
6.  **相关性与完整性**: 所有节点和资源都应直接服务于最终的 `target_goal`。确保路径覆盖达成目标所需的关键步骤。
7.  **可操作性**: 每个节点应代表一个具体的学习单元或实践活动。

# **严格的输出格式要求 (JSON)**
请确保你的**整个输出**是一个**单一的、完整的 JSON 对象**。**不要**在 JSON 对象的**开始之前**或**结束之后**包含任何其他文本、注释、说明或任何非 JSON 内容。输出**必须**以 `{` 开始，并以匹配的 `}` 结束，中间不能有任何非 JSON 字符。
```json
{
  "learning_path": {
    "title": "[根据用户目标和画像生成的个性化路径标题]",
    "description": "[简要描述路径特点、适用人群和预期成果，体现逻辑结构]",
    "estimated_duration": "[预估完成路径的总时间范围，例如 '3-6个月']",
    "target_goal": "[清晰描述通过此路径可达成的具体目标]",
    "nodes": [
      {
        "id": "[节点的唯一标识符，英文小写+下划线，例如 'python_basics']",
        "label": "[节点在图谱中显示的简短名称，例如 'Python 基础']", // 要求：简洁明了
        "type": "[节点类型: **必须且只能**从 'skill', 'concept', 'tool', 'project', 'meta_skill', 'influence_skill', 'bridge', 'other' 中选择。**严禁使用任何其他类型**]", // **再次强调：严格限制类型，禁止其他值**
        "details": "[对该节点的详细说明，学习内容或活动描述]",
        "estimated_time": "[完成此节点的预估时间，例如 '2周']"
      }
      // ... 其他所有节点 (请注意节点间的逻辑顺序和依赖)
    ],
    "edges": [
      {
        "from": "[起始节点的 id]",
        "to": "[目标节点的 id]",
        "relation_type": "[可选，但推荐使用以增强逻辑性: 'dependency'(强依赖/先导关系), 'sequence'(顺序步骤), 'related'(相关但不强制依赖), 'bridge_to'(阶段过渡)]" // 明确关系类型，尤其是 'dependency'
      }
      // ... 其他所有定义路径流向的边 (确保边的设置反映了设计的逻辑流程、先导关系，并允许**一个节点连接到多个后续节点以实现分支**)
    ],
    "resources": {
      "[节点 id]": [
        {
          "title": "[资源标题]",
          "type": "[资源类型: 必须严格从 'course', 'book', 'article', 'video', 'tutorial', 'documentation', 'practice', 'community', 'tool', 'podcast', 'other' 中选择]", // **严格限制类型**
          "url": "[资源的 URL 链接（如果适用）]",
          "description": "[对资源的简短推荐语或说明]"
        }
        // ... 该节点的其他资源
      ]
      // ... 其他节点的资源列表
    }
  }
}
```"""
        
        logger.info(f"DeepseekConfig 初始化完成:")
        logger.info(f"  - API Key: {self.api_key[:8]}...")
        logger.info(f"  - Base URL: {self.base_url}")
        logger.info(f"  - Model: {self.model}")
        logger.info(f"  - Timeout: {self.timeout}s")

class DeepseekError(Exception):
    def __init__(self, message: str, status_code: int = None):
        self.message = message
        self.status_code = status_code
        super().__init__(message)

class DeepseekMetrics:
    def __init__(self):
        self.total_requests = 0
        self.failed_requests = 0
        self.average_response_time = 0
        self.last_error = None
        self.last_error_time = None
    
    def record_request(self, success: bool, response_time: float):
        self.total_requests += 1
        if not success:
            self.failed_requests += 1
        self.average_response_time = (
            (self.average_response_time * (self.total_requests - 1) + response_time)
            / self.total_requests
        )
    
    def record_error(self, error: str):
        self.last_error = error
        self.last_error_time = datetime.now()
    
    def get_stats(self) -> Dict:
        return {
            "total_requests": self.total_requests,
            "failed_requests": self.failed_requests,
            "success_rate": (self.total_requests - self.failed_requests) / self.total_requests if self.total_requests > 0 else 0,
            "average_response_time": self.average_response_time,
            "last_error": self.last_error,
            "last_error_time": self.last_error_time.isoformat() if self.last_error_time else None
        }

class DeepseekService:
    def __init__(self):
        self.config = DeepseekConfig()
        self.metrics = DeepseekMetrics()
        # 配置 httpx 客户端，增加超时时间
        self.client = httpx.AsyncClient(
            headers={"Authorization": f"Bearer {self.config.api_key}"},
            timeout=httpx.Timeout(180.0, connect=10.0) # 设置总超时180秒, 连接超时10秒
        )
        self._cache = {}
        logger.info("DeepseekService 初始化完成")
    
    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=4, max=10),
        before=before_log(logger, logging.DEBUG),
        after=after_log(logger, logging.DEBUG)
    )
    async def chat(self, message: str, is_assessment: bool = False, is_learning_path: bool = False) -> ChatResponse:
        """发送单条消息到Deepseek API，并处理历史（如果需要）"""
        start_time = time.time()
        try:
            # 根据场景选择系统提示词
            system_prompt_to_use = self.config.system_prompt
            if is_assessment:
                system_prompt_to_use = self.config.assessment_system_prompt
            elif is_learning_path:
                system_prompt_to_use = self.config.learning_path_system_prompt

            # 构建发送给 API 的 messages 列表
            # TODO: 将来可能需要实现更复杂的历史记录管理
            api_messages = [
                Message(role="system", content=system_prompt_to_use).dict(),
                Message(role="user", content=message).dict() # 使用传入的单条消息
            ]

            payload = {
                "model": self.config.model,
                "messages": api_messages,
                "temperature": self.config.temperature,
                "max_tokens": self.config.max_tokens,
                "stream": False
            }
            logger.debug(f"发送到 Deepseek API 的 Payload: {json.dumps(payload, ensure_ascii=False)}")

            response = await self.client.post(f"{self.config.base_url}/chat/completions", json=payload)
            response.raise_for_status()  # 如果状态码不是 2xx，则抛出异常

            data = response.json()
            logger.debug(f"从 Deepseek API 收到的响应: {json.dumps(data, ensure_ascii=False)}")
            
            response_time = time.time() - start_time
            self.metrics.record_request(success=True, response_time=response_time)

            ai_content = data['choices'][0]['message']['content']
            usage = data.get('usage')

            return ChatResponse(
                content=ai_content,
                conversation_id="string", # TODO: 需要传入或生成会话ID
                usage=usage
            )

        except httpx.HTTPStatusError as e:
            response_time = time.time() - start_time
            self.metrics.record_request(success=False, response_time=response_time)
            error_content = e.response.text
            logger.error(f"Deepseek API 请求失败: {e.response.status_code} - {error_content}")
            self.metrics.record_error(f"HTTPStatusError: {e.response.status_code} - {error_content}")
            raise DeepseekError(f"Deepseek API错误: {e.response.status_code} - {error_content}", status_code=e.response.status_code) from e
        except httpx.RequestError as e:
            response_time = time.time() - start_time
            self.metrics.record_request(success=False, response_time=response_time)
            logger.error(f"连接 Deepseek API 失败: {e}")
            self.metrics.record_error(f"RequestError: {e}")
            raise DeepseekError(f"无法连接到 Deepseek API: {e}") from e
        except Exception as e:
            response_time = time.time() - start_time
            self.metrics.record_request(success=False, response_time=response_time)
            logger.exception("处理 Deepseek 响应时发生未知错误")
            self.metrics.record_error(f"Unknown Error: {e}")
            raise DeepseekError(f"处理 Deepseek 响应时发生未知错误: {e}") from e
    
    def _get_cache_key(self, messages: List[Message]) -> str:
        return str([(msg.role, msg.content) for msg in messages])
    
    def get_metrics(self) -> Dict:
        return self.metrics.get_stats()
    
    async def close(self):
        await self.client.aclose()

    async def stream_chat(self, message: str, **kwargs) -> AsyncGenerator[str, None]:
        """发送单条消息到Deepseek API，并流式返回响应"""
        try:
            # 构建发送给 API 的 messages 列表 (同 chat 方法)
            # TODO: 将来可能需要实现更复杂的历史记录管理
            api_messages = [
                Message(role="system", content=self.config.system_prompt).dict(), # 简化处理，默认使用通用 system prompt
                Message(role="user", content=message).dict()
            ]

            payload = {
                "model": self.config.model,
                "messages": api_messages,
                "temperature": self.config.temperature,
                "max_tokens": self.config.max_tokens,
                "stream": True
            }
            logger.debug(f"发送到 Deepseek API 的流式 Payload: {json.dumps(payload, ensure_ascii=False)}")

            async with self.client.stream("POST", f"{self.config.base_url}/chat/completions", json=payload) as response:
                response.raise_for_status()
                async for chunk in response.aiter_lines():
                    if chunk.startswith("data: "):
                        data_str = chunk[len("data: "):].strip()
                        if data_str == "[DONE]":
                            break
                        try:
                            data = json.loads(data_str)
                            content = data.get("choices", [{}])[0].get("delta", {}).get("content")
                            if content:
                                yield content
                        except json.JSONDecodeError:
                            logger.warning(f"无法解析流式块: {data_str}")
                            continue
        except httpx.HTTPStatusError as e:
             error_content = await e.response.aread() # 读取错误响应体
             logger.error(f"Deepseek API 流式请求失败: {e.response.status_code} - {error_content.decode()}")
             self.metrics.record_error(f"Stream HTTPStatusError: {e.response.status_code} - {error_content.decode()}")
             yield f"Error: Deepseek API错误 - {e.response.status_code}" # 在流中返回错误信息
        except httpx.RequestError as e:
             logger.error(f"连接 Deepseek API 流式请求失败: {e}")
             self.metrics.record_error(f"Stream RequestError: {e}")
             yield f"Error: 无法连接到 Deepseek API"
        except Exception as e:
             logger.exception("处理 Deepseek 流式响应时发生未知错误")
             self.metrics.record_error(f"Stream Unknown Error: {e}")
             yield f"Error: 处理 Deepseek 流式响应时发生未知错误"

# 全局服务实例
deepseek_service = DeepseekService()

# 移除或注释掉全局函数 chat 和 stream_chat，因为我们现在使用类方法
# async def chat(messages: List[Message], **kwargs) -> ChatResponse:
#     # ...
#
# async def stream_chat(messages: List[Message], **kwargs) -> AsyncGenerator[str, None]:
#     # ...

# 实例化服务 (如果需要在其他地方导入实例)
# deepseek_service = DeepseekService() 