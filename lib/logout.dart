import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void showLogoutDialog(BuildContext context) {
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
              const Text(
                "Do you want to sign out of the app?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // No Button
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
                  // Yes Button (Calls logout function)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB1902B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () async {
                      await logoutUser(context);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
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

Future<void> logoutUser(BuildContext context) async {
  String apiUrl = dotenv.env['API_URL'] ?? "http://localhost:3000";

  // Create an instance of secure storage
  const storage = FlutterSecureStorage();

  // Retrieve the stored token
  String? token = await storage.read(key: "jwt_token");

  if (token == null) {
    _showMessage(context, "No token found. Please log in.");
    return;
  }

  try {
    final response = await http.post(
      Uri.parse("$apiUrl/api/auth/logout"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Use the retrieved token
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Logged out successfully!"),
          backgroundColor: Color.fromRGBO(40, 37, 37, 1), // Alpha is 1 (fully opaque)
        ),
      );

      // Remove token from storage after logout
      await storage.delete(key: "jwt_token");

      // Delay navigation to allow message display
      await Future.delayed(Duration(seconds: 2));

      await Navigator.pushReplacementNamed(
          context, "/signin"); // Navigate only if widget is still active
    } else {
      final responseBody = jsonDecode(response.body);
      _showMessage(context, responseBody['message'] ?? 'Logout failed');
    }
  } on SocketException {
    _showMessage(context, "No internet connection.");
  } catch (e) {
    _showMessage(context, "An error occurred: $e");
  }
}

void _showMessage(BuildContext context, String message,
    {bool isSuccess = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Color.fromRGBO(40, 37, 37, 1) : Color.fromRGBO(40, 37, 37, 1),
    ),
  );
}
