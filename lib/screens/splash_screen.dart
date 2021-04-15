import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            child: Image(
              image: AssetImage('assets/image/splash.jpeg'),
              width: 200,
              height: 200,
            ),
          ),
        ));
  }
}
