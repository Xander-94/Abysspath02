from fastapi import APIRouter, HTTPException, Depends, Body, status
from typing import Dict, Any, List, Optional
from services.learning_path_service import LearningPathService
from auth import get_current_user
from pydantic import BaseModel, Field
import logging
from uuid import UUID

# 导入学习路径相关模型 (更正文件名)
from models.learning_path import LearningPath, LearningPathCreateRequest, FullLearningPathResponse

logger = logging.getLogger(__name__)

class ChatRequest(BaseModel):
    message: str

router = APIRouter(prefix="/learning-paths", tags=["Learning Paths"])

def get_learning_path_service() -> LearningPathService:
    return LearningPathService()

@router.post(
    "/",
    response_model=LearningPath,
    status_code=status.HTTP_201_CREATED,
    summary="生成并保存新的学习路径",
    description="接收用户目标和画像信息，调用 AI 生成学习路径，并将其存入数据库。"
)
async def create_learning_path_endpoint(
    request_body: LearningPathCreateRequest = Body(...),
    current_user: Dict[str, Any] = Depends(get_current_user),
    service: LearningPathService = Depends(get_learning_path_service)
):
    current_user_id = current_user.get('id')
    if not current_user_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="无法获取用户ID")
    try:
        created_path = await service.create_and_save_learning_path(
            user_id=current_user_id,
            user_goal=request_body.user_goal,
            user_profile_json=request_body.user_profile_json,
            assessment_session_id=request_body.assessment_session_id
        )
        return created_path
    except Exception as e:
        logger.exception(f"创建学习路径时发生意外错误 (用户: {current_user_id})")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"创建学习路径时发生内部错误: {e}")

@router.get(
    "/{path_id}",
    response_model=FullLearningPathResponse,
    summary="获取指定学习路径的完整信息",
    description="根据路径 ID 获取学习路径的元数据、所有节点、边和资源，会校验用户权限。"
)
async def get_learning_path_detail_endpoint(
    path_id: UUID,
    current_user: Dict[str, Any] = Depends(get_current_user),
    service: LearningPathService = Depends(get_learning_path_service)
):
    current_user_id = current_user.get('id')
    if not current_user_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="无法获取用户ID")
    try:
        full_path = await service.get_full_learning_path(path_id=path_id, user_id=current_user_id)
        if full_path is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="学习路径未找到或无权访问")
        return full_path
    except Exception as e:
        logger.exception(f"获取学习路径详情时发生意外错误 (用户: {current_user_id}, 路径: {path_id})")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"获取路径详情时发生内部错误: {e}")

@router.get(
    "/",
    response_model=List[LearningPath],
    summary="获取当前用户的所有学习路径列表",
    description="列出当前已认证用户创建的所有学习路径元数据，按创建时间降序排列。"
)
async def list_learning_paths_endpoint(
    current_user: Dict[str, Any] = Depends(get_current_user),
    service: LearningPathService = Depends(get_learning_path_service)
):
    current_user_id = current_user.get('id')
    if not current_user_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="无法获取用户ID")
    try:
        paths = await service.list_user_learning_paths(user_id=current_user_id)
        return paths
    except Exception as e:
        logger.exception(f"列出用户学习路径时发生意外错误 (用户: {current_user_id})")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"列出路径时发生内部错误: {e}")

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