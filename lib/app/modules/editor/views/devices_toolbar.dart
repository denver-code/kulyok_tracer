import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kulyok/app/models/network_nodes.dart';
import '../controllers/editor_controller.dart';

class DeviceToolbar extends StatelessWidget {
  final EditorController controller = Get.put(EditorController());

  DeviceToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 36, 36, 36),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Router button with dropdown
            _buildDeviceButton(
              icon: Icons.router_outlined,
              label: 'Routers',
              context: context,
              devices: [
                'Router 4331',
                'Router 2901',
              ],
              onDeviceSelected: (deviceName) {
                final newRouter = NetworkNode(
                  id: 'router_${controller.nodes.length}',
                  name: deviceName,
                  type: 'router',
                  ip: '10.0.0.${controller.nodes.length + 1}',
                  position: Offset(100, 100 + controller.nodes.length * 50),
                );
                controller.addNode(newRouter);
              },
            ),
            const SizedBox(width: 10),
            // User-end devices button with dropdown
            _buildDeviceButton(
              icon: Icons.devices,
              label: 'User-End',
              context: context,
              devices: [
                'PC',
                'Smartphone',
              ],
              onDeviceSelected: (deviceName) {
                final newDevice = NetworkNode(
                  id: '${deviceName.toLowerCase()}_${controller.nodes.length}',
                  name: '$deviceName ${controller.nodes.length}',
                  type: deviceName.toLowerCase(),
                  ip: '192.168.1.${controller.nodes.length + 1}',
                  position: Offset(150, 100 + controller.nodes.length * 50),
                );
                controller.addNode(newDevice);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build a device button with dropdown list
  Widget _buildDeviceButton({
    required IconData icon,
    required String label,
    required BuildContext context,
    required List<String> devices,
    required Function(String) onDeviceSelected,
  }) {
    return PopupMenuButton<String>(
      onSelected: (device) => onDeviceSelected(device),
      icon: Container(
        width: 70,
        height: 70,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 26, 26, 26),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            // Text(label,
            //     style: const TextStyle(color: Colors.white, fontSize: 10)),
          ],
        ),
      ),
      color: const Color.fromARGB(255, 36, 36, 36),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
      ),
      offset: const Offset(0, -150),
      itemBuilder: (context) => devices
          .map(
            (device) => PopupMenuItem(
              value: device,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    color: const Color.fromARGB(255, 26, 26, 26),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        device,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
