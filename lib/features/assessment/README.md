# Assessment 评估模块

## 功能说明
- **多轮对话评估**: 通过与 AI 进行多轮对话来评估用户能力。
- **智能追问**: AI 根据对话上下文生成相关追问问题。
- 能力评估测试 (通过对话进行)
- 测试结果分析 (集成在对话反馈和最终报告中)
- 评估报告生成 (待实现)
- 历史记录查看与管理
- 评估建议 (通过对话反馈和报告提供)

## 目录结构
- data/
  - datasources/  # 数据源
  - models/       # 数据模型
  - repositories/ # 仓库实现
- domain/
  - entities/     # 实体 (较少使用，业务逻辑主要在 Provider)
  - repositories/ # 仓库接口 (较少使用，业务逻辑主要在 Provider)
  - usecases/     # 用例 (较少使用，业务逻辑主要在 Provider)
- providers/      # 状态管理 (Riverpod)
- pages/        # 页面
- services/     # 服务层 (封装业务逻辑和 API 调用)
- widgets/      # 评估模块特定的组件 