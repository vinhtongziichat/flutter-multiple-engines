import 'package:core_module/core_module.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiModule extends CoreModule {

  static final ApiModule _instance = ApiModule._internal();
  ApiModule._internal();
  static ApiModule get instance => _instance;

  @override
  void init() {
    Channel.instance.addMethodCallHandler((call) async {
      switch (call.method) {
        case 'fetchData':
          return await fetchData();
          
        default:
          return null;
      }
    });
  }

  @override
  void dispose() {
    // Dispose API module
  }

  Future<dynamic> fetchData() async {
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return 'Request failed with status: ${response.statusCode}';
      }
    } catch (e) {
      return 'Failed to load data: $e';
    }
  }
}