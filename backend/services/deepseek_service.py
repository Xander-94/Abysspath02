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
        self.timeout = 30
        self.system_prompt = os.getenv("SYSTEM_PROMPT", "你是一个专业的AI助手")
        self.assessment_system_prompt = """你是一个专业的学习能力评估助手，负责通过对话评估用户的学习能力、兴趣和目标。
评估维度包括：
1. 学习方法和习惯
2. 知识掌握和记忆能力
3. 学习动机和目标
4. 时间管理能力
5. 问题解决能力
6. 自我反思和调整能力

请通过提问和交谈，了解用户的具体情况，并在合适的时机给出以下内容：
1. 对用户当前学习状态的分析
2. 个性化的学习建议
3. 可能存在的问题和改进方向
4. 具体的行动建议"""
        
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
    async def chat(self, message: str, is_assessment: bool = False, is_learning_path: bool = False) -> ChatResponse:
        """发送消息到Deepseek API"""
        try:
            # 根据不同场景选择系统提示词
            system_prompt = (
                self.config.assessment_system_prompt if is_assessment
                else self.config.learning_path_system_prompt if is_learning_path
                else self.config.system_prompt
            )
            
            # 构建API消息列表
            api_messages = [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": message}
            ]
            
            start_time = time.time()
            
            # 构建请求体
            api_request = {
                "messages": api_messages,
                "model": self.config.model,
                "temperature": self.config.temperature,
                "max_tokens": self.config.max_tokens
            }
            
            logger.debug(f"API请求配置: {json.dumps(api_request, ensure_ascii=False, indent=2)}")
            logger.info(f"发送请求到 {self.config.base_url}/chat/completions")
            
            async with httpx.AsyncClient(timeout=self.config.timeout) as client:
                response = await client.post(
                    f"{self.config.base_url}/chat/completions",
                    json=api_request,
                    headers={
                        "Authorization": f"Bearer {self.config.api_key}",
                        "Content-Type": "application/json"
                    }
                )
            
            logger.debug(f"API响应头: {dict(response.headers)}")
            logger.info(f"API响应状态码: {response.status_code}")
            
            if response.status_code != 200:
                error_msg = f"API请求失败: 状态码={response.status_code}, 响应={response.text}"
                logger.error(error_msg)
                return ChatResponse(
                    content="抱歉，服务器处理请求时出现错误",
                    success=False,
                    error=error_msg
                )
            
            try:
                result = response.json()
            except json.JSONDecodeError as e:
                error_msg = f"响应解析失败: {str(e)}\n响应内容: {response.text}"
                logger.error(error_msg)
                return ChatResponse(
                    content="抱歉，服务器处理请求时出现错误",
                    success=False,
                    error=error_msg
                )
            
            if "choices" not in result or not result["choices"]:
                error_msg = f"API响应格式错误: {json.dumps(result, ensure_ascii=False)}"
                logger.error(error_msg)
                return ChatResponse(
                    content="抱歉，服务器处理请求时出现错误",
                    success=False,
                    error=error_msg
                )
                
            content = result["choices"][0]["message"]["content"]
            
            # 记录成功请求
            self.metrics.record_request(True, time.time() - start_time)
            return ChatResponse(
                content=content,
                success=True,
                error=None
            )
            
        except Exception as e:
            error_msg = f"处理请求时出错: {str(e)}"
            logger.error(error_msg)
            self.metrics.record_request(False, time.time() - start_time)
            self.metrics.record_error(error_msg)
            return ChatResponse(
                content="抱歉，服务器处理请求时出现错误",
                success=False,
                error=error_msg
            )
    
    def _get_cache_key(self, messages: List[Message]) -> str:
        return str([(msg.role, msg.content) for msg in messages])
    
    def get_metrics(self) -> Dict:
        return self.metrics.get_stats()
    
    async def close(self):
        await self.client.aclose()

# 全局服务实例
deepseek_service = DeepseekService()

async def chat(messages: List[Message], **kwargs) -> ChatResponse:
    """发送聊天请求到Deepseek API"""
    try:
        request = ChatRequest(messages=messages, **kwargs)
        url = f"{deepseek_service.config.base_url}/chat/completions"
        
        async with httpx.AsyncClient(timeout=deepseek_service.config.timeout) as client:
            response = await client.post(
                url,
                headers={"Authorization": f"Bearer {deepseek_service.config.api_key}"},
                json=request.model_dump()
            )
            
            if response.status_code == 200:
                data = response.json()
                return ChatResponse(
                    content=data["choices"][0]["message"]["content"],
                    usage=data.get("usage")
                )
            else:
                logger.error(f"Deepseek API error: {response.status_code} - {response.text}")
                raise Exception(f"API request failed: {response.status_code}")
                
    except Exception as e:
        logger.error(f"Error in Deepseek chat: {str(e)}")
        raise
        
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