import 'package:flutter/material.dart';
import 'package:todo_marie/screens/category_screen.dart';

class AppDrawer extends StatelessWidget {

  const AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blueGrey[50],
        child: Column(
          children: <Widget>[
            AppBar(
              title: const Text('Menu'),
              automaticallyImplyLeading: false,
            ),
            const Divider(),
            ListTile(
                leading: const Icon(
                  Icons.work,
                  size: 25,
                ),
                title: Text('Todo List'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/');
                }),
            ListTile(
              leading: const Icon(
                Icons.edit,
                size: 25,
              ),
              title: const Text('Category (Todo)'),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(CategoryScreen.routeNamed);
              },
            )
          ],
        ),
      ),
    );
  }
}
