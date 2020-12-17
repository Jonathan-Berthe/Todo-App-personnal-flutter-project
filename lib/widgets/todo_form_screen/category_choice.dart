import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/category_list.dart';
import '../../models/category.dart';

class CategoryChoice extends StatefulWidget {
  final Category selectedCategory;
  final Function selectCategory;
  const CategoryChoice(this.selectedCategory, this.selectCategory, {Key key})
      : super(key: key);

  @override
  _CategoryChoiceState createState() => _CategoryChoiceState();
}

class _CategoryChoiceState extends State<CategoryChoice> {
  Category _selectedCategory;

  @override
  void initState() {
    _selectedCategory = widget.selectedCategory;
    super.initState();
  }

  void _selectCategory(String selectedCategoryIdKey) {
    setState(() {
      _selectedCategory =
          (selectedCategoryIdKey == null || selectedCategoryIdKey == '')
              ? null
              : Provider.of<CategoryList>(context, listen: false)
                  .findByIdKey(selectedCategoryIdKey);
      widget.selectCategory(_selectedCategory);
    });
  }

  void _presentCategoryPicker() {
    // https://flutterigniter.com/dismiss-keyboard-form-lose-focus/
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (_) {
        return GestureDetector(
          child: Container(
            constraints:  BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: CategoryChoiceBottomSheet(
              items: Provider.of<CategoryList>(context, listen: false).items,
              selectCategory: _selectCategory,
              initSelectedCategory: _selectedCategory,
            ),
          ),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      //height: 50,
      child: Row(
        children: <Widget>[
          if (_selectedCategory != null)
            InkWell(
                child: const Icon(Icons.settings_backup_restore),
                onTap: () {
                  _selectCategory(null); // reset le filtre
                }),
          if (_selectedCategory != null) SizedBox(width: 10),
          if (_selectedCategory != null) ...[
            Container(
              width: 15,
              height: 15,
              child: const Text(''),
              decoration: BoxDecoration(
                color:
                    _selectedCategory == null ? null : _selectedCategory.color,
                border: _selectedCategory == null ? null : Border.all(width: 1),
              ),
            ),
            SizedBox(width: 10),
          ],
          Expanded(
            child: Row(
              children: <Widget>[
                _selectedCategory != null
                    ? Expanded(
                        child: Text(
                          "${_selectedCategory.name}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : Text(
                        "No category",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
          ),
          FlatButton(
            textColor: Theme.of(context).primaryColor,
            child: Text(
              "Choose a category",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: _presentCategoryPicker,
          ),
        ],
      ),
    );
  }
}

class CategoryChoiceBottomSheet extends StatefulWidget {
  final List<Category> items;
  final void Function(String) selectCategory;
  final Category initSelectedCategory;

  CategoryChoiceBottomSheet(
      {this.items, this.selectCategory, this.initSelectedCategory});

  @override
  _CategoryChoiceBottomSheetState createState() =>
      _CategoryChoiceBottomSheetState();
}

class _CategoryChoiceBottomSheetState extends State<CategoryChoiceBottomSheet> {
  Category _selectChoice;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (widget.initSelectedCategory != null) {
        _selectChoice = widget.initSelectedCategory;
        _selectChoice.isSelected = true;
        Category tmp = Provider.of<CategoryList>(context, listen: false)
            .findParent(_selectChoice);
        while (tmp != null) {
          tmp.expanded = true;
          tmp =
              Provider.of<CategoryList>(context, listen: false).findParent(tmp);
        }
      }
      _isInit = false;
    }

    super.didChangeDependencies();
  }

  @override // On ovveride deactivate à la place place de dispose car a ce stade le Provider est encore accessible.
  void deactivate() {
    if (_selectChoice != null) {
      widget.selectCategory(_selectChoice.idKey);
      _selectChoice.isSelected = false;
      Provider.of<CategoryList>(context, listen: false)
          .setExpandedToFalse(widget.items);
    } else {
      widget.selectCategory(null);
      Provider.of<CategoryList>(context, listen: false)
          .setExpandedToFalse(widget.items);
    }
    super.deactivate();
  }

  List<Widget> builderCat(Category item) {
    List<Widget> a = [];
    if (item.expanded && item.children != null) {
      item.children.forEach((element) {
        a = [...a, ...builderCat(element)];
      });
    }
    return [
      Container(
        height: 45,
        child: ListTile(
          contentPadding:
              EdgeInsets.only(left: (item.tree.length - 1).toDouble() * 10),
          title: Row(children: <Widget>[
            item.children != null
                ? IconButton(
                    icon: item.expanded
                        ? Icon(Icons.expand_less)
                        : Icon(Icons.expand_more),
                    onPressed: () {
                      setState(() {
                        item.expanded = !item.expanded;
                        Provider.of<CategoryList>(context, listen: false)
                            .setExpandedToFalse(item.children);

                        Category parent =
                            Provider.of<CategoryList>(context, listen: false)
                                .findParent(item);

                        if (parent == null) {
                          Provider.of<CategoryList>(context, listen: false)
                              .setExpandedToFalse(widget.items
                                  .where((element) =>
                                      element.tree.last != item.tree.last)
                                  .toList());
                        } else {
                          Provider.of<CategoryList>(context, listen: false)
                              .setExpandedToFalse(parent.children
                                  .where((element) =>
                                      element.tree.last != item.tree.last)
                                  .toList());
                        }
                      });
                    },
                  )
                : SizedBox(
                    width: 24,
                  ),
            Text(
              item.name,
              style: TextStyle(
                fontWeight: (item.children == null)
                    ? FontWeight.normal
                    : FontWeight.bold,
              ),
            ),
          ]),
          trailing: Wrap(
            spacing: -10,
            children: [
              IconButton(
                  onPressed: null,
                  icon: Icon(
                    Icons.bookmark,
                    color: item.color,
                  )),
              buildCheckButton(item),
            ],
          ),
        ),
      ),
      Divider(
        thickness: 1.0,
      ),
      ...a
    ];
  }

  IconButton buildCheckButton(Category item) {
    return IconButton(
        icon: Icon(
          Icons.check,
          color: (item.isSelected) ? Colors.green : null,
          size: (item.isSelected) ? 38 : 24,
        ),
        onPressed: () {
          setState(() {
            if (_selectChoice == null) {
              _selectChoice = item;
              _selectChoice.isSelected = true;
            } else if (_selectChoice == item) {
              _selectChoice.isSelected = false;
              _selectChoice = null;
            } else {
              _selectChoice.isSelected = false;
              _selectChoice = item;
              _selectChoice.isSelected = true;
            }
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> itemsList = [];
    widget.items.forEach((element) {
      itemsList = [...itemsList, ...builderCat(element)];
    });

    return Card(
      elevation: 10,
      margin: const EdgeInsets.all(5),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ),
            SizedBox(height: 10),
            ...itemsList,
          ],
        ),
      ),
    );
  }
}
