import 'package:flutter/material.dart';
import 'dart:math';
import 'package:graphview/GraphView.dart';
import 'package:collection/collection.dart'; // 导入 collection 包

import '../../../../core/theme/app_colors.dart';
import '../../models/learning_path_models.dart';

/// 布局算法类型
enum LayoutType {
  tree, // 树形布局
  force // 力导向布局
}

/// 知识图谱可视化组件 - 支持多种布局算法
class KnowledgeGraphView extends StatefulWidget {
  final List<PathNode> nodes;
  final List<PathEdge> edges;
  final Function(PathNode) onNodeTap;

  const KnowledgeGraphView({
    super.key,
    required this.nodes,
    required this.edges,
    required this.onNodeTap,
  });

  @override
  State<KnowledgeGraphView> createState() => _KnowledgeGraphViewState();
}

class _KnowledgeGraphViewState extends State<KnowledgeGraphView> with SingleTickerProviderStateMixin {
  final Graph graph = Graph();
  late Algorithm layoutAlgorithm;
  final TransformationController _transformationController = TransformationController();
  final Map<String, PathNode> _pathNodeMap = {}; // 用于在builder中查找PathNode
  late AnimationController _animationController;
  bool _isAnimating = false;
  PathNode? _focusedNode;
  double _currentScale = 1.0;
  LayoutType _currentLayout = LayoutType.force; // 默认使用力导向布局

  @override
  void initState() {
    super.initState();
    // 根据当前布局构建图
    _buildGraph(_currentLayout);
    _initLayoutAlgorithm();
    
    // 添加动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // 延迟一帧后自动居中
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetView();
    });
  }

  /// 初始化布局算法
  void _initLayoutAlgorithm() {
    if (_currentLayout == LayoutType.tree) {
      // 树形布局配置 - 增大间距并调整方向
      final configuration = BuchheimWalkerConfiguration()
        ..orientation = BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT  // 修改为从左到右的布局
        ..levelSeparation = 100  // 增大层级间距
        ..siblingSeparation = 80  // 增大同级节点间距
        ..subtreeSeparation = 80;  // 增大子树间距
      layoutAlgorithm = BuchheimWalkerAlgorithm(configuration, TreeEdgeRenderer(configuration));
    } else {
      // 力导向布局配置
      layoutAlgorithm = FruchtermanReingoldAlgorithm();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  /// 切换布局算法
  void _toggleLayout() {
    setState(() {
      _currentLayout = _currentLayout == LayoutType.tree 
          ? LayoutType.force 
          : LayoutType.tree;
      
      // 根据新布局重新构建图
      _buildGraph(_currentLayout);
      _initLayoutAlgorithm();
      
      // 强制重绘并重置视图
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resetView();
      });
    });
  }

  /// 清理所有节点位置，使布局算法重新计算位置
  void _clearNodePositions() {
    for (final node in graph.nodes) {
      // 重置到默认位置，让布局算法重新分配位置
      node.position = Offset.zero;
    }
  }

  /// 重置视图并自动居中
  void _resetView() {
    if (graph.nodes.isEmpty) return;
    
    // 延迟以确保布局计算完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // 强制触发布局计算更新节点位置
        setState(() {}); 
        // 再次延迟以确保位置更新完成
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _computeViewBoundary();
        });
      }
    });
  }
  
  /// 计算视图边界并居中
  void _computeViewBoundary() {
    if (!mounted) return;
    
    // 计算图的边界
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = -double.infinity;
    double maxY = -double.infinity;
    
    for (final node in graph.nodes) {
      final pos = node.position;
      // 跳过尚未计算位置的节点
      if (pos.dx == 0 && pos.dy == 0 && graph.nodes.length > 1) continue;
      
      minX = min(minX, pos.dx);
      minY = min(minY, pos.dy);
      maxX = max(maxX, pos.dx + 100); // 使用节点估计宽度
      maxY = max(maxY, pos.dy + 60); // 使用节点估计高度
    }
    
    // 定义图的宽度和高度
    double graphWidth = maxX - minX;
    double graphHeight = maxY - minY;
    
    // 如果边界计算失败（例如，所有节点都在(0,0)），则使用默认视图
    if (minX == double.infinity || graphWidth <= 0 || graphHeight <= 0) {
       _transformationController.value = Matrix4.identity();
       return;
    }
    
    // 计算中心点
    final centerX = (minX + maxX) / 2;
    final centerY = (minY + maxY) / 2;
    
    // 计算合适的缩放比例
    final viewWidth = MediaQuery.of(context).size.width;
    final viewHeight = MediaQuery.of(context).size.height;
    
    double scale = 1.0;
    if (graphWidth > 0 && graphHeight > 0) {
      scale = min(
        (viewWidth * 0.8) / graphWidth,
        (viewHeight * 0.8) / graphHeight
      );
      scale = scale.clamp(0.1, 1.5); // 调整缩放范围
    } else {
      scale = 0.5; // 如果只有一个节点，使用固定比例
    }
    _currentScale = scale;
    
    // 设置变换矩阵，居中显示
    final Matrix4 matrix = Matrix4.identity()
      ..translate(viewWidth / 2, viewHeight / 2)
      ..scale(scale, scale, 1.0)
      ..translate(-centerX, -centerY);
    
    _transformationController.value = matrix;
  }

  /// 构建Graph对象 - 根据布局类型
  void _buildGraph(LayoutType layoutType) {
    graph.nodes.clear();
    graph.edges.clear();
    _pathNodeMap.clear();

    final allNodes = widget.nodes;
    final allEdges = widget.edges;
    final Map<String, Node> nodeMap = {};

    List<PathNode> nodesToBuild = [];
    List<PathEdge> edgesToBuild = [];

    if (layoutType == LayoutType.tree) {
      // 树形布局：查找最大的连通组件并构建
      final components = _findConnectedComponents(allNodes, allEdges);
      if (components.isNotEmpty) {
        // 假设最大的组件是主树
        components.sort((a, b) => b.nodes.length.compareTo(a.nodes.length));
        nodesToBuild = components[0].nodes;
        edgesToBuild = components[0].edges;
      }
    } else {
      // 力导向布局：构建所有节点和边
      nodesToBuild = allNodes;
      edgesToBuild = allEdges;
    }

    // 1. 创建需要构建的节点
    for (final pathNode in nodesToBuild) {
      if (pathNode.id == null) continue;
      final node = Node.Id(pathNode.id!);
      node.size = const Size(100, 60);
      nodeMap[pathNode.id!] = node;
      _pathNodeMap[pathNode.id!] = pathNode;
      graph.addNode(node);
    }

    // 2. 创建需要构建的边
    for (final pathEdge in edgesToBuild) {
      final fromNodeId = pathEdge.sourceNodeId;
      final toNodeId = pathEdge.targetNodeId;

      if (fromNodeId == null || toNodeId == null) continue;

      // 确保边连接的两个节点都在 nodeMap 中（即属于当前要构建的组件）
      final fromNode = nodeMap[fromNodeId];
      final toNode = nodeMap[toNodeId];

      if (fromNode != null && toNode != null) {
        final edgePaint = Paint()
          ..color = _getEdgeColor(pathEdge.relationshipType)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        graph.addEdge(fromNode, toNode, paint: edgePaint);
      }
    }
  }
  
  /// 查找图中的所有连通组件 (使用BFS)
  List<({List<PathNode> nodes, List<PathEdge> edges})> _findConnectedComponents(
      List<PathNode> allNodes, List<PathEdge> allEdges) {
    final components = <({List<PathNode> nodes, List<PathEdge> edges})>[];
    final visitedNodes = <String>{};
    final adj = <String, List<String>>{}; // 邻接表
    final edgeMap = <String, List<PathEdge>>{}; // 存储与节点相关的边
    final nodeMap = {for (var node in allNodes) node.id!: node}; // 通过ID快速查找节点

    // 构建邻接表和边映射
    for (final edge in allEdges) {
      if (edge.sourceNodeId != null && edge.targetNodeId != null) {
        adj.putIfAbsent(edge.sourceNodeId!, () => []).add(edge.targetNodeId!);
        adj.putIfAbsent(edge.targetNodeId!, () => []).add(edge.sourceNodeId!);
        edgeMap.putIfAbsent(edge.sourceNodeId!, () => []).add(edge);
        edgeMap.putIfAbsent(edge.targetNodeId!, () => []).add(edge);
      }
    }

    for (final node in allNodes) {
      if (node.id != null && !visitedNodes.contains(node.id!)) {
        final componentNodes = <PathNode>[];
        final componentEdges = <PathEdge>{}; // 使用 Set 去重
        final queue = QueueList<String>();

        queue.add(node.id!);
        visitedNodes.add(node.id!);

        while (queue.isNotEmpty) {
          final currentId = queue.removeFirst();
          if (nodeMap.containsKey(currentId)) {
            componentNodes.add(nodeMap[currentId]!);
          }
          
          // 添加与当前节点相关的边
          if (edgeMap.containsKey(currentId)) {
            componentEdges.addAll(edgeMap[currentId]!);
          }

          if (adj.containsKey(currentId)) {
            for (final neighborId in adj[currentId]!) {
              if (!visitedNodes.contains(neighborId)) {
                visitedNodes.add(neighborId);
                queue.add(neighborId);
              }
            }
          }
        }
        if (componentNodes.isNotEmpty) {
           // 只添加连接组件内节点的边
           final validEdges = componentEdges.where((edge) => 
               componentNodes.any((n) => n.id == edge.sourceNodeId) && 
               componentNodes.any((n) => n.id == edge.targetNodeId)
           ).toList();
          components.add((nodes: componentNodes, edges: validEdges));
        }
      }
    }
    return components;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InteractiveViewer(
          transformationController: _transformationController,
          constrained: false,
          boundaryMargin: const EdgeInsets.all(400),
          minScale: 0.05,
          maxScale: 2.5,
          onInteractionUpdate: (details) {
            setState(() {
              _currentScale = _transformationController.value.getMaxScaleOnAxis();
            });
          },
          child: Container(
            color: Colors.grey.shade50,
            child: graph.nodes.isEmpty 
              ? const Center(child: Text('知识图谱为空或正在加载...'))
              : GraphView(
                  graph: graph,
                  algorithm: layoutAlgorithm,
                  paint: Paint()
                    ..color = Colors.grey.withOpacity(0.5)
                    ..strokeWidth = 1,
                  builder: (Node node) {
                    final pathNodeId = node.key?.value as String?;
                    final pathNode = _pathNodeMap[pathNodeId];
                    if (pathNode == null) {
                      return const SizedBox(width: 100, height: 60, child: Center(child: Text('?')));
                    }
                    return _buildNodeWidget(pathNode);
                  },
                ),
          ),
        ),
        // 控制按钮面板
        Positioned(
          right: 16,
          bottom: 16,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 布局切换按钮
                  IconButton(
                    icon: Icon(_currentLayout == LayoutType.tree 
                        ? Icons.hub 
                        : Icons.account_tree),
                    tooltip: _currentLayout == LayoutType.tree 
                        ? '切换到树形图' 
                        : '切换到力导向图',
                    onPressed: _toggleLayout,
                  ),
                  IconButton(
                    icon: const Icon(Icons.center_focus_strong),
                    tooltip: '重置视图',
                    onPressed: _resetView,
                  ),
                  // 只在力导向布局下显示动画按钮
                  if (_currentLayout == LayoutType.force)
                    IconButton(
                      icon: Icon(_isAnimating ? Icons.pause : Icons.play_arrow),
                      tooltip: _isAnimating ? '暂停力导向' : '激活力导向',
                      onPressed: () {
                        setState(() {
                          _isAnimating = !_isAnimating;
                          if (_isAnimating) {
                            _animateLayout();
                          } else {
                            _animationController.stop();
                          }
                        });
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.zoom_in),
                    tooltip: '放大',
                    onPressed: () {
                      final newScale = _currentScale * 1.25;
                      _transformationController.value = Matrix4.copy(_transformationController.value)
                        ..scale(1.25, 1.25, 1.0);
                      setState(() {
                        _currentScale = newScale;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.zoom_out),
                    tooltip: '缩小',
                    onPressed: () {
                      final newScale = _currentScale * 0.8;
                      _transformationController.value = Matrix4.copy(_transformationController.value)
                        ..scale(0.8, 0.8, 1.0);
                      setState(() {
                        _currentScale = newScale;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        // 布局类型指示器
        Positioned(
          left: 16,
          top: 16,
          child: Card(
            elevation: 4,
            color: Colors.white.withOpacity(0.8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
              children: [
                  Icon(
                    _currentLayout == LayoutType.tree 
                        ? Icons.hub 
                        : Icons.account_tree,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _currentLayout == LayoutType.tree 
                        ? '力导向布局' 
                        : '树形布局',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 动画力导向布局
  void _animateLayout() {
    if (!_isAnimating) return;
    
    _animationController.reset();
    _animationController.forward().then((_) {
      if (_isAnimating) {
        // 简单触发重新布局
        setState(() {
          // 创建新的算法实例以触发重新计算
          layoutAlgorithm = FruchtermanReingoldAlgorithm();
        });
        _animateLayout(); // 递归继续动画
      }
    });
  }

  /// 构建单个节点的Widget
  Widget _buildNodeWidget(PathNode node) {
    final Color backgroundColor = _getNodeColor(node.type ?? '');
    final IconData iconData = _getNodeIcon(node.type ?? '');
    final bool isFocused = _focusedNode?.id == node.id;
    
    return GestureDetector(
      onTap: () {
        setState(() => _focusedNode = node);
        widget.onNodeTap(node);
      },
      onPanUpdate: (details) {
        // 只在力导向布局下允许拖动节点
        if (_currentLayout == LayoutType.force) {
          // 拖动节点更新位置
          if (node.id != null) {
            final nodeKey = ValueKey<String>(node.id!);
            final graphNode = graph.getNodeUsingKey(nodeKey);
            if (graphNode != null) {
              final delta = details.delta;
              setState(() {
                graphNode.position = Offset(
                  graphNode.position.dx + delta.dx / _currentScale,
                  graphNode.position.dy + delta.dy / _currentScale
                );
              });
            }
          }
        }
      },
      onPanEnd: (details) {
        // 拖动结束后，暂时不做特殊处理，依赖onPanUpdate的更新
        // // 拖动结束后，重新应用布局算法以稳定位置
        // // 延迟执行确保状态更新
        // Future.microtask(() {
        //   setState(() {
        //     _initLayoutAlgorithm(); // 重新初始化以应用最终布局
        //     // 延迟小段时间后重置视图边界
        //     Future.delayed(const Duration(milliseconds: 300), () {
        //       if (mounted) {
        //         _resetView();
        //       }
        //     });
        //   });
        // });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor.withAlpha(230),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
              color: isFocused 
                ? Colors.amber.withAlpha(120) 
                : Colors.black.withAlpha(40),
              blurRadius: isFocused ? 10 : 4,
              spreadRadius: isFocused ? 2 : 0,
              offset: const Offset(0, 1),
            ),
          ],
          border: isFocused 
            ? Border.all(color: Colors.amber, width: 2) 
            : null,
          ),
          child: Column(
          mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Icon(iconData, color: Colors.white, size: 22),
              const SizedBox(height: 4),
              Text(
                node.label ?? '',
                textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                fontSize: isFocused ? 12 : 10,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
        ),
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
      case 'tool': return Colors.teal;
      case 'meta_skill': return Colors.deepPurple;
      case 'influence_skill': return Colors.brown;
      case 'bridge': return Colors.cyan;
      default: return Colors.grey;
    }
  }

  IconData _getNodeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'skill': return Icons.build;
      case 'concept': return Icons.lightbulb_outline;
      case 'project': return Icons.work_outline;
      case 'goal': return Icons.flag;
      case 'meta': return Icons.psychology;
      case 'influence': return Icons.people;
      case 'tool': return Icons.construction;
      case 'meta_skill': return Icons.psychology_alt;
      case 'influence_skill': return Icons.record_voice_over;
      case 'bridge': return Icons.swap_horiz;
      default: return Icons.adjust;
    }
  }

  Color _getEdgeColor(String? relationshipType) {
    if (relationshipType == null) return Colors.grey.shade400;
    switch (relationshipType.toLowerCase()) {
      case 'prerequisite': return Colors.red.withOpacity(0.7);
      case 'related': return Colors.blue.shade300.withOpacity(0.7);
      case 'influence': return Colors.orange.withOpacity(0.7);
      case 'includes': return AppColors.primary.withOpacity(0.7);
      case 'optional': return Colors.purple.withOpacity(0.7);
      case 'dependency': return Colors.red.shade700.withOpacity(0.7);
      case 'sequence': return AppColors.secondary.withOpacity(0.7);
      case 'bridge_from': return Colors.cyan.withOpacity(0.7);
      case 'bridge_to': return Colors.teal.withOpacity(0.7);
      case 'bridge': return Colors.cyan.withOpacity(0.7);
      default: return Colors.grey.shade400.withOpacity(0.7);
    }
  }
} 