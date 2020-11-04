import 'dart:io';

import 'package:flutter/material.dart';
import 'img_model.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);


  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int index = 1;

  Future future;

  HttpClient _httpClient = HttpClient();

  ImgModel imgModel;

  ScrollController scrollController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(() async{
      if(scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        index++;
        await getData();
      }
    });
    future = getData();
  }


  Future getData() async{
    HttpClientRequest request = await _httpClient.getUrl(Uri.parse("https://gank.io/api/v2/data/category/Girl/type/Girl/page/$index/count/10"));
    HttpClientResponse response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    Map<String,dynamic> map=jsonDecode(responseBody);
    var model = ImgModel.fromJson(map);
   if(imgModel == null){
     imgModel = model;
   }else{
     imgModel.data.addAll(model.data);
   }
   setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()),);
            } else {
              return RepaintBoundary(
                child: GridView.builder(
                  physics: ClampingScrollPhysics(),
                  controller: scrollController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1),
                  itemBuilder: (BuildContext itemContext, int index) {
                    return item(imgModel.data[index]);
                  },
                  itemCount: imgModel.data.length,
                ),
              );
            }
          } else {
            return LoadingDialog();
          }
        },
      ),
    );
  }

  Widget item(Data data){
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
         Image.network(data.images[0],height: 150,width: 150,),
         Text(data.desc,style: TextStyle(fontSize: 10),maxLines: 2,overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,),
      ],
    );
  }
}

class LoadingDialog extends Dialog {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Material(
          type: MaterialType.transparency, //透明类型
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 4.0,
              backgroundColor: Colors.blue,
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),
        ),
        onWillPop: () async {
          return Future.value(false);
        });
  }
}