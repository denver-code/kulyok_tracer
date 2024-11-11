import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kulyok Tracer Main Menu'),
        centerTitle: true,
      ),
      body: Center(
        child: TextButton(
            onPressed: () {
              Get.toNamed('/editor');
            },
            child: const Text(
              'Try Editor',
              style: TextStyle(fontSize: 20),
            )),
      ),
    );
  }
}
