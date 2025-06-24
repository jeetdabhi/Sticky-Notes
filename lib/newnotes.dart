import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NewNotePage extends StatefulWidget {
  final Map<String, dynamic>? note; // Accept a note for editing
  final String? title;
  final String? content;

  const NewNotePage({Key? key, this.note, this.title, this.content})
      : super(key: key);

  @override
  _NewNotePageState createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  late TextEditingController titleController;
  late TextEditingController noteController;
  final storage = FlutterSecureStorage();
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note?['title'] ?? '');
    noteController = TextEditingController(text: widget.note?['content'] ?? '');
    isUpdating = widget.note != null;
  }

  /// ✅ Create or Update Note API
  Future<void> saveNote() async {
    String title = titleController.text.trim();
    String content = noteController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Note is empty!'), backgroundColor: Color.fromRGBO(40, 37, 37, 1)),
      );
      return;
    }

    String? token = await storage.read(key: "jwt_token");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User not logged in! Please log in again.'),
            backgroundColor: Color.fromRGBO(40, 37, 37, 1)),
      );
      return;
    }

    String apiUrl = dotenv.env['API_URL'] ?? "http://localhost:3000";
    var url = isUpdating
        ? Uri.parse("$apiUrl/notes/${widget.note!['_id']}")
        : Uri.parse("$apiUrl/notes/create");

    try {
      var response = await (isUpdating
          ? http.patch(url,
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $token"
              },
              body: jsonEncode({"title": title, "content": content}))
          : http.post(url,
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $token"
              },
              body: jsonEncode({
                "title": title,
                "content": content,
                "date": DateTime.now().toIso8601String(),
              })));

      var responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isUpdating
                ? 'Note updated successfully!'
                : 'Note added successfully!'),
            backgroundColor: Color.fromRGBO(40, 37, 37, 1),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${responseData['error']}'),
              backgroundColor: Color.fromRGBO(40, 37, 37, 1)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Something went wrong. Please try again!"),
            backgroundColor: Color.fromRGBO(40, 37, 37, 1)),
      );
    }
  }

  /// ✅ Move the confirmation dialog inside `_NewNotePageState`
  void showUpdateConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog Title
                const Text(
                  "Are you sure you want to update this note?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel Button (Bordered)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                            color: Color(0xFFB1902B)), // Gold border
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Color(0xFFB1902B)), // Gold text
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Update Button (Solid Color)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB1902B), // Gold color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        saveNote(); // ✅ Calls saveNote() after closing dialog
                      },
                      child: const Text(
                        "Update",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: isUpdating // ✅ Show back button ONLY when editing
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFFB1902B)),
                onPressed: () => Navigator.pop(context),
              )
            : null, // ❌ No back button for new notes
        title: Text(
          isUpdating ? "Edit Note" : "New Note",
          style: const TextStyle(
              color: Color(0xFFB1902B), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black),
            onPressed: () {
              if (isUpdating) {
                showUpdateConfirmationDialog(context);
              } else {
                saveNote();
              }
            },
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "Title here",
                border: InputBorder.none,
              ),
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: noteController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
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
