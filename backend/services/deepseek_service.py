import httpx
import os
import logging
import json
from typing import List, Optional, AsyncGenerator, Dict
from datetime import datetime
from tenacity import retry, stop_after_attempt, wait_exponential
from models.chat import Message, ChatRequest, ChatResponse
import time
from functools import lru_cache

logger = logging.getLogger(__name__)

class DeepseekConfig:
    def __init__(self):
        self.api_key = os.getenv("DEEPSEEK_API_KEY")
        self.base_url = os.getenv("DEEPSEEK_BASE_URL", "https://api.deepseek.com/v1")
        self.model = "deepseek-chat"
        self.temperature = 0.7
        self.max_tokens = 1000
        self.timeout = 30

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
            headers={"Authorization": f"Bearer {self.config.api_key}"}
        )
        self.metrics = DeepseekMetrics()
        self._cache = {}
    
    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=4, max=10)
    )
    async def chat(self, messages: List[Message]) -> str:
        start_time = time.time()
        try:
            # 检查缓存
            cache_key = self._get_cache_key(messages)
            if cache_key in self._cache:
                return self._cache[cache_key]
            
            api_request = {
                "messages": [{"role": msg.role, "content": msg.content} for msg in messages],
                "model": self.config.model,
                "temperature": self.config.temperature,
                "max_tokens": self.config.max_tokens
            }
            
            response = await self.client.post(
                f"{self.config.base_url}/chat/completions",
                json=api_request
            )
            response.raise_for_status()
            result = response.json()
            content = result["choices"][0]["message"]["content"]
            
            # 更新缓存
            self._cache[cache_key] = content
            if len(self._cache) > 1000:  # 限制缓存大小
                self._cache.pop(next(iter(self._cache)))
            
            # 记录成功请求
            self.metrics.record_request(True, time.time() - start_time)
            return content
            
        except httpx.HTTPStatusError as e:
            self.metrics.record_request(False, time.time() - start_time)
            self.metrics.record_error(f"API请求失败: {str(e)}")
            raise DeepseekError(f"API请求失败: {str(e)}", e.response.status_code)
        except Exception as e:
            self.metrics.record_request(False, time.time() - start_time)
            self.metrics.record_error(f"处理请求时出错: {str(e)}")
            raise DeepseekError(f"处理请求时出错: {str(e)}")
    
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