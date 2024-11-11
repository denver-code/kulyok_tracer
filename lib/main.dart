// import 'package:flutter/material.dart';

// import 'package:get/get.dart';

// import 'app/routes/app_pages.dart';

// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  Connection({required this.nodeId, required this.portId});
}

class NetworkController extends GetxController {
  var nodes = <NetworkNode>[].obs;
  var connections = <Map<String, dynamic>>[].obs;
  var isWiringMode = false.obs;
  var selectedNode = Rx<NetworkNode?>(null);
  var selectedPort = Rx<Port?>(null);

  void addNode(NetworkNode node) {
    nodes.add(node);
  }

  void updateNodePosition(String id, Offset newPosition) {
    final index = nodes.indexWhere((node) => node.id == id);
    if (index != -1) {
      nodes[index].position = newPosition;
      nodes.refresh();
    }
  }

  void handleNodeTap(NetworkNode node) {
    if (!isWiringMode.value) return;

    if (selectedNode.value == null) {
      selectedNode.value = node;
      // Don't show port selection for the first node yet
    } else if (selectedNode.value!.id != node.id) {
      // Show port selection for the second node
      _showPortSelectionDialog(node, isDestination: true);
    }
  }

  void _showPortSelectionDialog(NetworkNode node,
      {bool isDestination = false}) {
    Get.dialog(
      AlertDialog(
        title: Text('Select ${isDestination ? "Destination" : "Source"} Port'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: node.ports.map((port) {
            return ListTile(
              title: Text(port.name),
              onTap: () {
                if (isDestination) {
                  // Complete the connection
                  addConnection(
                    selectedNode.value!.id,
                    selectedPort.value!.id,
                    node.id,
                    port.id,
                  );
                  Get.back();
                  selectedNode.value = null;
                  selectedPort.value = null;
                } else {
                  selectedPort.value = port;
                  Get.back();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void addConnection(
      String fromNodeId, String fromPortId, String toNodeId, String toPortId) {
    // Check if connection already exists
    final exists = connections.any((conn) =>
        (conn['fromNode'] == fromNodeId &&
            conn['fromPort'] == fromPortId &&
            conn['toNode'] == toNodeId &&
            conn['toPort'] == toPortId) ||
        (conn['fromNode'] == toNodeId &&
            conn['fromPort'] == toPortId &&
            conn['toNode'] == fromNodeId &&
            conn['toPort'] == fromPortId));

    if (!exists) {
      connections.add({
        'fromNode': fromNodeId,
        'fromPort': fromPortId,
        'toNode': toNodeId,
        'toPort': toPortId,
      });
    }
  }
}

class NetworkTopologyPage extends StatelessWidget {
  final controller = Get.put(NetworkController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          CustomPaint(
            painter: GridPainter(),
            child: Container(),
          ),
          Obx(() => Stack(
                children: [
                  // Draw connections
                  ...controller.connections.map((connection) => ConnectionLine(
                        from: controller.nodes
                            .firstWhere((n) => n.id == connection['from'])
                            .position,
                        to: controller.nodes
                            .firstWhere((n) => n.id == connection['to'])
                            .position,
                      )),
                  // Draw nodes
                  ...controller.nodes.map((node) => DraggableNode(node: node)),
                ],
              )),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: ToolbarWidget(),
          ),
          Positioned(
            left: 60,
            right: 0,
            bottom: 0,
            child: DeviceToolbar(),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[800]!
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    const double spacing = 20;
    const double dotSize = 2;

    // Calculate the number of dots needed
    int horizontalDots = (size.width / spacing).ceil();
    int verticalDots = (size.height / spacing).ceil();

    // Draw dots
    for (int i = 0; i <= horizontalDots; i++) {
      for (int j = 0; j <= verticalDots; j++) {
        canvas.drawCircle(
          Offset(i * spacing, j * spacing),
          dotSize / 2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DraggableNode extends StatelessWidget {
  final NetworkNode node;

  const DraggableNode({required this.node});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NetworkController>();

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
    final controller = Get.find<NetworkController>();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 150,
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: controller.isWiringMode.value &&
                    controller.selectedNode.value?.id == node.id
                ? Colors.blue
                : const Color(0xFF2A2A2A),
            width: controller.isWiringMode.value &&
                    controller.selectedNode.value?.id == node.id
                ? 2
                : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getIconForType(node.type),
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  node.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              node.ip,
              style: TextStyle(
                color: Colors.blue[300],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  node.ports.map((port) => _buildPortIndicator(port)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortIndicator(Port port) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
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

class ConnectionLine extends StatelessWidget {
  final Offset from;
  final Offset to;

  const ConnectionLine({required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LinePainter(from: from, to: to),
    );
  }
}

// Update ConnectionLine to show better wiring
class LinePainter extends CustomPainter {
  final Offset from;
  final Offset to;

  LinePainter({required this.from, required this.to});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(from.dx, from.dy);

    // Calculate control points for a curved line
    final midX = (from.dx + to.dx) / 2;
    final midY = (from.dy + to.dy) / 2;

    path.quadraticBezierTo(midX, midY, to.dx, to.dy);
    canvas.drawPath(path, paint);

    // Draw dots at connection points
    final dotPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(from, 4, dotPaint);
    canvas.drawCircle(to, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Update ToolbarWidget to show wiring mode state
class ToolbarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NetworkController>();

    return Container(
      width: 50,
      color: Colors.grey[850],
      child: Column(
        children: [
          Obx(() => IconButton(
                icon: Icon(
                  Icons.cable,
                  color: controller.isWiringMode.value
                      ? Colors.blue
                      : Colors.white,
                ),
                onPressed: () {
                  controller.isWiringMode.toggle();
                  controller.selectedNode.value = null;
                },
              )),
        ],
      ),
    );
  }
}

class DeviceToolbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.grey[850],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DeviceButton(
            icon: Icons.router,
            label: 'Router',
            onTap: () => _addDevice('router'),
          ),
          DeviceButton(
            icon: Icons.computer,
            label: 'PC',
            onTap: () => _addDevice('pc'),
          ),
          DeviceButton(
            icon: Icons.phone_android,
            label: 'Smartphone',
            onTap: () => _addDevice('smartphone'),
          ),
        ],
      ),
    );
  }

  void _addDevice(String type) {
    final controller = Get.find<NetworkController>();
    controller.addNode(NetworkNode(
      id: DateTime.now().toString(),
      name: '${type.capitalize} ${controller.nodes.length + 1}',
      type: type,
      ip: '192.168.1.${controller.nodes.length + 1}',
      position: Offset(100, 100),
    ));
  }
}

class DeviceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const DeviceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            Text(label, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    GetMaterialApp(
      title: "Application",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: NetworkTopologyPage(),
      ),
    ),
  );
}
