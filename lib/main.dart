import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kitchen_display_system/pages/collection_display_page/collection_display_page_vm.dart';
import 'package:kitchen_display_system/pages/landing_page/landing_page.dart';
import 'package:kitchen_display_system/pages/kitchen_display_page/kitchen_display_page_vm.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  Get.put(KitchenDisplayPageVM());
  Get.put(CollectionDisplayPageVM());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kitchen Display System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'Roboto',
      ),
      home: const LandingPage(),
    );
  }
}
