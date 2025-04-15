import pytest
from fastapi.testclient import TestClient
import httpx
import json
from unittest.mock import patch, MagicMock
from main import app

client = TestClient(app)

def test_health_check():
    """测试健康检查端点"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

@pytest.mark.asyncio
async def test_chat_endpoint_success():
    """测试聊天端点 - 成功场景"""
    mock_response = {
        "choices": [{
            "message": {
                "content": "这是一个测试回复"
            }
        }]
    }
    
    # 模拟httpx.AsyncClient的响应
    async def mock_post(*args, **kwargs):
        response = MagicMock()
        response.status_code = 200
        response.text = json.dumps(mock_response)
        response.json.return_value = mock_response
        return response
        
    with patch('httpx.AsyncClient.post', new=mock_post):
        response = client.post(
            "/api/chat",
            json={"message": "你好，这是一个测试消息"}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert "content" in data
        assert data["content"] == "这是一个测试回复"
        assert "raw_response" in data

@pytest.mark.asyncio
async def test_chat_endpoint_api_error():
    """测试聊天端点 - API错误场景"""
    async def mock_post(*args, **kwargs):
        response = MagicMock()
        response.status_code = 401
        response.text = "Unauthorized"
        return response
        
    with patch('httpx.AsyncClient.post', new=mock_post):
        response = client.post(
            "/api/chat",
            json={"message": "测试消息"}
        )
        
        assert response.status_code == 401
        assert "Unauthorized" in response.json()["detail"]

@pytest.mark.asyncio
async def test_chat_endpoint_timeout():
    """测试聊天端点 - 超时场景"""
    async def mock_post(*args, **kwargs):
        raise httpx.TimeoutException("Connection timeout")
        
    with patch('httpx.AsyncClient.post', side_effect=mock_post):
        response = client.post(
            "/api/chat",
            json={"message": "测试消息"}
        )
        
        assert response.status_code == 504
        assert "timeout" in response.json()["detail"].lower()

@pytest.mark.asyncio
async def test_chat_endpoint_validation():
    """测试聊天端点 - 请求验证"""
    # 测试缺少必要字段
    response = client.post("/api/chat", json={})
    assert response.status_code == 422
    
    # 测试空消息
    response = client.post("/api/chat", json={"message": ""})
    assert response.status_code == 422

@pytest.mark.asyncio
async def test_chat_endpoint_request_error():
    """测试聊天端点 - 网络请求错误"""
    async def mock_post(*args, **kwargs):
        raise httpx.RequestError("Connection error")
        
    with patch('httpx.AsyncClient.post', side_effect=mock_post):
        response = client.post(
            "/api/chat",
            json={"message": "测试消息"}
        )
        
        assert response.status_code == 500
        assert "error" in response.json()["detail"].lower() 