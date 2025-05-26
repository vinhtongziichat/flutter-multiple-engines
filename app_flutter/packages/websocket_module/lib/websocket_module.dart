// ignore_for_file: avoid_print

import 'package:core_module/core_module.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketModule extends CoreModule {

  static final WebSocketModule _instance = WebSocketModule._internal();
  WebSocketModule._internal();
  static WebSocketModule get instance => _instance;

  WebSocketChannel? _channel;
  VoidCallback? onMessageUpdated;

  // Stream to listen for incoming messages
  Stream get stream => _channel!.stream;

  // Send message through WebSocket
  void sendMessage(dynamic message) {
    _channel?.sink.add(message);
    onMessageUpdated?.call();
  }

  void sendNative(String data) async {
    Channel.instance.streamOut(data);
  }
  
  @override
  void dispose() {
    _channel?.sink.close();
  }
  
  @override
  void init() async {
    print("WebSocket connecting...");
    _channel = IOWebSocketChannel.connect('ws://10.1.3.4:8765');
    try {
      await _channel!.ready; // Wait for the connection to be established
      print("WebSocket connected successfully");
      onMessageUpdated?.call();
    } catch (e) {
      print("WebSocket connection failed: $e");
      onMessageUpdated?.call();
      return;
    }

    stream.listen(
      (message) {
        sendNative(message);
        onMessageUpdated?.call();
      },
      onError: (error) {
        sendNative('Error: $error');
        onMessageUpdated?.call();
      },
      onDone: () {
        sendNative('Connection closed');
        onMessageUpdated?.call();
      },
    );

    Channel.instance.addStreamHandler((message) async {
      print("🍎 ${message}");
    });
  }
}