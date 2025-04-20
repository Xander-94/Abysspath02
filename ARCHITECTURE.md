# AbyssPath02 项目架构设计文档

**版本**: 1.0 (初步完成版)
**日期**: 2025年04月19日

## 1. 引言

### 1.1 项目背景与目标
AbyssPath02 项目旨在构建一个个性化的智能学习路径规划与引导系统。核心目标是根据用户的评估结果（包括问卷调查和对话式评估）以及个人资料，利用人工智能技术生成定制化的学习计划，并通过可视化的方式呈现给用户，辅助其实现特定的学习或发展目标。

### 1.2 架构概述
为实现上述目标，项目采用了现代化的前后端分离架构。前端负责用户交互与展示，后端负责业务逻辑处理、数据持久化及与第三方 AI 服务集成。数据库选用 Supabase（PostgreSQL），利用其提供的后端即服务 (BaaS) 能力简化开发。整体架构注重模块化、可扩展性和可维护性。

## 2. 系统架构

系统主要由以下几个部分组成：

*   **前端应用 (Flutter)**: 基于 Flutter 框架构建的跨平台移动应用程序，提供用户界面 (UI)、用户体验 (UX) 管理以及与后端服务的交互。
*   **后端服务 (Python/FastAPI)**: 基于 FastAPI 框架构建的 API 服务，负责处理核心业务逻辑，包括用户管理、评估处理、学习路径生成调度、数据库访问控制等。
*   **数据库 (Supabase/PostgreSQL)**: 作为系统的核心数据存储，管理用户信息、问卷数据、评估结果、学习路径结构（节点、边、资源）等。利用 Supabase 进行用户认证和数据行级安全 (RLS) 控制。
*   **AI 服务 (Deepseek API)**: 作为外部智能服务，接收来自后端的请求（如用户目标、画像信息），生成个性化的学习路径建议或进行对话式评估分析。

*(可选建议：在论文中，此处可配上一张简洁的系统架构图，展示各组件间的交互关系)*

## 3. 技术栈选型

| 层面   | 技术/框架                | 选用理由                                                                 |
| :----- | :----------------------- | :----------------------------------------------------------------------- |
| **前端** | Flutter 3.x              | 高性能跨平台 UI 工具包，支持快速开发和丰富的组件生态。                   |
|        | Riverpod                 | 可扩展、类型安全的状态管理和依赖注入解决方案，适用于 Flutter。           |
|        | GoRouter                 | 官方推荐的声明式路由解决方案，简化导航逻辑。                             |
|        | Dio                      | 功能强大的 HTTP 客户端库，支持拦截器、请求取消等高级功能。               |
|        | Freezed                  | 代码生成库，用于创建不可变数据模型，减少样板代码并提高类型安全。         |
|        | flutter_dotenv           | 用于管理环境变量，分离配置与代码。                                       |
| **后端** | Python 3.x               | 语法简洁，拥有丰富的库生态，特别是在 AI 和数据科学领域。                 |
|        | FastAPI                  | 高性能、易于使用的现代 Python Web 框架，自带数据验证和异步支持。         |
|        | Pydantic                 | 基于类型注解的数据验证库，与 FastAPI 深度集成，保证 API 接口的健壮性。 |
|        | Supabase Python Client   | 用于与 Supabase 数据库和认证服务进行交互。                               |
|        | Uvicorn                  | 高性能 ASGI 服务器，用于运行 FastAPI 应用。                              |
| **数据库** | Supabase (PostgreSQL)    | 提供集成的认证、数据库、存储等后端服务，加速开发；基于强大的 PostgreSQL。 |
| **AI服务** | Deepseek API             | 提供符合项目需求的自然语言处理和内容生成能力。                           |

## 4. 模块化设计

### 4.1 前端模块划分 (基于特性)
前端代码库遵循基于特性的模块化组织方式 (`lib/features/`)，主要模块包括：

*   **Auth (认证)**: 处理用户注册、登录、会话管理。
*   **Home (首页)**: 应用入口，可能包含概览信息和功能导航。
*   **Profile (用户资料)**: 显示和管理用户的基本信息及生成的画像数据。
*   **Survey (问卷)**: 实现问卷的展示、填写和提交逻辑。
*   **Assessment/Portrait (评估与画像)**: 处理问卷/对话评估，与 AI 服务交互生成用户画像。
*   **Learning Path (学习路径)**: 核心模块，负责路径的创建请求、历史记录管理、消息交互及详情（含图谱）展示。
*   **Widgets (共享组件)**: 存放跨特性模块复用的 UI 组件。
*   **Core (核心)**: 包含应用级配置、主题、工具类、网络请求封装等基础支持。

此结构提高了代码的可读性、可维护性，并降低了模块间的耦合度。

### 4.2 后端架构分层
后端服务采用分层架构，主要包括：

*   **路由层 (Routers)**: 定义 API 端点，处理 HTTP 请求和响应，调用服务层。
*   **服务层 (Services)**: 封装核心业务逻辑，协调不同组件（如仓库、AI 服务）完成任务。
*   **仓库层 (Repositories)**: 负责与数据库的交互，封装数据访问逻辑 (CRUD 操作)。
*   **模型层 (Models)**: 使用 Pydantic 定义数据结构和验证规则。

## 5. 核心功能模块实现概述

### 5.1 评估与画像模块 (Assessment & Portrait)

此模块旨在通过多种评估方式形成对用户能力、特质及偏好的结构化理解，即用户画像，并将其应用于后续的个性化服务中。

*   **数据收集**:
    *   **问卷评估**: 通过 `Survey` 模块提供动态问卷。用户提交答案后，`SurveyProvider` 调用后端服务或直接写入数据库 `responses` 和 `response_details` 表。
    *   **对话式评估**: (未来扩展或部分实现) 通过特定对话流程引导用户深入探讨，收集更丰富的定性信息。相关交互数据可能存储于 `assessment_interactions` 或类似表中。
*   **AI 分析与画像生成**:
    *   **触发机制**: 画像生成可以由问卷提交成功后触发，或在对话式评估结束后进行。
    *   **异步处理 (针对评估)**: 为避免阻塞用户操作，项目采用了数据库触发器方案 (`trigger_extract_profile_on_interaction_insert`)。当包含 AI 分析结果的新记录插入 `assessment_interactions` 表时，触发器调用 `SECURITY DEFINER` 函数 (`extract_and_upsert_assessment_profile`)。
    *   **画像提取与持久化**: 该数据库函数负责从 `ai_response` (JSON 格式) 中提取结构化的画像数据，并将其 `UPSERT` 到 `assessment_profiles` 表中，关联相应的用户 ID。
*   **画像整合与应用**:
    *   `ProfileService` 在获取用户完整 Profile (`getProfile`) 时，会尝试关联查询 `assessment_profiles` 表中的最新画像数据，并将其整合到最终返回给前端的 `Profile` 对象中。
    *   解决数据同步延迟：为确保问卷提交后 Profile 能立即反映最新评估结果，`SurveyProvider` 在提交成功后，不再依赖可能存在延迟的数据库视图刷新，而是直接调用 `ProfileNotifier` 的特定方法 (`loadProfileFromResponse`)，强制使用本次提交的 `responseId` 来加载包含最新评估细节的 Profile，并调用 `ProfileService.updateProfile` 将此整合后的 Profile 更新回 `profiles` 主表。

### 5.2 学习路径模块 (Learning Path)

此模块是系统的核心功能，实现了从个性化路径生成到可视化展示的完整流程。

1.  **路径生成请求 (Frontend -> Backend)**:
    *   用户在 `LearningPathPage` 的聊天界面输入学习目标 (`userGoal`)。
    *   `LearningPathNotifier` 捕获输入，并调用 `ProfileNotifier` 获取当前用户的 Profile 数据（包含基础信息和可能的 AI 评估画像），将其序列化为 `userProfileJson`。
    *   构造 `LearningPathCreateRequest` 对象，包含 `userGoal` 和 `userProfileJson`。
    *   通过 `LearningPathService` 和 `LearningPathApiService` 调用后端 POST `/api/learning-paths/` 端点。
2.  **AI 调用与数据处理 (Backend)**:
    *   `learning_path_router` 接收请求，调用 `LearningPathService` (后端)。
    *   后端 `LearningPathService` 进一步调用 `DeepseekService`，构造包含用户目标、画像信息以及预定义结构化输出要求的 Prompt。
    *   `DeepseekService` 向 Deepseek API 发送请求，获取包含学习路径结构（标题、描述、节点、边、资源）的 JSON 响应。
    *   后端 `LearningPathService` 解析 AI 返回的 JSON。`LearningPathRepository` 负责将解析后的数据进行原子性写入：
        *   首先向 `learning_paths` 表插入路径元数据。
        *   然后，为返回的每个节点、边和资源对象**显式赋上**刚创建的 `learning_paths` 记录的 `path_id`。
        *   最后，**批量插入**到 `path_nodes`, `path_edges`, 和 `node_resources` 表中。同时，向 `learning_path_messages` 表插入一条用户消息（目标）和一条助手确认消息（标记 `is_creation_confirmation=true`）。
    *   利用 Pydantic 模型在数据传入仓库层前进行严格校验，确保数据类型和枚举值（如资源类型）的有效性。
    *   通过 `retry_on_timeout` 装饰器和统一的 `_execute_db_operation` 方法处理数据库操作的潜在超时和网络错误。
3.  **前端状态更新与展示 (Frontend)**:
    *   API 调用成功 (201 Created) 后，`LearningPathNotifier` 执行**乐观更新**:
        *   不再立刻请求完整历史列表，而是手动构造一个包含新路径 ID 和标题（从用户目标截取）的列表项 `newPathListItem`。
        *   将此 `newPathListItem` 添加到 `state.conversations` 列表的开头。
        *   构造初始的用户消息和助手确认消息（含 `is_creation_confirmation=true` 标记）更新 `state.messages`。
        *   使用更新后的 `conversations` 和 `messages` 更新 Notifier 状态。
    *   `LearningPathPage` 通过 `ref.watch` 监听到状态变化，聊天面板 (`_buildChatPanel`) 显示初始消息，`ChatMessageWidget` 根据 `is_creation_confirmation` 标记显示"查看详情"按钮。历史记录抽屉 (`_buildHistoryDrawer`) 也因 `conversations` 列表更新而立即显示新路径条目。
4.  **历史记录与消息加载 (Frontend)**:
    *   `LearningPathPage` 在 `initState` 时调用 `loadConversations`，`LearningPathService.getHistoryPaths` 从**正确的 `learning_paths` 表**获取用户历史路径列表（包含真实标题）。
    *   用户在 Drawer 中点击历史路径项时，触发 `LearningPathNotifier.selectPath(pathId)`。
    *   `selectPath` 调用 `LearningPathService.getPathMessages(pathId)`，该方法从 `learning_path_messages` 表 `SELECT` 包含 `is_creation_confirmation` 在内的所有消息字段。RLS 策略确保了用户只能读取属于自己路径的消息。
    *   获取到消息后，更新 `state.messages` 和 `state.currentPathId`，触发 `_buildChatPanel` 重新渲染，显示选中路径的消息历史。
5.  **路径详情与可视化 (Frontend)**:
    *   用户点击"查看详情"按钮或通过其他方式导航至 `LearningPathDetailPage`。
    *   `LearningPathDetailPage` 在初始化时调用 Provider 获取 `pathId`，然后调用 `LearningPathService.getFullLearningPath(pathId)`。
    *   `getFullLearningPath` 通过 `LearningPathApiService` 调用后端 GET `/api/learning-paths/{pathId}` 端点，获取包含完整路径、节点、边、资源数据的 `FullLearningPathResponse`。
    *   页面使用 `DefaultTabController` 和 `TabBar` 创建"知识图谱"和"节点列表"两个 Tab。
    *   **知识图谱视图 (`KnowledgeGraphView`)**:
        *   接收节点 (`nodes`) 和边 (`edges`) 数据。
        *   使用 `graphview` 包创建 `Graph` 对象。
        *   遍历节点数据创建 `Node` 对象，并根据节点类型应用不同的样式（通过 `KnowledgeGraphNodeWidget` 实现）。
        *   遍历边数据，根据 `sourceNodeId` 和 `targetNodeId` 查找对应的 `Node` 对象，创建 `graph.addEdge()`。
        *   使用 `BuchheimWalkerConfiguration` 配置树状布局算法。
        *   将 `GraphView` Widget 嵌入到 `InteractiveViewer` 中，实现缩放和平移。
    *   **节点列表视图**: 使用 `ListView.builder` 简单地遍历节点数据，展示每个节点的 `label`, `type`, `details` 等信息。

## 6. 关键技术实现与挑战应对

在项目开发过程中，采用并解决了一系列关键技术问题：

*   **API 接口设计规范**: 遵循 RESTful 设计原则，确保接口语义清晰、资源命名规范、请求与响应结构（利用 Pydantic 模型）明确。采用版本控制 (`/api/v1/...`) 和统一的错误处理机制，提高了接口的可维护性和前后端协作效率。
*   **大模型提示词工程优化**: 针对学习路径生成等核心 AI 功能，设计并迭代优化了向 Deepseek 等大模型发送的提示词 (Prompt)。重点在于结构化 Prompt 以引导模型输出稳定、可解析的 JSON 格式，并有效融入用户画像、学习目标等个性化上下文信息，同时根据实际输出效果持续调整 Prompt 细节以提升生成内容的准确性和相关性。
*   **前端状态管理**: 利用 Riverpod 的 `StateNotifierProvider` 对各特性模块的状态进行封装和管理。通过"乐观更新"模式优化用户体验，在执行耗时操作（如创建学习路径）时即时更新 UI，避免了不必要的等待。通过 `Future.microtask` 解决了在 Widget 生命周期方法中直接修改 Provider 状态引发的冲突。 *(参考: debugging_log.md #3, #4, #19)*
*   **异步流程协调**: 对涉及多异步步骤的操作（如问卷提交后更新用户画像）进行了细致处理，通过显式传递关键 ID (`responseId`) 并直接调用目标 Provider 的更新方法，解决了因数据库读写延迟导致的视图状态与数据不一致问题。 *(参考: debugging_log.md #4)*
*   **API 设计与通信**: 后端使用 FastAPI 快速构建类型安全的 API 接口，利用 Pydantic 进行请求体验证。前端使用 Dio 进行网络请求，并通过封装 Provider (如 `DioProvider`) 统一管理网络配置和拦截器。
*   **数据库交互与安全**: 后端通过 `supabase-py` 与数据库交互，解决了 Python 异步库与部分同步数据库操作的兼容性问题，并添加了重试机制应对网络波动。前端直接与 Supabase 交互的部分（如读取消息、历史列表），严格依赖数据库的行级安全 (RLS) 策略来保障数据隔离与安全。开发中重点调试并修正了 RLS 策略的目标角色和 `USING` 条件。 *(参考: debugging_log.md #13, #19)*
*   **AI 服务集成**: 封装了对 Deepseek API 的调用逻辑。在开发中遇到了 AI 返回数据与后端模型定义不匹配的问题（如非预期的资源类型），通过扩展后端 Pydantic 模型的验证规则得以解决。 *(参考: debugging_log.md #19)*
*   **数据持久化与一致性**: 对于评估画像等异步生成的数据，采用了数据库触发器 (`SECURITY DEFINER` 函数) 的方式确保数据能被可靠地写入目标表，解决了因权限问题导致的写入失败。 *(参考: debugging_log.md #11)*
*   **代码生成与构建**: 解决了因依赖版本冲突（如 `freezed` 与 `riverpod_generator`）导致 `build_runner` 无法正常生成代码的问题，通过调整 `pubspec.yaml` 中的版本约束恢复了代码生成流程。 *(参考: debugging_log.md #12)*
*   **调试策略**: 综合运用前端日志、后端日志、数据库日志（包括创建独立日志表）、网络请求检查以及详细堆栈跟踪分析，定位并解决了多处涉及前后端、数据库和 AI 服务交互的复杂问题。详细记录见 `debugging_log.md`。 *(参考: debugging_log.md #1, #18)*

## 7. 结论与展望

AbyssPath02 项目当前已完成核心功能的初步实现，包括基于评估的个性化学习路径生成、存储、展示和可视化。前后端分离的架构、模块化的设计以及所选技术栈为系统的稳定性和未来扩展奠定了良好基础。

未来可考虑的优化与扩展方向包括：

*   实现更复杂的推荐引擎逻辑。
*   丰富学习路径的可视化交互方式。
*   构建更独立的知识库模块。
*   引入单元测试和集成测试，提高代码质量。
*   对 AI Prompt 进行持续优化，提升生成路径的质量和多样性。
*   性能优化，特别是在处理大规模学习路径数据时。 