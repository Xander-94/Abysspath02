import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abysspath02/core/providers/app_providers.dart' as app;
import '../../../profile/providers/profile_notifier.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../profile/models/profile.dart';
import '../../../profile/models/competency.dart';
import '../../../profile/models/interest_graph.dart';
import '../../../profile/models/behavior.dart';
import '../../../profile/models/constraints.dart';
import '../../../profile/models/dynamic_flags.dart';

/// 用户画像页面 (Stateful to handle lifecycle)
class PortraitPage extends ConsumerStatefulWidget {
  const PortraitPage({super.key});

  @override
  ConsumerState<PortraitPage> createState() => _PortraitPageState();
}

class _PortraitPageState extends ConsumerState<PortraitPage> with WidgetsBindingObserver {
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    print('[_PortraitPageState] initState called');
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    print('[_PortraitPageState] dispose called');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('[_PortraitPageState] didChangeDependencies called');
    if (_isFirstBuild) {
      _isFirstBuild = false;
      Future.microtask(() {
        if (mounted) ref.read(app.profileProvider.notifier).loadProfile();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('[_PortraitPageState] didChangeAppLifecycleState called with state: $state');
    if (state == AppLifecycleState.resumed) {
      print('[_PortraitPageState] App resumed - Triggering refresh');
      Future.microtask(() {
        if (mounted) ref.read(app.profileProvider.notifier).loadProfile();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('[_PortraitPageState] build called');
    final profileState = ref.watch(app.profileProvider);
    print('[_PortraitPageState] Watched profileState: $profileState');

    return AppScaffold(
      title: '用户画像',
      showBottomNav: true,
      body: _buildBody(context, profileState),
    );
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.profile == null) { 
      return Center(child: Text('错误: ${state.error}'));
    }
    if (state.profile == null) {
      return const Center(child: Text('未找到用户画像信息'));
    }

    final profile = state.profile!;                   
    final theme = Theme.of(context);


     return ListView(                             
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionTitle(context, '基本信息'),
        _buildInfoItem('用户名', profile.name),
        _buildInfoItem('邮箱', profile.email),
        const Divider(height: 24),

        _buildCompetencySection(context, profile.competency, profile.dynamicFlags),
        const Divider(height: 24),

        _buildInterestSection(context, profile.interestGraph),
        const Divider(height: 24),
        
        _buildBehaviorSection(context, profile.behavior),
        const Divider(height: 24),

        _buildConstraintsSection(context, profile.constraints),
        if (state.error != null) 
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text('部分画像数据加载可能存在问题: ${state.error}', style: TextStyle(color: theme.colorScheme.error)),
            ),
      ],
    );
  }

  // --- 构建辅助方法 ---

  /// 构建区块标题
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  /// 构建单条信息项 (处理空值)
  Widget _buildInfoItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text('$label: ${value ?? '未设置'}'),
    );
  }

  /// 构建列表信息项 (处理空列表和空值)
  Widget _buildInfoList(String label, List<String>? values) {
    final displayValue = (values == null || values.isEmpty) 
        ? '未设置' 
        : values.join(', ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text('$label: $displayValue'),
    );
  }

  /// 构建能力与目标区块
  Widget _buildCompetencySection(BuildContext context, Competency? competency, DynamicFlags? flags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '能力与目标'),
        _buildInfoList('通用能力', competency?.generalSkills),
        _buildInfoList('目标里程碑', competency?.targetMilestones),
        _buildInfoItem('当前阶段', flags?.currentStage),
      ],
    );
  }

  /// 构建兴趣方向区块
  Widget _buildInterestSection(BuildContext context, InterestGraph? interestGraph) {
    List<String>? primaryInterests = interestGraph?.primaryInterests?.keys.toList();
    List<String>? crossDomains = interestGraph?.crossDomainLinks?.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '兴趣方向'),
        _buildInfoList('核心兴趣', primaryInterests),
        _buildInfoList('跨领域组合', crossDomains),
      ],
    );
  }

  /// 构建学习偏好区块
  Widget _buildBehaviorSection(BuildContext context, Behavior? behavior) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '学习偏好'),
        _buildInfoItem('学习人格', behavior?.learningPersonality),
        _buildInfoList('偏好资源类型', behavior?.preferredResourceTypes),
        _buildInfoList('偏好实践形式', behavior?.preferredPracticeForms),
        _buildInfoList('学习动机', behavior?.motivations),
      ],
    );
  }

  /// 构建学习条件区块
  Widget _buildConstraintsSection(BuildContext context, Constraints? constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '学习条件'),
        _buildInfoList('主要学习设备', constraints?.preferredDevices),
        _buildInfoList('可接受投入', constraints?.acceptedInvestment),
        _buildInfoList('偏好学习时段', constraints?.preferredLearningTimes),
      ],
    );
  }
}

