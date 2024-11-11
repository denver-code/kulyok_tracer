import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kulyok/app/modules/editor/controllers/editor_controller.dart';

class NetworkNode {
  final String id;
  final String name;
  final String type;
  final String ip;
  Offset position;
  List<Port> ports;
  List<String> connectedTo = [];

  NetworkNode({
    required this.id,
    required this.name,
    required this.type,
    required this.ip,
    required this.position,
  }) : ports = _getDefaultPorts(type);

  static List<Port> _getDefaultPorts(String type) {
    switch (type) {
      case 'router':
        return List.generate(
            4, (i) => Port(id: 'port_$i', name: 'ETH${i + 1}'));
      case 'pc':
        return [Port(id: 'port_0', name: 'ETH1')];
      case 'smartphone':
        return [Port(id: 'port_0', name: 'WIFI')];
      default:
        return [];
    }
  }
}

class Port {
  final String id;
  final String name;
  List<Connection> connections = [];

  Port({required this.id, required this.name});
}

class Connection {
  final String nodeId;
  final String portId;
  Offset position; // Add position field

  Connection({
    required this.nodeId,
    required this.portId,
    required this.position,
  });
}

class DraggableNode extends StatelessWidget {
  final NetworkNode node;

  const DraggableNode({required this.node});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EditorController>();

    return Positioned(
      left: node.position.dx,
      top: node.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          controller.updateNodePosition(
            node.id,
            Offset(
              node.position.dx + details.delta.dx,
              node.position.dy + details.delta.dy,
            ),
          );
        },
        child: NodeWidget(node: node),
      ),
    );
  }
}

class NodeWidget extends StatelessWidget {
  final NetworkNode node;
  final bool isDragging;

  const NodeWidget({
    required this.node,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EditorController>();

    return Obx(() => Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.handleNodeTap(node),
            child: Row(
              children: [
                Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    // color: const Color(0xFF1E1E1E),
                    color: _getNodeColor(controller),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: _getBorderColor(controller),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _getIconForType(node.type),
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 7),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      node.ip,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: node.ports
                    //       .map((port) => _buildPortIndicator(port))
                    //       .toList(),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  Color _getBorderColor(EditorController controller) {
    if (!controller.isWiringMode.value) return const Color(0xFF2A2A2A);

    if (controller.sourceNode.value?.id == node.id) {
      return Colors.blue;
    } else if (controller.isCreatingConnection.value) {
      return Colors.green
          .withOpacity(0.5); // Shows available nodes for connection
    }

    return const Color(0xFF2A2A2A);
  }

  Color _getNodeColor(EditorController controller) {
    if (controller.isWiringMode.value &&
        (controller.sourceNode.value?.id == node.id ||
            controller.selectedNode.value?.id == node.id)) {
      return Colors.blue;
    }
    return const Color(0xFF1E1E1E);
  }

  double _getBorderWidth(EditorController controller) {
    if (controller.isWiringMode.value &&
        (controller.sourceNode.value?.id == node.id ||
            controller.selectedNode.value?.id == node.id)) {
      return 2;
    }
    return 2;
  }

  Widget _buildPortIndicator(Port port) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: port.connections.isEmpty ? Colors.grey : Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            port.name,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'router':
        return Icons.router;
      case 'pc':
        return Icons.computer;
      case 'smartphone':
        return Icons.phone_android;
      default:
        return Icons.device_unknown;
    }
  }
}
