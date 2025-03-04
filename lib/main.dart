// import 'package:flutter/material.dart';
// import 'package:sticky_note/notes.dart';
// import 'package:sticky_note/signup_page.dart'; // Adjust the path based on your project structure

// void main() {
//   runApp(MaterialApp(
//     home: NotesScreen(),
//   ));
// }


import 'package:flutter/material.dart';
import 'package:sticky_note/notes.dart';
import 'package:sticky_note/signin_page.dart';
import 'package:sticky_note/signup_page.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/signin', // Start with SignInPage
    routes: {
      '/signin': (context) => SignInPage(),
      '/signup': (context) => SignUpPage(),
      '/notes': (context) => NotesScreen(),
    },
  ));
}
