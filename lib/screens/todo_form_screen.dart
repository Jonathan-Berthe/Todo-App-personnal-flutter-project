// TODO: todos repetables
// TODO: bug si on lance le bottomsheet des catégories, meme si on selectionne rien => considère qu'il y a eu un changement et demande confirmation de sauver sans chmt

import 'dart:io' as io;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todo_marie/models/task.dart';
import 'package:todo_marie/widgets/reutilisable_widgets/delete_button.dart';

import '../providers/todo_list.dart';
import '../providers/category_list.dart';
import '../providers/notification_provider.dart';

import '../models/category.dart';
import '../models/record.dart';
import '../models/place.dart';
import '../models/todo_item.dart';

import '../widgets/todo_form_screen/category_choice.dart';
import '../widgets/todo_form_screen/priority_choice.dart';
import '../widgets/todo_form_screen/images_picker.dart';
import '../widgets/todo_form_screen/audio_recorder.dart';
import '../widgets/todo_form_screen/map/location_input.dart';
import '../widgets/todo_form_screen/date/date_section.dart';
import '../widgets/todo_form_screen/text_section.dart';
import '../widgets/task_content.dart/tasks_view_form.dart';



class TodoFormScreen extends StatefulWidget {
  static const routeNamed = '/edit-todo';

  const TodoFormScreen();

  @override
  _TodoFormScreenState createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends State<TodoFormScreen> {

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
  bool _withAlarm = false;
  bool _previousAlarm = false;

  PlaceLocation _pickedLocation;

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

          // No null seconds => code to see that there is no time selected
          _selectedTime = _editedTodo.deadline.second != 0
              ? null
              : TimeOfDay(
                  hour: _editedTodo.deadline.hour,
                  minute: _editedTodo.deadline.minute);
          _withAlarm = _editedTodo.withAlarm;
          _previousAlarm = _withAlarm;
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

        // d. place

        if (_editedTodo.place != null) {
          _pickedLocation = PlaceLocation(
            latitude: _editedTodo.place.latitude,
            longitude: _editedTodo.place.longitude,
            address: _editedTodo.place.address,
            name: _editedTodo.place.name,
          );
        }
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
        _addingNewItem = true;
      }
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  void dispose() {
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

  ///////////// SAVE DU FORMULAIRE

  Future<bool> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      final snackBar = SnackBar(content: Text('Please provide a title'));
      // Find the Scaffold in the widget tree and use it to show a SnackBar.
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(snackBar);

      return false; // fail in save, can't save
    }

    _form.currentState.save();

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
                ? DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    0,
                    0,
                    1,
                  ) // 1 seconds => code to see that there is no time selected
                : DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _selectedTime.hour,
                    _selectedTime.minute,
                  ),
        id: _todoItemId,
        records: _records,
        tasks: _listOfTasks,
        withAlarm: _withAlarm,
        place: _pickedLocation,
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
                ? DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    0,
                    0,
                    1,
                  ) // 1 seconds => code to see that there is no time selected
                //? _selectedDate
                : DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _selectedTime.hour,
                    _selectedTime.minute,
                  ),
        newRecords: _records,
        tasks: _listOfTasks,
        tmpImgsPath: _tmpImgsPath,
        withAlarm: _withAlarm,
        place: _pickedLocation,
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
          (previousDate.compareTo(DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _selectedTime.hour,
                  _selectedTime.minute)) !=
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
          (previousDate.compareTo(DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _selectedTime.hour,
                  _selectedTime.minute)) ==
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

    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Saved'),
      duration: Duration(seconds: 1),
    ));
    _isSaveWithoutChange = true;

    return true; // Sucess in save
  }

  ////////////////// Gestion des images

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

  ////////////// Gestion des records

  void _addRecord(Record record) {
    _isSaveWithoutChange = false;
    _addRecordsWithoutSave = true;
    _records.add(record);
  }

  void _deleteRecord(int index) {
    _isSaveWithoutChange = false;
    _records.removeAt(index);
  }

  //////////// Gestion de la catégorie

  void _selectCategory(Category value) {
    _isSaveWithoutChange = false;
    _selectedCategory = value;
  }

  ///////////// Gestion de la priority

  void _selectPriority(int value) {
    _isSaveWithoutChange = false;
    _selectedPriority = value;
  }

  ///////////// Gestion de la date

  void _selectTime(TimeOfDay value) {
    _isSaveWithoutChange = false;
    _selectedTime = value;
  }

  void _selectDate(DateTime value) {
    _isSaveWithoutChange = false;
    _selectedDate = value;
  }

  void _setAlarm(bool val) {
    _isSaveWithoutChange = false;
    _withAlarm = val;
  }

  //////////// Gestion des tasks

  void _changeOccurInTasks({bool value, String taskId}) {
    _isSaveWithoutChange = false;
  }

  void _deletingTask({String id, bool isEmpty = false}) {
    if (!isEmpty) _isSaveWithoutChange = false;
    _listOfTasks.removeWhere((element) => element.id == id);
  }

  void _addATask(Task item) {
    _isSaveWithoutChange = false;
    _listOfTasks.add(item);
  }

  void _onReorder(int oldIndex, int newIndex) {
    _isSaveWithoutChange = false;
    final Task item = _listOfTasks.removeAt(oldIndex);
    _listOfTasks.insert(newIndex, item);
  }

  /////// GESTION DE LA PLACE

  void _changeOccurInPlace({bool value, String taskId}) {
    _isSaveWithoutChange = false;
  }

  void _selectPlace(double lat, double lng, String address, String name) {
    _isSaveWithoutChange = false;

    if (lat == null &&
        lng == null &&
        (address == null || address == '') &&
        (name == null || name == '')) {
      _pickedLocation = null;
      return;
    }
    print(name);
    _pickedLocation = PlaceLocation(
        latitude: lat, longitude: lng, address: address, name: name);
  }

  //////// Gestion des textfields

  void _changeOccurInText({bool value, String taskId}) {
    if (_isSaveWithoutChange) _isSaveWithoutChange = false;
  }

  void _setTitle(String title) {
    if (_title == title) return;
    _isSaveWithoutChange = false;
    _title = title;
  }

  void _setDescription(String descr) {
    if (_description == descr) return;
    _isSaveWithoutChange = false;
    _description = descr;
  }

  ///// Si on veut delete un item

  void _ifDelete() {
    Provider.of<TodoList>(context, listen: false).deleteItem(_todoItemId,
        turnOffNotificationById:
            Provider.of<NotificationProvider>(context, listen: false)
                .turnOffNotificationById);
  }

  ///// Si on veut retourner en arrière

  void _ifBack() {
    if (!_isSaveWithoutChange) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Are you sure ?'),
          content: const Text('Do you want to go back without saving ?'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(ctx).pop(false);
              },
              child: const Text('Save changes'),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(ctx).pop(true);
              },
              child: const Text('No save'),
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
  }

  /// BUILD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _ifBack,
        ),
        title: Text(_titleScreen),
        actions: <Widget>[
          if (_todoItemId != null && _addingNewItem == false)
            DeleteButton(
              objectToDelete: 'Todo item',
              ifDelete: _ifDelete,
            ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: const CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              // FORMULAIRE
              child: Form(
                key: _form,
                child: Container(
                  height: 700,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        TextSection(
                          changeOccur: _changeOccurInText,
                          description: _description,
                          title: _title,
                          setTitle: _setTitle,
                          setDescription: _setDescription,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TasksViewForm(
                          listOfTask: _listOfTasks,
                          addATask: _addATask,
                          todoId: _todoItemId,
                          deletingTask: _deletingTask,
                          changeOccur: _changeOccurInTasks,
                          isInFormMode: true,
                          onReorder: _onReorder,
                        ),
                        CategoryChoice(_selectedCategory, _selectCategory),
                        DateSection(
                          setAlarm: _setAlarm,
                          selectDate: _selectDate,
                          selectTime: _selectTime,
                          initDate: _selectedDate,
                          initTime: _selectedTime,
                          initAlarm: _withAlarm,
                        ),
                        PriorityChoice(_selectedPriority, _selectPriority),
                        LocationInput(
                          onSelectPlace: _selectPlace,
                          initLocation: _pickedLocation,
                          changeOccur: _changeOccurInPlace,
                        ),
                        ImagesPicker(_setImages, _selectedImages),
                        const SizedBox(
                          height: 15,
                        ),
                        AudioRecorder(
                          id: _todoItemId,
                          addRecord: _addRecord,
                          records: _records,
                          deleteRecord: _deleteRecord,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
