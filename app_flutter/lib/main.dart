import 'package:app_flutter/home_page.dart';
import 'package:flutter/material.dart';
import 'package:api_module/api_module.dart';
import 'package:database_module/database_module.dart';
import 'package:websocket_module/websocket_module.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}


@pragma('vm:entry-point')
void runServices() {
  WidgetsFlutterBinding.ensureInitialized();
  final modules = [
    ApiModule.instance,
    DatabaseModule.instance,
    WebSocketModule.instance,
  ];
  for (var module in modules) {
    module.init();
  }
  print("runServices");
}