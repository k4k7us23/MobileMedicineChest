import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

Future<HttpClient> getHttpClient() async{
  ByteData data = await rootBundle.load('assets/russianca.p12');
  SecurityContext context = SecurityContext.defaultContext;
  context.setTrustedCertificatesBytes(data.buffer.asUint8List(), password: "pwd");
  return HttpClient(context: context);
}