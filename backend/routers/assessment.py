from fastapi import APIRouter, HTTPException, Depends
from typing import Dict, Any, List
from models.assessment import AssessmentInteraction, AssessmentHistory
from services.assessment_service import AssessmentService
from auth import get_current_user
from pydantic import BaseModel
import logging

logger = logging.getLogger(__name__)

class ChatRequest(BaseModel):
    message: str

router = APIRouter(prefix="/api/assessment", tags=["assessment"])

def get_assessment_service() -> AssessmentService:
    return AssessmentService()

@router.post("/start")
async def start_assessment(
    assessment_type: str = "dialogue",
    service: AssessmentService = Depends(get_assessment_service),
    current_user: Dict[str, Any] = Depends(get_current_user)
) -> Dict[str, Any]:
    """开始新的评估"""
    try:
        result = await service.create_assessment(current_user["id"], assessment_type)
        return {"status": "success", "data": result}
    except Exception as e:
        logger.error(f"开始评估失败: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/{assessment_id}/chat")
async def chat(
    assessment_id: str,
    request: ChatRequest,
    service: AssessmentService = Depends(get_assessment_service),
    current_user: Dict[str, Any] = Depends(get_current_user)
) -> Dict[str, Any]:
    """发送评估对话消息"""
    try:
        result = await service.save_interaction(assessment_id, request.message)
        return {"status": "success", "data": result}
    except Exception as e:
        logger.error(f"发送评估消息失败: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/history")
async def get_history(
    service: AssessmentService = Depends(get_assessment_service),
    current_user: Dict[str, Any] = Depends(get_current_user)
) -> Dict[str, Any]:
    """获取评估历史记录"""
    try:
        result = await service.get_assessment_history(current_user["id"])
        return {"status": "success", "data": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{assessment_id}")
async def get_assessment(
    assessment_id: str,
    service: AssessmentService = Depends(get_assessment_service),
    current_user: Dict[str, Any] = Depends(get_current_user)
) -> Dict[str, Any]:
    """获取评估详情"""
    try:
        result = await service.get_assessment_detail(assessment_id)
        return {"status": "success", "data": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/{assessment_id}/complete")
async def complete_assessment(
    assessment_id: str,
    summary: str = None,
    service: AssessmentService = Depends(get_assessment_service),
    current_user: Dict[str, Any] = Depends(get_current_user)
) -> Dict[str, Any]:
    """完成评估"""
    try:
        result = await service.complete_assessment(assessment_id, summary)
        return {"status": "success", "data": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) 