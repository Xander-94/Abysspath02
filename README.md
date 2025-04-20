# AbyssPath - AI驱动的个性化学习路径规划应用

## 项目简介
AbyssPath 是一个基于 Flutter 开发的移动应用，结合 AI 技术为用户提供个性化的学习路径规划。应用通过评估用户当前知识水平和学习目标，生成定制化的学习计划。

## 技术栈
- 前端：Flutter 3.24.4
- 后端：FastAPI
- 数据库：Supabase + PostgreSQL
- AI 模型：Deepseek API
- 状态管理：Riverpod
- 路由管理：GoRoute
- 网络请求：Dio + Retrofit
- 依赖注入：get_it + injectable

## 主要功能
1. 用户认证
   - 注册/登录
   - 密码重置
   - 个人信息管理
   - 会话管理

2. 学习评估
   - **多轮对话评估**: 通过与 AI 助手进行多轮对话，深入评估用户知识水平和学习目标。AI 生成的用户画像数据异步保存至 `assessment_profiles` 表。
   - **评估结果展示**: 在用户完成评估后，提供专门页面 (`AssessmentResultPage`) 展示 AI 生成的画像分析结果。
     - **UI 优化**: 对评估结果页面进行了视觉和布局优化，例如为章节添加图标、优化卡片样式和间距，提升了信息的可读性和用户体验。
   - 实时反馈: AI 根据对话内容提供即时反馈和建议。
   - **智能追问**: AI 能根据对话上下文生成相关的追问问题。
   - 评估历史记录: 查看和管理过往的评估会话。
   - 知识水平评估
   - 学习目标设定

3. 学习路径
   - **AI 生成学习路径**: 后端调用 Deepseek API，结合用户评估结果和输入的学习目标，生成个性化的学习计划。
   - **数据模型**: 采用基于节点 (Node) 和边 (Edge) 的结构化数据模型，存储在 Supabase 数据库中 (`learning_paths`, `path_nodes`, `path_edges`, `node_resources` 表)。
   - **知识图谱可视化**: 前端使用自定义 Canvas 绘制和交互式查看器 (`InteractiveViewer`) 实现学习路径的图谱可视化。
   - **多视图展示**: 提供图谱视图和列表视图两种方式浏览学习路径。
   - **节点详情与资源**: 点击图谱或列表中的节点可查看详细信息及关联的学习资源。
   - **状态管理**: 前端使用 Riverpod 进行状态管理，处理数据获取、加载状态和错误。
   - **重要开发提示**:
     - **模型与数据同步**: 由于 AI 生成数据的不确定性，后端返回的 JSON 可能包含 `null` 值。前端 Freezed 模型必须与实际数据严格匹配，大量字段（包括 ID 字段）被设为可空 (`String?`) 并添加了相应的 `null` 处理 (`??`)，以确保解析成功。
     - **后端代理问题**: 在本地开发环境中，如果使用了 VPN 或代理 (如 Clash)，可能会干扰后端服务连接 Supabase。建议在启动后端服务前，在同一终端设置 `NO_PROXY` 环境变量，将 Supabase 域名加入排除列表 (例如 `$env:NO_PROXY = "[your-ref].supabase.co,127.0.0.1,localhost"`)。

4. 个人中心
   - 个人信息管理
   - 学习历史
   - 进度统计
   - 密码修改
   - 头像管理

## 环境要求
- Flutter 3.24.4
- JDK 17
- Gradle 8.3
- Android Studio Flamingo / IntelliJ IDEA
- Android SDK 33/34/35
- Supabase 账号
- Deepseek API Key

## 安装说明
1. 克隆项目
```bash
git clone [repository-url]
cd abysspath
```

2. 安装依赖
```bash
flutter pub get
# 如果修改了模型，需要运行代码生成
flutter pub run build_runner build --delete-conflicting-outputs
```

3. 配置环境变量
   - **前端**: 在项目根目录创建 `.env` 文件并配置 Supabase 相关变量 (如果应用需要直接访问):
     ```
     SUPABASE_URL=your_supabase_url
     SUPABASE_ANON_KEY=your_supabase_anon_key
     ```
   - **后端**: 在 `backend` 目录下创建 `.env` 文件并配置：
     ```
     SUPABASE_URL=your_supabase_url
     SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
     DEEPSEEK_API_KEY=your_deepseek_api_key
     DATABASE_URL="postgresql://postgres:[YOUR-PASSWORD]@db.[your-ref].supabase.co:5432/postgres" # 替换为你的数据库连接串
     ```

4. 运行后端服务
```bash
cd backend
# (可选) 设置 NO_PROXY 环境变量，如果使用代理
# $env:NO_PROXY = "[your-ref].supabase.co,127.0.0.1,localhost"
python -m venv venv
# Windows
.\venv\Scripts\activate
# macOS/Linux
# source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

5. 运行前端项目
```bash
flutter run
```

## 项目结构
```
├── backend/            # 后端 FastAPI 应用
│   ├── .env            # 后端环境变量
│   ├── main.py         # FastAPI 入口
│   ├── models/         # Pydantic 模型
│   ├── repositories/   # 数据库交互
│   ├── routers/        # API 路由
│   ├── services/       # 业务逻辑服务
│   └── requirements.txt # Python 依赖
├── lib/                # Flutter 应用核心代码
│   ├── core/           # 核心功能 (主题, 路由, 工具, 公共组件等)
│   ├── features/       # 功能模块 (认证, 评估, 学习路径, 个人中心)
│   ├── main.dart       # Flutter 入口
│   └── .env            # (可选) 前端环境变量
├── test/               # 测试代码
└── README.md           # 本文件
```

## 开发规范
1. 代码风格
   - 使用 Flutter 官方推荐的代码风格
   - 遵循 clean architecture 原则
   - 使用 Riverpod 进行状态管理
   - 使用 GoRoute 进行路由管理
   - 实现适当的错误处理和边界情况
   - 保持组件小而专注
   - 优先使用 const 构造函数
   - 实现适当的性能优化

2. 提交规范
   - feat: 新功能
   - fix: 修复问题
   - docs: 文档变更
   - style: 代码格式
   - refactor: 代码重构
   - test: 测试相关
   - chore: 其他修改

## 贡献指南
1. Fork 项目
2. 创建特性分支
3. 提交修改
4. 发起 Pull Request

## 版本历史
- v0.1.0 (2024-03-20)
  - 初始版本发布
  - 基础功能实现
  - 用户认证系统
  - AI 评估功能
  - 学习路径生成

- v0.2.0 (2024-03-25)
  - 新增个人中心功能
  - 优化评估流程
  - 添加路径历史管理
  - 改进错误处理
  - 优化用户界面
  - 添加数据持久化
  - 实现路径分享功能

- v0.2.1 (已完成)
  - **实现多轮对话评估**: 前后端支持多轮对话历史传递。
  - **修复智能追问**: 解决 AI 生成的追问问题无法在前端显示的 Bug。
  - **增强错误处理**: 优化前后端错误传递和展示逻辑。
  - **API 超时调整**: 增加后端调用 AI 服务的超时时间。
  - **修复用户画像同步问题**: 
    - **问题**: 旧方案尝试将 AI 评估数据直接合并到主 `profiles` 表，因数据结构不匹配和字段映射问题导致更新失败。
    - **解决方案**: 新建 `assessment_profiles` 表专门存储 AI 生成的原始 JSON 画像。使用 Supabase 数据库触发器和函数，在每次评估交互后异步解析 AI 回复并 `UPSERT` 最新画像到新表，确保数据隔离和更新及时性。
  - **新增功能**: 添加 AI 评估结果展示页面 (`AssessmentResultPage`)，用于显示 `assessment_profiles` 表中的画像数据。
  - **依赖和构建修复**: 解决了 `freezed`, `riverpod_generator` 等代码生成库的版本冲突和 Linter 错误。

- v0.3.0 (当前版本)
  - **学习路径核心功能**: 
    - 后端实现 AI (Deepseek) 生成学习路径，包含节点、边和资源，存入 Supabase。
    - 前端实现路径获取、状态管理 (Riverpod) 和详情展示 (`LearningPathDetailPage`)。
  - **知识图谱可视化**: 使用自定义 Canvas 和 `InteractiveViewer` 实现交互式图谱展示 (`KnowledgeGraphView`)。
  - **模型与数据处理**: 升级模型以支持节点/边结构，处理元技能/影响力类型，关联学习资源。
  - **调试与健壮性**: 
    - 解决了后端通过代理连接 Supabase 时的 SSL 错误 (需配置 `NO_PROXY`)。
    - **前端 API 响应处理修复**: 解决了前端在调用创建学习路径接口时，因预期返回数据结构与后端实际返回不符（期望完整对象 vs 实际简单JSON），导致的 `type 'Null' is not a subtype of type 'String'` 错误。通过修改 `LearningPathService` 直接使用 Dio 处理该请求并解析响应中的 `learning_path_id` 来修复。
    - **物理设备连接后端**: 解决了物理手机无法连接本地开发后端的问题，通过在构建 APK 时使用 `--dart-define` 指定开发电脑的局域网 IP 地址作为 `BASE_URL` 来解决。
  - **UI 优化**: 
    - 改进学习路径详情页面的布局和交互。
    - 优化评估结果页面 (`AssessmentResultPage`) 的视觉效果。

## 许可证
MIT License
