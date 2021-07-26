import 'package:flutter/material.dart';
import 'package:smart_attendence/login.dart';
import 'package:smart_attendence/signup.dart';
import 'package:http/http.dart' as http;
import 'src/bloc.dart';

void main() {
  final String URL = '192.168.0.194:8000';

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.indigo,
        accentColor: Colors.indigoAccent,
      ),
      home: LoginPage(),
    );
  }
}

// int curIndex = 0;
//
// class Wrapper extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: curIndex == 0 ? LoginPage() : Signup(),
//     );
//   }
// }
