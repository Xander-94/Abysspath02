from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional, Dict
from uuid import UUID
import logging
import traceback

# 假设你的认证依赖项位于 auth.dependencies
# from backend.auth.dependencies import get_current_user
# from backend.models.user import User  # 假设用户模型
# 移除模拟用户
# class User: id: UUID = UUID("111e4567-e89b-12d3-a456-426614174111") # Mock User
# async def get_current_user() -> User: return User() # Mock dependency

# 导入模型和服务
from models.learning_path import (
    LearningPathCreateRequestAPI,
    LearningPathCreateResponseAPI,
    FullLearningPathResponseAPI,
    LearningPathListItemAPI
)
from services.learning_path_service import LearningPathService
from dependencies import get_learning_path_service
from auth import get_current_user

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/learning-paths",
    tags=["Learning Paths"],
    # dependencies=[Depends(get_current_user)] # 在路由器级别应用认证
)

@router.post(
    "/",
    response_model=LearningPathCreateResponseAPI,
    status_code=status.HTTP_201_CREATED,
    summary="创建新的学习路径",
    description="调用AI生成学习路径，解析并保存到数据库。"
)
async def create_learning_path(
    request: LearningPathCreateRequestAPI,
    service: LearningPathService = Depends(get_learning_path_service),
    current_user: Dict = Depends(get_current_user)
):
    """创建学习路径端点"""
    try:
        user_id = current_user.get('user', {}).get('id')
        if not user_id:
             logger.error(f"无法从认证信息中获取用户ID: {current_user}")
             raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="无法识别用户ID")
        logger.info(f"User {user_id} requested learning path creation.")
        user_uuid = UUID(user_id)
        path_id = await service.generate_and_save_learning_path(request, user_uuid)
        return LearningPathCreateResponseAPI(
            message="Learning path created successfully.",
            learning_path_id=path_id
        )
    except ValueError as e:
        logger.error(f"Validation error during path creation for user {user_id}: {e}")
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        logger.exception(f"Failed to create learning path for user {user_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create learning path."
        )

@router.get(
    "/",
    response_model=List[LearningPathListItemAPI],
    summary="获取当前用户的所有学习路径列表",
    description="返回当前认证用户的所有学习路径的简要信息列表。"
)
async def list_user_learning_paths(
    service: LearningPathService = Depends(get_learning_path_service),
    current_user: Dict = Depends(get_current_user)
):
    """列出用户学习路径端点"""
    try:
        user_id = current_user.get('user', {}).get('id')
        if not user_id:
             logger.error(f"无法从认证信息中获取用户ID: {current_user}")
             raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="无法识别用户ID")
        logger.info(f"Fetching learning paths for user {user_id}.")
        user_uuid = UUID(user_id)
        paths = await service.get_user_learning_paths(user_uuid)
        return paths
    except Exception as e:
        logger.exception(f"Failed to list learning paths for user {user_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve learning paths."
        )

@router.get(
    "/{path_id}",
    response_model=FullLearningPathResponseAPI,
    summary="获取指定学习路径的详细信息",
    description="根据路径ID获取完整的学习路径数据，包括节点、边和资源。",
    responses={404: {"description": "Learning path not found"}}
)
async def get_learning_path(
    path_id: UUID,
    service: LearningPathService = Depends(get_learning_path_service),
    current_user: Dict = Depends(get_current_user)
):
    """获取学习路径详情端点"""
    try:
        user_id = current_user.get('user', {}).get('id')
        if not user_id:
             logger.error(f"无法从认证信息中获取用户ID: {current_user}")
             raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="无法识别用户ID")
        user_uuid = UUID(user_id)
        logger.info(f"Fetching details for path {path_id} requested by user {user_id}.")
        path_details = await service.get_learning_path_details(path_id)
        if not path_details:
            logger.warning(f"Path {path_id} not found.")
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Learning path not found")
        
        # 权限检查：确保用户只能访问自己的路径
        if path_details.path.user_id != user_uuid:
             logger.warning(f"User {user_id} attempt to access unauthorized path {path_id}.")
             raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to access this path")

        return path_details
    except HTTPException: # Re-raise HTTP exceptions
        raise
    except Exception as e:
        logger.exception(f"Failed to get learning path {path_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve learning path details."
        )

@router.delete(
    "/{path_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="删除指定的学习路径",
    description="删除指定的学习路径及其所有关联数据。",
    responses={404: {"description": "Learning path not found"}, 403: {"description": "Not authorized"}}
)
async def delete_learning_path_route(
    path_id: UUID,
    service: LearningPathService = Depends(get_learning_path_service),
    current_user: Dict = Depends(get_current_user)
):
    """删除学习路径端点"""
    try:
        user_id = current_user.get('user', {}).get('id')
        if not user_id:
             logger.error(f"无法从认证信息中获取用户ID: {current_user}")
             raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="无法识别用户ID")
        user_uuid = UUID(user_id)
        logger.info(f"User {user_id} requested deletion of path {path_id}.")
        # Service层已有权限检查逻辑，这里直接调用
        deleted = await service.remove_learning_path(path_id, user_uuid)
        if not deleted:
            # 区分是没找到还是删除失败（Service层日志会记录）
            # 我们可以假设如果 service 返回 False 是因为没找到或无权限
            # 或者让 service 抛出特定异常
            logger.warning(f"Path {path_id} not found or user {user_id} not authorized for deletion.")
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Learning path not found or not authorized")
        # 成功删除，返回 204 No Content，不需要响应体
        return None # FastAPI 会处理 204 状态码
    except HTTPException: # Re-raise HTTP exceptions from service or here
        raise
    except Exception as e:
        logger.exception(f"Failed to delete learning path {path_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete learning path."
        ) 