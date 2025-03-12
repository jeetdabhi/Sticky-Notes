import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sticky_note/newnotes.dart';
import 'package:sticky_note/signin_page.dart';
import 'package:sticky_note/register.dart';
import 'package:sticky_note/signup.dart';
import 'package:sticky_note/notes.dart';

Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
   // ✅ Load .env from assets folder (for Flutter Web)
  await dotenv.load(fileName: "assets/.env");

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/signin',
    routes: {
      '/signin': (context) => SignInPage(),
      '/register': (context) => registerPage(),
      '/notes': (context) => NotesScreen(),
      '/signup': (context) => SignUpPage(),
      '/newnote': (context) => NewNotePage(),
    },
  ));
}
