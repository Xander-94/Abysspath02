# 测试目录

本目录包含应用程序的所有测试用例，遵循Flutter测试最佳实践。

## 目录结构

```
test/
├── unit/           # 单元测试
│   ├── core/       # 核心功能测试
│   └── features/   # 功能模块测试
├── widget/         # Widget测试
│   ├── core/       # 共享组件测试
│   └── features/   # 功能组件测试
└── integration/    # 集成测试
    └── features/   # 功能模块集成测试
```

## 测试规范

### 单元测试 (unit/)
- 测试独立的业务逻辑
- 测试数据模型转换
- 测试工具函数
- 测试状态管理
- 使用mockito模拟依赖

### Widget测试 (widget/)
- 测试UI组件渲染
- 测试用户交互
- 测试状态更新
- 测试动画效果
- 使用flutter_test框架

### 集成测试 (integration/)
- 测试完整功能流程
- 测试页面导航
- 测试数据持久化
- 测试网络请求
- 使用integration_test框架

## 命名规范

- 测试文件：`{被测试文件名}_test.dart`
- 测试组：`group('被测试类名', () {...})`
- 测试用例：`test('should 预期行为 when 条件', () {...})`

## 编写建议

1. 遵循AAA模式：Arrange(准备) -> Act(执行) -> Assert(断言)
2. 每个测试用例只测试一个行为
3. 使用有意义的测试描述
4. 适当使用setUp和tearDown
5. 保持测试代码的可维护性 