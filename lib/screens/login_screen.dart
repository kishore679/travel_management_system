import 'package:firebase_auth/firebase_auth.dart'; // ✅ Import Firebase Auth
import 'package:flutter/material.dart';
import 'home_screen.dart'; // ✅ Import the Home Screen
import 'register_screen.dart'; // Make sure this is correct
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? emailError; // Stores email error message
  String? passwordError; // Stores password error message

  // Login User function with enhanced validation
  Future<void> loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    setState(() {
      emailError = email.isEmpty ? "Email is required" : null;
      passwordError = password.isEmpty ? "Password is required" : null;
    });

    if (email.isEmpty || password.isEmpty) return;

    try {
      // Attempt to sign in the user with the provided credentials
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (userCredential.user != null) {
        setState(() {
          emailError = null;
          passwordError = null;
        });

        // Successfully logged in, navigate to the home screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Successful")),
        );

        // Navigate to the Home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found' || e.code == 'invalid-email') {
          emailError = "Invalid email";
          passwordError = "Invalid password"; // Assume password is also wrong
        } else if (e.code == 'wrong-password') {
          emailError = null;
          passwordError = "Invalid password";
        } else {
          emailError = null;
          passwordError = "Invalid password";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome to WanderWish")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Login",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Email Field
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                errorText: emailError, // Show email error if exists
              ),
            ),
            const SizedBox(height: 10),

            // Password Field
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                errorText: passwordError, // Show password error if exists
              ),
            ),
            const SizedBox(height: 20),

            // Login Button
            ElevatedButton(
              onPressed: loginUser,
              child: const Text("Login"),
            ),

            // Navigate to Register Screen
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}
