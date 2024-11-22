import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../main.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) { // Note the '?'
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}





Dio dio = Dio();

void setupDio() async {
  final sslCert = await rootBundle.load('profilepic.jpeg');
  dio.httpClientAdapter = DefaultHttpClientAdapter()
    ..onHttpClientCreate = (client) {
      SecurityContext sc = SecurityContext();
      sc.setTrustedCertificatesBytes(sslCert.buffer.asUint8List());
      HttpClient httpClient = HttpClient(context: sc);
      return httpClient;
    };
}
