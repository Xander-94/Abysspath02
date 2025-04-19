import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../core/theme/app_colors.dart';
import '../../models/learning_path_models.dart';

/// 知识图谱可视化组件
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

class _KnowledgeGraphViewState extends State<KnowledgeGraphView> {
  final TransformationController _transformationController = TransformationController();
  late Size _size;
  late Map<String, Offset> _nodePositions;

  @override
  void initState() {
    super.initState();
    _nodePositions = {};
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _calculateNodePositions(BoxConstraints constraints) {
    _nodePositions.clear();
    final int nodeCount = widget.nodes.length;
    if (nodeCount == 0) return;
    
    final double availableWidth = constraints.maxWidth;
    final double availableHeight = constraints.maxHeight;
    final double centerX = availableWidth / 2;
    final double centerY = availableHeight * 0.45;
    final double radius = min(availableWidth, availableHeight) * 0.35;
    
    for (int i = 0; i < nodeCount; i++) {
      final node = widget.nodes[i];
      
      if (node.uiPosition != null && 
          node.uiPosition!.containsKey('x') && 
          node.uiPosition!.containsKey('y')) {
        _nodePositions[node.id ?? ''] = Offset(
          (node.uiPosition!['x'] as num?)?.toDouble() ?? centerX,
          (node.uiPosition!['y'] as num?)?.toDouble() ?? centerY,
        );
        continue;
      }
      
      final double angle = 2 * 3.14159 * i / nodeCount;
      final double x = centerX + radius * cos(angle);
      final double y = centerY + radius * sin(angle);
      _nodePositions[node.id ?? ''] = Offset(x, y);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _calculateNodePositions(constraints);
        
        final Size stackSize = constraints.biggest;
        
        return InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.5,
          maxScale: 2.5,
          boundaryMargin: const EdgeInsets.all(50),
          child: SizedBox(
            width: stackSize.width,
            height: stackSize.height,
            child: Stack(
              children: [
                ...widget.edges.map((edge) => _buildEdge(edge, stackSize)),
                ...widget.nodes.map((node) => _buildNode(node)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEdge(PathEdge edge, Size stackSize) {
    final fromPosition = _nodePositions[edge.sourceNodeId ?? ''];
    final toPosition = _nodePositions[edge.targetNodeId ?? ''];
    
    if (fromPosition == null || toPosition == null) {
      return const SizedBox.shrink();
    }
    
    return CustomPaint(
      painter: EdgePainter(
        startPoint: fromPosition,
        endPoint: toPosition,
        color: _getEdgeColor(edge.relationshipType),
        isDashed: edge.relationshipType == 'influence' || edge.relationshipType == 'optional',
      ),
      size: stackSize,
    );
  }

  Widget _buildNode(PathNode node) {
    final position = _nodePositions[node.id ?? ''];
    if (position == null) return const SizedBox.shrink();
    
    final Color backgroundColor = _getNodeColor(node.type ?? '');
    final IconData iconData = _getNodeIcon(node.type ?? '');
    
    return Positioned(
      left: position.dx - 40,
      top: position.dy - 40,
      child: GestureDetector(
        onTap: () => widget.onNodeTap(node),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: backgroundColor.withAlpha(230),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData, color: Colors.white, size: 24),
              const SizedBox(height: 4),
              Text(
                node.label ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
      default: return Colors.grey;
    }
  }

  IconData _getNodeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'skill': return Icons.build;
      case 'concept': return Icons.lightbulb;
      case 'project': return Icons.work;
      case 'goal': return Icons.flag;
      case 'meta': return Icons.psychology;
      case 'influence': return Icons.people;
      default: return Icons.circle;
    }
  }

  Color _getEdgeColor(String? relationshipType) {
    if (relationshipType == null) return Colors.grey;
    switch (relationshipType.toLowerCase()) {
      case 'prerequisite': return Colors.red;
      case 'related': return Colors.blue;
      case 'influence': return Colors.orange;
      case 'includes': return AppColors.primary;
      case 'optional': return Colors.purple;
      case 'dependency': return Colors.red.shade700;
      case 'sequence': return AppColors.secondary;
      case 'bridge_from': return Colors.cyan;
      case 'bridge_to': return Colors.teal;
      default: return Colors.grey;
    }
  }
}

/// 自定义画笔：绘制边
class EdgePainter extends CustomPainter {
  final Offset startPoint;
  final Offset endPoint;
  final Color color;
  final bool isDashed;

  EdgePainter({
    required this.startPoint,
    required this.endPoint,
    required this.color,
    this.isDashed = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (isDashed) {
      final path = Path();
      final double dist = (endPoint - startPoint).distance;
      const double dashWidth = 5.0;
      const double dashSpace = 5.0;
      double start = 0.0;
      final dx = endPoint.dx - startPoint.dx;
      final dy = endPoint.dy - startPoint.dy;
      
      while (start < dist) {
        final end = start + dashWidth;
        path.moveTo(startPoint.dx + dx * start / dist, startPoint.dy + dy * start / dist);
        path.lineTo(startPoint.dx + dx * min(end, dist) / dist, startPoint.dy + dy * min(end, dist) / dist);
        start += dashWidth + dashSpace;
      }
      canvas.drawPath(path, paint);
    } else {
      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
} 