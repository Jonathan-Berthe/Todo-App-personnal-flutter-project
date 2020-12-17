import 'package:flutter/material.dart';
class Category {
  String name;
  //List<int> id;
  List<int> tree;
  List<Category> children;
  Color color;
  String emoji;
  bool expanded = false;
  bool isSelected = false;
  String idKey;

  Category({
    this.name,
    this.children,
    this.color = Colors.white,
    this.tree,
    //this.id,
    this.idKey,
    this.emoji = '',
  });


}
