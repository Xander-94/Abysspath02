from fastapi import APIRouter, HTTPException, Depends
from typing import Dict, Any, List
from services.learning_path_service import LearningPathService
from auth import get_current_user
from pydantic import BaseModel
import logging

logger = logging.getLogger(__name__)

class ChatRequest(BaseModel):
    message: str

router = APIRouter(prefix="/api/learning-path", tags=["learning-path"])

def get_learning_path_service() -> LearningPathService:
    return LearningPathService()

@router.post("/start")
async def start_learning_path(
    title: str = "新的学习路径",
    service: LearningPathService = Depends(get_learning_path_service),
    current_user: Dict[str, Any] = Depends(get_current_user)
) -> Dict[str, Any]:
    """开始新的学习路径规划"""
    try:
        result = await service.create_learning_path(current_user["id"], title)
        return {"status": "success", "data": result}
    except Exception as e:
        logger.error(f"开始学习路径失败: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/{path_id}/chat")
async def chat(
    path_id: str,
    request: ChatRequest,
    service: LearningPathService = Depends(get_learning_path_service),
    current_user: Dict[str, Any] = Depends(get_current_user)
) -> Dict[str, Any]:
    """发送学习路径对话消息"""
    try:
        result = await service.save_interaction(path_id, request.message)
        return {"status": "success", "data": result}
    except Exception as e:
        logger.error(f"发送学习路径消息失败: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/history")
async def get_history(
    service: LearningPathService = Depends(get_learning_path_service),
    current_user: Dict[str, Any] = Depends(get_current_user)
) -> Dict[str, Any]:
    """获取学习路径历史记录"""
    try:
        result = await service.get_learning_path_history(current_user["id"])
        return {"status": "success", "data": result}
    except Exception as e:
        logger.error(f"获取学习路径历史失败: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{path_id}")
async def get_learning_path(
    path_id: str,
    service: LearningPathService = Depends(get_learning_path_service),
    current_user: Dict[str, Any] = Depends(get_current_user)
) -> Dict[str, Any]:
    """获取学习路径详情"""
    try:
        result = await service.get_learning_path_detail(path_id)
        return {"status": "success", "data": result}
    except Exception as e:
        logger.error(f"获取学习路径详情失败: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/{path_id}/complete")
async def complete_learning_path(
    path_id: str,
    service: LearningPathService = Depends(get_learning_path_service),
    current_user: Dict[str, Any] = Depends(get_current_user)
) -> Dict[str, Any]:
    """完成学习路径"""
    try:
        result = await service.complete_learning_path(path_id)
        return {"status": "success", "data": result}
    except Exception as e:
        logger.error(f"完成学习路径失败: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{path_id}")
async def delete_learning_path(
    path_id: str,
    service: LearningPathService = Depends(get_learning_path_service),
    current_user: Dict[str, Any] = Depends(get_current_user)
) -> Dict[str, Any]:
    """删除学习路径"""
    try:
        await service.delete_learning_path(path_id)
        return {"status": "success", "message": "学习路径已删除"}
    except Exception as e:
        logger.error(f"删除学习路径失败: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e)) 