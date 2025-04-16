from fastapi import APIRouter, Depends
from fastapi.responses import StreamingResponse
from models.chat import ChatRequest, ChatResponse, Message
from services.deepseek_service import DeepseekService
import logging

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/chat", tags=["chat"])

def get_deepseek_service() -> DeepseekService:
    return DeepseekService()

@router.post("/", response_model=ChatResponse)
async def chat(request: ChatRequest, service: DeepseekService = Depends(get_deepseek_service)):
    """处理聊天请求"""
    logger.debug(f"收到聊天请求: {request.model_dump_json()}")
    return await service.chat(
        messages=request.messages,
        is_assessment=request.conversation_id == "assessment" if request.conversation_id else False
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
        return ChatResponse(
            content="抱歉，服务器处理流式请求时出现错误",
            conversation_id=request.conversation_id or "string",
            success=False,
            error=str(e)
        ).model_dump() 