
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class PluginAbnormalCapture {
  static const MethodChannel _channel = MethodChannel('plugin_abnormal_capture');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  //获取需要上报的其他信息
  static Future<String?> get upLoadInfo async {
    String json = await _channel.invokeMethod('upLoadExceptionInfo');
    return json;
  }

  static void uploadError(String json,String error,String type,String pageName) async {
    var jsonResP=jsonDecode(json);
    Response response;
    var dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
        onRequest:(options, handler){
          // Do something before request is sent
          debugPrint("Params:"+options.queryParameters.toString());
          return handler.next(options); //continue
          // If you want to resolve the request with some custom data，
          // you can resolve a `Response` object eg: `handler.resolve(response)`.
          // If you want to reject the request with a error message,
          // you can reject a `DioError` object eg: `handler.reject(dioError)`
        },
        onResponse:(response,handler) {
          // Do something with response data
          return handler.next(response); // continue
          // If you want to reject the request with a error message,
          // you can reject a `DioError` object eg: `handler.reject(dioError)`
        },
        onError: (DioError e, handler) {
          // Do something with response error
          return  handler.next(e);//continue
          // If you want to resolve the request with some custom data，
          // you can resolve a `Response` object eg: `handler.resolve(response)`.
        }
    ));
    var baseApmUrl="https://apm-ntocc.huoyunren.com";
    if(isInDebugMode){
      baseApmUrl="http://apm.ntocc.test.chinawayltd.com";
    }
    var euri=baseApmUrl+"?query="+jsonResP["query"]+"&os="+jsonResP["os"]
        +"&osv="+jsonResP["osv"]+"&uid="+jsonResP["uid"]+"&mobile="+jsonResP["mobile"]
        +"&appname="+jsonResP["appName"]+"&errorMsg="+error+"&type="+type+"&pageName="+pageName
        +"&time="+DateTime.now().microsecondsSinceEpoch.toString()+"&traceid="+jsonResP["traceid"]
        +"&clientversion="+jsonResP["clientversion"] +"&devicename="+jsonResP["devicename"]
        +"&rt="+jsonResP["rt"]+"&cat="+jsonResP["cat"]+"&resolution="+jsonResP["resolution"];
    try{
      response = await dio.get(baseApmUrl, queryParameters: {
        'query': jsonResP["query"],
        'os': jsonResP["os"],
        'osv': jsonResP["osv"],
        'uid': jsonResP["uid"],
        'mobile': jsonResP["mobile"],
        'appname':jsonResP["appName"],
        'traceid':jsonResP["traceid"],
        'clientversion':jsonResP["clientversion"],
        'devicename':jsonResP["devicename"],
        'rt':jsonResP["rt"],
        'cat':jsonResP["cat"],
        'resolution':jsonResP["resolution"],
        'euri':euri,
        'errorMsg': error,
        'type': type,
        'pageName': pageName,
        'time': DateTime.now().microsecondsSinceEpoch,});
      debugPrint("Response:"+response.data.toString());
    } catch(e){
      debugPrint(e.toString());
    }
  }
  static bool get isInDebugMode {
    // Assume you're in production mode.
    bool inDebugMode = false;
    // Assert expressions are only evaluated during development. They are ignored
    // in production. Therefore, this code only sets `inDebugMode` to true
    // in a development environment.
    assert(inDebugMode = true);
    return inDebugMode;
  }
}
