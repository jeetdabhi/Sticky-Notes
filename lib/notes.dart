import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sticky_note/logout.dart';
import 'package:sticky_note/newnotes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: NotesListScreen(),
  ));
}

class NotesListScreen extends StatefulWidget {
  @override
  _NotesListScreenState createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  List<Map<String, dynamic>> notes = [];
  List<Map<String, dynamic>> filteredNotes = [];
  final TextEditingController searchController = TextEditingController();
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    searchController.addListener(_searchNotes);
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    String apiUrl = dotenv.env['API_URL'] ?? "http://localhost:3000";
    String? token = await storage.read(key: "jwt_token");

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/api/notes/all'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          notes = List<Map<String, dynamic>>.from(json.decode(response.body));
          filteredNotes = List.from(notes);
        });
      }
    } catch (e) {
      print("Error fetching notes: $e");
    }
  }

  Future<void> deleteNote(String noteId) async {
    String apiUrl = dotenv.env['API_URL'] ?? "http://localhost:3000";
    String? token = await storage.read(key: "jwt_token");

    if (token == null) return;

    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/api/notes/delete/$noteId'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          notes.removeWhere((note) => note['_id'] == noteId);
          filteredNotes = List.from(notes);
        });
      }
    } catch (e) {
      print("Error deleting note: $e");
    }
  }

  void _searchNotes() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredNotes = notes
          .where((note) =>
              note['title'].toLowerCase().contains(query) ||
              note['content'].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Awesome Notes',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB1902B)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFB1902B)),
            onPressed: () {
              showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // SHOW SEARCH BAR ONLY IF NOTES EXIST
          if (notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search notes...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 5),
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/person.png', // Make sure the image exists
                          height: 200,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No notes available!',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Tap the + button to create your first note.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      DateTime createdAt =
                          DateTime.parse(filteredNotes[index]['createdAt']);
                      String formattedDate =
                          "${createdAt.day}/${createdAt.month}/${createdAt.year}";
                      return GestureDetector(
                        onTap: () async {
                          final updatedNote = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewNotePage(
                                note: filteredNotes[index],
                                title: filteredNotes[index]['title'],
                                content: filteredNotes[index]['content'],
                              ),
                            ),
                          );
                          if (updatedNote == true) {
                            fetchNotes();
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 5),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Color(0xFFB1902B), width: 2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      filteredNotes[index]['title'],
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      filteredNotes[index]['content'],
                                      style: const TextStyle(fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.grey),
                                onPressed: () => showDeleteConfirmationDialog(
                                    context,
                                    filteredNotes[index]['_id'],
                                    deleteNote),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final noteAdded = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewNotePage()),
          );
          if (noteAdded == true) {
            fetchNotes();
          }
        },
        backgroundColor: const Color(0xFFB1902B),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

void showDeleteConfirmationDialog(
    BuildContext context, String noteId, Function deleteNote) {
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
                "Are you sure you want to delete this note?",
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
                  // No Button (Bordered)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFB1902B)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "No",
                      style: TextStyle(color: Color(0xFFB1902B)),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Yes Button (Solid Color)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB1902B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      deleteNote(noteId);
                      Navigator.of(context).pop();
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Note deleted successfully!"),
                          backgroundColor: Color.fromRGBO(40, 37, 37, 1),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text(
                      "Yes",
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
