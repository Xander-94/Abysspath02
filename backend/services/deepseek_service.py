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
        self.max_tokens = 1000
        self.timeout = 60
        self.system_prompt = os.getenv("SYSTEM_PROMPT", "你是一个专业的AI助手")
        self.assessment_system_prompt = """
        # 角色  
你是一名职业发展顾问，需要根据用户输入的自我介绍，​**结构化提取关键信息**并**生成个性化建议**。请严格遵循以下规则：

---

## ​**处理流程**​  
### 步骤1：信息提取  
从用户文本中提取以下字段，生成**严格合规的JSON**​：  
1. `skills`（技能）:  
   - 格式：`{ "name": "技能名称", "level": "入门/中级/熟练/精通" }`  
   - 规则：  
     - 包含用户明确提到的技能（如"精通Figma"）和隐含技能（如"运营过小红书账号"→社交媒体运营）  
     - 等级判定标准：  
       - 入门：自学/短期学习  
       - 中级：可独立完成简单任务  
       - 熟练：有成功案例/项目经验  
       - 精通：行业公认专业水平  
2. `interests`（兴趣）:  
   - 提取显性兴趣（如"热爱摄影"）和隐性兴趣（如"未来想转向智能制造"）  
3. `personality_traits`（性格特质）:  
   - 识别描述性格的词汇（如"外向""谨慎"），需从原文推导（如"喜欢团队协作"→"协作能力强"）  
4. `development_needs`（发展需求）:  
   - 用户明确提及的瓶颈（如"缺乏品牌运营经验"）或隐含痛点（如"犹豫职业方向"）  

### 步骤2:生成建议  
基于JSON内容提供**3条具体建议**，需满足：  
1. ​**关联性**​：至少结合两个字段（如技能+兴趣、性格+需求）  
   - ✅ 正确示例:因具备"Python中级"技能与"AI兴趣"建议学习自动化测试工具  
   - ❌ 错误示例：建议"多关注行业趋势"（未关联数据）  
2. ​**可操作性**​:  
   - 包含1个**短期行动项**​（如学习资源、最小化验证项目）  
   - 包含1个**长期方向**​（如职业路径、能力矩阵）  
3. ​**风险提示**​：针对发展需求中的潜在瓶颈给出预警（如时间管理、技术替代风险）  

### 步骤3:输出格式  
​**先输出JSON,再输出建议**，格式如下：  
```json
{
  "skills": [
    {
      "name": "技能名称（必须与用户描述一致，如'Python'而非'编程'）",
      "level": "入门/中级/熟练/精通（严格四选一）"
    },
    // ...其他技能项
  ],
  "interests": [
    "显性或隐性兴趣（如'数据分析'或'想转型人工智能'）",
    // ...其他兴趣项
  ],
  "personality_traits": [
    "从原文推导的性格关键词（如'注重细节''外向'）",
    // ...其他性格项
  ],
  "development_needs": [
    "用户明确或隐含的发展需求（如'缺乏项目管理经验'）",
    // ...其他需求项
  ]
}  """
        
        self.learning_path_system_prompt = """你是一个专业的学习路径规划助手，负责根据用户的学习目标和需求，生成个性化的学习路径。

请按照以下格式生成JSON格式的学习路径：
{
  "title": "学习路径标题",
  "description": "路径描述",
  "estimated_duration": "预计完成时间",
  "difficulty_level": "难度级别(1-5)",
  "prerequisites": ["前置要求1", "前置要求2"],
  "milestones": [
    {
      "title": "里程碑1标题",
      "description": "里程碑描述",
      "duration": "预计时间",
      "resources": [
        {
          "type": "video/article/book/practice",
          "title": "资源标题",
          "description": "资源描述",
          "url": "资源链接（如有）",
          "estimated_time": "预计学习时间"
        }
      ],
      "learning_objectives": ["学习目标1", "学习目标2"],
      "assessment_criteria": ["评估标准1", "评估标准2"]
    }
  ],
  "success_metrics": ["成功指标1", "成功指标2"],
  "next_steps": ["后续建议1", "后续建议2"]
}

在生成路径时，请注意：
1. 根据用户的基础水平调整内容难度
2. 提供具体、可操作的学习资源
3. 设置合理的时间预期
4. 添加清晰的学习目标和评估标准
5. 考虑实践项目和动手机会
6. 推荐优质的学习资源和工具"""
        
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
        self.client = httpx.AsyncClient(
            timeout=self.config.timeout,
            headers={
                "Authorization": f"Bearer {self.config.api_key}",
                "Content-Type": "application/json"
            }
        )
        self.metrics = DeepseekMetrics()
        self._cache = {}
        logger.info("DeepseekService 初始化完成")
    
    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=4, max=10),
        before=before_log(logger, logging.DEBUG),
        after=after_log(logger, logging.DEBUG)
    )
    async def chat(self, messages: List[Message], is_assessment: bool = False, is_learning_path: bool = False) -> ChatResponse:
        """发送消息列表到Deepseek API"""
        start_time = time.time()
        try:
            # 根据场景选择系统提示词
            if is_assessment:
                system_prompt = self.config.assessment_system_prompt
                logger.debug("选择系统提示词: assessment")
            elif is_learning_path:
                system_prompt = self.config.learning_path_system_prompt
                logger.debug("选择系统提示词: learning_path")
            else:
                system_prompt = self.config.system_prompt
                logger.debug("选择系统提示词: default")
            
            # 修改: 构建API消息列表，将系统提示词插入到传入的messages之前
            # 将 Pydantic Message 对象转换为字典列表
            api_messages_dicts = [msg.model_dump() for msg in messages]
            
            # 检查 messages 列表是否已经包含 system role，避免重复添加
            if not any(msg['role'] == 'system' for msg in api_messages_dicts):
                api_messages = [{"role": "system", "content": system_prompt}]
                api_messages.extend(api_messages_dicts)
            else:
                # 如果已包含 system role，可能需要替换或保持不变，这里选择保持传入的不变
                logger.warning("传入的消息列表已包含 system role，将直接使用传入列表。")
                api_messages = api_messages_dicts
            
            # 构建请求体
            api_request = {
                "messages": api_messages, 
                "model": self.config.model, 
                "temperature": self.config.temperature, 
                "max_tokens": self.config.max_tokens
            }
            
            logger.debug(f"最终API请求体: {json.dumps(api_request, ensure_ascii=False, indent=2)}") # 打印最终请求体
            logger.info(f"发送请求到 {self.config.base_url}/chat/completions")
            
            # 使用共享的 client 发送请求
            response = await self.client.post(
                f"{self.config.base_url}/chat/completions",
                json=api_request,
            )
            
            logger.debug(f"API响应头: {dict(response.headers)}")
            logger.info(f"API响应状态码: {response.status_code}")
            
            response.raise_for_status() # 如果状态码不是 2xx，则抛出异常

            result = response.json()
            if "choices" not in result or not result["choices"]:
                error_msg = f"API响应格式错误: {json.dumps(result, ensure_ascii=False)}"
                logger.error(error_msg)
                raise DeepseekError(error_msg)
                
            content = result["choices"][0]["message"]["content"]
            usage = result.get("usage") # 获取 token 使用情况

            self.metrics.record_request(True, time.time() - start_time)
            # 返回包含 usage 的响应
            return ChatResponse(content=content, success=True, error=None, usage=usage)
            
        except httpx.HTTPStatusError as e:
            error_msg = f"API请求失败: 状态码={e.response.status_code}, 响应={e.response.text}"
            logger.error(error_msg)
            self.metrics.record_request(False, time.time() - start_time)
            self.metrics.record_error(error_msg)
            return ChatResponse(content="抱歉，服务器处理请求时出现错误", success=False, error=error_msg)
        except Exception as e:
            error_msg = f"处理请求时出错: {str(e)}"
            logger.exception("处理聊天请求时发生未预期错误") # 使用 logger.exception 记录完整堆栈
            self.metrics.record_request(False, time.time() - start_time)
            self.metrics.record_error(error_msg)
            return ChatResponse(content="抱歉，服务器处理请求时出现错误", success=False, error=error_msg)
    
    def _get_cache_key(self, messages: List[Message]) -> str:
        return str([(msg.role, msg.content) for msg in messages])
    
    def get_metrics(self) -> Dict:
        return self.metrics.get_stats()
    
    async def close(self):
        await self.client.aclose()

    async def stream_chat(self, messages: List[Message], **kwargs) -> AsyncGenerator[str, None]:
        """流式发送消息到Deepseek API"""
        try:
            # 构建API消息列表 (与 chat 方法类似)
            # 这里也需要确保 system prompt 的处理方式一致
            system_prompt = self.config.system_prompt # 假设流式默认使用通用提示词
            api_messages_dicts = [msg.model_dump() for msg in messages]
            if not any(msg['role'] == 'system' for msg in api_messages_dicts):
                api_messages = [{"role": "system", "content": system_prompt}]
                api_messages.extend(api_messages_dicts)
            else:
                logger.warning("传入的流式消息列表已包含 system role，将直接使用传入列表。")
                api_messages = api_messages_dicts

            api_request = {
                "messages": api_messages,
                "model": self.config.model,
                "stream": True, # 启用流式输出
                **kwargs # 可以传递 temperature 等额外参数
            }
            
            logger.info(f"发送流式请求到 {self.config.base_url}/chat/completions")
            async with self.client.stream(
                "POST",
                f"{self.config.base_url}/chat/completions",
                json=api_request
            ) as response:
                response.raise_for_status()
                async for line in response.aiter_lines():
                    if line.startswith("data:"):                        
                        chunk = line[len("data:"):].strip()
                        if chunk == "[DONE]":
                            break
                        try:
                            data = json.loads(chunk)
                            content = data["choices"][0]["delta"]["content"]
                            if content:
                                yield content
                        except json.JSONDecodeError:
                            logger.warning(f"无法解析流式块: {chunk}")
                        except KeyError:
                            logger.warning(f"流式块缺少必要字段: {chunk}")
        except httpx.HTTPStatusError as e:
            logger.error(f"流式API请求失败: 状态码={e.response.status_code}, 响应={e.response.text}")
            yield f"Error: {e.response.status_code} - 请求失败"
        except Exception as e:
            logger.exception("处理流式聊天请求时发生未预期错误")
            yield f"Error: 处理请求时出错 - {str(e)}"

# 全局服务实例
deepseek_service = DeepseekService()

async def chat(messages: List[Message], **kwargs) -> ChatResponse:
    """发送聊天请求到Deepseek API"""
    try:
        request = ChatRequest(messages=messages, **kwargs)
        url = f"{deepseek_service.config.base_url}/chat/completions"
        async with httpx.AsyncClient(timeout=deepseek_service.config.timeout) as client:
            response = await client.post(url, headers={"Authorization": f"Bearer {deepseek_service.config.api_key}"}, json=request.model_dump())
            return ChatResponse(content=response.json()["choices"][0]["message"]["content"], success=True, error=None) if response.status_code == 200 else ChatResponse(content="API请求失败", success=False, error=f"状态码: {response.status_code}")
    except Exception as e:
        logger.error(f"Error in Deepseek chat: {str(e)}")
        return ChatResponse(content="处理请求时出错", success=False, error=str(e))
        
async def stream_chat(messages: List[Message], **kwargs) -> AsyncGenerator[str, None]:
    """发送流式聊天请求到Deepseek API"""
    try:
        request = ChatRequest(messages=messages, stream=True, **kwargs)
        url = f"{deepseek_service.config.base_url}/chat/completions"
        
        async with httpx.AsyncClient(timeout=deepseek_service.config.timeout) as client:
            async with client.stream(
                "POST",
                url,
                headers={"Authorization": f"Bearer {deepseek_service.config.api_key}"},
                json=request.model_dump()
            ) as response:
                if response.status_code == 200:
                    async for line in response.aiter_lines():
                        if line.startswith("data: "):
                            data = line[6:]
                            if data == "[DONE]":
                                break
                            try:
                                chunk = json.loads(data)
                                if "choices" in chunk and chunk["choices"]:
                                    content = chunk["choices"][0].get("delta", {}).get("content", "")
                                    if content:
                                        yield content
                            except json.JSONDecodeError:
                                continue
                else:
                    logger.error(f"Deepseek API error: {response.status_code} - {response.text}")
                    raise Exception(f"API request failed: {response.status_code}")
                    
    except Exception as e:
        logger.error(f"Error in Deepseek stream chat: {str(e)}")
        raise 