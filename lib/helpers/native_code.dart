import 'package:flutter/services.dart';


class NativeCode{
  static Future<String> getTimeZoneName() async{
    const platform = MethodChannel("timezone.name");
    try{
      final String name = await platform.invokeMethod('getTimeZoneName');
      return name;
    } catch (error){
      throw error;
    }
  }
}