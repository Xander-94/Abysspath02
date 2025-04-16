from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any

class Message(BaseModel):
    role: str = Field(..., description="消息角色：system/user/assistant")
    content: str = Field(..., description="消息内容")

    def dict(self) -> Dict[str, str]:
        """转换为API请求格式"""
        return {
            "role": self.role,
            "content": self.content
        }

class ChatRequest(BaseModel):
    messages: List[Message] = Field(..., description="包含对话历史的消息列表")
    conversation_id: Optional[str] = Field(default="string", description="会话ID")
    metadata: Optional[Dict[str, Any]] = Field(default_factory=dict, description="元数据")

class ChatResponse(BaseModel):
    content: str = Field(..., description="AI回复内容")
    conversation_id: str = Field(default="string", description="会话ID")
    success: bool = Field(default=True, description="是否成功")
    error: Optional[str] = Field(default=None, description="错误信息")
    usage: Optional[Dict[str, Any]] = Field(default=None, description="token使用情况") 