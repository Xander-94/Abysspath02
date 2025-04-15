from pydantic import BaseModel, Field
from typing import List, Optional

class Message(BaseModel):
    role: str = Field(..., description="消息角色：system/user/assistant")
    content: str = Field(..., description="消息内容")

class ChatRequest(BaseModel):
    messages: List[Message] = Field(..., description="对话消息列表")
    model: str = Field(default="deepseek-chat", description="使用的模型")
    temperature: float = Field(default=0.7, ge=0.0, le=1.0, description="温度参数")
    max_tokens: int = Field(default=2000, gt=0, description="最大token数")
    stream: bool = Field(default=False, description="是否使用流式响应")

class ChatResponse(BaseModel):
    content: str = Field(..., description="AI回复内容")
    usage: Optional[dict] = Field(None, description="token使用情况") 