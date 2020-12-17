import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/category_screen/category_list_widget.dart';
import '../widgets/category_screen/settings.dart';
import '../widgets/drawer/app_drawer.dart';

import '../providers/category_list.dart';

class CategoryScreen extends StatefulWidget {
  static const routeNamed = '/category';
  const CategoryScreen({Key key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  //List<int> _isEditingId = [];
  String _isEditingId = '';

  /* void _setIsEditingId(List<int> id) {
    setState(() {
      _isEditingId = id;
    });
  } */

  void _setIsEditingId(String id) {
    setState(() {
      _isEditingId = id;
    });
  }

  void _settings({bool colorPropagation, bool emojiPropagation}) {
    Provider.of<CategoryList>(context, listen: false).settings(
        colorPropagation: colorPropagation, emojiPropagation: emojiPropagation);
  }

  @override
  Widget build(BuildContext context) {
    CategoryList _provider = Provider.of<CategoryList>(context);

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text('Editing Categories'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Row(
                        children: <Widget>[
                          InkWell(
                            child: Icon(Icons.arrow_back),
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          const Text('Settings'),
                        ],
                      ),
                      content: SettingsCat(
                        colorPropagation: _provider.colorPropagation,
                        emojiPropagation: _provider.emojiPropagation,
                        settings: _settings,
                      ),
                    );
                  });
            },
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (MediaQuery.of(context).viewInsets.bottom > 0.0) {
            // On enlève le focus et reset les edits des catégorie si on tape et SI le keyBoard est ouvert => MediaQuery.of(context).viewInsets.bottom > 0
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            _setIsEditingId('');
          }
        },
        child: CategoryListWidget(_isEditingId, _setIsEditingId, _provider),
      ),
      drawer: const AppDrawer(),
    );
  }
}
