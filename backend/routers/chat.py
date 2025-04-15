from fastapi import APIRouter, Depends
from models.chat import ChatRequest, ChatResponse
from services.deepseek_service import DeepseekService
import logging

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/chat", tags=["chat"])

def get_deepseek_service() -> DeepseekService:
    return DeepseekService()

@router.post("/", response_model=ChatResponse)
async def chat(
    request: ChatRequest,
    service: DeepseekService = Depends(get_deepseek_service)
) -> ChatResponse:
    """发送聊天请求"""
    try:
        return await service.chat(message=request.message)
    except Exception as e:
        logger.error(f"聊天请求失败: {str(e)}")
        return ChatResponse(
            content="抱歉，服务器处理请求时出现错误",
            success=False,
            error=str(e)
        )

@router.post("/stream")
async def chat_stream(
    request: ChatRequest,
    service: DeepseekService = Depends(get_deepseek_service)
):
    """发送流式聊天请求"""
    try:
        return StreamingResponse(
            service.stream_chat(messages=request.messages),
            media_type="text/event-stream"
        )
    except Exception as e:
        logger.error(f"流式聊天请求失败: {str(e)}")
        return {
            "content": "抱歉，服务器处理请求时出现错误",
            "success": False,
            "error": str(e)
        } 