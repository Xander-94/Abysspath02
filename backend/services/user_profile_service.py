from typing import Dict, Any, Optional
import uuid
from datetime import datetime
import json
import logging
from database import get_supabase_client

logger = logging.getLogger(__name__)

class UserProfileService:
    def __init__(self):
        self.supabase = get_supabase_client()

    async def get_profile(self, user_id: str) -> Optional[Dict[str, Any]]:
        """获取用户画像"""
        try:
            result = await self.supabase.table("user_profiles").select("*").eq("user_id", user_id).execute()
            return result.data[0] if result.data else None
        except Exception as e:
            logger.error(f"获取用户画像失败: {str(e)}")
            return None

    async def create_profile(self, user_id: str) -> Dict[str, Any]:
        """创建新的用户画像"""
        try:
            profile_data = {
                "id": str(uuid.uuid4()),
                "user_id": user_id,
                "profile_version": 1,
                "competency": {
                    "skill_tree": {},
                    "knowledge_gaps": {"weaknesses": [], "last_updated": datetime.utcnow().isoformat()},
                    "skill_transfer_score": 0.0,
                    "learning_velocity": {"avg_hours_per_skill": 0, "recent_trend": "0%"}
                },
                "interest_graph": {
                    "primary_interests": {},
                    "cross_domain_links": {},
                    "interest_consistency": {"volatility_score": 0, "top_stable_tags": []}
                },
                "behavior": {
                    "activity_cycle": {"peak_hours": [], "weekly_pattern": []},
                    "content_preference": {"format_weights": {}, "difficulty_bias": "0%"},
                    "engagement_metrics": {"avg_session_minutes": 0, "completion_rate": 0}
                },
                "constraints": {
                    "time_availability": {"daily_max_minutes": 0, "preferred_days": []},
                    "resource_constraints": {"allowed_formats": [], "device_types": []},
                    "deadline": None
                },
                "dynamic_flags": {
                    "learning_blocks": {"blocked_skills": [], "detected_at": datetime.utcnow().isoformat()},
                    "achievements": {"badges": []},
                    "adaptive_flags": {"needs_reassessment": True, "reason": "初始化"}
                },
                "domain_relations": {
                    "domain_graph": [],
                    "cross_domain_scores": {},
                    "bridge_recommendations": {}
                },
                "created_at": datetime.utcnow().isoformat(),
                "updated_at": datetime.utcnow().isoformat()
            }
            
            result = await self.supabase.table("user_profiles").insert(profile_data).execute()
            return result.data[0]
        except Exception as e:
            logger.error(f"创建用户画像失败: {str(e)}")
            raise

    async def update_profile(self, user_id: str, assessment_data: Dict[str, Any]) -> Dict[str, Any]:
        """根据评估结果更新用户画像"""
        try:
            # 获取现有画像
            profile = await self.get_profile(user_id)
            if not profile:
                profile = await self.create_profile(user_id)

            # 更新版本号
            profile["profile_version"] += 1
            
            # 更新核心能力维度
            if "competency" in assessment_data:
                self._merge_competency(profile, assessment_data["competency"])
            
            # 更新兴趣图谱
            if "interest_graph" in assessment_data:
                self._merge_interest_graph(profile, assessment_data["interest_graph"])
            
            # 更新行为特征
            if "behavior" in assessment_data:
                self._merge_behavior(profile, assessment_data["behavior"])
            
            # 更新约束条件
            if "constraints" in assessment_data:
                self._merge_constraints(profile, assessment_data["constraints"])
            
            # 更新动态标记
            if "dynamic_flags" in assessment_data:
                self._merge_dynamic_flags(profile, assessment_data["dynamic_flags"])
            
            # 更新领域关联
            if "domain_relations" in assessment_data:
                self._merge_domain_relations(profile, assessment_data["domain_relations"])
            
            # 更新时间戳
            profile["updated_at"] = datetime.utcnow().isoformat()
            
            # 保存更新后的画像
            result = await self.supabase.table("user_profiles").update(profile).eq("id", profile["id"]).execute()
            return result.data[0]
        except Exception as e:
            logger.error(f"更新用户画像失败: {str(e)}")
            raise

    def _merge_competency(self, profile: Dict[str, Any], new_data: Dict[str, Any]):
        """合并能力维度数据"""
        comp = profile["competency"]
        # 合并技能树
        if "skill_tree" in new_data:
            for skill, data in new_data["skill_tree"].items():
                if skill in comp["skill_tree"]:
                    comp["skill_tree"][skill]["level"] = max(
                        comp["skill_tree"][skill]["level"],
                        data["level"]
                    )
                else:
                    comp["skill_tree"][skill] = data
        
        # 更新知识盲点
        if "knowledge_gaps" in new_data:
            comp["knowledge_gaps"]["weaknesses"] = list(set(
                comp["knowledge_gaps"]["weaknesses"] + 
                new_data["knowledge_gaps"]["weaknesses"]
            ))
            comp["knowledge_gaps"]["last_updated"] = datetime.utcnow().isoformat()
        
        # 更新技能迁移分数
        if "skill_transfer_score" in new_data:
            comp["skill_transfer_score"] = (
                comp["skill_transfer_score"] * 0.7 + 
                new_data["skill_transfer_score"] * 0.3
            )
        
        # 更新学习速度
        if "learning_velocity" in new_data:
            comp["learning_velocity"] = new_data["learning_velocity"]

    def _merge_interest_graph(self, profile: Dict[str, Any], new_data: Dict[str, Any]):
        """合并兴趣图谱数据"""
        interest = profile["interest_graph"]
        # 更新主要兴趣
        if "primary_interests" in new_data:
            for domain, weight in new_data["primary_interests"].items():
                if domain in interest["primary_interests"]:
                    interest["primary_interests"][domain] = (
                        interest["primary_interests"][domain] * 0.7 + 
                        weight * 0.3
                    )
                else:
                    interest["primary_interests"][domain] = weight
        
        # 更新跨领域关联
        if "cross_domain_links" in new_data:
            interest["cross_domain_links"].update(new_data["cross_domain_links"])
        
        # 更新兴趣稳定性
        if "interest_consistency" in new_data:
            interest["interest_consistency"] = new_data["interest_consistency"]

    def _merge_behavior(self, profile: Dict[str, Any], new_data: Dict[str, Any]):
        """合并行为特征数据"""
        behavior = profile["behavior"]
        # 更新活动周期
        if "activity_cycle" in new_data:
            behavior["activity_cycle"] = new_data["activity_cycle"]
        
        # 更新内容偏好
        if "content_preference" in new_data:
            for format_type, weight in new_data["content_preference"]["format_weights"].items():
                if format_type in behavior["content_preference"]["format_weights"]:
                    behavior["content_preference"]["format_weights"][format_type] = (
                        behavior["content_preference"]["format_weights"][format_type] * 0.7 + 
                        weight * 0.3
                    )
                else:
                    behavior["content_preference"]["format_weights"][format_type] = weight
            behavior["content_preference"]["difficulty_bias"] = new_data["content_preference"]["difficulty_bias"]
        
        # 更新参与度指标
        if "engagement_metrics" in new_data:
            behavior["engagement_metrics"] = new_data["engagement_metrics"]

    def _merge_constraints(self, profile: Dict[str, Any], new_data: Dict[str, Any]):
        """合并约束条件数据"""
        constraints = profile["constraints"]
        # 更新时间可用性
        if "time_availability" in new_data:
            constraints["time_availability"] = new_data["time_availability"]
        
        # 更新资源限制
        if "resource_constraints" in new_data:
            constraints["resource_constraints"] = new_data["resource_constraints"]
        
        # 更新截止日期
        if "deadline" in new_data:
            constraints["deadline"] = new_data["deadline"]

    def _merge_dynamic_flags(self, profile: Dict[str, Any], new_data: Dict[str, Any]):
        """合并动态标记数据"""
        flags = profile["dynamic_flags"]
        # 更新学习障碍
        if "learning_blocks" in new_data:
            flags["learning_blocks"] = new_data["learning_blocks"]
        
        # 更新成就
        if "achievements" in new_data:
            flags["achievements"]["badges"] = list(set(
                flags["achievements"]["badges"] + 
                new_data["achievements"]["badges"]
            ))
        
        # 更新自适应标记
        if "adaptive_flags" in new_data:
            flags["adaptive_flags"] = new_data["adaptive_flags"]

    def _merge_domain_relations(self, profile: Dict[str, Any], new_data: Dict[str, Any]):
        """合并领域关联数据"""
        relations = profile["domain_relations"]
        # 更新领域图谱
        if "domain_graph" in new_data:
            relations["domain_graph"] = new_data["domain_graph"]
        
        # 更新跨领域评分
        if "cross_domain_scores" in new_data:
            relations["cross_domain_scores"].update(new_data["cross_domain_scores"])
        
        # 更新桥接技能推荐
        if "bridge_recommendations" in new_data:
            relations["bridge_recommendations"] = new_data["bridge_recommendations"] 