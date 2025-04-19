# 用户资料 (Profile) 特性模块

此模块负责管理用户的核心资料信息，包括显示和更新。

## 目录结构

*   **models/**: 定义用户资料相关的数据模型 (例如 `Profile` 类)。
*   **pages/**: 包含用户资料相关的 UI 页面 (例如 `profile_page.dart` 用于显示和编辑资料)。
*   **providers/**: 包含用于管理用户资料状态的 Riverpod Provider (例如 `ProfileNotifier`)。
*   **services/**: 包含与用户资料相关的业务逻辑和数据获取/持久化操作 (例如 `ProfileService`)。
*   **widgets/**: 包含此模块特有的、可复用的 UI 组件。

## 说明

该模块遵循了较清晰的分层结构，用于处理用户基础信息的展示和管理。 