import 'package:flutter/material.dart';

class NewNotePage extends StatefulWidget {
  @override
  _NewNotePageState createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFB1902B),),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("New Note", style: TextStyle(color: Color(0xFFB1902B), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Color(0xFFB1902B)),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.check, color: Colors.black),
            onPressed: () {},
          ),
        ],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: "Title here",
                border: InputBorder.none,
              ),
            ),
            Divider(),
            Expanded(
              child: TextField(
                controller: noteController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: "Note here...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
