from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from typing import List, Optional, Dict
import httpx
import os
import logging
from dotenv import load_dotenv
from routers import chat, assessment, learning_path_router 
from datetime import datetime
import json
from services.deepseek_service import deepseek_service, DeepseekError
from fastapi.encoders import jsonable_encoder
import sys
from pathlib import Path
from contextlib import asynccontextmanager
from database import get_supabase_client
from config import AppConfig
from dependencies import setup_dependencies

# 配置日志
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# 加载环境变量
env_path = Path(__file__).parent / '.env'
if not env_path.exists():
    logger.error(f"环境变量文件不存在: {env_path}")
    sys.exit(1)

load_dotenv(env_path)
logger.info(f"已加载环境变量文件: {env_path}")

# 验证必要的环境变量
DEEPSEEK_API_KEY = os.getenv("DEEPSEEK_API_KEY")
if not DEEPSEEK_API_KEY:
    logger.error("DEEPSEEK_API_KEY环境变量未设置")
    sys.exit(1)
logger.info(f"DEEPSEEK_API_KEY: {DEEPSEEK_API_KEY[:8]}...")

config = AppConfig()

@asynccontextmanager
async def lifespan(app: FastAPI):
    # 应用启动时执行
    logger.info("应用启动中...")
    try: # 尝试获取客户端以验证配置
        get_supabase_client() 
        logger.info("Supabase 配置验证通过")
    except ValueError as e:
        logger.error(f"Supabase 配置错误: {e}")
        # 可以选择在这里退出应用或抛出更严重的错误
        # sys.exit(1) 
    setup_dependencies() # 设置依赖注入
    logger.info("依赖已设置")
    yield
    # 应用关闭时执行
    logger.info("应用关闭中...")
    # await close_supabase_client() # 移除调用 (Supabase 客户端通常不需要手动关闭)
    logger.info("应用已关闭")

app = FastAPI(
    title="AbyssPath API",
    description="AI驱动的个性化学习路径生成器",
    version="1.0.0",
    lifespan=lifespan
)

# 配置CORS和响应编码
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 在生产环境中需要限制
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Deepseek配置
DEEPSEEK_BASE_URL = os.getenv("DEEPSEEK_BASE_URL", "https://api.deepseek.com/v1")

logger.info(f"使用Deepseek API URL: {DEEPSEEK_BASE_URL}")
logger.info(f"API Key前缀: {DEEPSEEK_API_KEY[:8]}...")

# 系统提示词
SYSTEM_PROMPT = """你是一个专业的学习能力评估助手，负责通过对话评估用户的学习能力、兴趣和目标。
评估维度包括：
1. 学习方法和习惯
2. 知识掌握和记忆能力
3. 学习动机和目标
4. 时间管理能力
5. 问题解决能力
6. 自我反思和调整能力

请通过提问和交谈，了解用户的具体情况，并在合适的时机给出以下内容：
1. 对用户当前学习状态的分析
2. 个性化的学习建议
3. 可能存在的问题和改进方向
4. 具体的行动建议

在对话过程中，请：
1. 保持专业、友好的语气
2. 循序渐进地收集信息
3. 适时给出具体的例子和建议
4. 鼓励用户进行自我反思
5. 根据用户的反馈调整建议"""

class Message(BaseModel):
    role: str
    content: str

# 对话历史存储
class ConversationManager:
    def __init__(self):
        self.conversations: Dict[str, List[Message]] = {}
        self.max_history = 10  # 最大历史消息数
    
    def add_message(self, conversation_id: str, message: Message) -> None:
        if conversation_id not in self.conversations:
            self.conversations[conversation_id] = []
        self.conversations[conversation_id].append(message)
        # 保持最近的消息
        if len(self.conversations[conversation_id]) > self.max_history:
            self.conversations[conversation_id] = self.conversations[conversation_id][-self.max_history:]
    
    def get_history(self, conversation_id: str) -> List[Message]:
        return self.conversations.get(conversation_id, [])
    
    def clear_history(self, conversation_id: str) -> None:
        if conversation_id in self.conversations:
            del self.conversations[conversation_id]

# 全局对话管理器实例
conversation_manager = ConversationManager()

class ChatRequest(BaseModel):
    message: str
    conversation_id: Optional[str] = None
    metadata: Optional[Dict] = None

    @property
    def is_valid(self) -> bool:
        return bool(self.message.strip())

class ChatResponse(BaseModel):
    content: str
    conversation_id: str
    success: bool = True
    error: Optional[str] = None
    metadata: Optional[Dict] = None

# 自定义JSON响应类，确保正确的编码
class CustomJSONResponse(JSONResponse):
    def render(self, content: any) -> bytes:
        return json.dumps(
            jsonable_encoder(content),
            ensure_ascii=False,
            allow_nan=False,
            indent=None,
            separators=(",", ":")
        ).encode("utf-8")

# 注册路由
logger.info("开始注册路由...")
logger.info(f"注册chat路由: {chat.router.routes}")
app.include_router(chat.router)
logger.info(f"注册assessment路由: {assessment.router.routes}")
app.include_router(assessment.router)
logger.info(f"注册learning_path路由: {learning_path_router.router.routes}")
app.include_router(learning_path_router.router, prefix="/api")
logger.info("路由注册完成")

@app.get("/")
async def root():
    return {"message": "欢迎使用 AbyssPath API"}

@app.get("/metrics")
async def get_metrics():
    """获取Deepseek服务监控指标"""
    return deepseek_service.get_metrics()

@app.post("/chat_backup", response_model=ChatResponse)  # 备用路由
async def chat_backup(request: ChatRequest) -> CustomJSONResponse:
    """备用的聊天路由，保持原有逻辑"""
    try:
        logger.info(f"收到备用聊天请求: {request.message}")
        conversation_id = request.conversation_id or str(datetime.now().timestamp())
        
        # 创建用户消息
        user_message = Message(role="user", content=request.message)
        conversation_manager.add_message(conversation_id, user_message)
        
        # 获取对话历史
        history = conversation_manager.get_history(conversation_id)
        logger.debug(f"对话历史: {[msg.dict() for msg in history]}")
        
        # 调用 AI 服务
        try:
            ai_message = await deepseek_service.chat(message=request.message)
            ai_message_obj = Message(role="assistant", content=ai_message)
            conversation_manager.add_message(conversation_id, ai_message_obj)
            
            return CustomJSONResponse(content={
                "content": ai_message,
                "conversation_id": conversation_id,
                "success": True,
                "metadata": request.metadata
            })
        except DeepseekError as e:
            logger.error(f"Deepseek服务错误: {str(e)}")
            return CustomJSONResponse(content={
                "content": "抱歉，AI服务暂时不可用",
                "conversation_id": conversation_id,
                "success": False,
                "error": f"AI服务错误: {str(e)}"
            })
            
    except Exception as e:
        error_msg = f"处理请求时出错: {str(e)}"
        logger.error(error_msg)
        return CustomJSONResponse(content={
            "content": "抱歉，服务器处理请求时出现错误",
            "conversation_id": request.conversation_id or "",
            "success": False,
            "error": error_msg
        })

@app.delete("/chat_backup/{conversation_id}")  # 备用的清除对话历史路由
async def clear_conversation_backup(conversation_id: str):
    """备用的清除对话历史路由"""
    conversation_manager.clear_history(conversation_id)
    return {"status": "success", "message": "对话历史已清除"}

@app.get("/health")
async def health_check():
    """健康检查端点"""
    try:
        # 检查API连接
        test_message = "test"
        await deepseek_service.chat(message=test_message)
        return {
            "status": "healthy",
            "metrics": deepseek_service.get_metrics()
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "error": str(e),
            "metrics": deepseek_service.get_metrics()
        }

@app.on_event("shutdown")
async def shutdown_event():
    """应用关闭时的清理工作"""
    await deepseek_service.close()

if __name__ == "__main__":
    import uvicorn
    import asyncio
    logger.info("启动FastAPI服务器...")
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="debug") 