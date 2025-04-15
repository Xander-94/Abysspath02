import httpx
import os
import logging
import json
from typing import List, Optional, AsyncGenerator, Dict, Any
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
        env_path = Path(__file__).parent.parent / '.env'
        if not env_path.exists():
            raise ValueError(f"环境变量文件不存在: {env_path}")
        load_dotenv(env_path)
        
        self.api_key = os.getenv('DEEPSEEK_API_KEY')
        if not self.api_key:
            raise ValueError('DEEPSEEK_API_KEY 环境变量未设置')
        
        self.base_url = os.getenv('DEEPSEEK_BASE_URL', 'https://api.deepseek.com/v1')
        self.model = "deepseek-chat"
        self.temperature = 0.7
        self.max_tokens = 1000
        self.timeout = 30
        self.system_prompt = os.getenv('SYSTEM_PROMPT', '你是一个专业的学习能力评估助手，负责通过对话评估用户的学习能力、兴趣和目标。')
        self.assessment_prompt = """
你是一个专业的学习能力评估助手。你的任务是通过对话评估用户的学习能力、兴趣和目标。请遵循以下规则:

1. 每次对话最多问5个问题
2. 问题应该循序渐进,由浅入深
3. 根据用户回答动态调整问题难度
4. 关注用户的学习动机、方法和习惯
5. 收集用户的兴趣爱好和职业规划
6. 评估用户的知识储备和学习瓶颈

当你判断已经收集到足够信息时,请给出评估总结,包含以下方面:
- 学习能力评分(1-100)
- 优势和不足
- 适合的学习方向
- 改进建议

总结时请在开头加上"[评估完成]"标记。
"""
        
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
            base_url=self.config.base_url,
            headers={
                "Authorization": f"Bearer {self.config.api_key}",
                "Content-Type": "application/json"
            },
            timeout=30.0
        )
        self.metrics = DeepseekMetrics()
        self._cache = {}
        logger.info(f"DeepseekService 初始化完成, API Key: {self.config.api_key[:8]}...")
    
    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=4, max=10),
        before=before_log(logger, logging.DEBUG),
        after=after_log(logger, logging.DEBUG)
    )
    async def chat(self, messages: List[Dict[str, str]]) -> str:
        """通用对话接口"""
        start_time = time.time()
        try:
            response = await self.client.post(
                "/chat/completions",
                json={
                    "model": "deepseek-chat",
                    "messages": [{"role": "system", "content": self.config.system_prompt}] + messages
                }
            )
            response.raise_for_status()
            result = response.json()
            
            # 记录成功请求
            self.metrics.record_request(True, time.time() - start_time)
            return result["choices"][0]["message"]["content"]
            
        except httpx.HTTPStatusError as e:
            error_msg = f"API请求失败: 状态码={e.response.status_code}, 响应={e.response.text}"
            logger.error(error_msg)
            self.metrics.record_request(False, time.time() - start_time)
            self.metrics.record_error(error_msg)
            raise DeepseekError(error_msg, e.response.status_code)
        except httpx.RequestError as e:
            error_msg = f"请求错误: {str(e)}"
            logger.error(error_msg)
            self.metrics.record_request(False, time.time() - start_time)
            self.metrics.record_error(error_msg)
            raise DeepseekError(error_msg)
        except Exception as e:
            error_msg = f"处理请求时出错: {str(e)}"
            logger.error(error_msg)
            self.metrics.record_request(False, time.time() - start_time)
            self.metrics.record_error(error_msg)
            raise DeepseekError(error_msg)
    
    def _get_cache_key(self, messages: List[Message]) -> str:
        return str([(msg.role, msg.content) for msg in messages])
    
    def get_metrics(self) -> Dict:
        return self.metrics.get_stats()
    
    async def close(self):
        await self.client.aclose()

    async def chat_for_assessment(self, user_message: str, history: List[Dict[str, str]] = None) -> str:
        """评估对话专用接口"""
        try:
            messages = [{"role": "system", "content": self.config.assessment_prompt}]
            if history:
                messages.extend(history)
            messages.append({"role": "user", "content": user_message})
            
            response = await self.chat(messages)
            logger.debug(f"评估对话响应: {response[:100]}...")
            return response
        except Exception as e:
            logger.error(f"评估对话失败: {str(e)}")
            raise

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