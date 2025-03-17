import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OtpPopup extends StatefulWidget {
  final String email;

  const OtpPopup({super.key, required this.email});

  @override
  OtpPopupState createState() => OtpPopupState();
}

class OtpPopupState extends State<OtpPopup> {
  final List<TextEditingController> controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  bool isLoading = false;

  void _onKeyPress(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).requestFocus(focusNodes[index + 1]);
    }
  }

  void _onBackspace(int index) {
    if (index > 0 && controllers[index].text.isEmpty) {
      FocusScope.of(context).requestFocus(focusNodes[index - 1]);
    }
  }

  Future<void> _verifyOTP() async {
     String apiUrl = dotenv.env['API_URL'] ?? "http://localhost:3000"; // Fetch from .env
    String otp = controllers.map((controller) => controller.text).join();

    final url = Uri.parse('$apiUrl/api/users/verify-otp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': widget.email, 'otp': otp}),
    );

    final responseData = jsonDecode(response.body);

    if (!mounted) return; // Ensure widget is mounted

    if (response.statusCode == 201) {
      String verifiedEmail =
          responseData['email']; // Extract email from response
      _showMessage("OTP verified successfully!", isSuccess: true);
      removeOtpPopup();

      // Navigate to Signup page with email as argument
      Navigator.pushReplacementNamed(
        context,
        "/signup",
        arguments: {'email': verifiedEmail},
      );
    } else {
      _showMessage(responseData['message'] ?? "Invalid OTP. Try again.");
    }
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(
              color: Colors.black.withAlpha((0.2 * 255).toInt()),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Enter OTP',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB1902B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: 40,
                              child: KeyboardListener(
                                focusNode: FocusNode(),
                                onKeyEvent: (KeyEvent event) {
                                  if (event is KeyDownEvent &&
                                      event.logicalKey ==
                                          LogicalKeyboardKey.backspace) {
                                    _onBackspace(index);
                                  }
                                },
                                child: TextField(
                                  controller: controllers[index],
                                  focusNode: focusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  decoration: InputDecoration(
                                    counterText: "",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onChanged: (value) =>
                                      _onKeyPress(value, index),
                                  onTap: () => controllers[index].clear(),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _verifyOTP,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB1902B),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 96, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Verify',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

OverlayEntry? _overlayEntry;

void showOtpPopup(BuildContext context, String email) {
  _overlayEntry = OverlayEntry(
    builder: (context) => OtpPopup(email: email),
  );
  Overlay.of(context).insert(_overlayEntry!);
}

void removeOtpPopup() {
  _overlayEntry?.remove();
  _overlayEntry = null;
}
