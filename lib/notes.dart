import 'package:flutter/material.dart';
import 'package:sticky_note/logout.dart';
import 'package:sticky_note/newnotes.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: NotesScreen(),
  ));
}

class NotesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Awesome Notes 📒',
          style: TextStyle(color: Color(0xFFB1902B), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFB1902B)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFB1902B)),
            onPressed: () {
              showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/person.png', width: 250), // Replace with your asset path
            const SizedBox(height: 20),
            const Text(
              'You have no notes yet!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text(
              'Start creating by pressing the + button below!',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewNotePage()),
          );
        },
        backgroundColor: const Color(0xFFB1902B),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

