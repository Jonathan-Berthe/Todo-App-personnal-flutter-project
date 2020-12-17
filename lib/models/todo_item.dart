import 'dart:async';

import '../models/task.dart';
import '../models/record.dart';
import '../models/place.dart';


class TodoItem {
  final String id;
  final String title;
  final String description;
  String idCategory;
  final int priority;
  final DateTime deadline;
  final PlaceLocation place;
  List<String> imagesPath;
  List<Record> records;
  List<Task> tasks;
  bool isDone;
  bool areTasksExpand;
  bool withAlarm;

  bool isInFuture;
  Timer timer;

  TodoItem({
    this.idCategory,
    this.description,
    this.id,
    this.priority = 0,
    this.title,
    this.deadline,
    this.imagesPath,
    this.records,
    this.isDone = false,
    this.tasks,
    this.withAlarm = false,
    this.areTasksExpand = false,
    this.isInFuture = true,
    this.timer,
    this.place,
  });
}