import pytest
import httpx
import os
from dotenv import load_dotenv
import logging

# 配置日志
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# 加载环境变量
load_dotenv()

DEEPSEEK_API_KEY = os.getenv("DEEPSEEK_API_KEY")
DEEPSEEK_BASE_URL = os.getenv("DEEPSEEK_BASE_URL", "https://api.deepseek.com/v1")

@pytest.mark.asyncio
async def test_deepseek_api_connection():
    """测试Deepseek API的实际连通性"""
    assert DEEPSEEK_API_KEY, "DEEPSEEK_API_KEY未设置"
    
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {DEEPSEEK_API_KEY}",
        "Accept": "application/json"
    }
    
    payload = {
        "model": "deepseek-chat",
        "messages": [
            {
                "role": "system",
                "content": "你是一个测试助手。"
            },
            {
                "role": "user",
                "content": "这是一个API连通性测试，请回复'测试成功'。"
            }
        ],
        "temperature": 0.7,
        "max_tokens": 100,
        "stream": False
    }
    
    logger.info("开始测试Deepseek API连通性...")
    logger.debug(f"API URL: {DEEPSEEK_BASE_URL}")
    logger.debug(f"请求头: {headers}")
    logger.debug(f"请求体: {payload}")
    
    timeout = httpx.Timeout(30.0, connect=10.0)
    async with httpx.AsyncClient(timeout=timeout, verify=False) as client:
        try:
            response = await client.post(
                f"{DEEPSEEK_BASE_URL}/chat/completions",
                headers=headers,
                json=payload
            )
            
            logger.debug(f"响应状态码: {response.status_code}")
            logger.debug(f"响应头: {dict(response.headers)}")
            logger.debug(f"响应内容: {response.text[:1000]}...")
            
            # 验证响应状态码
            assert response.status_code == 200, f"API请求失败，状态码: {response.status_code}, 响应: {response.text}"
            
            # 验证响应格式
            data = response.json()
            assert "choices" in data, "响应中缺少choices字段"
            assert len(data["choices"]) > 0, "choices为空"
            assert "message" in data["choices"][0], "响应中缺少message字段"
            assert "content" in data["choices"][0]["message"], "响应中缺少content字段"
            
            content = data["choices"][0]["message"]["content"]
            logger.info(f"API响应内容: {content}")
            
            return content
            
        except httpx.TimeoutException as e:
            logger.error(f"请求超时: {e}")
            raise
        except httpx.RequestError as e:
            logger.error(f"请求错误: {e}")
            raise
        except Exception as e:
            logger.error(f"测试过程中出错: {e}")
            raise

if __name__ == "__main__":
    import asyncio
    asyncio.run(test_deepseek_api_connection()) 