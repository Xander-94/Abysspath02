from typing import Dict, Any, List
from datetime import datetime
import uuid
from models.assessment import AssessmentInteraction, AssessmentHistory
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
            ai_response = await self.deepseek.chat_for_assessment(user_message)
            
            # 保存交互记录
            interaction_data = {
                "id": str(uuid.uuid4()),
                "assessment_id": assessment_id,
                "user_message": user_message,
                "ai_response": ai_response,
                "created_at": datetime.utcnow().isoformat()
            }
            
            result = await self.supabase.table("assessment_interactions").insert(interaction_data).execute()
            
            # 更新评估记录的更新时间
            await self.supabase.table("assessment_history").update({
                "updated_at": datetime.utcnow().isoformat()
            }).eq("id", assessment_id).execute()
            
            # 分析AI回复，判断是否需要完成评估
            is_complete = "总结" in ai_response or "评估完成" in ai_response
            
            if is_complete:
                # 提取总结信息
                summary = ai_response
                # 更新评估状态
                await self.complete_assessment(assessment_id, summary)
            
            return {
                "interaction": result.data[0],
                "is_complete": is_complete
            }
        except Exception as e:
            logger.error(f"保存对话交互记录失败: {str(e)}")
            raise Exception(f"保存对话失败: {str(e)}")

    async def get_assessment_history(self, user_id: str) -> List[Dict[str, Any]]:
        """获取用户的评估历史记录"""
        result = await self.supabase.table("assessment_history").select("*").eq("user_id", user_id).execute()
        return result.data

    async def get_assessment_detail(self, assessment_id: str) -> Dict[str, Any]:
        """获取评估详情，包括对话记录"""
        # 获取评估记录
        assessment = await self.supabase.table("assessment_history").select("*").eq("id", assessment_id).single().execute()
        
        # 获取对话记录
        interactions = await self.supabase.table("assessment_interactions").select("*").eq("assessment_id", assessment_id).execute()
        
        return {
            "assessment": assessment.data,
            "interactions": interactions.data
        }

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