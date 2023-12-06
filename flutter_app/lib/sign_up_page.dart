import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/home_page.dart';
import 'package:flutter_app/log_in_page.dart';
import 'package:flutter_app/settings_page.dart';

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

  void _validateFields() {
    setState(() {
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
              ? "Make sure your password is at least 8 characters"
              : null;

      _confirmPasswordError = _passwordController.text.isEmpty
          ? "Please confirm your password"
          : _passwordController.text != _confirmPasswordController.text
              ? "Your password doesn't match"
              : null;
    });
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
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SettingsPage(
                  profileImagePath: 'assets/images/profile.png',
                ),
              ),
            );
          },
        ),
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
                hintText: "Must be at least 8 characters",
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
                  _validateFields();
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
                    onPressed: () {
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

  Widget _buildLogoButton(String imagePath) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Image.asset(imagePath),
    );
  }
}
