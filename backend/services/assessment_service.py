from typing import Dict, Any, List
from datetime import datetime
import uuid
from models.assessment import AssessmentInteraction, AssessmentHistory
from models.chat import Message, ChatResponse
from services.deepseek_service import DeepseekService
from database import get_supabase_client
import logging

logger = logging.getLogger(__name__)

class AssessmentService:
    def __init__(self):
        self.supabase = get_supabase_client()
        self.deepseek = DeepseekService()

    async def create_assessment(self, user_id: str, assessment_type: str = "dialogue") -> Dict[str, Any]:
        """创建新的评估记录"""
        assessment_data = {
            "id": str(uuid.uuid4()),
            "user_id": user_id,
            "type": assessment_type,
            "status": "in_progress",
            "created_at": datetime.utcnow().isoformat(),
            "updated_at": datetime.utcnow().isoformat()
        }
        
        result = await self.supabase.table("assessment_history").insert(assessment_data).execute()
        return result.data[0]

    async def save_interaction(self, assessment_id: str, user_message: str) -> Dict[str, Any]:
        """保存对话交互记录"""
        try:
            # 获取AI回复
            response = await self.deepseek.chat(message=user_message, is_assessment=True)
            
            if not response.success:
                return {
                    "interaction": None,
                    "success": False,
                    "error": response.error,
                    "is_complete": False
                }
            
            # 保存交互记录
            interaction_data = {
                "id": str(uuid.uuid4()),
                "assessment_id": assessment_id,
                "user_message": user_message,
                "ai_response": response.content,
                "created_at": datetime.utcnow().isoformat()
            }
            
            result = await self.supabase.table("assessment_interactions").insert(interaction_data).execute()
            
            # 更新评估记录的更新时间
            await self.supabase.table("assessment_history").update({
                "updated_at": datetime.utcnow().isoformat()
            }).eq("id", assessment_id).execute()
            
            return {
                "interaction": result.data[0],
                "success": True,
                "error": None,
                "is_complete": False  # 可以根据AI回复内容判断是否完成评估
            }
        except Exception as e:
            logger.error(f"保存对话交互失败: {str(e)}")
            return {
                "interaction": None,
                "success": False,
                "error": str(e),
                "is_complete": False
            }

    async def get_assessment_history(self, user_id: str) -> List[Dict[str, Any]]:
        """获取用户的评估历史记录"""
        result = await self.supabase.table("assessment_history").select("*").eq("user_id", user_id).execute()
        return result.data

    async def get_assessment_detail(self, assessment_id: str) -> Dict[str, Any]:
        """获取评估详情，包括对话记录"""
        try:
            # 获取评估记录，使用外键关联获取对话记录
            result = await self.supabase.table("assessment_history").select(
                "*",
                count="exact"
            ).eq("id", assessment_id).execute()
            
            if not result.data:
                return {"error": "评估记录不存在"}
                
            assessment = result.data[0]
            
            # 获取对话记录并按时间排序
            interactions = await self.supabase.table("assessment_interactions").select(
                "*"
            ).eq("assessment_id", assessment_id).order(
                "created_at", desc=False
            ).execute()
            
            # 将对话记录添加到评估记录中
            assessment["assessment_interactions"] = interactions.data if interactions.data else []
            
            return assessment
            
        except Exception as e:
            logger.error(f"获取评估详情失败: {str(e)}")
            return {"error": f"获取评估详情失败: {str(e)}"}

    async def complete_assessment(self, assessment_id: str, summary: str = None) -> Dict[str, Any]:
        """完成评估"""
        update_data = {
            "status": "completed",
            "completed_at": datetime.utcnow().isoformat(),
            "updated_at": datetime.utcnow().isoformat()
        }
        if summary:
            update_data["summary"] = summary
            
        result = await self.supabase.table("assessment_history").update(update_data).eq("id", assessment_id).execute()
        return result.data[0] 