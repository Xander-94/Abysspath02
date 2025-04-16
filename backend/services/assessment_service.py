from typing import Dict, Any, List, Optional
from datetime import datetime
import uuid
import json
from models.assessment import AssessmentInteraction, AssessmentHistory
from models.chat import Message, ChatResponse
from services.deepseek_service import DeepseekService
from services.user_profile_service import UserProfileService
from database import get_supabase_client
import logging

logger = logging.getLogger(__name__)

class AssessmentService:
    def __init__(self):
        self.supabase = get_supabase_client()
        self.deepseek = DeepseekService()
        self.profile_service = UserProfileService()

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
        """保存对话交互记录并更新用户画像"""
        try:
            # 获取评估记录
            assessment = await self.supabase.table("assessment_history").select("*").eq("id", assessment_id).single().execute()
            if not assessment.data:
                raise ValueError("评估记录不存在")

            # 获取AI回复
            logger.debug(f"调用deepseek.chat，参数：message={user_message}, is_assessment=True")
            response = await self.deepseek.chat(message=user_message, is_assessment=True)
            logger.debug(f"deepseek.chat响应：success={response.success}, content长度={len(response.content) if response.content else 0}")
            
            if not response.success:
                return {
                    "interaction": None,
                    "success": False,
                    "error": response.error,
                    "is_complete": False
                }
            
            # 解析AI回复中的用户画像数据
            profile_data = self._extract_profile_data(response.content)
            
            # 保存交互记录
            interaction_data = {
                "id": str(uuid.uuid4()),
                "assessment_id": assessment_id,
                "user_message": user_message,
                "ai_response": response.content,
                "profile_data": profile_data,
                "created_at": datetime.utcnow().isoformat()
            }
            
            result = await self.supabase.table("assessment_interactions").insert(interaction_data).execute()
            
            # 更新用户画像
            if profile_data:
                await self.profile_service.update_profile(
                    assessment.data["user_id"],
                    profile_data
                )
            
            # 更新评估记录
            await self.supabase.table("assessment_history").update({
                "updated_at": datetime.utcnow().isoformat()
            }).eq("id", assessment_id).execute()
            
            return {
                "interaction": result.data[0],
                "success": True,
                "error": None,
                "is_complete": self._check_assessment_complete(response.content)
            }
        except Exception as e:
            logger.error(f"保存对话交互失败: {str(e)}")
            return {
                "interaction": None,
                "success": False,
                "error": str(e),
                "is_complete": False
            }

    def _extract_profile_data(self, ai_response: str) -> Optional[Dict[str, Any]]:
        """从AI回复中提取用户画像数据"""
        try:
            # 查找JSON格式的用户画像数据
            start_idx = ai_response.find("{")
            end_idx = ai_response.rfind("}")
            
            if start_idx == -1 or end_idx == -1:
                return None
                
            json_str = ai_response[start_idx:end_idx + 1]
            profile_data = json.loads(json_str)
            
            # 验证数据结构
            required_fields = ["competency", "interest_graph", "behavior", "constraints"]
            if not all(field in profile_data for field in required_fields):
                return None
                
            return profile_data
        except Exception as e:
            logger.error(f"提取用户画像数据失败: {str(e)}")
            return None

    def _check_assessment_complete(self, ai_response: str) -> bool:
        """检查评估是否完成"""
        # 检查AI回复中是否包含完整的用户画像数据
        profile_data = self._extract_profile_data(ai_response)
        if not profile_data:
            return False
            
        # 检查必要字段是否都有有效值
        required_fields = {
            "competency": ["skill_tree", "knowledge_gaps"],
            "interest_graph": ["primary_interests"],
            "behavior": ["activity_cycle", "content_preference"],
            "constraints": ["time_availability"]
        }
        
        try:
            for section, fields in required_fields.items():
                if section not in profile_data:
                    return False
                for field in fields:
                    if not profile_data[section].get(field):
                        return False
            return True
        except Exception:
            return False

    async def get_assessment_result(self, assessment_id: str) -> Dict[str, Any]:
        """获取评估结果"""
        try:
            # 获取评估记录和所有交互
            result = await self.supabase.table("assessment_history").select(
                "*",
                "assessment_interactions(*)"
            ).eq("id", assessment_id).single().execute()
            
            if not result.data:
                raise ValueError("评估记录不存在")
                
            # 获取用户画像
            profile = await self.profile_service.get_profile(result.data["user_id"])
            
            return {
                "assessment": result.data,
                "profile": profile
            }
        except Exception as e:
            logger.error(f"获取评估结果失败: {str(e)}")
            raise

    async def get_assessment_history(self, user_id: str) -> List[Dict[str, Any]]:
        """获取用户的评估历史记录"""
        result = await self.supabase.table("assessment_history").select("*").eq("user_id", user_id).execute()
        return result.data

    async def get_assessment_detail(self, assessment_id: str) -> Dict[str, Any]:
        """获取评估详情，包括对话记录"""
        try:
            # 移除 single() 调用，允许返回多条记录
            result = await self.supabase.table("assessment_history").select(
                "*",
                "assessment_interactions(id, user_message, ai_response, profile_data, created_at)"
            ).eq("id", assessment_id).execute()
            
            if not result.data:
                return {"error": "评估记录不存在"}
                
            return result.data[0] if len(result.data) == 1 else result.data
            
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