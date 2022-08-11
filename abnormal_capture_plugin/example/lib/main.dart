import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:package_request/api_utils.dart';
import 'package:package_request/entity/base_response_data.dart';
import 'package:plugin_abnormal_capture/plugin_abnormal_capture.dart';


class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // List<String> numList = ['1', '2'];
    // print(numList[6]);
    // return Container();
    return Scaffold(
      appBar: AppBar(
        title: Text('App Name'),
      ),
      body: RaisedButton(
          key: null,
          onPressed: buttonPressed,
          // onPressed: (){
          //   assert(false, 'YOU SHOULD BE ABLE TO READ THIS MESSAGE');
          // },
          color: const Color(0xFFe0e0e0),
          child: const Text(
            "Test Exception",
            style: TextStyle(
                fontSize: 12.0,
                color: Color(0xFF000000),
                fontWeight: FontWeight.w200),
          )),
    );
  }
}
void buttonPressed(){
  List<String> numList = ['1', '2'];
  print(numList[6]);
}
// bool get isInDebugMode {
//   // Assume you're in production mode.
//   bool inDebugMode = false;
//
//   // Assert expressions are only evaluated during development. They are ignored
//   // in production. Therefore, this code only sets `inDebugMode` to true
//   // in a development environment.
//   assert(inDebugMode = true);
//
//   return inDebugMode;
// }


Future<Null> main() async {
  runZoned<Future<void>>(() async {
    runApp(MyApp());
  },  onError: (error, stackTrace) async {
    //await _reportError(error, stackTrace);
  });

}

Future<Null> _reportError(dynamic error, dynamic stackTrace) async {
  print('catch error='+error.toString());
  getUploadInfo(error.toString()+stackTrace.toString());
}
  Future<void> getUploadInfo(dynamic error) async {
    String jsonInfo;
    //jsonInfo = await PluginAbnormalCapture.upLoadInfo ?? '';
    HashMap<String,dynamic> hashmap = HashMap();
    hashmap['query']='native';
    hashmap['os']='os';
    hashmap['osv']='osv';
    hashmap['uid']='uid';
    hashmap['mobile']='mobile';
    hashmap['appName']='appName';
    jsonInfo=jsonEncode(hashmap);
    //上报
    PluginAbnormalCapture.uploadError(jsonInfo, error,"1","test");
  }


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          setError();
          return MyHomePage();
        },
      ),
      // home: Scaffold(
      //   appBar: AppBar(title: Text('Flutter Crash Capture'),),
      //   body: MyHomePage(),
      // ),
    );
  }
}

void setError() {
  FlutterError.onError = (FlutterErrorDetails details) async {
    getUploadInfo(details.exception.toString() + details.stack.toString());
    Zone.current.handleUncaughtError(details.exception, details.stack!);
  };
}
