import 'dart:io' as io;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/task.dart';
import '../models/category.dart';
import '../helpers/db_helper.dart';
import '../models/record.dart';
import '../models/place.dart';
import '../models/todo_item.dart';


class TodoList with ChangeNotifier {
  Category catFilter;
  bool _withCatFilter;
  List<int> priorityRangeFilter = [0, 5];
  List<DateTime> dateRangeFilter; // if null => -infty, +infty
  String _wordFilter = ''; // if null => no word
  bool _isDoneFilter;
  bool _withDateFilter;
  bool calendarView = false; // => false si on est deja en mode calendrier

  int _numOfFilters = 0;

  int _sortChoice = 0;
  bool _ascendingOrder = true;

  bool _isInit = false;

  List<TodoItem> _items = [];

  List<TodoItem> get items {
    return [..._items];
  }

  int get sortChoice => _sortChoice;
  bool get ascendingOrder => _ascendingOrder;
  String get wordFilter => _wordFilter;
  int get numOfFilters => _numOfFilters;
  bool get isDoneFilter => _isDoneFilter;
  bool get withDateFilter => _withDateFilter;
  bool get withCatFilter => _withCatFilter;

  void updateNumberOfFilters() {
    int tmp = 0;

    if (catFilter != null) tmp++;
    if (_withCatFilter != null) tmp++;

    if (_isDoneFilter == true || _isDoneFilter == false) tmp++;

    if (!calendarView && dateRangeFilter != null) tmp++;

    if (_withDateFilter != null) tmp++;

    if (priorityRangeFilter[0] != 0 || priorityRangeFilter[1] != 5) tmp++;

    _numOfFilters = tmp;
  }

  List<TodoItem> get filteredItemsTmp {
    List<TodoItem> tmp = [
      ..._items.where((element) {
        bool c1 = (catFilter == null)
            ? true
            : _isDescendentOfCat(catFilter, element.idCategory);
        /* : (catFilter.idKey == element.idCategory); */
        bool c1bis = (_withCatFilter == null)
            ? true
            : ((_withCatFilter)
                ? (element.idCategory != '' && element.idCategory != null)
                : (element.idCategory == '' || element.idCategory == null));
        bool c2 = element.priority >= priorityRangeFilter[0] &&
            element.priority <= priorityRangeFilter[1];
        bool c3 = (dateRangeFilter == null || calendarView)
            ? true
            : (element.deadline == null
                ? false
                : (element.deadline.isAfter(dateRangeFilter[0]) &&
                    element.deadline.isBefore(dateRangeFilter[1])));

        bool c3bis = (_withDateFilter == null)
            ? true
            : ((_withDateFilter)
                ? element.deadline != null
                : element.deadline == null);

        bool c4bis =
            false; //(element.tasks == null || element.tasks.length == 0) ? true : element.tasks.;

        if (element.tasks != null &&
            element.tasks.length > 0 &&
            _wordFilter != '') {
          for (int i = 0; i < element.tasks.length; i++) {
            if (element.tasks[i].content.contains(_wordFilter)) {
              c4bis = true;
              break;
            }
          }
        }

        bool c4 = (_wordFilter == '')
            ? true
            : (element.title.contains(_wordFilter) ||
                element.description.contains(_wordFilter) ||
                c4bis);
        bool c5 =
            (_isDoneFilter == null) ? true : (element.isDone == _isDoneFilter);

        return (c1 && c1bis && c2 && c3 && c3bis && c4 && c5);
      })
    ];

    if (!_ascendingOrder) return tmp.reversed.toList();
    return tmp;
  }

  bool _isDescendentOfCat(Category cat, String id) {
    if (cat.idKey == id) return true;

    List<Category> children = cat.children;
    if (children == null || children.length == 0) return false;

    bool c = false;
    children.forEach((element) {
      c = c || _isDescendentOfCat(element, id);
      if (c) return;
    });
    return c;
  }

  List<TodoItem> get filteredItems {
    // With Dates => TODO: changer nom pour dire avec date
    return [
      ...filteredItemsTmp.where((element) => !((element.deadline == null) &&
          ((_sortChoice == 0 && !calendarView) || calendarView)))
    ];
  }

  List<TodoItem> get filteredItemsWithoutDate {
    return [
      ...filteredItemsTmp.where((element) =>
          (element.deadline == null) &&
          ((_sortChoice == 0 && !calendarView) || calendarView))
    ];
  }

  void switchCalendarView(bool newVal) {
    calendarView = newVal;
    notifyListeners();
  }

  TodoItem findById(String id) {
    return items.firstWhere((element) => element.id == id, orElse: () => null);
  }

  List<TodoItem> todosOfADate(DateTime date) {
    return [...filteredItems]
        .where((element) => (element.deadline != null &&
            element.deadline.year == date.year &&
            element.deadline.month == date.month &&
            element.deadline.day == date.day))
        .toList();
  }

  Map<int, List<TodoItem>> todosFromADate(int numberOfDays, DateTime firstDay) {
    Map<int, List<TodoItem>> out = Map();

    for (int i = 0; i <= numberOfDays; i++) {
      DateTime tmpDay = firstDay.add(Duration(days: i));
      out[i] = todosOfADate(tmpDay);
    }

    return out;
  }

  void _sortByDate(List<TodoItem> itemsToSort) {
    itemsToSort.sort((a, b) {
      DateTime aDate = a.deadline ?? DateTime.fromMicrosecondsSinceEpoch(0);
      DateTime bDate = b.deadline ?? DateTime.fromMicrosecondsSinceEpoch(0);
      if (aDate == bDate) {
        int aPrior = a.priority;
        int bPrior = b.priority;
        if (aPrior == bPrior) {
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        }
        return -aPrior.compareTo(bPrior);
      }
      return aDate.compareTo(bDate);
    });
  }

  void _sortByPriority(List<TodoItem> itemsToSort) {
    itemsToSort.sort((a, b) {
      int aPrior = a.priority;
      int bPrior = b.priority;
      if (aPrior == bPrior) {
        DateTime aDate = a.deadline ?? DateTime.fromMicrosecondsSinceEpoch(0);
        DateTime bDate = b.deadline ?? DateTime.fromMicrosecondsSinceEpoch(0);
        if (aDate == bDate) {
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        }
        return aDate.compareTo(bDate);
      }
      return aPrior.compareTo(bPrior);
    });
  }

  void _sortByAddingTime(List<TodoItem> itemsToSort) {
    itemsToSort.sort((a, b) {
      return int.parse(a.id).compareTo(int.parse(b.id));
    });
  }

  void sortTodo({int newVal}) {
    if (newVal != null) _sortChoice = newVal;
    if (_sortChoice == 0) {
      _sortByDate(_items);
    } else if (_sortChoice == 1) {
      _sortByPriority(_items);
    } else if (_sortChoice == 2) {
      _sortByAddingTime(_items);
    }
    if (_isInit) notifyListeners();
  }

  void switchAscendingOrder() {
    _ascendingOrder = _ascendingOrder ? false : true;
    notifyListeners();
  }

  void filterByCategory({Category newCat}) {
    catFilter = newCat;
    updateNumberOfFilters();
    notifyListeners();
  }

  void filterwithCat(bool val) {
    _withCatFilter = val;
    updateNumberOfFilters();
    notifyListeners();
  }

  void filterByPriority({int min, int max}) {
    priorityRangeFilter[0] = min;
    priorityRangeFilter[1] = max;
    updateNumberOfFilters();
    notifyListeners();
  }

  void filterByDate({DateTime start, DateTime end}) {
    dateRangeFilter = (start == null || end == null) ? null : [start, end];
    if (dateRangeFilter != null) _withDateFilter = null;
    updateNumberOfFilters();
    notifyListeners();
  }

  void filterwithDate(bool val) {
    _withDateFilter = val;
    if (val == false) _sortChoice = 1;
    updateNumberOfFilters();
    notifyListeners();
  }

  void filterByWord(String word) {
    if (word == null || word == '') {
      _wordFilter = '';
      notifyListeners();
      return;
    }
    _wordFilter = word;
    notifyListeners();
  }

  void setIsDoneFilter(bool newVal) {
    _isDoneFilter = newVal;
    updateNumberOfFilters();
    notifyListeners();
  }

  void resetFilters({bool withListener = true}) {
    catFilter = null;
    priorityRangeFilter = [0, 5];
    dateRangeFilter = null;
    _numOfFilters = 0;
    _isDoneFilter = null;
    _withDateFilter = null;
    _withCatFilter = null;
    if (withListener) notifyListeners();
  }

  void toggleTasksExpand(String todoId) {
    TodoItem item = findById(todoId);
    item.areTasksExpand =
        item.areTasksExpand == null ? false : !item.areTasksExpand;
    //notifyListeners();
  }

  void addATask(String todoId, Task task, int index) {
    TodoItem item = findById(todoId);
    if (index == null) {
      item.tasks.add(task);
    } else {
      item.tasks.insert(index, task);
    }
    notifyListeners();

    // ADD in DB

    //updateInDb(todoId);
  }

  void deleteATask(String todoId, String taskId) {
    TodoItem item = findById(todoId);

    item.tasks.removeWhere((element) => element.id == taskId);

    notifyListeners();

    // Delete in DB

    updateInDb(todoId);
  }

  void moveATask(String todoId, int oldIndex, int newIndex) {
    Task item = findById(todoId).tasks.removeAt(oldIndex);

    findById(todoId).tasks.insert(newIndex, item);

    notifyListeners();

    // Update in DB

    updateInDb(todoId);
  }

  List<Task> getTask(String todoId) {
    return findById(todoId).tasks;
  }

  void setTaskDone(String todoId, String taskId, bool value) {
    findById(todoId)
        .tasks
        .firstWhere((element) => element.id == taskId)
        .isDone = value;

    notifyListeners();

    updateInDb(todoId);
  }

  Future<String> addItem({
    List<Task> tasks,
    String title,
    String description,
    String idCategory,
    int priority = 0,
    DateTime deadline,
    List<ByteData> images,
    String id,
    List<Record> records,
    bool withAlarm = false,
    PlaceLocation place,
  }) async {
    List<String> imagesPath = [];
    for (int i = 0; i < images.length; i++) {
      String path = await DBHelper.saveImagesToFile(
          images[i], '/${id}_${DateTime.now().toString().replaceAll(' ', '')}');
      imagesPath.add(path);
    }
    _items.insert(
        0,
        TodoItem(
          id: id,
          title: title,
          description: description,
          idCategory: idCategory,
          priority: priority,
          deadline: deadline,
          imagesPath: imagesPath,
          records: records,
          tasks: tasks,
          withAlarm: withAlarm,
          isInFuture: _isInFuture(deadline),
          timer: _setItemTimer(id: id, date: deadline),
          place: place,
        ));
    sortTodo();
    notifyListeners();

    Map<String, String> imagesMap = Map();
    if (imagesPath.length > 0) {
      int i = 0;
      imagesPath.forEach((element) {
        imagesMap[i.toString()] = element;
        i++;
      });
    }

    Map<String, Map<String, String>> recordsMap = Map();
    if (records != null && records.length > 0) {
      int i = 0;
      records.forEach((element) {
        recordsMap[i.toString()] = {
          'name': element.name ?? '',
          'url': element.url ?? ''
        };
        i++;
      });
    }

    Map<String, Map<String, String>> tasksMap = Map();
    if (tasks != null && tasks.length > 0) {
      int i = 0;
      tasks.forEach((element) {
        tasksMap[i.toString()] = {
          'content': element.content ?? '',
          'id': element.id ?? '',
          'isDone': element.isDone == false ? '0' : '1',
        };
        i++;
      });
    }

    Map<String, String> placeMap = Map();
    if (place != null) {
      placeMap = {
        'address': place.address ?? '',
        'lat': place.latitude == null ? '' : place.latitude.toString(),
        'lng': place.longitude == null ? '' : place.longitude.toString(),
        'name': place.name ?? ''
      };
    }

    Map<String, dynamic> data = {
      'title': title,
      'description': (description == null) ? '' : description,
      'idCategory': (idCategory == null) ? '' : idCategory,
      'priority': priority.toString(),
      'deadline': (deadline == null) ? '' : deadline.toString(),
      'imagesPath': (imagesMap == null) ? '' : imagesMap,
      'records': (recordsMap == null) ? '' : recordsMap,
      'tasks': (tasksMap == null) ? '' : tasksMap,
      'isDone': '0', // 0 => false, 1 => true
      'withAlarm': withAlarm == false ? '0' : '1',
      'place': placeMap == null ? '' : placeMap,
    };
    await DBHelper.insertTodos({'id': id, 'todoJson': json.encode(data)});
    return id;
  }

  // TODO: enlever la duplication de code entre add et update
  Future<void> updateItem({
    String id,
    String title,
    String description,
    String idCategory,
    int priority = 0,
    DateTime deadline,
    List<ByteData> images, // image to add
    List<Record> newRecords,
    List<String> tmpImgsPath, // New imagesPath (without images that the user delete)
    List<Task> tasks,
    bool withAlarm,
    PlaceLocation place,
  }) async {
    TodoItem tmp = findById(id);

    bool done = tmp.isDone;
    List<String> imagesPath = tmp.imagesPath; // Old imagesPath

    // Si un timer existe, on le cancel()

    tmp.timer?.cancel();

    // 1: on supprime des dossiers toutes les images qui sont dans imagesPath mais pas dans tmpImgsPath

    int l = imagesPath.length;

    for (int i = 0; i < l; i++) {
      String imgi = imagesPath[i];
      bool toSupress = true;
      for (int j = 0; j < tmpImgsPath.length; j++) {
        if (imgi == tmpImgsPath[j]) toSupress = false;
      }
      if (toSupress) {
        await DBHelper.deleteImageFile(imgi);
        imagesPath.removeAt(i);
        i--;
        l--;
      }
    }

    // 2: On save les images qui ont été rajoutées

    for (int i = imagesPath.length; i < images.length; i++) {
      String path = await DBHelper.saveImagesToFile(
          images[i], '/${id}_${DateTime.now().toString()}');
      imagesPath.add(path);
    }

    // On supprime des dossiers les records qui sont dans records mais pas dans newRecords

    List<Record> records = findById(id).records;

    if (records != null) {
      for (int i = 0; i < records.length; i++) {
        bool test = true;
        String url = records[i].url;
        for (int j = 0; j < newRecords.length; j++) {
          if (newRecords[j].url == url) {
            test = false;
            break;
          }
        }
        if (test) io.File(url).delete();
      }
    }

    int index = _items.indexWhere((element) => element.id == id);
    _items[index] = TodoItem(
      id: id,
      title: title,
      idCategory: idCategory,
      description: description,
      priority: priority,
      imagesPath: imagesPath,
      deadline: deadline,
      records: newRecords,
      isDone: done,
      tasks: tasks,
      withAlarm: withAlarm,
      isInFuture: _isInFuture(deadline),
      timer: _setItemTimer(id: id, date: deadline),
      place: place,
    );
    sortTodo();
    notifyListeners();

    Map<String, String> imagesMap = Map();
    if (imagesPath.length > 0) {
      int i = 0;
      imagesPath.forEach((element) {
        imagesMap[i.toString()] = element;
        i++;
      });
    }

    Map<String, Map<String, String>> recordsMap = Map();
    if (newRecords != null && newRecords.length > 0) {
      int i = 0;
      newRecords.forEach((element) {
        recordsMap[i.toString()] = {
          'name': element.name ?? '',
          'url': element.url ?? ''
        };
        i++;
      });
    }

    Map<String, Map<String, String>> tasksMap = Map();
    if (tasks != null && tasks.length > 0) {
      int i = 0;
      tasks.forEach((element) {
        tasksMap[i.toString()] = {
          'content': element.content ?? '',
          'id': element.id ?? '',
          'isDone': element.isDone == false ? '0' : '1',
        };
        i++;
      });
    }

    Map<String, String> placeMap = Map();
    if (place != null) {
      placeMap = {
        'address': place.address ?? '',
        'lat': place.latitude == null ? '' : place.latitude.toString(),
        'lng': place.longitude == null ? '' : place.longitude.toString(),
        'name': place.name ?? ''
      };
    }

    Map<String, dynamic> data = {
      'title': title,
      'description': (description == null) ? '' : description,
      'idCategory': (idCategory == null) ? '' : idCategory,
      'priority': priority.toString(),
      'deadline': (deadline == null) ? '' : deadline.toString(),
      'imagesPath': (imagesMap == null) ? '' : imagesMap,
      'records': (recordsMap == null) ? '' : recordsMap,
      'tasks': (tasksMap == null) ? '' : tasksMap,
      'isDone': (done == false) ? '0' : '1',
      'withAlarm': withAlarm == false ? '0' : '1',
      'place': placeMap == null ? '' : placeMap,
    };
    DBHelper.updateTodos({'id': id, 'todoJson': json.encode(data)})
        .then((value) {
      print('update done !');
    });
  }

  Future<void> updateInDb(String id) async {
    TodoItem item = findById(id);
    if (item == null) return;
    List<String> imagesPath = item.imagesPath;

    Map<String, String> imagesMap = Map();
    if (imagesPath != null && imagesPath.length > 0) {
      int i = 0;
      imagesPath.forEach((element) {
        imagesMap[i.toString()] = element;
        i++;
      });
    }

    List<Record> records = item.records;
    Map<String, Map<String, String>> recordsMap = Map();
    if (records != null && records.length > 0) {
      int i = 0;
      records.forEach((element) {
        recordsMap[i.toString()] = {
          'name': element.name ?? '',
          'url': element.url ?? ''
        };
        i++;
      });
    }

    List<Task> tasks = item.tasks;
    Map<String, Map<String, String>> tasksMap = Map();
    if (tasks != null && tasks.length > 0) {
      int i = 0;
      tasks.forEach((element) {
        tasksMap[i.toString()] = {
          'content': element.content ?? '',
          'id': element.id ?? '',
          'isDone': element.isDone == false ? '0' : '1',
        };
        i++;
      });
    }

    Map<String, String> placeMap = Map();
    if (item.place != null) {
      placeMap = {
        'address': item.place.address ?? '',
        'lat':
            item.place.latitude == null ? '' : item.place.latitude.toString(),
        'lng':
            item.place.longitude == null ? '' : item.place.longitude.toString(),
        'name': item.place.name ?? ''
      };
    }

    Map<String, dynamic> data = {
      'title': item.title,
      'description': (item.description == null) ? '' : item.description,
      'idCategory': (item.idCategory == null) ? '' : item.idCategory,
      'priority': item.priority.toString(),
      'deadline': (item.deadline == null) ? '' : item.deadline.toString(),
      'imagesPath': (imagesMap == null) ? '' : imagesMap,
      'records': (recordsMap == null) ? '' : recordsMap,
      'isDone': (item.isDone == false) ? '0' : '1',
      'tasks': (tasksMap == null) ? '' : tasksMap,
      'withAlarm': item.withAlarm == false ? '0' : '1',
      'place': placeMap == null ? '' : placeMap,
    };
    DBHelper.updateTodos({'id': id, 'todoJson': json.encode(data)})
        .then((value) {
      print('update!');
    });
  }

  void setDoneItem(String id, bool newVal,) {
    TodoItem item = findById(id);
    if (item.isDone == newVal) return;
    item.isDone = newVal;
    notifyListeners();

    updateInDb(id);
  }

  void deleteItem(String id, {Future<void> turnOffNotificationById(num id)}) {
    TodoItem item = findById(id);
    if (item == null) {
      print('item to delete no exist');
      return;
    }

    item.timer?.cancel();
    deleteAllImageFile(item);

    _items.removeWhere((element) => element.id == id);

    notifyListeners();
    DBHelper.deleteTodos(id);

    if (item.withAlarm) {
      resetAlarm(id, turnOffNotificationById);
    }
  }

  Future<List<ByteData>> imagesPathToByte(List<String> paths) async {
    List<ByteData> listOfData = [];
    var tmp;
    for (int i = 0; i < paths.length; i++) {
      tmp = await DBHelper.loadImageFromFile(paths[i]);
      listOfData.add(tmp);
    }
    return listOfData;
  }

  void deleteAllImageFile(TodoItem item) {
    item.imagesPath.forEach((element) {
      DBHelper.deleteImageFile(element);
    });
  }

  void deleteImageFile({TodoItem item, int index}) {
    DBHelper.deleteImageFile(item.imagesPath[index]);
    item.imagesPath.removeAt(index);
  }

  void updateCategory(String oldId, String newId) {
    List<TodoItem> items = [..._items];
    items.retainWhere((element) {
      return element.idCategory == oldId;
    });

    for (int i = 0; i < items.length; i++) {
      
      items[i].idCategory = newId;

      updateInDb(items[i].id);

      /* updateItem(
          id: items[i].id,
          title: items[i].title,
          description: items[i].description,
          idCategory: newId,
          priority: items[i].priority,
          deadline: items[i].deadline,
          tasks: items[i].tasks,
          images: [], // Aucune image a rajouter
          tmpImgsPath: [],
          newRecords: [],
          ); */
    }
  }

  void updateListOfTasks({String id, List<Task> newList}) {
    TodoItem item = _items.firstWhere((element) => element.id == id);
    print('on est la');
    updateItem(
        id: item.id,
        title: item.title,
        description: item.description,
        idCategory: item.idCategory,
        priority: item.priority,
        deadline: item.deadline,
        tasks: newList,
        images: [], // Aucune image a rajouter
        tmpImgsPath: []);
  }

  Future<void> fetchAndSetPlaces(BuildContext ctx) async {
    // TODO changer nom de fonction

    // Reset le search word si jamais on re-rentre dans la page todo overview (faire idem pour les filters?)
    // resetFilters(withListener: false);

    _wordFilter = '';

    if (_isInit) return; // On a deja fetch une fois

    final List<Map<String, dynamic>> dataList = await DBHelper.getDataTodos();

    _items = (dataList == null || dataList.length == 0)
        ? []
        : dataList.map((e) {
            String id = e['id'];
            Map<String, dynamic> jsonMap =
                json.decode(e['todoJson']) as Map<String, dynamic>;

            var imagesMap = (jsonMap['imagesPath'] as Map<String, dynamic>);
            List<String> imagesPath =
                imagesMap.values.map((e) => e as String).toList();

            var recordsMap = (jsonMap['records'] as Map<String, dynamic>);

            List<Record> records = recordsMap.values
                .map((e) => e as Map<String, dynamic>)
                .map((e) => Record(name: e['name'], url: e['url']))
                .toList();

            var tasksMap = (jsonMap['tasks'] as Map<String, dynamic>);

            List<Task> tasks = tasksMap.values
                .map((e) => e as Map<String, dynamic>)
                .map((e) => Task(
                    content: e['content'],
                    id: e['id'],
                    isDone: e['isDone'] == '0' ? false : true))
                .toList();

            var placeMap = !jsonMap.containsKey('place')
                ? null
                : (jsonMap['place'] as Map<String, dynamic>);
            print(placeMap);
            PlaceLocation place = (placeMap == null || placeMap.length == 0)
                ? null
                : PlaceLocation(
                    name: placeMap['name'] as String == ''
                        ? null
                        : placeMap['name'] as String,
                    address: placeMap['address'] as String == ''
                        ? null
                        : placeMap['address'] as String,
                    latitude: placeMap['lat'] as String == '' ||
                            placeMap['lat'] as String == 'null'
                        ? null
                        : double.parse(placeMap['lat'] as String),
                    longitude: placeMap['lng'] as String == '' ||
                            placeMap['lng'] as String == 'null'
                        ? null
                        : double.parse(placeMap['lng'] as String),
                  );

            DateTime date = (jsonMap['deadline'] as String == '')
                ? null
                : DateTime.parse(jsonMap['deadline'] as String);

            // Set Timer if In Future
            bool isInFuture = _isInFuture(date);
            Timer itemTimer = _setItemTimer(date: date, id: id);

            TodoItem tmp = TodoItem(
              id: id,
              title: jsonMap['title'] as String,
              idCategory: jsonMap['idCategory'] as String,
              description: jsonMap['description'] as String,
              priority: int.parse(jsonMap['priority'] as String),
              imagesPath: imagesPath,
              deadline: date,
              records: records,
              tasks: tasks,
              isDone: (jsonMap['isDone'] as String) == '0' ? false : true,
              withAlarm: (jsonMap['withAlarm'] as String) == '0' ? false : true,
              isInFuture: isInFuture,
              timer: itemTimer,
              place: place,
            );

            return tmp;
          }).toList();

    sortTodo();
    print('Syncro todo done');
    _isInit = true;
  }

  //// ALARM Management
  ///

  // TODO rajouter comme dans le cours sur flutter (optimistic update puis retour en arriere si erreur)
  Future<void> setAlarm(
      String todoId,
      Future<void> scheduleNotification(
          String id, String body, DateTime scheduledNotificationDateTime),
      ) async {
    TodoItem item = findById(todoId);
    if (item == null) return;

    print('On set une alarme');
    item.withAlarm = true;
    notifyListeners();

    updateInDb(todoId);

    DateTime scheduledNotificationDateTime = item.deadline;
    if (!scheduledNotificationDateTime.isAfter(DateTime.now())) {
      return;
    }
    if (scheduledNotificationDateTime == null) return;
    await scheduleNotification(
        todoId, item.title, scheduledNotificationDateTime);
  }

  Future<void> resetAlarm(
      String todoId, Future<void> turnOffNotificationById(num id),
      ) async {
    print('on reset');

    TodoItem item = findById(todoId);
    if (item == null) return;

    item.withAlarm = false;
     notifyListeners();

    updateInDb(todoId);

    int tmp = todoId.length;
    await turnOffNotificationById(int.parse(todoId.substring(tmp - 9)));
  }

  //// TIMER Management
  ///

  bool _isInFuture(DateTime date) {
    return (date == null ? false : date.isAfter(DateTime.now()));
  }

  Timer _setItemTimer({String id, DateTime date}) {
    DateTime now = DateTime.now();
    bool isInFuture = _isInFuture(date);
    Timer itemTimer;
    if (isInFuture && date.second == 0) {
      Duration diff = date.difference(now);
      itemTimer = Timer(diff, () {
        TodoItem item = findById(id);
        if (item == null) return;
        item.isInFuture = false;
        item.withAlarm = false;

        notifyListeners();
        updateInDb(id);
      });
    }
    return itemTimer;
  }
}
