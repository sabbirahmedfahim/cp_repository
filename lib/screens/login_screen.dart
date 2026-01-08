import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../constants/strings.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService auth = AuthService();
  bool isLoading = false;
  String errorMessage = '';

  Future<void> performLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      await auth.signIn( 
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (error) {
      String message = error.toString();
      
      if (message.contains('Invalid login credentials')) {
        message = 'Invalid email or password. Please try again.';
      } else if (message.contains('400')) {
        message = 'Login failed. Please check your credentials.';
      } else if (message.contains('Email not confirmed')) {
        message = 'Please confirm your email first. Check your inbox.';
      }
      
      setState(() {
        errorMessage = message;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildFeature(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, size: 20, color: Colors.green),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 40),
                        
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.shade50,
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                            'CP Repository',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 8),
                        Center(
                          child: Text(
                            'All your CP problems. One place.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 40),
                        
                        if (errorMessage.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(12),
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error, color: Colors.red, size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    style: TextStyle(
                                      color: Colors.red.shade800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        SizedBox(height: 8),
                        CustomTextField(
                          controller: _emailController, // main check
                          hintText: 'your.email@example.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Email is required';
                            if (!value.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        
                        Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        SizedBox(height: 8),
                        CustomTextField(
                          controller: _passwordController, // pass check
                          hintText: '••••••••',
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Password is required';
                            return null;
                          },
                        ),
                        
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                              );
                            },
                            child: Text('Forgot password?', style: TextStyle(color: Colors.blue, fontSize: 12)),
                          ),
                        ),
                        
                        SizedBox(height: 24),
                        CustomButton(text: 'See My Progress', onPressed: performLogin, isLoading: isLoading),
                        
                        SizedBox(height: 24),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('First time?', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                              SizedBox(width: 4),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                                  );
                                },
                                child: Text('Sign up', style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
              
              Container(width: 1, color: Colors.grey.shade300, margin: EdgeInsets.symmetric(vertical: 40)),
              
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 60),
                      
                      Text(
                        'Ever lost track of which problems you\'ve solved across Codeforces, LeetCode, or HackerRank?',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade900,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      Text(
                        'We\'ve been there too. That\'s why we built CP Repository - a simple place to keep all your CP problems organized.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                          height: 1.5,
                        ),
                      ),
                      
                      SizedBox(height: 32),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFeature('Add problems from ANY platform'),
                          SizedBox(height: 16),
                          _buildFeature('Mark them as Solved/In Progress'),
                          SizedBox(height: 16),
                          _buildFeature('See your stats grow'),
                          SizedBox(height: 16),
                          _buildFeature('Add notes for later review'),
                        ],
                      ),
                      
                      SizedBox(height: 32),
                      Text(
                        'No more scattered solutions. Just clean, focused tracking of your CP journey.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                      
                      SizedBox(height: 48),
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.format_quote, color: Colors.blue.shade400, size: 24),
                            SizedBox(height: 12),
                            Text(
                              'A competitive programmer is someone who gets excited about things that no one else cares about.',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade800,
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}