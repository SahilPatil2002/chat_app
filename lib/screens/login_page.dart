import 'package:chat_app/screens/chat_contact_screen.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/sign_in_page.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  final Color mainColor = const Color.fromRGBO(108, 99, 255, 1);

  // Error state variables
  bool emailError = false;
  bool passwordError = false;
  String emailErrorMsg = '';
  String passwordErrorMsg = '';

  void handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Reset errors before validation
    setState(() {
      emailError = false;
      passwordError = false;
      emailErrorMsg = '';
      passwordErrorMsg = '';
    });

    // Basic validation
    if (email.isEmpty) {
      setState(() {
        emailError = true;
        emailErrorMsg = 'Email cannot be empty';
      });
    } else if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email)) {
      setState(() {
        emailError = true;
        emailErrorMsg = 'Enter a valid email address';
      });
    }

    if (password.isEmpty) {
      setState(() {
        passwordError = true;
        passwordErrorMsg = 'Password cannot be empty';
      });
    }

    // If any error, don't proceed
    if (emailError || passwordError) return;

    // Proceed with login
    final user = await _authService.signIn(email, password);

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Login Successful",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Color.fromRGBO(139, 195, 74, 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChatContactsScreen()),
      );
    } else {
      // Show inline error message on password field
      setState(() {
        passwordError = true;
        passwordErrorMsg = 'Incorrect email or password';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Login Failed",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 255, 89, 86),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  InputDecoration customInputDecoration({
    required String label,
    required IconData icon,
    bool error = false,
  }) {
    return InputDecoration(
      labelText: label,
      floatingLabelStyle: TextStyle(
        color: mainColor,
        fontWeight: FontWeight.bold,
      ),
      prefixIcon: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(108, 99, 255, 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: mainColor),
      ),
      filled: true,
      fillColor: const Color.fromRGBO(255, 255, 255, 0.95),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: error ? Colors.red : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: error ? Colors.red : mainColor, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(241, 243, 250, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: "logo",
                child: Container(
                  height: 120,
                  width: 120,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SvgPicture.asset(
                    "assets/icons/login.svg",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login to continue',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Login Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.85),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.05),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: customInputDecoration(
                        label: "Email Address",
                        icon: Icons.email_outlined,
                        error: emailError,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    if (emailError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            emailErrorMsg,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: customInputDecoration(
                        label: "Password",
                        icon: Icons.lock_outline,
                        error: passwordError,
                      ),
                    ),
                    if (passwordError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            passwordErrorMsg,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(
                          fontSize: 15,
                          color: mainColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
