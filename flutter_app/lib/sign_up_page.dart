// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/home_page.dart';
import 'package:flutter_app/log_in_page.dart';
import 'package:flutter_app/settings_page.dart';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  bool validateFields() {
    _emailError = _emailController.text.isEmpty
        ? "Please enter an email"
        : !_emailController.text.contains('@') ||
                (!_emailController.text.contains('.com') &&
                    !_emailController.text.contains('.ca'))
            ? "Please enter a valid email"
            : null;

    _passwordError = _passwordController.text.isEmpty
        ? "Please enter a password"
        : _passwordController.text.length < 8
            ? "Make sure it's at least 8 characters"
            : !_passwordController.text.contains(RegExp(r'[A-Z]'))
                ? "Make sure it contains at least one capital letter"
                : !_passwordController.text.contains(RegExp(r'[0-9]'))
                    ? "Make sure it contains at least one number"
                    : null;

    _confirmPasswordError = _confirmPasswordController.text.isEmpty
        ? "Please confirm your password"
        : _passwordController.text != _confirmPasswordController.text
            ? "Your passwords don't match"
            : null;

    // Return true if all fields are valid, otherwise return false
    return _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  /// Signs a user up with a username and email.
  Future<void> signUpUser({
    required String email,
    required String password,
  }) async {
    try {
      final userAttributes = {
        AuthUserAttributeKey.email: email,
      };
      final result = await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(
          userAttributes: userAttributes,
        ),
      );
      await _handleSignUpResult(result);
    } on AuthException catch (e) {
      safePrint('Error signing up user: ${e.message}');
    }
  }

  Future<void> _handleSignUpResult(SignUpResult result) async {
    switch (result.nextStep.signUpStep) {
      case AuthSignUpStep.confirmSignUp:
        final codeDeliveryDetails = result.nextStep.codeDeliveryDetails!;
        await _showCodeDeliveryDialog(codeDeliveryDetails);
        break;
      case AuthSignUpStep.done:
        Navigator.of(context).pop();
        await _showRegistrationSuccessSnackBar();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LogInPage()),
        );
        break;
    }
  }

  Future<void> confirmUser({
    required String username,
    required String confirmationCode,
  }) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: username,
        confirmationCode: confirmationCode,
      );
      await _handleSignUpResult(result);
    } on AuthException catch (e) {
      rethrow; // Propagate exception for handling in _showConfirmationCodeDialog
    }
  }

  Future<void> _showCodeDeliveryDialog(
      AuthCodeDeliveryDetails codeDeliveryDetails) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Next Step:'),
          content: Text(
            'A confirmation code has been sent to ${codeDeliveryDetails.destination}. '
            'Please check your ${codeDeliveryDetails.deliveryMedium.name} for the code.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showConfirmationCodeDialog();
              },
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConfirmationCodeDialog() async {
    String confirmationCode = '';
    bool invalidCode = false;

    while (!invalidCode) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enter Code:'),
            content: TextField(
              onChanged: (value) {
                confirmationCode = value;
              },
              decoration: const InputDecoration(hintText: 'Confirmation Code'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  if (confirmationCode.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(milliseconds: 1000),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        content: const Text('Please enter your code'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    try {
                      await confirmUser(
                        username: _emailController.text,
                        confirmationCode: confirmationCode,
                      );
                      invalidCode = true; // Set flag to exit loop on success
                    } on AuthException {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(milliseconds: 1000),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          content: const Text('Invalid code. Please re-enter.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      // Stay in the dialog for re-entering code
                    }
                  }
                },
                child: const Text(
                  'OK',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _showRegistrationSuccessSnackBar() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 4000),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        content: const Text('Registration Success! Please log in.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> signOutCurrentUser() async {
    final result = await Amplify.Auth.signOut();
    if (result is CognitoCompleteSignOut) {
      safePrint('Sign out completed successfully');
    } else if (result is CognitoFailedSignOut) {
      safePrint('Error signing user out: ${result.exception.message}');
    }
  }

  @override
  void initState() {
    super.initState();
    signOutCurrentUser();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'SIGN UP',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextFieldWithLabel(
                "Email",
                hintText: "example@gmail.com",
                errorText: _emailError,
                controller: _emailController,
              ),
              const SizedBox(height: 20),
              _buildPasswordTextFieldWithLabel(
                "Create a Password",
                hintText: "At least 8 characters long",
                obscureText: _obscurePassword,
                toggleVisibility: _togglePasswordVisibility,
                errorText: _passwordError,
                controller: _passwordController,
              ),
              const SizedBox(height: 20),
              _buildPasswordTextFieldWithLabel(
                "Confirm Password",
                hintText: "Repeat password",
                obscureText: _obscureConfirmPassword,
                toggleVisibility: _toggleConfirmPasswordVisibility,
                errorText: _confirmPasswordError,
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (validateFields()) {
                      String email = _emailController.text;
                      String password = _passwordController.text;
                      signUpUser(email: email, password: password);
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(child: Divider()),
                  TextButton(
                    onPressed: () async {
                      await signOutCurrentUser();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Continue as Guest",
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 10),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Already have an account? ",
                  style: const TextStyle(color: Colors.grey),
                  children: [
                    TextSpan(
                      text: "Log in",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LogInPage(),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithLabel(
    String label, {
    String? hintText,
    String? errorText,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTextFieldWithLabel(
    String label, {
    String? hintText,
    bool? obscureText,
    void Function()? toggleVisibility,
    String? errorText,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextFormField(
              controller: controller,
              obscureText: obscureText!,
              decoration: InputDecoration(
                hintText: hintText,
                errorText: errorText,
                border: const OutlineInputBorder(),
              ),
            ),
            if (toggleVisibility != null)
              Positioned(
                top: 7,
                child: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: toggleVisibility,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
