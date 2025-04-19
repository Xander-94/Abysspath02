# Auth 认证模块

## 功能说明
- 用户注册
- 用户登录
- 密码重置
- 邮箱验证
- 个人信息管理 (部分可能与 Profile 模块联动)

## 目录结构 (当前简化结构)
*   **models/**: 定义认证相关的数据模型 (例如用户、认证响应等)。
*   **pages/**: 包含认证流程相关的 UI 页面 (例如登录页 `login_page.dart`、注册页 `register_page.dart`)。
*   **providers/**: 包含管理认证状态和逻辑的 Riverpod Provider (例如 `AuthProvider`)。
*   **services/**: 包含处理认证请求、与后端或 Supabase Auth 交互的服务 (例如 `AuthService`)。
*   **widgets/**: 包含认证模块特有的、可复用的 UI 组件。

## 说明
负责用户身份验证和会话管理的核心模块。 