import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sticky_note/auth_service.dart';
import 'package:sticky_note/notes.dart';
import 'dart:convert';
import 'package:sticky_note/register.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignInPage extends StatefulWidget {
  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final AuthService _authService = AuthService();
  final storage = FlutterSecureStorage(); // ✅ Define storage globally

  // ✅ Initialize Google Sign-In
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: dotenv.env['GOOGLE_CLIENT_ID'], // ✅ Fetch from .env
    scopes: ['email', 'profile'],
  );

  // ✅ Google Sign-In Function
  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User canceled login

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      String? apiUrl = dotenv.env['API_URL'] ?? "http://localhost:3000";
      var url = Uri.parse("$apiUrl/api/users/google-signin");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"idToken": googleAuth.idToken}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // ✅ Extract JWT token and userId
        final String token = data["token"];
        final String userId = data["user"]["_id"]; // Assuming API sends user ID

        // ✅ Save token & user ID securely
        await storage.write(key: "jwt_token", value: token);
        await storage.write(key: "user_id", value: userId);

        // ✅ Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Successful!")),
        );

        // ✅ Wait before navigation
        await Future.delayed(const Duration(seconds: 1));

        // ✅ Navigate to Notes Page and remove all previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => NotesListScreen()),
          (route) => false, // Removes all previous routes
        );
      } else {
        var errorData = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Google Sign-In Failed: ${errorData['error']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Something went wrong. Please try again!")),
      );
    }
  }

  Future<void> _submitForm() async {
    String apiUrl = dotenv.env['API_URL'] ?? "http://localhost:3000";

    if (_formKey.currentState!.validate()) {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      var url = Uri.parse("$apiUrl/api/users/login");

      try {
        var response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"email": email, "password": password}),
        );

        print("Response Status Code: ${response.statusCode}");

        var data = jsonDecode(response.body);

        print(data["token"]);

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);

          print("Data: ${data}");

          if (data["token"] == null) {
            print("Error: Missing token in response");
            return;
          }

          final String? token = data["token"];

          await storage.write(key: "jwt_token", value: token);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login Successful!")),
          );

          await Future.delayed(const Duration(seconds: 1));

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => NotesListScreen()),
            (route) => false,
          );

        } else {
          var errorData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login Failed: ${errorData['error']}")),
          );
        }
      } catch (e) {
        print("Login Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Something went wrong. Please try again!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB1902B),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sync your notes to the cloud by registering/signing in.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    SizedBox(height: 24),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email Address",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "No email provided!";
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                            .hasMatch(value)) {
                          return "Invalid email format!";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "No password provided!";
                        } else if (value.length < 6) {
                          return "Password must be at least 6 characters!";
                        }
                        return null;
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/forgotpassword",
                              arguments: {"email": emailController.text});
                        },
                        child: const Text(
                          "Forgot Password!",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB1902B),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 0),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(
                        'Log me in',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFB1902B),
                        padding:
                            EdgeInsets.symmetric(horizontal: 131, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                            child: Divider(thickness: 1, color: Colors.grey)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text("Or sign in with",
                              style: TextStyle(color: Colors.black54)),
                        ),
                        Expanded(
                            child: Divider(thickness: 1, color: Colors.grey)),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _handleGoogleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFB1902B),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/1.jpg',
                            width: 20,
                            height: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Continue with Google',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'Register',
                            style: TextStyle(
                              color: Color(0xFFB1902B),
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => registerPage()),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
