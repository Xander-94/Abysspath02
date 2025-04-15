from fastapi import APIRouter, HTTPException, Depends
from typing import List
from models.chat import Message, ChatRequest, ChatResponse
from services.deepseek_service import DeepseekService
from fastapi.responses import StreamingResponse
import asyncio

router = APIRouter(prefix="/api/chat", tags=["chat"])

def get_deepseek_service() -> DeepseekService:
    return DeepseekService()

@router.post("/completions", response_model=ChatResponse)
async def chat_completion(
    request: ChatRequest,
    service: DeepseekService = Depends(get_deepseek_service)
):
    """发送聊天请求"""
    try:
        response = await service.chat(
            messages=request.messages,
            model=request.model,
            temperature=request.temperature,
            max_tokens=request.max_tokens
        )
        return response
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/completions/stream")
async def chat_completion_stream(
    request: ChatRequest,
    service: DeepseekService = Depends(get_deepseek_service)
):
    """发送流式聊天请求"""
    try:
        return StreamingResponse(
            service.stream_chat(
                messages=request.messages,
                model=request.model,
                temperature=request.temperature,
                max_tokens=request.max_tokens
            ),
            media_type="text/event-stream"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) 