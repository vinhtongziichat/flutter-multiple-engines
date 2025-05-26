// ignore_for_file: avoid_print

import 'package:flutter/services.dart';

abstract class CoreModule {
  void init();
  void dispose();
}

class Channel {

  static final Channel _instance = Channel._internal();
  Channel._internal();
  static Channel get instance => _instance;

  final MethodChannel _channel = MethodChannel('com.ziichat/services');
  final BasicMessageChannel _streamOutChannel = BasicMessageChannel('com.ziichat/stream/out', JSONMessageCodec());
  final BasicMessageChannel _streamInChannel = BasicMessageChannel('com.ziichat/stream/in', JSONMessageCodec());
  final List<Future<dynamic> Function(MethodCall call)> _handlers = [];
  final List<Future<dynamic> Function(dynamic)> _streamHandlers = [];

  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (e, stackTrace) {
      // Log detailed error information
      _logPlatformError(method, e, stackTrace);
      rethrow; // Rethrow to allow callers to handle specific errors
    }
  }

  void streamOut(dynamic data) async {
    try {
      await _streamOutChannel.send(data);
    } on PlatformException catch (e, stackTrace) {
      // Log detailed error information
      _logPlatformError('STREAM', e, stackTrace);
      rethrow; // Rethrow to allow callers to handle specific errors
    }
  }

  void addStreamHandler(Future<dynamic> Function(dynamic) handler) {
    _streamHandlers.add(handler);
    _updateStreamHandlers();
  }

  void _updateStreamHandlers() {
    if (_streamHandlers.isEmpty) {
      _streamInChannel.setMessageHandler(null);
      return;
    }
    _streamInChannel.setMessageHandler((message) async {
      for (final handler in _streamHandlers) {
        final result = await handler(message);
        if (result != null) {
          return result;
        }
      }
      return null;
    });
  }

  void addMethodCallHandler(Future<dynamic> Function(MethodCall call) handler) {
    _handlers.add(handler);
    _updateMethodCallHandler();
  }

  bool removeMethodCallHandler(Future<dynamic> Function(MethodCall call) handler) {
    final removed = _handlers.remove(handler);
    if (removed) {
      _updateMethodCallHandler();
    }
    return removed;
  }

  void _updateMethodCallHandler() {
    if (_handlers.isEmpty) {
      _channel.setMethodCallHandler(null);
      return;
    }

    _channel.setMethodCallHandler((MethodCall call) async {
      for (final handler in _handlers) {
        try {
          final result = await handler(call);
          if (result != null) {
            return result;
          }
        } catch (e, stackTrace) {
          _logHandlerError(call.method, e, stackTrace);
        }
      }
      return null; // No handler processed the call
    });
  }

  void _logPlatformError(String method, PlatformException e, StackTrace stackTrace) {
    print('Platform error invoking $method: ${e.message}');
    print('Error details: ${e.details}');
    print('Stack trace: $stackTrace');
  }

  void _logHandlerError(String method, dynamic e, StackTrace stackTrace) {
    print('Handler error for method $method: $e');
    print('Stack trace: $stackTrace');
  }

  void dispose() {
    _handlers.clear();
    _channel.setMethodCallHandler(null);
  }
}

