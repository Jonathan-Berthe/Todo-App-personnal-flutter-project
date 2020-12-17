import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

import 'dart:async';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tza;

import 'package:meta/meta.dart';
import 'package:todo_marie/helpers/native_code.dart';
import 'package:todo_marie/screens/home.dart';
import 'package:todo_marie/screens/todo_item_detail_screen.dart';
import 'package:todo_marie/screens/todo_overview_screen.dart';

import '../main.dart';

class ReminderNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReminderNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}

class NotHelper {
  bool _timezoneAvailable = true;
  bool _isInit = false;
  String _payload;

  Future<String> initNotifications(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    tz.initializeTimeZones();

    String timezone;
    try {
      timezone = await NativeCode.getTimeZoneName();
    } catch (e) {
      timezone = 'Failed to get the timezone.';
      print('error, Failed to get the timezone.');
    }

    try {
      tza.setLocalLocation(tza.getLocation(timezone));
    } on tza.LocationNotFoundException catch (e) {
      print('error, Failed to get the timezone. ' + e.toString());
      _timezoneAvailable = false;
    }

    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
          // your call back to the UI
          // voir doc (https://pub.dev/packages/flutter_local_notifications/example) => à gérer avec des Stream !
        });
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: _onSelectNotification,
    );

    _isInit = true;
    return _payload;
  }

  // this method is called when u tap on the notification
  Future<void> _onSelectNotification(String payload) async {
    _payload = payload;

    if (!_isInit) return;

    try {
      await Future.delayed(Duration(), () {
        MyApp.navigatorKey.currentState.push(MaterialPageRoute(
          builder: (context) => TodoItemDetailScreen(),
          settings: RouteSettings(arguments: payload),
        ));
      });
    } catch (e) {
      print('error ' + e.toString());
    } 
  }

  Future<void> showNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      String id) async {
    var android = AndroidNotificationDetails(
      id,
      'Reminder notifications',
      'Remember about it',
      icon: 'app_icon',
    );
    var iOS = IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
        0, 'Flutter devs', 'Flutter Local Notification Demo', platform,
        payload: 'Welcome to the Local Notification demo');
  }

  Future<void> turnOffNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> turnOffNotificationById(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      num id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> scheduleNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      String id,
      String body,
      DateTime scheduledNotificationDateTime) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'todo App',
      'Reminder notifications',
      'Remember about it',
      //icon: 'app_icon',
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    int tmp = id.length;

    if (_timezoneAvailable) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        int.parse(id.substring(tmp - 9)),
        'Reminder Todo App',
        body,
        tza.TZDateTime.from(scheduledNotificationDateTime, tza.local),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: id,
      );
    } else {
      print('time zone pas available');
      await flutterLocalNotificationsPlugin.schedule(
        int.parse(id.substring(tmp - 9)),
        'Reminder Todo App',
        body,
        scheduledNotificationDateTime,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        payload: id,
      );
    }
  }

  Future<bool> requestIOSPermissions(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    final bool result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    return result;
  }
}
