

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'image_texture_plugins.dart';

class ImageTextureWidget extends StatefulWidget {

  final String url;

  final int width;

  final int height;

  const ImageTextureWidget({Key key, this.url, this.width, this.height}) : super(key: key);

  @override
  _ImageTextureWidgetState createState() => _ImageTextureWidgetState();
}

class _ImageTextureWidgetState extends State<ImageTextureWidget> {

  int textureId;


  EventChannel eventChannel;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadImage();
  }


  Future loadImage() async{
    textureId = await ImageTexturePlugins.loadImg(widget.url,widget.width,widget.height);
    if(mounted)setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    if(textureId == null){
      return Container();
    }
    return Container(
      width: widget.width.toDouble(),
      height: widget.height.toDouble(),
      child: Texture(textureId: textureId)
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if(textureId!=null){
      ImageTexturePlugins.release(textureId?.toString());
    }
    super.dispose();
  }
}
