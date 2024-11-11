import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:kulyok/app/models/network_nodes.dart';
import 'package:kulyok/app/models/painters.dart';
import 'package:kulyok/app/modules/editor/views/devices_toolbar.dart';
import 'package:kulyok/app/modules/editor/views/toolbar.dart';

import '../controllers/editor_controller.dart';

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

class EditorView extends GetView<EditorController> {
  const EditorView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditorController());
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          // Navbar
          Container(
            height: 50,
            color: const Color.fromARGB(255, 26, 26, 26),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      // Text('Editor', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  const Spacer(),
                  const Text('Cisco Kulyok Tracer / Class 1',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.supervised_user_circle_sharp,
                            color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon:
                            Icon(Icons.data_usage_rounded, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: Stack(
              children: [
                CustomPaint(
                  painter: GridPainter(),
                  child: Container(),
                ),
                Obx(() => Stack(
                      children: [
                        // Draw connections
                        ...controller.connections.map((connection) {
                          final fromPosition =
                              connection['fromPosition'] as Offset;
                          final toPosition = connection['toPosition'] as Offset;
                          return ConnectionLine(
                            from: fromPosition,
                            to: toPosition,
                          );
                        }),
                        // Draw nodes
                        ...controller.nodes
                            .map((node) => DraggableNode(node: node)),
                      ],
                    )),
                Positioned(
                  left: 0,
                  top: Get.height / 2 - 150,
                  child: ToolbarWidget(),
                ),
                Positioned(
                  left: Get.width / 2 - 75,
                  bottom: 0,
                  child: DeviceToolbar(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
