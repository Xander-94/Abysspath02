import os
import httpx
import logging
import json
from dotenv import load_dotenv

# 配置日志
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# 设置API密钥
os.environ["DEEPSEEK_API_KEY"] = "sk-a4849565ebce484b98ee7084924a3d99"
os.environ["DEEPSEEK_BASE_URL"] = "https://api.deepseek.com/v1"

async def test_connection():
    """测试Deepseek API连接"""
    try:
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {os.getenv('DEEPSEEK_API_KEY')}",
            "Accept": "application/json"
        }
        
        data = {
            "model": "deepseek-chat",
            "messages": [
                {
                    "role": "user",
                    "content": "你好，这是一个测试消息"
                }
            ],
            "temperature": 0.7,
            "max_tokens": 100
        }
        
        logger.debug(f"请求头: {headers}")
        logger.debug(f"请求数据: {json.dumps(data, ensure_ascii=False)}")
        
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                f"{os.getenv('DEEPSEEK_BASE_URL')}/chat/completions",
                headers=headers,
                json=data
            )
            
            logger.debug(f"响应状态码: {response.status_code}")
            logger.debug(f"响应头: {dict(response.headers)}")
            logger.debug(f"响应内容: {response.text}")
            
            if response.status_code == 200:
                result = response.json()
                logger.info("API连接测试成功！")
                logger.info(f"响应内容: {result['choices'][0]['message']['content']}")
                return True
            else:
                logger.error(f"API请求失败: {response.status_code}")
                logger.error(f"错误信息: {response.text}")
                return False
                
    except httpx.TimeoutException as e:
        logger.error(f"请求超时: {str(e)}")
        return False
    except httpx.RequestError as e:
        logger.error(f"请求错误: {str(e)}")
        return False
    except json.JSONDecodeError as e:
        logger.error(f"JSON解析错误: {str(e)}")
        return False
    except Exception as e:
        logger.error(f"测试过程中发生错误: {str(e)}")
        return False

if __name__ == "__main__":
    import asyncio
    asyncio.run(test_connection()) 