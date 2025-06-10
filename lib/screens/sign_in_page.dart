import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chat_app/screens/login_page.dart';
import 'package:chat_app/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  

  final Color mainColor = const Color.fromRGBO(108, 99, 255, 1);

  // Error state variables
  bool nameError = false;
  bool emailError = false;
  bool passwordError = false;
  String nameErrorMsg = '';
  String emailErrorMsg = '';
  String passwordErrorMsg = '';
  bool isPasswordVisible = false;


  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void handleSignUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Reset errors
    setState(() {
      nameError = false;
      emailError = false;
      passwordError = false;
      nameErrorMsg = '';
      emailErrorMsg = '';
      passwordErrorMsg = '';
    });

    // Manual validation logic
    if (name.isEmpty) {
      setState(() {
        nameError = true;
        nameErrorMsg = 'Please enter your name';
      });
    }

    if (email.isEmpty) {
      setState(() {
        emailError = true;
        emailErrorMsg = 'Please enter your email';
      });
    } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() {
        emailError = true;
        emailErrorMsg = 'Enter a valid email address';
      });
    }

    if (password.isEmpty) {
      setState(() {
        passwordError = true;
        passwordErrorMsg = 'Please enter your password';
      });
    } else if (password.length < 6) {
      setState(() {
        passwordError = true;
        passwordErrorMsg = 'Password must be at least 6 characters';
      });
    }

    // If any error, don't proceed
    if (nameError || emailError || passwordError) return;

    // Proceed with signup — pass name too!
    final user = await _authService.signUp(email, password, name);

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Sign Up Successful",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color.fromRGBO(139, 195, 74, 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Sign Up Failed",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 255, 89, 86),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
        borderSide: BorderSide(
          color: error ? Colors.red : Colors.grey.shade300,
        ),
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
                    "assets/icons/sign_in.svg",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join the conversation 👋',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.85),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.06),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: customInputDecoration(
                        label: "Name",
                        icon: Icons.person_outline,
                        error: nameError,
                      ),
                      keyboardType: TextInputType.name,
                    ),
                    if (nameError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            nameErrorMsg,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
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
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: customInputDecoration(
                        label: "Password",
                        icon: Icons.lock_outline,
                        error: passwordError,
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: mainColor,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),

                    if (passwordError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            passwordErrorMsg,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          "Sign Up",
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
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Already have an account? Login",
                        style: TextStyle(
                          color: mainColor,
                          fontSize: 15,
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
