
import 'package:flutter/services.dart';

class ImageTexturePlugins{
  static const MethodChannel _channel =
  const MethodChannel('ImageTexture');

  static Future<int> loadImg(String url,int width,int height) async {
    final args = <String, dynamic>{"url":url,"height":height,"width":width};
    return await _channel.invokeMethod("load", args);
  }

  static Future<String> release(String id) async {
    final args = <String, dynamic>{"id": id};
    return await _channel.invokeMethod("release", args);
  }
}