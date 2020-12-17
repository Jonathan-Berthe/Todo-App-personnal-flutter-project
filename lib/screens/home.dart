import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_marie/providers/notification_provider.dart';
import 'package:todo_marie/screens/todo_overview_screen.dart';

import '../providers/notification_provider.dart';
import './splash_screen.dart';

class Home extends StatelessWidget {
  const Home({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isInit =
        Provider.of<NotificationProvider>(context, listen: false).isInit;

    return isInit
        ? const TodoOverviewScreen()
        : FutureBuilder(
            future: Future.delayed(Duration(seconds: 1), () async{
              return await Provider.of<NotificationProvider>(context, listen: false).init();
            }),
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                String notifTodoId = snapshot
                    .data; // will be not null if the app lauch because of a tap on notification

                return TodoOverviewScreen(notifTodoId: notifTodoId);
              } else {
                return const SplashScreen();
              }
            });
  }
}
