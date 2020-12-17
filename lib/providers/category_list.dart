import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/category.dart';

import './todo_list.dart';

import '../helpers/db_helper.dart';
import '../helpers/color_helper.dart';

class CategoryList with ChangeNotifier {
  bool _isInit = false;

  TodoList todoListProvider;

  CategoryList({this.todoListProvider});

  void updateTodoListProvider(TodoList newTodoList) {
    this.todoListProvider = newTodoList;
  }

  bool _colorPropagation = true;
  bool _emojiPropagation = true;

  List<Category> _items = [];
  /* List<Category> _initListOfItems = [
    Category(
      name: 'Coloc',
      tree: [1],
      idKey: '1',
      children: <Category>[
        Category(
          color: Colors.red,
          name: 'Vaisselle',
          tree: [1, 1],
          idKey: '11',
        ),
        Category(
          name: 'Chambre',
          tree: [1, 2],
          idKey: '12',
          children: <Category>[
            Category(
              name: 'aspirateur',
              tree: [1, 2, 1],
              idKey: '121',
            ),
            Category(
              name: 'lessive',
              tree: [1, 2, 2],
              idKey: '122',
            )
          ],
        )
      ],
    ),
    Category(
      name: 'Travail',
      tree: [2],
      idKey: '2',
      children: <Category>[
        Category(
          name: 'Oliwood',
          tree: [2, 1],
          idKey: '21',
          children: <Category>[
            Category(
              name: 'Emballer cadeau',
              tree: [2, 1, 1],
              idKey: '211',
            ),
            Category(
              name: 'Ranger rayon',
              tree: [2, 1, 2],
              idKey: '212',
              children: <Category>[
                Category(
                  name: 'jeux de soc',
                  tree: [2, 1, 2, 1],
                  idKey: '2121',
                ),
                Category(
                  name: 'bricolage',
                  tree: [2, 1, 2, 2],
                  idKey: '2122',
                ),
                Category(
                  name: 'jeux de soc2',
                  tree: [2, 1, 2, 3],
                  idKey: '2123',
                ),
                Category(
                  name: 'jeux de soc322222',
                  tree: [2, 1, 2, 4],
                  idKey: '2124',
                ),
                Category(
                  name: 'jeux de soc4',
                  tree: [2, 1, 2, 5],
                  idKey: '2125',
                ),
                Category(
                  name: 'jeux de soc5',
                  tree: [2, 1, 2, 6],
                  idKey: '2126',
                ),
              ],
            )
          ],
        ),
        Category(
          name: 'Sciensano',
          tree: [2, 2],
          idKey: '22',
        )
      ],
    )
  ]; */

  // TODO utiliser le getter au lieu de _items quand c'est pas nécessaire de modifier la liste (ex: pour trouver un id)

  /// GETTERs ////
  ///

  List<Category> get items {
    return [..._items];
  }

  bool get colorPropagation {
    return _colorPropagation;
  }

  bool get emojiPropagation {
    return _emojiPropagation;
  }

  void setExpandedToFalse(List<Category> items) {
    items.forEach((element) {
      if (element.children != null) {
        element.expanded = false;
        setExpandedToFalse(element.children);
      }
    });
  }

  List<String> findListOfParents(String itemId) {
    final Category item = findByIdKey(itemId);
    final List<String> listOfParents = [item.name];

    Category parent = findParent(item);
    bool test = parent != null;
    while (test) {
      listOfParents.insert(0, parent.name);
      parent = findParent(parent);
      test = parent != null;
    }
    return listOfParents;
  }

  Category findParent(Category item) {
    if (item.tree.length <= 1) {
      return null;
    }
    List<int> tree = item.tree;
    Category parent = _items[tree[0] - 1];
    for (int i = 1; i < tree.length - 1; i++) {
      parent = parent.children[tree[i] - 1];
    }
    return parent;
  }

  Category findParentWithTree(List<int> tree) {
    if (tree.length <= 1) {
      return null;
    }
    Category parent = _items[tree[0] - 1];
    for (int i = 1; i < tree.length - 1; i++) {
      parent = parent.children[tree[i] - 1];
    }
    return parent;
  }

  Category findByIdKey(String id, {List<Category> searchingList}) {
    if (id == null) {
      return null;
    }
    searchingList = (searchingList == null) ? items : searchingList;
    Category item;

    for (int i = 0; i < searchingList.length; i++) {
      item = searchingList[i];

      if (item.idKey == id) {
        return item;
      }
      if (item.children != null && item.children.length > 0) {
        if (findByIdKey(id, searchingList: item.children) != null) {
          return findByIdKey(id, searchingList: item.children);
        }
      }
    }
    return null;
  }

  Category findByTree(List<int> tree) {
    if (tree == null) {
      return null;
    }
    Category item = _items[tree[0] - 1];
    for (int i = 1; i < tree.length; i++) {
      item = item.children[tree[i] - 1];
    }
    return item;
  }

  List<int> idKeyToTree(String idKey,
      {List<Category> searchingList, List<int> currentTree}) {
    if (idKey == null) {
      return null;
    }

    if (currentTree == null) currentTree = [];
    searchingList = (searchingList == null) ? items : searchingList;

    Category item;
    List<int> tmpTree = [];

    for (int i = 0; i < searchingList.length; i++) {
      item = searchingList[i];
      if (item.idKey == idKey) {
        currentTree = currentTree..add(i + 1);
        return [...currentTree];
      }

      if (item.children != null && item.children.length > 0) {
        tmpTree = [
          ...idKeyToTree(idKey,
              searchingList: item.children,
              currentTree: [...currentTree]..add(i + 1))
        ];
        if (tmpTree.length > 0) return tmpTree;
      }
    }
    return tmpTree;
  }

  void changeRecursiveTree(List<Category> itemsToChangeTree) {
    if (itemsToChangeTree == null) return;
    itemsToChangeTree.forEach((element) {
      element.tree = idKeyToTree(element.idKey, currentTree: []);
      changeRecursiveTree(element.children);
    });
  }

  void _recursiveCopy(
      Category item, List<Category> children, Color color, String emoji) {
    if (children == null) {
      item.children = null;
      return;
    }
    item.children = [];

    children.forEach((element) {
      Color newColor = (element.color != null && element.color != Colors.white)
          ? element.color
          : color;
      String newEmoji = (element.emoji != null && element.emoji != '')
          ? element.emoji
          : emoji;
      item.children.add(Category(
        tree: element.tree,
        idKey: element.idKey,
        name: element.name,
        color: newColor,
        emoji: newEmoji,
      ));
      item.children[item.children.length - 1].expanded = element.expanded;
      if (element.children != null)
        _recursiveCopy(item.children[item.children.length - 1],
            [...element.children], color, emoji);
    });
  }

  void movePosition(
      {isAddingAsChild: false, String movingItemIdKey, String beforeItemIdKey}) {
    String tempIdKey =
        isAddingAsChild ? addAsChild2(beforeItemIdKey, moveMode: true) : addAfter(beforeItemIdKey, moveMode: true);
    Category newCreateItem = findByIdKey(tempIdKey);

    Category movingItem = findByIdKey(movingItemIdKey);
    List<int> movingItemTreeToDelete = [...movingItem.tree];

    newCreateItem.name = movingItem.name;
    newCreateItem.expanded = movingItem.expanded;
    if (movingItem.color != null && movingItem.color != Colors.white)
      newCreateItem.color = movingItem.color;
    if (movingItem.emoji != null && movingItem.emoji != '')
      newCreateItem.emoji = movingItem.emoji;

    if (movingItem.children != null) {
      _recursiveCopy(
          newCreateItem,
          [...movingItem.children],
          newCreateItem.color,
          newCreateItem.emoji);
    }

    changeRecursiveTree([newCreateItem]);

    delete(
      movingItemIdKey,
      moveMode: true,
      treeToDelete: movingItemTreeToDelete,
    );

    newCreateItem.idKey = movingItemIdKey;

    saveInDB();
    notifyListeners();
  }

  String addAsChild2(String idKey, {String namedIdKey, bool moveMode = false}) {
    Category parent = findByIdKey(idKey);
    List<int> newTree = [...idKeyToTree(idKey, currentTree: [])];
    newTree.add(1);
    String newIdKey = namedIdKey ?? DateTime.now().toString();
    if (parent.children == null) {
      parent.children = <Category>[
        Category(
          tree: newTree,
          name: '',
          idKey: newIdKey,
          color: _colorPropagation ? parent.color : Colors.white,
          emoji: _emojiPropagation ? parent.emoji : '',
        )
      ];
    } else {
      parent.children.insert(
          0,
          Category(
            tree: newTree,
            idKey: newIdKey,
            name: '',
            color: _colorPropagation ? parent.color : Colors.white,
            emoji: _emojiPropagation ? parent.emoji : '',
          ));

      changeRecursiveTree(parent.children.sublist(1));
    }
    parent.expanded = true;

    if (!moveMode) {
      saveInDB();
      notifyListeners();
    }

    return newIdKey;
  }

  String addAfter(String idKey, {String namedIdKey, bool moveMode = false}) {
    List<int> tree;
    List<int> newTree;
    int lastDigit;
    Category parent;

    if (idKey == '') {
      newTree = [1];
      lastDigit = 1;
      parent = null;
    } else {
      tree = idKeyToTree(idKey, currentTree: []);
      newTree = [...tree];
      lastDigit = tree[tree.length - 1] + 1;
      newTree[tree.length - 1] = lastDigit;
      parent = findParent(findByIdKey(idKey));
    }

    String newIdKey = namedIdKey ?? DateTime.now().toString();

    if (parent == null) {
      _items.insert(
        lastDigit - 1,
        Category(
          tree: newTree,
          name: '',
          idKey: newIdKey,
        ),
      );
      changeRecursiveTree(_items.sublist(lastDigit));
    } else {
      parent.children.insert(
        lastDigit - 1,
        Category(
          tree: newTree,
          name: '',
          idKey: newIdKey,
          color: _colorPropagation ? parent.color : Colors.white,
          emoji: _emojiPropagation ? parent.emoji : '',
        ),
      );
      changeRecursiveTree(parent.children.sublist(lastDigit));
    }
    if (!moveMode) {
      saveInDB();
      notifyListeners();
    }

    return newIdKey;
  }

  // DELETE METHOD

  void delete(String idKey, {bool moveMode = false, List<int> treeToDelete}) {
    Category itemToDelete = findByIdKey(idKey);
    treeToDelete = treeToDelete ?? itemToDelete.tree;
    if (moveMode) {
      itemToDelete.children = null;
    }

    if (itemToDelete.children != null) {
      for (int i = itemToDelete.children.length - 1; i >= 0; i--) {
        delete(itemToDelete.children[i].idKey);
      }
    }

    itemToDelete.children = null;

    Category parent = findParentWithTree(treeToDelete);
    List<Category> children = (parent == null) ? _items : parent.children;

    if (!moveMode)
      todoListProvider.updateCategory(
          idKey, parent == null ? '' : parent.idKey);

    int p = treeToDelete.length - 1;
    children.removeAt(treeToDelete[p] - 1);
    if (children.length == 0) {
      children = null;
      if (parent != null) parent.children = null;
    } else {
      changeRecursiveTree(children.sublist(treeToDelete[p] - 1));
    }

    if (!moveMode) {
      saveInDB();
      notifyListeners();
    }
  }

  /////// UPDATE DE PROPRIETES //////////////////////

  void updateColor(
    String idKey,
    Color color, {
    bool recursiveChildrenMod = false,
    Category itemArg,
  }) {
    Category item = itemArg ?? findByIdKey(idKey);
    if (item == null) return;
    Color oldColor = item.color;
    item.color = color;
    if (item.children != null && _colorPropagation) {
      item.children.forEach((element) {
        if (element.color == oldColor || element.color == Colors.white) {
          updateColor(
            element.idKey,
            color,
            itemArg: element,
            recursiveChildrenMod: true,
          );
        }
      });
    }
    if (recursiveChildrenMod) return;
    saveInDB();
    notifyListeners();
  }

  void updateEmoji(
    String idKey,
    String emoji, {
    bool recursiveChildrenMod = false,
    Category itemArg,
  }) {
    Category item = itemArg ?? findByIdKey(idKey);
    if (item == null) return;
    String oldEmoji = item.emoji;
    item.emoji = emoji;
    if (item.children != null && _emojiPropagation) {
      item.children.forEach((element) {
        if (element.emoji == oldEmoji || element.emoji == '') {
          updateEmoji(
            element.idKey,
            emoji,
            itemArg: element,
            recursiveChildrenMod: true,
          );
        }
      });
    }
    if (recursiveChildrenMod) return;
    saveInDB();
    notifyListeners();
  }

  void updateName(String idKey, String name) {
    Category item = findByIdKey(idKey);
    if (item == null) return;
    item.name = name;
    saveInDB();
    notifyListeners();
  }

  /////////////////// Settings de la construction de category //////////////

  void settings({bool colorPropagation, bool emojiPropagation}) {
    _colorPropagation = colorPropagation ?? _colorPropagation;
    _emojiPropagation = emojiPropagation ?? _emojiPropagation;
  }

  /////////////////// GESTION DB ///////////////////////:

  Map<String, dynamic> mappingCat(Category category) {
    Map<String, dynamic> childrenMap = Map();
    if (category.children != null) {
      for (int i = 0; i < category.children.length; i++) {
        childrenMap[i.toString()] = mappingCat(category.children[i]);
      }
    }

    Map<String, dynamic> treeMap = Map();
    if (category.tree != null) {
      for (int i = 0; i < category.tree.length; i++) {
        treeMap[i.toString()] = category.tree[i].toString();
      }
    }

    Map<String, dynamic> data = {
      'name': category.name,
      'tree': treeMap,
      'idKey': category.idKey,
      'color': category.color.toHex(),
      'emoji': category.emoji,
      'children': (category.children == null) ? '' : childrenMap,
    };
    return data;
  }

  Future<void> saveInDB() async {
    Map<String, dynamic> dataMap = Map();

    int i = 0;
    _items.forEach((element) {
      dataMap[i.toString()] = mappingCat(element);
      i++;
    });

    String data = json.encode(dataMap);
    DBHelper.insertCategory({'id': '1', 'categoryJson': data});
  }

  List<Category> decodeMappingCat(Map<String, dynamic> mapOfCat) {
    List<Category> items = [];

    mapOfCat.values.forEach((element) {
      var item = element;
      var treeMap = item['tree'] as Map<dynamic, dynamic>;
      List<int> tree = (treeMap).values.map((e) => int.parse(e)).toList();

      items.add(Category(
          name: item['name'],
          tree: tree,
          idKey: item['idKey'],
          color: HexColor.fromHex(item['color']),
          emoji: item['emoji'],
          children: item['children'] == ''
              ? null
              : decodeMappingCat(item['children'])));
    });

    return items;
  }

  Future<void> fetchAndSetCategory() async {
    if (_isInit) return; // On a deja fetch une fois
    _isInit = true;

    final List<Map<String, dynamic>> dataList =
        await DBHelper.getDataCategory();
    print(dataList.toString());

    if (dataList.length == 0) {
      _items = []; //_initListOfItems;
      await saveInDB();
      return;
    }

    Map<String, dynamic> jsonMap =
        json.decode(dataList[0]['categoryJson']) as Map<String, dynamic>;

    _items = decodeMappingCat(jsonMap);

    print("syncro categorie done");
  }
}
