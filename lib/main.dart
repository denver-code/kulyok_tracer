import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kulyok/app/routes/app_pages.dart';
// import 'dart:html';

void main() {
  // window.document.onContextMenu.listen((evt) => evt.preventDefault());
  runApp(
    GetMaterialApp(
      title: "Application",
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
