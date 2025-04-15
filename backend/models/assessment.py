from pydantic import BaseModel, UUID4
from typing import Optional, Dict, Any
from datetime import datetime

class AssessmentInteraction(BaseModel):
    """评估对话记录模型"""
    id: Optional[UUID4] = None
    assessment_id: UUID4
    user_message: str
    ai_response: str
    traits: Optional[Dict[str, Any]] = None
    created_at: Optional[datetime] = None

class AssessmentHistory(BaseModel):
    """评估历史记录模型"""
    id: Optional[UUID4] = None
    user_id: UUID4
    type: str
    title: Optional[str] = None
    status: str
    summary: Optional[str] = None
    skill_proficiency: Optional[Dict[str, Any]] = None
    meta_skills: Optional[Dict[str, Any]] = None
    interests: Optional[Dict[str, Any]] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None 