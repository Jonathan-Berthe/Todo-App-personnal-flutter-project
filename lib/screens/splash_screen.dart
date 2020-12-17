import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: Image.asset('assets/logo.png'),
          ),
          Column(
            children: <Widget>[
              const CircularProgressIndicator(
                //backgroundColor: Color.fromRGBO(90, 165, 229, 1),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text('Waiting...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Color.fromRGBO(254, 85, 1, 1),//Color(0xfe5501),
                  )),
            ],
          )
        ],
      ),
    );
  }
}
