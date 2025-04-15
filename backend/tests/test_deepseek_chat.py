import pytest
import httpx
import os
import asyncio
import logging
from dotenv import load_dotenv

# 配置日志
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# 加载环境变量
load_dotenv()

DEEPSEEK_API_KEY = os.getenv("DEEPSEEK_API_KEY")
DEEPSEEK_BASE_URL = os.getenv("DEEPSEEK_BASE_URL", "https://api.deepseek.com/v1")

# 测试消息列表
test_messages = [
    "你好，我想了解一下自己的学习能力",
    "我最近在学习编程，但感觉记不住知识点",
    "我想提高自己的学习效率，有什么建议吗？",
    "测试一下中文响应",
    "这是一个测试消息，请随意回复"
]

@pytest.mark.asyncio
async def test_deepseek_chat_responses():
    """测试Deepseek API的自由对话响应"""
    assert DEEPSEEK_API_KEY, "DEEPSEEK_API_KEY未设置"
    
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {DEEPSEEK_API_KEY}",
        "Accept": "application/json"
    }
    
    timeout = httpx.Timeout(30.0, connect=10.0)
    async with httpx.AsyncClient(timeout=timeout, verify=False) as client:
        for message in test_messages:
            logger.info(f"\n开始测试消息: {message}")
            
            payload = {
                "model": "deepseek-chat",
                "messages": [
                    {
                        "role": "system",
                        "content": "你是一个专业的学习能力评估助手，负责通过对话评估用户的学习能力、兴趣和目标。你需要通过提问和交谈，了解用户的学习经历、方法、习惯等，并给出专业的分析和建议。"
                    },
                    {"role": "user", "content": message}
                ],
                "temperature": 0.5,
                "max_tokens": 2000,
                "stream": False
            }
            
            try:
                logger.debug("发送请求...")
                response = await client.post(
                    f"{DEEPSEEK_BASE_URL}/chat/completions",
                    headers=headers,
                    json=payload
                )
                
                logger.debug(f"收到响应状态码: {response.status_code}")
                
                # 验证响应状态码
                assert response.status_code == 200, f"API请求失败，状态码: {response.status_code}"
                
                # 验证响应格式
                data = response.json()
                assert "choices" in data, "响应中缺少choices字段"
                assert len(data["choices"]) > 0, "choices为空"
                assert "message" in data["choices"][0], "响应中缺少message字段"
                assert "content" in data["choices"][0]["message"], "响应中缺少content字段"
                
                # 获取响应内容
                content = data["choices"][0]["message"]["content"]
                assert content, "响应内容为空"
                assert isinstance(content, str), "响应内容不是字符串类型"
                assert len(content) > 0, "响应内容长度为0"
                
                # 验证是否包含中文
                assert any('\u4e00' <= char <= '\u9fff' for char in content), "响应不包含中文字符"
                
                # 记录响应
                logger.info(f"响应内容: {content[:200]}...")
                logger.info(f"Token使用情况: {data.get('usage', {})}")
                logger.info("-" * 80)
                
                # 等待一小段时间，避免请求过于频繁
                await asyncio.sleep(2)
                
            except httpx.TimeoutException as e:
                logger.error(f"请求超时: {e}")
                pytest.fail(f"请求超时: {e}")
            except httpx.RequestError as e:
                logger.error(f"请求错误: {e}")
                pytest.fail(f"请求错误: {e}")
            except Exception as e:
                logger.error(f"测试过程中出错: {e}")
                pytest.fail(f"测试失败: {e}")

def test_api_key_configuration():
    """测试API密钥配置"""
    assert DEEPSEEK_API_KEY is not None, "DEEPSEEK_API_KEY未设置"
    assert DEEPSEEK_API_KEY.startswith("sk-"), "DEEPSEEK_API_KEY格式不正确"
    assert len(DEEPSEEK_API_KEY) > 20, "DEEPSEEK_API_KEY长度不足"

def test_api_url_configuration():
    """测试API URL配置"""
    assert DEEPSEEK_BASE_URL is not None, "DEEPSEEK_BASE_URL未设置"
    assert DEEPSEEK_BASE_URL.startswith("https://"), "DEEPSEEK_BASE_URL必须使用HTTPS"
    assert "api.deepseek.com" in DEEPSEEK_BASE_URL, "DEEPSEEK_BASE_URL域名不正确"

if __name__ == "__main__":
    logging.info("开始运行Deepseek API测试...")
    pytest.main(["-v", __file__]) 