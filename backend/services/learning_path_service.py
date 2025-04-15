from typing import Dict, Any, List
from datetime import datetime
import uuid
import json
from services.deepseek_service import DeepseekService
from database import get_supabase_client
import logging

logger = logging.getLogger(__name__)

class LearningPathService:
    def __init__(self):
        self.supabase = get_supabase_client()
        self.deepseek = DeepseekService()

    async def create_learning_path(self, user_id: str, title: str = "新的学习路径") -> Dict[str, Any]:
        """创建新的学习路径记录"""
        try:
            path_data = {
                "id": str(uuid.uuid4()),
                "user_id": user_id,
                "title": title,
                "status": "in_progress",
                "created_at": datetime.utcnow().isoformat(),
                "updated_at": datetime.utcnow().isoformat()
            }
            
            result = await self.supabase.table("learning_path_history").insert(path_data).execute()
            logger.info(f"创建学习路径成功: {result.data[0]}")
            return result.data[0]
        except Exception as e:
            logger.error(f"创建学习路径失败: {str(e)}")
            raise Exception(f"创建学习路径失败: {str(e)}")

    async def save_interaction(self, path_id: str, user_message: str) -> Dict[str, Any]:
        """保存对话交互并更新学习路径"""
        try:
            # 获取AI回复
            response = await self.deepseek.chat(message=user_message, is_learning_path=True)
            
            if not response.success:
                return {
                    "interaction": None,
                    "success": False,
                    "error": response.error
                }
            
            # 尝试解析JSON响应
            try:
                path_data = json.loads(response.content)
                # 更新学习路径数据
                await self.supabase.table("learning_path_history").update({
                    "path_data": path_data,
                    "description": path_data.get("description", ""),  # 添加描述字段
                    "updated_at": datetime.utcnow().isoformat()
                }).eq("id", path_id).execute()
            except json.JSONDecodeError:
                logger.warning(f"AI响应不是有效的JSON格式: {response.content}")
            
            # 保存交互记录
            interaction_data = {
                "id": str(uuid.uuid4()),
                "path_id": path_id,
                "user_message": user_message,
                "ai_response": response.content,
                "created_at": datetime.utcnow().isoformat()
            }
            
            result = await self.supabase.table("learning_path_interactions").insert(interaction_data).execute()
            
            return {
                "interaction": result.data[0],
                "success": True,
                "error": None
            }
        except Exception as e:
            logger.error(f"保存学习路径交互失败: {str(e)}")
            return {
                "interaction": None,
                "success": False,
                "error": str(e)
            }

    async def get_learning_path_history(self, user_id: str) -> List[Dict[str, Any]]:
        """获取用户的学习路径历史记录"""
        try:
            result = await self.supabase.table("learning_path_history").select("*").eq("user_id", user_id).order("created_at", desc=True).execute()
            return result.data
        except Exception as e:
            logger.error(f"获取学习路径历史失败: {str(e)}")
            raise Exception(f"获取学习路径历史失败: {str(e)}")

    async def get_learning_path_detail(self, path_id: str) -> Dict[str, Any]:
        """获取学习路径详情，包括对话记录"""
        try:
            # 获取学习路径记录
            result = await self.supabase.table("learning_path_history").select(
                "*",
                count="exact"
            ).eq("id", path_id).execute()
            
            if not result.data:
                return {"error": "学习路径不存在"}
                
            path = result.data[0]
            
            # 获取对话记录并按时间排序
            interactions = await self.supabase.table("learning_path_interactions").select(
                "*"
            ).eq("path_id", path_id).order(
                "created_at", desc=False
            ).execute()
            
            # 将对话记录添加到路径记录中
            path["learning_path_interactions"] = interactions.data if interactions.data else []
            
            return path
            
        except Exception as e:
            logger.error(f"获取学习路径详情失败: {str(e)}")
            return {"error": f"获取学习路径详情失败: {str(e)}"}

    async def complete_learning_path(self, path_id: str) -> Dict[str, Any]:
        """完成学习路径"""
        try:
            update_data = {
                "status": "completed",
                "completed_at": datetime.utcnow().isoformat(),
                "updated_at": datetime.utcnow().isoformat()
            }
            
            result = await self.supabase.table("learning_path_history").update(update_data).eq("id", path_id).execute()
            return result.data[0]
        except Exception as e:
            logger.error(f"完成学习路径失败: {str(e)}")
            raise Exception(f"完成学习路径失败: {str(e)}")

    async def delete_learning_path(self, path_id: str) -> None:
        """删除学习路径及其相关记录"""
        try:
            await self.supabase.table("learning_path_history").delete().eq("id", path_id).execute()
        except Exception as e:
            logger.error(f"删除学习路径失败: {str(e)}")
            raise Exception(f"删除学习路径失败: {str(e)}") 