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
    # 检查 conversation_id 来决定使用哪个 system prompt
    # 假设非 "assessment" 的都用于学习路径
    is_learning_path_request = request.conversation_id != "assessment"
    
    return await service.chat(
        message=request.message,
        # is_assessment=request.conversation_id == "assessment" if request.conversation_id else False,
        is_assessment=not is_learning_path_request, # 如果不是学习路径，则认为是评估
        is_learning_path=is_learning_path_request  # 明确传递 is_learning_path
    )

@router.post("/stream")
async def chat_stream(
    request: ChatRequest,
    service: DeepseekService = Depends(get_deepseek_service)
):
    """发送流式聊天请求"""
    try:
        # 同样判断是否为学习路径
        is_learning_path_request = request.conversation_id != "assessment"
        # 注意：stream_chat 在 DeepseekService 中可能没有处理 is_learning_path 的逻辑
        # 如果需要流式学习路径生成，需要进一步修改 DeepseekService.stream_chat
        return StreamingResponse(
            service.stream_chat(message=request.message), # 暂时不传递 is_learning_path
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