/* // TODO: todos repetables
// TODO: bug si on lance le bottomsheet des catégories, meme si on selectionne rien => considère qu'il y a eu un changement et demande confirmation de sauver sans chmt
// TODO: mettre focus sur titre qd on rajoute un todo

// TODO: plus de cohérence avec _editedTodo

import 'dart:io' as io;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todo_marie/models/task.dart';
import 'package:todo_marie/widgets/delete_button.dart';
import 'package:todo_marie/suppress/tasks_view.dart';
/* import 'package:keyboard_visibility/keyboard_visibility.dart'; */
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:todo_marie/widgets/todo_form_screen/alarm_choice.dart';

import '../providers/todo_list.dart';
import '../providers/category_list.dart';
import '../providers/notification_provider.dart';

import '../models/category.dart';
import '../models/record.dart';
import '../models/place.dart';
import '../models/todo_item.dart';

import '../widgets/todo_form_screen/category_choice.dart';
import '../widgets/todo_form_screen/date_choice.dart';
import '../widgets/todo_form_screen/time_choice.dart';
import '../widgets/todo_form_screen/priority_choice.dart';
import '../widgets/todo_form_screen/images_picker.dart';
import '../widgets/todo_form_screen/audio_recorder.dart';
import '../widgets/todo_form_screen/map/location_input.dart';
import '../widgets/todo_form_screen/date_section.dart';

class TodoFormScreen extends StatefulWidget {
  static const routeNamed = '/edit-todo';
  @override
  _TodoFormScreenState createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends State<TodoFormScreen> {
  final _descriptionFocusNode = FocusNode();

  final _form = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _titleScreen = "Add todo item";

  TodoItem _editedTodo = TodoItem();
  String _todoItemId;

  String _title = '';
  String _description = '';
  DateTime _selectedDate;
  TimeOfDay _selectedTime;
  Category _selectedCategory;
  int _selectedPriority = 0;
  List<ByteData> _selectedImages = [];
  List<Record> _records = [];

  List<String> _tmpImgsPath =
      []; // Liste des chemins des images, temporaire avant que le form soit save => permet qd on save de comparer _tmpImgsPath et todoItem.imagesPath préexistant et déterminer les images qui ont été supprimées entre temps pour les delete des dossiers.
  List<Task> _listOfTasks = [];

  bool _isInit = true;
  bool _isLoading = false;
  bool _addRecordsWithoutSave = false;
  bool _isSaveWithoutChange = true;
  bool _addingNewItem = false;
  bool _isAddingTask = false;
  bool _withAlarm = false;
  bool _previousAlarm = false;
  bool _isInFuture = false;

  Timer _timer;

  PlaceLocation _pickedLocation;

  @override
  void initState() {
    super.initState();

    // Subscribe
    KeyboardVisibility.onChange.listen((bool visible) {
      if (!visible && !_isAddingTask) {
        print("On rentre dans le listener");
        if (_listOfTasks.length > 0 && _listOfTasks.last.content == '') {
          print('deleting with list');
          _deletingTask(id: _listOfTasks.last.id, isEmpty: true);
        }
        //Future.delayed(Duration(milliseconds: 300), () {
        _unFocus(list: true);
        //  });
      }
    });
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      print('Init du formulaire');

      // On récupère l'éventuel id du todo si c'est un update
      var tmp =
          (ModalRoute.of(context).settings.arguments as Map<String, dynamic>);
      _todoItemId =
          (tmp != null && tmp.containsKey('id')) ? tmp['id'] as String : null;

      if (_todoItemId != null) {
        /////////////////////////////////
        // Cas 1: on est sur un update //
        /////////////////////////////////

        _titleScreen = "Edit todo item";
        // On enregistre l'item dans _editedTodo pour initialiser toutes les valeurs
        _editedTodo = Provider.of<TodoList>(context, listen: false).findById(
            _todoItemId); // Attention: comme _editedTodo est en listen false, tout se gere via les setState!

        _title = _editedTodo.title;
        _description = _editedTodo.description;
        _selectedCategory = Provider.of<CategoryList>(context, listen: false)
            .findByIdKey(_editedTodo.idCategory);
        _selectedPriority = _editedTodo.priority;

        if (_editedTodo.deadline != null) {
          _selectedDate = DateTime(_editedTodo.deadline.year,
              _editedTodo.deadline.month, _editedTodo.deadline.day);
          _selectedTime = TimeOfDay(
              hour: _editedTodo.deadline.hour,
              minute: _editedTodo.deadline.minute);
          _withAlarm = _editedTodo.withAlarm;
          DateTime date = _selectedDate.add(
            Duration(
              hours: _selectedTime.hour,
              minutes: _selectedTime.minute,
            ),
          );
          DateTime now = DateTime.now();
          _isInFuture = (date.isAfter(now));
        }

        // On créé une copie des objets (pour éviter les conflits avec _ediedTodo) //

        // a. records
        if (_editedTodo.records != null && _editedTodo.records.length > 0) {
          _editedTodo.records.forEach((element) {
            _records.add(Record(
                name: element.name.toString(), url: element.url.toString()));
          });
        }

        // b. tasks
        if (_editedTodo.tasks != null && _editedTodo.tasks.length > 0) {
          _editedTodo.tasks.forEach((element) {
            _listOfTasks.add(Task(
                content: element.content,
                isDone: element.isDone,
                id: element.id));
          });
        }

        // c. images (prend un certain temps)
        if (_editedTodo.imagesPath != null) {
          setState(() {
            _isLoading = true;
          });
          _tmpImgsPath = [..._editedTodo.imagesPath];
          Provider.of<TodoList>(context, listen: false)
              .imagesPathToByte(_tmpImgsPath)
              .then((value) {
            setState(() {
              for (int i = 0; i < value.length; i++) {
                _selectedImages.add(value[i]);
              }
              _isLoading = false;
            });
          });
        }

       
        //_resetTimer();
      } else {
        /////////////////////////////////
        // Cas 2: on est sur une créa. //
        /////////////////////////////////
        _todoItemId = DateTime.now()
            .millisecondsSinceEpoch
            .toString()
            .replaceAll(' ', '');
        // If we add item at a specific date (depuis le calendar screen)
        _selectedDate = (tmp != null && tmp.containsKey('initDate'))
            ? tmp['initDate'] as DateTime
            : null;
        //_resetTimer();
        _addingNewItem = true;
      }
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    //_timer?.cancel();
    if (_addRecordsWithoutSave) {
      List<Record> savedRecords = _editedTodo.records ?? [];
      if (_records != null) {
        for (int i = 0; i < _records.length; i++) {
          bool test = true;
          String url = _records[i].url;
          for (int j = 0; j < savedRecords.length; j++) {
            if (savedRecords[j].url == url) {
              test = false;
              break;
            }
          }
          if (test) io.File(url).delete();
        }
      }
    }
    _selectedImages = [];
    super.dispose();
  }

  void _deletingTask({String id, bool isEmpty = false}) {
    if (!isEmpty) _isSaveWithoutChange = false;
    setState(() {
      _listOfTasks.removeWhere((element) => element.id == id);
    });
  }

  Future<bool> _addATask(Task item) async {
    _isSaveWithoutChange = false;

    setState(() {
      _isAddingTask = true;
    });

    _unFocus();

    bool test = await Future.delayed(Duration(milliseconds: 500), () {
      bool out = true;
      if (_listOfTasks.length > 0 && _listOfTasks.last.content == '') {
        _deletingTask(id: _listOfTasks.last.id, isEmpty: true);
        out = false;
      }

      setState(() {
        _listOfTasks.add(item);
        _isAddingTask = false;
      });
      return out;
    });

    return test;
  }

  void _unFocus({bool list = false}) {
    if (context == null) return;
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  Future<bool> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return false; // fail in save, can't save
    }

    _form.currentState.save();

    setState(() {
      _isLoading = true;
    });

    print('title ' + _title);
    if (_addingNewItem) {
      await Provider.of<TodoList>(context, listen: false).addItem(
        title: _title,
        idCategory: _selectedCategory == null ? '' : _selectedCategory.idKey,
        description: _description,
        priority: _selectedPriority,
        images: _selectedImages,
        deadline: (_selectedDate == null)
            ? null
            : (_selectedTime == null)
                ? _selectedDate
                : _selectedDate.add(
                    Duration(
                      hours: _selectedTime.hour,
                      minutes: _selectedTime.minute,
                    ),
                  ),
        id: _todoItemId,
        records: _records,
        tasks: _listOfTasks,
        withAlarm: _withAlarm,
      );

      // On save l'item à ce stade
      _editedTodo =
          Provider.of<TodoList>(context, listen: false).findById(_todoItemId);

      _tmpImgsPath = [..._editedTodo.imagesPath];

      if (_withAlarm == true) {
        Function scheduleNotification =
            Provider.of<NotificationProvider>(context, listen: false)
                .scheduleNotification;
        Provider.of<TodoList>(context, listen: false)
            .setAlarm(_todoItemId, scheduleNotification);
      }

      _addingNewItem = false;
    } else {
      /////////////
      /// Update //
      /////////////

      await Provider.of<TodoList>(context, listen: false).updateItem(
        id: _todoItemId,
        title: _title,
        idCategory: _selectedCategory == null ? '' : _selectedCategory.idKey,
        description: _description,
        priority: _selectedPriority,
        images: _selectedImages,
        deadline: (_selectedDate == null)
            ? null
            : (_selectedTime == null)
                ? _selectedDate
                : _selectedDate.add(
                    Duration(
                      hours: _selectedTime.hour,
                      minutes: _selectedTime.minute,
                    ),
                  ),
        newRecords: _records,
        tasks: _listOfTasks,
        tmpImgsPath: _tmpImgsPath,
        withAlarm: _withAlarm,
      );
    }

    /////////////////////////
    // Gestion des alarmes //
    /////////////////////////
    bool previousAlarm = _editedTodo.withAlarm;

    if (_withAlarm) {
      DateTime previousDate = _editedTodo.deadline;

      // Si une autre alarme existait à un autre moment avant l'update: il faut la reset
      bool c = previousDate != null &&
          _selectedDate != null &&
          _selectedTime != null &&
          (previousDate.compareTo(_selectedDate.add(
                Duration(
                  hours: _selectedTime.hour,
                  minutes: _selectedTime.minute,
                ),
              )) !=
              0) &&
          previousAlarm;

      if (c) {
        Function turnOffNotificationById =
            Provider.of<NotificationProvider>(context, listen: false)
                .turnOffNotificationById;
        Provider.of<TodoList>(context, listen: false)
            .resetAlarm(_todoItemId, turnOffNotificationById);
      }

      // On ajoute l'alarme, mais seulement si elle n'existe pas deja à la meme heure
      c = previousDate != null &&
          _selectedDate != null &&
          _selectedTime != null &&
          (previousDate.compareTo(_selectedDate.add(
                Duration(
                  hours: _selectedTime.hour,
                  minutes: _selectedTime.minute,
                ),
              )) ==
              0) &&
          previousAlarm;

      if (!c) {
        Function scheduleNotification =
            Provider.of<NotificationProvider>(context, listen: false)
                .scheduleNotification;
        Provider.of<TodoList>(context, listen: false)
            .setAlarm(_todoItemId, scheduleNotification);
      }
    }

    // Si l'alarme était mise et qu'on l'a désactivée => on la reset
    if (_withAlarm == false && _previousAlarm == true) {
      Function turnOffNotificationById =
          Provider.of<NotificationProvider>(context, listen: false)
              .turnOffNotificationById;
      Provider.of<TodoList>(context, listen: false)
          .resetAlarm(_todoItemId, turnOffNotificationById);
    }

    // On save l'item à ce stade
    _editedTodo =
        Provider.of<TodoList>(context, listen: false).findById(_todoItemId);

    _tmpImgsPath = [..._editedTodo.imagesPath];

    _addRecordsWithoutSave = false;
    _previousAlarm = _withAlarm;

    setState(() {
      _isLoading = false;
    });

    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Saved'),
      duration: Duration(seconds: 1),
    ));
    _isSaveWithoutChange = true;

    return true; // Sucess in save
  }

  ///// GESTION DE LA PLACE
  ///
  ///

  void _selectPlace(double lat, double lng) {
    _pickedLocation = PlaceLocation(latitude: lat, longitude: lng);
  }

  /// Fonctions qui se triggers depuis autres widgets
  ///
  ///

  void _changeOccur({bool value, String taskId}) {
    _isSaveWithoutChange = false;
  }

  void _setImages(List<ByteData> value,
      {int indexDelete, bool isUpdate = false}) {
    if (isUpdate) _isSaveWithoutChange = false;
    _selectedImages = [...value];
    // Si on a delete une image depuis le picker, on veut aussi le delete de son dossier.
    if (_todoItemId == null || indexDelete == null) return;

    if (indexDelete < _tmpImgsPath.length) {
      _tmpImgsPath.removeAt(indexDelete);
      /* Provider.of<TodoList>(context, listen: false)
          .deleteImageFile(item: todoItem, index: indexDelete); */
    }
  }

  void _addRecord(Record record) {
    _isSaveWithoutChange = false;
    _addRecordsWithoutSave = true;
    _records.add(record);
  }

  void _deleteRecord(int index) {
    _isSaveWithoutChange = false;
    _records.removeAt(index);
  }

  void _selectCategory(Category value) {
    _isSaveWithoutChange = false;
    _selectedCategory = value;
  }

  void _selectPriority(int value) {
    _isSaveWithoutChange = false;
    _selectedPriority = value;
  }

  ///////////// Gestion de la date

  void _selectTime(TimeOfDay value) {
    _isSaveWithoutChange = false;
    _selectedTime = value;

    /* _resetTimer();

    if (value == null) _withAlarm = false; */
  }

  void _selectDate(DateTime value) {
    //if (_timer != null) _timer.cancel();
    _isSaveWithoutChange = false;

    _selectedDate = value;
    /* _resetTimer();

    if (value == null) _withAlarm = false; */
  }

  void _setAlarm(bool val) {
    _isSaveWithoutChange = false;

    _withAlarm = val;
  }


  /// BUILD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (!_isSaveWithoutChange) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Are you sure ?'),
                  content: Text('Do you want to go back without saving ?'),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(false);
                      },
                      child: Text('Save changes'),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(true);
                      },
                      child: Text('No save'),
                    )
                  ],
                ),
              ).then((res) {
                if (res == null) return;
                if (res == false) {
                  _saveForm().then((sucess) {
                    if (sucess) Navigator.of(context).pop();
                  });
                } else {
                  Navigator.of(context).pop();
                }
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(_titleScreen),
        actions: <Widget>[
          if (_todoItemId != null && _addingNewItem == false)
            DeleteButton(
              objectToDelete: 'Todo item',
              ifDelete: () {
                Provider.of<TodoList>(context, listen: false).deleteItem(
                    _todoItemId,
                    turnOffNotificationById: Provider.of<NotificationProvider>(
                            context,
                            listen: false)
                        .turnOffNotificationById);
              },
            ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              // FORMULAIRE
              child: Form(
                key: _form,
                child: Container(
                  height: 700,
                  child: ListView(
                    children: <Widget>[
                      TextFormField(
                          // TITLE
                          initialValue: _title, //_initValues['title'],
                          decoration: InputDecoration(
                            labelText: 'Title',
                          ),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(
                              _descriptionFocusNode,
                            ); // When this input is submitted, the focus is gived to the TextFormFild wich have focusNode: _priceFocusNode
                          },
                          onSaved: (value) {
                            _title = value;
                            /* _editedTodo = TodoItem(
                              description: _editedTodo.description,
                              id: _editedTodo.id,
                              title: value,
                              idCategory: _editedTodo.idCategory,
                            ); */
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please provide a title.';
                            }
                            return null;
                          },
                          onChanged: (_) {
                            if (_isSaveWithoutChange)
                              _isSaveWithoutChange = false;
                          }),
                      LimitedBox(
                        maxHeight: 200,
                        child: TextFormField(
                          // DESCRIPTION(must be multiline)
                          initialValue:
                              _description, //_initValues['description'],
                          decoration: InputDecoration(
                            labelText: 'Description',
                          ),
                          minLines: 2,
                          maxLines: null, // How many line that your want
                          keyboardType: TextInputType
                              .multiline, // need to remove "textInputAction: TextInputAction.next" to accept multiline
                          focusNode: _descriptionFocusNode,
                          onSaved: (value) {
                            _description = value;
                            /* _editedTodo = TodoItem(
                              description: value,
                              id: _editedTodo.id,
                              title: _editedTodo.title,
                              idCategory: _editedTodo.idCategory,
                            ); */
                          },
                          onChanged: (_) {
                            if (_isSaveWithoutChange)
                              _isSaveWithoutChange = false;
                          },
                          /* validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter a description.';
                                }
                                return null;
                              }, */
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TasksView(
                        listOfTask: _listOfTasks,
                        addATask: _addATask,
                        todoId: _todoItemId,
                        deletingTask: _deletingTask,
                        changeOccur: _changeOccur,
                        isInFormMode: true,
                      ),
                      CategoryChoice(_selectedCategory, _selectCategory),
                      DateSection(
                        setAlarm: _setAlarm,
                        selectDate: _selectDate,
                        selectTime: _selectTime,
                        initDate: _selectedDate,
                        initTime: _selectedTime,
                      ),
                      /* DateChoice(_selectedDate, _selectDate),
                      TimeChoice(_selectedTime, _selectTime),
                      if (_isInFuture)
                        AlarmChoice(
                          date: _selectedDate.add(
                            Duration(
                              hours: _selectedTime.hour,
                              minutes: _selectedTime.minute,
                            ),
                          ),
                          setAlarm: _setAlarm,
                          withAlarm: _withAlarm,
                        ),
                      if (_selectedDate != null &&
                          _selectedTime != null &&
                          _selectedDate
                              .add(
                                Duration(
                                  hours: _selectedTime.hour,
                                  minutes: _selectedTime.minute,
                                ),
                              )
                              .isBefore(DateTime.now()))
                        Text(
                          'Be careful, you select a past date',
                          style: TextStyle(color: Colors.red),
                        ), */
                      PriorityChoice(_selectedPriority, _selectPriority),
                      LocationInput( onSelectPlace: _selectPlace),
                      ImagesPicker(_setImages, _selectedImages),
                      SizedBox(
                        height: 15,
                      ),
                      AudioRecorder(
                        id: _todoItemId,
                        addRecord: _addRecord,
                        records: _records,
                        deleteRecord: _deleteRecord,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
 */