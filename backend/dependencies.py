import logging
from typing import Callable
from functools import lru_cache

from database import get_supabase_client
from repositories.learning_path_repository import LearningPathRepository
from services.learning_path_service import LearningPathService
from services.deepseek_service import deepseek_service

logger = logging.getLogger(__name__)

# 全局服务实例储存
_services = {}

def setup_dependencies():
    """初始化所有依赖服务"""
    logger.info("正在设置依赖注入...")
    
    # 初始化 LearningPathRepository
    supabase_client = get_supabase_client()
    learning_path_repo = LearningPathRepository(supabase_client)
    
    # 初始化 LearningPathService
    learning_path_service = LearningPathService(
        repository=learning_path_repo,
        deepseek_service=deepseek_service
    )
    
    # 存储服务实例
    _services["learning_path_service"] = learning_path_service
    
    logger.info("依赖注入设置完成")

@lru_cache()
def get_learning_path_service() -> LearningPathService:
    """获取学习路径服务实例"""
    return _services.get("learning_path_service") 