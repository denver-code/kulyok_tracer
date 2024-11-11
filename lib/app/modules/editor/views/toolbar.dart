import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/editor_controller.dart';

class ToolbarWidget extends StatelessWidget {
  final EditorController controller = Get.put(EditorController());

  ToolbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Container(
        padding: const EdgeInsets.all(8),
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(255, 36, 36, 36),
        ),
        child: Column(
          children: [
            IconButton(
              icon: Obx(() => Icon(
                    Icons.bolt,
                    color: controller.isWiringMode.value
                        ? Colors.yellow
                        : Colors.white,
                  )),
              onPressed: controller.toggleWiringMode,
            ),
          ],
        ),
      ),
    );
  }
}
