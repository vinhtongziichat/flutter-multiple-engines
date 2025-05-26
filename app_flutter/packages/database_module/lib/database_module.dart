// ignore_for_file: avoid_print

import 'package:core_module/core_module.dart';
import 'store.dart';

class DatabaseModule extends CoreModule {

  static final DatabaseModule _instance = DatabaseModule._internal();
  DatabaseModule._internal();
  static DatabaseModule get instance => _instance;
  // StoreBox? _objectBox;

  @override
  void init() async {
    // _objectBox = await StoreBox.create();
    Channel.instance.addMethodCallHandler((call) async {
      switch (call.method) {
        case 'getUserList':
          // return await _objectBox?.getUserList() ?? [];
          return [];

        default:
          return null;
      }
    });
  }

  @override
  void dispose() {
    // _objectBox?.dispose();
  }
}



