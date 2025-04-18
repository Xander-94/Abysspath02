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
import re

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
            
            # 更新用户画像 (修改为写入新表 assessment_profiles)
            if profile_data:
                user_id = assessment.data["user_id"]
                upsert_data = {
                    "user_id": user_id,
                    "profile_data": profile_data,
                    "last_updated_at": datetime.utcnow().isoformat()
                }
                try:
                    # 使用 upsert 写入 assessment_profiles 表
                    await self.supabase.table("assessment_profiles").upsert(upsert_data).execute()
                    logger.info(f"成功更新 assessment_profiles 表，用户 ID: {user_id}")
                except Exception as upsert_error:
                    logger.error(f"更新 assessment_profiles 表失败: {upsert_error}")
                    # 即使画像更新失败，也继续执行，不阻塞交互
            
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
        """从AI回复中提取用户画像数据(使用正则表达式)"""
        try:
            # 使用正则表达式查找 ```json ... ``` 块
            match = re.search(r"```json\s*(\{.*?\})\s*```", ai_response, re.DOTALL)
            if not match:
                logger.warning("在AI响应中未找到 ```json ... ``` 块")
                # 尝试备用方法：查找第一个 { 和最后一个 } (保持谨慎)
                start_idx = ai_response.find("{")
                end_idx = ai_response.rfind("}")
                if start_idx != -1 and end_idx != -1 and start_idx < end_idx:
                    json_str = ai_response[start_idx:end_idx + 1]
                else:
                    return None # 如果两种方法都找不到，则返回 None
            else:
                json_str = match.group(1) # 获取捕获的 JSON 字符串
                
            # 尝试解析 JSON
            profile_data = json.loads(json_str)
            
            # 验证数据结构 (与 Prompt 统一)
            required_top_level_fields = ["core_analysis", "behavioral_profile"]
            if not all(field in profile_data for field in required_top_level_fields):
                logger.warning(f"提取的JSON缺少必要的顶级字段: {required_top_level_fields}")
                return None # 如果缺少关键顶级字段，视为无效
                
            logger.info("成功提取并解析了用户画像JSON数据")
            return profile_data
            
        except json.JSONDecodeError as e:
            logger.error(f"解析提取的JSON字符串失败: {e}\nJSON String: {json_str}")
            return None
        except Exception as e:
            # 捕获其他潜在错误，例如 re 模块错误
            logger.error(f"提取用户画像数据时发生意外错误: {str(e)}")
            return None

    def _check_assessment_complete(self, ai_response: str) -> bool:
        """检查评估是否完成(基于提取的JSON和统一的字段名)"""
        profile_data = self._extract_profile_data(ai_response)
        if not profile_data:
            return False # 如果无法提取有效画像，则未完成
            
        # 检查核心部分是否存在 (与 Prompt 统一)
        # 可以根据需要添加更详细的检查，例如检查 specific sub-fields
        # required_fields = ["core_analysis", "behavioral_profile"] # 简化检查，只要能提取到有效JSON就认为可能完成
        # for field in required_fields:
        #     if field not in profile_data or not profile_data[field]: # 检查字段存在且不为空
        #         logger.debug(f"评估未完成：缺少或为空的字段 {field}")
        #         return False

        # 简化逻辑：只要成功提取到包含 core_analysis 和 behavioral_profile 的 JSON，就认为评估在结构上是完整的
        # 实际业务可能需要更复杂的完成度判断逻辑
        logger.debug(f"检查评估完成度：已成功提取画像数据，包含必须的顶级字段。")
        return True 
        
        # try:
        #     # 保留之前的详细检查逻辑作为注释，以备将来需要
        #     # required_fields_detailed = {
        #     #     "core_analysis": ["competencies", "interest_layers"], # 根据Prompt调整
        #     #     "behavioral_profile": ["hobbies", "personality"] # 根据Prompt调整
        #     # }
        #     # for section, fields in required_fields_detailed.items():
        #     #     if section not in profile_data:
        #     #         return False
        #     #     for field in fields:
        #     #         # 检查子字段是否存在且不为空列表/字典
        #     #         if field not in profile_data[section] or not profile_data[section][field]:
        #     #             return False
        #     # return True # 所有检查通过
        # except Exception as e:
        #      logger.error(f"检查评估完成度时出错: {str(e)}")
        #      return False # 出错则认为未完成

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