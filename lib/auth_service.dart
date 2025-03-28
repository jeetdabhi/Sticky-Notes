import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      if (googleAuth?.idToken != null) {
        String idToken = googleAuth!.idToken!;
        print("Google ID Token: $idToken"); // ✅ This is the correct token!

        // ✅ Send ID Token to backend API
        final response = await http.post(
          Uri.parse("http://localhost:5000/api/google-auth"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"token": idToken}),
        );

        final data = jsonDecode(response.body);
        print("Backend Response: $data"); // ✅ Verify response
      } else {
        print("❌ Failed to get Google ID Token");
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
    }
  }
}
