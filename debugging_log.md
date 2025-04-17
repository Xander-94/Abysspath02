 # 调试日志与解决方案

本文档记录了在开发 abysspath02 应用过程中遇到的主要问题及其解决方案。

## 1. 问题：提交问卷时出现 `PostgresException: duplicate key value violates unique constraint "response_details_response_id_question_id_key"`

*   **现象**: 在 Flutter 应用中提交（更新）问卷答案时，数据库抛出唯一键冲突错误。
*   **初步分析**: 错误发生在尝试向 `response_details` 表插入数据时，表明 `(response_id, question_id)` 组合已存在。
*   **解决方案探索**:
    *   **尝试 1 (Upsert/删除)**: 考虑使用 `upsert` 或在插入新数据前先删除旧数据。创建了一个 PostgreSQL 函数 `update_response_details` 来原子化地处理删除和插入操作。
    *   **尝试 2 (日志)**: 为了调试函数行为，尝试在函数内部添加 `RAISE NOTICE` 日志。但 Supabase Dashboard 中的日志级别限制和潜在的事务回滚导致日志信息不完整。
    *   **尝试 3 (独立日志表)**: 创建了一个独立的 `debug_log` 表和一个 `SECURITY DEFINER` 函数 `log_debug_message`，以便在独立事务中记录日志，避免主事务回滚影响。这帮助确认了错误发生在 `INSERT` 语句，但未能解决根本的重复键问题（调试重点后续转移）。
*   **关键**: 虽然重复键的根本原因未在对话中完全解决（焦点转移），但创建独立日志函数是调试事务性问题的有效手段。

## 2. 问题：调用 `ProfileNotifier` 方法时出现 `NoSuchMethodError: Class 'ProfileNotifier' has no instance method 'getProfile'.`

*   **现象**: 在 `portrait_page.dart` 中调用 `ref.read(app.profileProvider.notifier).getProfile()` 失败。
*   **原因**: `ProfileNotifier` 类中实际获取 Profile 的方法被命名为 `loadProfile()` 而不是 `getProfile()`。
*   **解决方案**: 将 `portrait_page.dart` 中的所有 `getProfile()` 调用修改为 `loadProfile()`。

## 3. 问题：用户画像页面出现 `StateNotifierListenerError: Tried to modify a provider while the widget tree was building`

*   **现象**: 在 `PortraitPage` 的 `initState`, `didChangeDependencies` 或 `didChangeAppLifecycleState` 等生命周期方法中直接调用 `ref.read(app.profileProvider.notifier).loadProfile()` 导致状态更新冲突。
*   **原因**: Flutter 和 Riverpod 不允许在 Widget 构建或生命周期方法执行期间同步修改 Provider 状态。
*   **解决方案**:
    *   使用 `Future.microtask(() { ... });` 将 `loadProfile()` 调用延迟到当前构建帧之后执行。
    *   在 `didChangeDependencies` 中添加 `_isFirstBuild` 标志，确保初始加载只执行一次。
    *   在 `didChangeAppLifecycleState` 的 `AppLifecycleState.resumed` 分支中同样使用 `Future.microtask`。

## 4. 问题：提交问卷后，用户画像页面 "学习人格" 字段仍显示 "未设置"

*   **现象**: 即使用户在问卷中明确回答了学习人格问题（例如 "ISTP"），用户画像页面刷新后依然显示旧状态或 "未设置"。数据库 `response_details` 表中确认存在最新的正确答案。
*   **初步分析**:
    *   `ProfileService.getProfile()` 在处理 `readableSurveyData` 时未能正确映射学习人格字段。-> 通过日志确认映射逻辑本身没错，但 Map 中缺少对应的键。
    *   数据库 `questions` 表中的问题文本与代码中硬编码的键不符。-> 通过查询数据库确认文本匹配。
    *   `ProfileService.getProfile()` 在未指定 `responseId` 时，查找"最新"问卷的逻辑存在问题。
*   **深入分析 (核心原因)**: 在问卷提交 (`SurveyProvider.submitResponse`) 成功后，立即触发 `ProfileNotifier.loadProfile()` (通过 `invalidate` 或 `refresh`) 时，数据库的写操作（新问卷数据）对于 `ProfileService` 随后执行的读操作（查找最新问卷）可能由于事务隔离级别或微小的同步延迟而**不可见**。导致 `getProfile()` 仍然读取到**旧的**问卷 `response_id`，从而无法获取最新的学习人格答案。
*   **解决方案尝试**:
    *   在 `SurveyProvider` 的 `finally` 块中添加 `Future.delayed` 再 `invalidate`。(失败)
    *   将 `invalidate` 替换为 `refresh`。(失败)
*   **最终解决方案 (成功)**:
    1.  **修改 `ProfileService.getProfile`**: 添加可选参数 `targetResponseId`。如果提供此 ID，则直接使用它查询 `response_details`，跳过查找最新问卷的步骤。
    2.  **修改 `ProfileNotifier`**: 添加新方法 `loadProfileFromResponse(String responseId)`，内部调用 `profileService.getProfile(targetResponseId: responseId)`。
    3.  **修改 `SurveyProvider.submitResponse`**:
        *   在问卷提交成功后（RPC 调用/数据插入/更新完成），获取本次操作**实际使用**的 `responseId`。
        *   **直接调用** `ref.read(profileProvider.notifier).loadProfileFromResponse(finalResponseId)`，使用确定的 ID 更新 Notifier 状态。
        *   **关键补充**: 在 `loadProfileFromResponse` 调用成功后，**立即**读取 `profileProvider` 的最新状态，并调用 `profileService.updateProfile()` 将这个包含正确结构化数据（含学习人格）的 Profile 对象**保存回数据库 `profiles` 表**。
        *   移除 `finally` 块中的 `invalidate`/`refresh` 调用。
*   **效果**: 这样既保证了提交后应用状态的即时更新（通过 `loadProfileFromResponse`），也保证了数据库基础 Profile 数据的持久化更新，使得后续即使普通的 `loadProfile()` 遇到读延迟问题，也能从 `profiles` 表读到正确的结构化数据。

## 5. 问题：实现多轮对话时 Provider 状态管理出错

*   **现象**: 在为对话评估添加多轮交互能力后，相关的 Riverpod Provider (例如 `DialogueAssessmentProvider`) 出现 Linter 错误或状态更新逻辑不正确。
*   **原因**: Provider 未能正确处理和存储符合 DeepSeek API 要求的对话历史消息列表。
*   **解决方案**: 修改 Provider 的状态结构以包含 `List<Map<String, String>>` (或其他符合 API 的结构) 来存储对话历史，并更新 Provider 方法以正确地添加用户和模型的发言，确保传递给 Service 层的数据格式正确。

## 6. 问题：依赖更新后出现版本冲突

*   **现象**: 运行 `flutter pub upgrade` 后，提示某些传递性依赖项存在版本冲突，无法自动解决。
*   **原因**: 项目直接依赖的包可能间接依赖了不同版本的同一个库，或者 `pubspec.yaml` 中的版本约束过于严格或存在矛盾。
*   **解决方案**: 
    *   运行 `flutter pub outdated` 分析过时的依赖及其传递关系。
    *   根据分析结果，谨慎调整 `pubspec.yaml` 中的版本约束 (例如放宽或指定特定兼容版本)。
    *   在某些情况下，可能需要等待库作者更新或寻找替代库。

## 7. 问题：需要撤销 Git 提交

*   **场景**: 代码提交后发现问题，需要回退到之前的状态。
*   **解决方案**: 
    *   **保留更改，仅撤销提交**: `git reset --soft HEAD~1` (将上次提交的更改放回暂存区)。
    *   **彻底丢弃更改，完全恢复**: `git reset --hard HEAD~1` (警告：此操作会丢失上次提交之后的所有本地更改)。

## 8. 问题：Flutter 应用无法加载 `.env` 环境变量

*   **现象**: 应用启动时无法读取 `.env` 文件中定义的配置（如 API密钥）。
*   **原因**: `main.dart` 中缺少初始化加载 `.env` 文件的逻辑，或者加载时机不当。
*   **解决方案**: 在 `main()` 函数的早期阶段（例如 `runApp()` 之前），使用 `flutter_dotenv` 包提供的 `dotenv.load()` 方法加载环境变量，并添加必要的错误处理。

## 9. 问题：后端 FastAPI 服务启动失败或 API 调用出错

*   **现象**: 后端服务无法启动，或者前端调用后端接口/后端调用外部 API (如 Deepseek) 时失败。
*   **原因**: 可能包括端口冲突、依赖缺失、代码错误 (如请求格式、认证方式不正确)、网络问题、API 密钥错误等。
*   **解决方案**: 
    *   检查后端服务的启动日志，定位具体错误信息。
    *   确认 API 请求的 URL、方法、Header、Body 格式是否符合接口文档要求。
    *   检查 API 密钥或认证 Token 是否正确配置和传递。
    *   修改后端服务代码（如 Python FastAPI 中的 Service 类），调整数据处理和 API 调用逻辑。
    *   重启后端服务以应用代码更改。

## 10. 问题：需要设计数据库表来存储历史记录

*   **场景**: 需要持久化存储如对话评估、用户行为等历史数据。
*   **解决方案**: 
    *   设计数据库表结构（例如为 `assessment_history` 设计包含 `user_id`, `session_id`, `message_content`, `role`, `timestamp` 等字段）。
    *   编写 SQL 迁移脚本，使用 `CREATE TABLE` 语句定义表、字段类型、主键、外键、索引等。
    *   根据需要，使用 `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` 和 `CREATE POLICY` 为表配置行级安全策略，确保用户只能访问自己的数据。
