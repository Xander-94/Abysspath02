import os
from supabase import create_client, Client
from pathlib import Path
from dotenv import load_dotenv
import logging

logger = logging.getLogger(__name__)

# 加载环境变量
env_path = Path(__file__).parent / '.env'
load_dotenv(env_path)
logger.info(f"尝试加载环境变量文件: {env_path}")

def get_supabase_client() -> Client:
    """获取Supabase客户端实例"""
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_KEY")
    
    if not url or not key:
        logger.error("Supabase配置缺失，请检查环境变量")
        raise ValueError("缺少必要的Supabase配置，请检查SUPABASE_URL和SUPABASE_KEY")
        
    logger.info(f"初始化Supabase客户端: {url}")
    return create_client(url, key) 