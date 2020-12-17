import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../helpers/notification_helper.dart';

class NotificationProvider with ChangeNotifier {
  bool _isInit = false;

  bool get isInit => _isInit;

  NotHelper notHelper = NotHelper();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationAppLaunchDetails notificationAppLaunchDetails;

  Future<String> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    
    String payload = await notHelper.initNotifications(flutterLocalNotificationsPlugin);
    notHelper.requestIOSPermissions(flutterLocalNotificationsPlugin);

    print(payload);

   /*  notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    print('lauch by notif ? ' +
        notificationAppLaunchDetails.didNotificationLaunchApp.toString());
      
      print('payload: ' + notificationAppLaunchDetails.payload.toString());   */

    _isInit = true;

    return payload;
  }

  Future<void> turnOffNotification() async {
    await notHelper.turnOffNotification(flutterLocalNotificationsPlugin);
  }

  Future<void> turnOffNotificationById(num id) async {
    await notHelper
        .turnOffNotificationById(flutterLocalNotificationsPlugin, id);
  }

  Future<void> scheduleNotification(
      String id, String body, DateTime scheduledNotificationDateTime) async {
    await notHelper.scheduleNotification(flutterLocalNotificationsPlugin, id,
        body, scheduledNotificationDateTime);
  }

  Future<void> showNotification(String id) async {
    await notHelper.showNotification(flutterLocalNotificationsPlugin, id);
  }
}
