# Backend - FastAPI Application

## 简介
此目录包含 AbyssPath 应用的后端服务，使用 FastAPI 框架构建。

## 技术栈
- **框架**: FastAPI
- **数据验证**: Pydantic
- **数据库 ORM/客户端**: Supabase Python Client (supabase-py)
- **数据库**: PostgreSQL (通过 Supabase)
- **AI 服务**: Deepseek API
- **Web 服务器**: Uvicorn

## 项目结构
```
backend/
├── .env            # 环境变量 (需要手动创建)
├── main.py         # FastAPI 应用入口
├── models/         # Pydantic 数据模型 (请求/响应体, 数据库对象)
├── repositories/   # 数据仓库层，负责与数据库交互
├── routers/        # API 路由定义 (如 chat, assessment, learning_path)
├── services/       # 业务逻辑服务层 (调用 AI, 组合仓库操作等)
└── requirements.txt # Python 依赖列表
```

## 核心功能
后端提供 API 支持前端应用的各项功能，主要包括：

- **学习路径模块 (`/api/learning-paths/`)**:
    - **创建 (`POST /`)**: 接收用户目标，调用 `LearningPathService`。
        - `LearningPathService` 调用 Deepseek API 生成包含节点、边、资源的路径数据。
        - `LearningPathRepository` 将生成的路径数据（包括 `learning_paths`, `path_nodes`, `path_edges`, `node_resources` 表）存入 Supabase 数据库。
    - **获取列表 (`GET /`)**: 获取当前用户的所有学习路径。
    - **获取详情 (`GET /{path_id}`)**: 获取指定学习路径的完整数据（路径信息、节点、边、资源）。
- **聊天/评估模块 (`/api/chat/`, `/api/assessment/`)**: 处理与 AI 的对话交互、评估逻辑等（根据具体实现）。
- **用户认证**: 通常通过 Supabase 的 GoTrue 服务处理，后端可能需要验证 Token。

## 配置 (`.env` 文件)
在 `backend` 目录下创建 `.env` 文件，并至少包含以下变量：
```
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key # 注意使用 Service Role Key
DEEPSEEK_API_KEY=your_deepseek_api_key
DATABASE_URL="postgresql://postgres:[YOUR-PASSWORD]@db.[your-ref].supabase.co:5432/postgres" # 替换为你的数据库连接串 (如果直接使用)
```

## 运行
```bash
# 1. 进入 backend 目录
cd backend

# 2. (可选) 设置 NO_PROXY 环境变量 (如果使用代理/VPN)
# PowerShell:
# $env:NO_PROXY = "[your-ref].supabase.co,127.0.0.1,localhost"
# Bash:
# export NO_PROXY="[your-ref].supabase.co,127.0.0.1,localhost"

# 3. 创建并激活虚拟环境
python -m venv venv
# Windows: .\venv\Scripts\activate
# macOS/Linux: source venv/bin/activate

# 4. 安装依赖
pip install -r requirements.txt

# 5. 运行 FastAPI 服务 (开发模式)
uvicorn main:app --reload --port 8000
```
服务将在 `http://127.0.0.1:8000` 上运行。

## 开发提示
- **代理问题**: 在本地开发且使用 VPN/代理时，务必确保后端服务能够直接连接到 Supabase API 和数据库。推荐使用 `NO_PROXY` 环境变量排除 Supabase 相关域名。
- **数据库迁移**: 当前项目直接通过 SQL 修改数据库。对于更复杂的项目，考虑引入数据库迁移管理工具（如 Alembic）。
- **错误处理**: 注意在 Service 层和 Router 层添加健壮的错误处理逻辑。
- **异步操作**: FastAPI 是异步框架，尽可能使用 `async`/`await` 以获得最佳性能，但要注意调用的库（如 `supabase-py` 的某些版本）是否完全支持异步。 