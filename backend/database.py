import os
from supabase import create_client, Client, ClientOptions
from pathlib import Path
from dotenv import load_dotenv
import logging
import httpx

logger = logging.getLogger(__name__)

# 加载环境变量
env_path = Path(__file__).parent / '.env'
load_dotenv(env_path)
logger.info(f"尝试加载环境变量文件: {env_path}")

def get_supabase_client() -> Client:
    """获取Supabase客户端实例"""
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_KEY")
    
    # 在使用前打印获取到的 URL，用于调试
    logger.debug(f"从环境变量获取的 SUPABASE_URL: '{url}'") 
    
    if not url or not key:
        logger.error("Supabase配置缺失，请检查环境变量")
        raise ValueError("缺少必要的Supabase配置，请检查SUPABASE_URL和SUPABASE_KEY")
        
    logger.info(f"初始化Supabase客户端: {url}")
    
    # 创建一个完全禁用代理的 httpx 客户端
    transport = httpx.HTTPTransport(
        retries=3,  # 增加重试次数
        verify=True,  # 验证 SSL 证书
    )
    
    # 创建具有更完整配置的 httpx 客户端
    httpx_client = httpx.Client(
        transport=transport,
        proxies=None,  # 显式禁用代理
        timeout=30.0,  # 增加超时时间
        trust_env=False,  # 不信任环境变量（包括代理设置）
        verify=True,  # 验证 SSL 证书
        follow_redirects=True  # 允许重定向
    )
    
    # 创建 ClientOptions 并设置自定义客户端
    client_options = ClientOptions()
    client_options.httpx_client = httpx_client
    
    return create_client(url, key, options=client_options) 