// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:schedule_app/pages/home_page.dart';
import 'package:schedule_app/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:schedule_app/main.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  bool _passwordVisible = true;

  String? _erorEmailMessage;
  String? _erorPasswordMessage;
  String? _errorUsernameMessage;
  String? _errorFirstNameMessage;

  void _inputChecker() {
    setState(() {
      _erorEmailMessage =
          emailController.text.isEmpty ? 'Email can\'t be empty' : null;
      _erorPasswordMessage = passwordController.text.isEmpty
          ? 'Password can\'t be empty'
          : (passwordController.text.length < 6
              ? 'Minimum password has 6 characters'
              : null);
      _errorFirstNameMessage = firstNameController.text.isEmpty
          ? 'First name can\'t be empty'
          : null;
      _errorUsernameMessage =
          usernameController.text.isEmpty ? 'Username can\'t be empty' : null;
    });
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signUp() async {
    try {
      await supabase.auth.signUp(
        password: passwordController.text.trim(),
        email: emailController.text.trim(),
        data: {
          'username': usernameController.text,
          'last_name': lastNameController.text,
          'first_name': firstNameController.text,
          'full_name': '${firstNameController.text} ${lastNameController.text}'
        },
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } on AuthApiException catch (e) {
      if (e.statusCode == 400 && e.message.contains('already registered')) {
        // Email already used
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email already in use. Try logging in.'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Unknown Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check your internet connection'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Welcome',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(80),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                child: Column(
                  children: [
                    Text(
                      'Sign Up',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                    ),
                    SizedBox(height: 25),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        errorText: _erorEmailMessage,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        errorText: _erorPasswordMessage,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: firstNameController,
                      decoration: InputDecoration(
                        labelText: 'First name',
                        hintText: 'Enter your first name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorText: _errorFirstNameMessage,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Last name (optional)',
                        hintText: 'Enter your last name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        hintText: 'Enter your username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorText: _errorUsernameMessage,
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        _inputChecker();
                        if (_erorEmailMessage == null &&
                            _erorPasswordMessage == null &&
                            _errorFirstNameMessage == null &&
                            _errorUsernameMessage == null) {
                          _signUp();
                        }
                      },
                      child: Text('Sign Up'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? '),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Login',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
