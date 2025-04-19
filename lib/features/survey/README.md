# 问卷调查 (Survey) 特性模块

此模块负责处理应用内的问卷调查功能，包括问卷的显示、填写、提交以及结果的处理。

## 目录结构

*   **models/**: 定义问卷、问题、答案等相关的数据模型。
*   **pages/**: 包含问卷调查相关的 UI 页面 (例如 `survey_page.dart`)。
*   **presentation/**: (可能包含 UI 表示层逻辑，但在此项目中似乎与 `pages` 和 `widgets` 合并)。
*   **providers/**: 包含用于管理问卷状态和提交逻辑的 Riverpod Provider (例如 `SurveyProvider`)。
*   **services/**: 包含问卷数据获取、答案提交等业务逻辑 (例如 `SurveyService`)。
*   **widgets/**: 包含问卷模块特有的、可复用的 UI 组件 (例如不同类型问题的 Widget)。

## 说明

该模块负责完整的问卷流程，从展示问题到提交答案，并可能触发后续的用户画像更新。 