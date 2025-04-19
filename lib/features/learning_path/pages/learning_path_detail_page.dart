import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../models/learning_path_models.dart';
import '../services/learning_path_service.dart';
import 'subpages/knowledge_graph_view.dart';

/// 学习路径详情页面 - 显示知识图谱可视化
class LearningPathDetailPage extends ConsumerStatefulWidget {
  final String pathId;

  const LearningPathDetailPage({
    super.key,
    required this.pathId,
  });

  @override
  ConsumerState<LearningPathDetailPage> createState() => _LearningPathDetailPageState();
}

class _LearningPathDetailPageState extends ConsumerState<LearningPathDetailPage> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  FullLearningPathResponse? _pathData;
  late TabController _tabController;
  PathNode? _selectedNode;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPathData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPathData() async {
    try {
      setState(() => _isLoading = true);
      final service = ref.read(learningPathLogicProvider);
      final data = await service.getFullLearningPath(widget.pathId);
      if (!mounted) return;
      setState(() {
        _pathData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: _pathData?.path.title ?? '路径详情',
      showBackButton: true,
      showBottomNav: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadPathData,
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _pathData != null
                  ? _buildPathView()
                  : const Center(child: Text('无数据')),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('加载失败: $_error', style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPathData,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPathView() {
    return Column(
      children: [
        _buildPathHeader(),
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.account_tree), text: '知识图谱'),
            Tab(icon: Icon(Icons.list), text: '节点列表'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildGraphView(),
              _buildListView(),
            ],
          ),
        ),
        if (_selectedNode != null) _buildNodeDetails(),
      ],
    );
  }
  
  Widget _buildPathHeader() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _pathData!.path.title ?? '无标题',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (_pathData!.path.description != null) ...[
              const SizedBox(height: 8),
              Text(_pathData!.path.description!),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  _pathData!.path.estimatedDuration ?? '未知时长',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(width: 16),
                Icon(Icons.flag, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _pathData!.path.targetGoal ?? '未设置目标',
                    style: TextStyle(color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGraphView() {
    if (_pathData!.nodes.isEmpty) {
      return const Center(child: Text('暂无知识节点'));
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade100,
      child: KnowledgeGraphView(
        nodes: _pathData!.nodes,
        edges: _pathData!.edges,
        onNodeTap: (node) {
          setState(() => _selectedNode = node);
        },
      ),
    );
  }
  
  Widget _buildListView() {
    if (_pathData!.nodes.isEmpty) {
      return const Center(child: Text('暂无知识节点'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pathData!.nodes.length,
      itemBuilder: (context, index) {
        final node = _pathData!.nodes[index];
        final nodeResources = _pathData!.resources.where((r) => r.nodeId == node.id).toList();
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ExpansionTile(
            leading: _getNodeIcon(node.type ?? ''),
            title: Text(node.label ?? ''),
            subtitle: Text(node.type ?? ''),
            children: [
              if (node.details != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(node.details!),
                ),
              if (nodeResources.isNotEmpty) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('学习资源:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      ...nodeResources.map((resource) => ListTile(
                        dense: true,
                        leading: _getResourceIcon(resource.type ?? ''),
                        title: Text(resource.title ?? ''),
                        subtitle: resource.description != null ? Text(resource.description!) : null,
                        trailing: resource.url != null ? const Icon(Icons.open_in_new, size: 16) : null,
                        onTap: resource.url != null ? () {} : null,
                      )),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildNodeDetails() {
    final nodeResources = _pathData!.resources
        .where((r) => r.nodeId == _selectedNode!.id)
        .toList();
        
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: _getNodeColor(_selectedNode!.type ?? ''),
                child: _getNodeIcon(_selectedNode!.type ?? ''),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedNode!.label ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _selectedNode!.type ?? '',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selectedNode = null),
              ),
            ],
          ),
          if (_selectedNode!.details != null) ...[
            const SizedBox(height: 8),
            Text(_selectedNode!.details!),
          ],
          if (nodeResources.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('学习资源:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: nodeResources.length,
                itemBuilder: (context, index) {
                  final resource = nodeResources[index];
                  return Card(
                    margin: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 150,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        title: Text(
                          resource.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(resource.type ?? '', style: const TextStyle(fontSize: 12)),
                            if (resource.url != null)
                              TextButton(
                                onPressed: () {},
                                child: const Text('打开'),
                              ),
                          ],
                        ),
                        leading: _getResourceIcon(resource.type ?? ''),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Color _getNodeColor(String type) {
    switch (type.toLowerCase()) {
      case 'skill': return AppColors.primary;
      case 'concept': return Colors.amber;
      case 'project': return Colors.indigo;
      case 'goal': return Colors.green;
      case 'meta': return Colors.purple;
      case 'influence': return Colors.orange;
      default: return Colors.grey;
    }
  }
  
  Icon _getNodeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'skill': return Icon(Icons.build, color: Colors.white);
      case 'concept': return Icon(Icons.lightbulb, color: Colors.white);
      case 'project': return Icon(Icons.work, color: Colors.white);
      case 'goal': return Icon(Icons.flag, color: Colors.white);
      case 'meta': return Icon(Icons.psychology, color: Colors.white);
      case 'influence': return Icon(Icons.people, color: Colors.white);
      default: return Icon(Icons.circle, color: Colors.white);
    }
  }
  
  Icon _getResourceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'video': return const Icon(Icons.videocam, size: 20);
      case 'article': return const Icon(Icons.article, size: 20);
      case 'book': return const Icon(Icons.book, size: 20);
      case 'course': return const Icon(Icons.school, size: 20);
      case 'tool': return const Icon(Icons.handyman, size: 20);
      default: return const Icon(Icons.link, size: 20);
    }
  }
} 
 
 
 