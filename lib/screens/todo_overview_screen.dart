import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import '../widgets/drawer/app_drawer.dart';
import '../widgets/filters/filter_dialog.dart';
import '../providers/todo_list.dart';
import '../providers/category_list.dart';

import 'todo_item_detail_screen.dart';
import 'todo_form_screen.dart';
import 'todo_list_screen.dart';
import 'todo_calendar_screen.dart';

class TodoOverviewScreen extends StatefulWidget {
  final String notifTodoId;

  const TodoOverviewScreen({this.notifTodoId});

  @override
  _TodoOverviewScreenState createState() => _TodoOverviewScreenState();
}

class _TodoOverviewScreenState extends State<TodoOverviewScreen> {
  bool _calendarView = false;
  bool _isInit = false;
  bool _keyboardVisible = false;
  String _notifTodoId;

  Widget _listScreen;

  Widget _calendarScreen;



  @override
  void initState() {
    _notifTodoId = widget.notifTodoId;

    // Subscribe
    KeyboardVisibility.onChange.listen((bool visible) {
     
      if (context != null && ModalRoute.of(context).isCurrent) setState(() {
        _keyboardVisible = visible;
      });
    });

    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text('Todo List'),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.calendar_today,
                color: _calendarView ? Colors.black : null,
                size: _calendarView ? 32 : 24,
              ),
              onPressed: () {
                if (!_calendarView) {
                  setState(() {
                    _calendarView = true;
                  });
                  Provider.of<TodoList>(context, listen: false)
                      .switchCalendarView(true);
                }
              }),
          IconButton(
            icon: Icon(
              Icons.list,
              color: !_calendarView ? Colors.black : null,
              size: !_calendarView ? 32 : 24,
            ),
            onPressed: () {
              if (_calendarView) {
                setState(() {
                  _calendarView = false;
                });
                Provider.of<TodoList>(context, listen: false)
                    .switchCalendarView(false);
              }
            },
          ),
        ],
      ),
      body: _isInit
          ? (_calendarView ? _calendarScreen : _listScreen)
          : FutureBuilder(
              future: Provider.of<CategoryList>(context, listen: false)
                  .fetchAndSetCategory(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return FutureBuilder(
                      future: Provider.of<TodoList>(context, listen: false)
                          .fetchAndSetPlaces(context),
                      builder: (_, snapshot2) {
                        if (snapshot2.connectionState == ConnectionState.done) {
                          _calendarScreen = TodoCalendarScreen();
                          _listScreen = TodoListScreen();
                          _isInit = true;

                          // Petit trick pour permettre de setState alors qu'on est dans un builder.
                          Future.delayed(Duration(milliseconds: 0))
                              .then((value) {
                            setState(() {
                              if (_notifTodoId != null)
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  Navigator.of(context).pushNamed(
                                    TodoItemDetailScreen.routeNamed,
                                    arguments: _notifTodoId,
                                  );
                                });
                            });
                          });
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      });
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
      drawer: AppDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:  _keyboardVisible
          ? null
          :  Container(
              child: Row(
                children: <Widget>[
                  SizedBox(width: 10),
                  FloatingActionButton(
                    heroTag: "btn1",
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return FilterDialog(_calendarView);
                          });
                    },
                    child: Icon(Icons.settings),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  if (Provider.of<TodoList>(context).numOfFilters > 0) ...[
                    FloatingActionButton(
                      backgroundColor: Theme.of(context).errorColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        side: BorderSide.none,
                      ),
                      heroTag: "btn3",
                      onPressed: () {
                        Provider.of<TodoList>(context, listen: false)
                            .resetFilters();
                      },
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 3.0),
                            child: Icon(
                              Icons.settings_backup_restore,
                              size: 15,
                            ),
                          ),
                          FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Text('Reset'),
                              )),
                          FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                    '${Provider.of<TodoList>(context, listen: false).numOfFilters} filters'),
                              )),
                        ],
                      ),
                    ),
                    Spacer(
                      flex: 1,
                    ),
                  ],
                  FloatingActionButton(
                    heroTag: "btn2",
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(TodoFormScreen.routeNamed);
                    },
                    child: Icon(Icons.add),
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ),
    );
  }
}
