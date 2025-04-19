import os
from pydantic_settings import BaseSettings
from dotenv import load_dotenv
from pathlib import Path
import logging

logger = logging.getLogger(__name__)

# 确定 .env 文件的路径 (相对于 config.py)
env_path = Path(__file__).parent / '.env'

# 显式加载 .env 文件
if env_path.is_file():
    load_dotenv(dotenv_path=env_path)
    logger.info(f"加载环境变量文件: {env_path}")
else:
    logger.warning(f"环境变量文件未找到: {env_path}")

class AppConfig(BaseSettings):
    """应用程序配置模型"""
    SUPABASE_URL: str
    SUPABASE_KEY: str
    DEEPSEEK_API_KEY: str
    DEEPSEEK_BASE_URL: str = "https://api.deepseek.com/v1"
    LOG_LEVEL: str = "INFO" 
    # 如果还有其他配置项，可以在这里添加

    class Config:
        # Pydantic-settings 会自动从环境变量读取
        # 也可以指定 .env 文件，但我们已在上面手动加载
        env_file = str(env_path)
        env_file_encoding = 'utf-8'
        extra = 'ignore' # 忽略 .env 中多余的变量

# 创建配置实例 (可选，通常在需要的地方创建)
# config = AppConfig()
# logger.info(f"配置加载完成: {config.dict(exclude={'DEEPSEEK_API_KEY', 'SUPABASE_KEY'})}") 