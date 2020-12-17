// TODO : bug qd on save le formulaire => reset les textformfield

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

import './providers/todo_list.dart';
import './providers/category_list.dart';
import './providers/notification_provider.dart';

import './screens/todo_item_detail_screen.dart';
import './screens/category_screen.dart';
import './screens/home.dart';
import './screens/todo_form_screen.dart';

void main() {
   WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
      runApp(new MyApp());
    });
}

class MyApp extends StatelessWidget {
  static final navigatorKey =  GlobalKey<NavigatorState>();

  MaterialColor createMaterialColor(Color color) {
    // https://medium.com/@filipvk/creating-a-custom-color-swatch-in-flutter-554bcdcb27f3
    List strengths = <double>[.05];
    Map swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: NotificationProvider(),
        ),
        ChangeNotifierProvider.value(
          value: TodoList(),
        ),
        ChangeNotifierProxyProvider<TodoList, CategoryList>(
          create: (context) => CategoryList(
              todoListProvider: Provider.of<TodoList>(context, listen: false)),
          update: (_, todoList, previousCatList) =>
              previousCatList..updateTodoListProvider(todoList),
        )
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Todo App',
        theme: ThemeData(
          primarySwatch: createMaterialColor(Color(0xFFbf4e30)), //Colors.green,
          accentColor: createMaterialColor(Color(0xFFa9ad9a)),
          fontFamily: 'Lato',
        ),
        routes: {
          '/': (ctx) => Home(),
          TodoFormScreen.routeNamed: (ctx) => TodoFormScreen(),
          TodoItemDetailScreen.routeNamed: (ctx) => TodoItemDetailScreen(),
          CategoryScreen.routeNamed: (ctx) => CategoryScreen(),
        },
      ),
    );
  }
}
