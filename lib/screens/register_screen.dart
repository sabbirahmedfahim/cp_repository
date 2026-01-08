import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../constants/strings.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService auth = AuthService();
  bool isLoading = false;
  String successMessage = '';
  String errorMessage = '';

  Future<void> performRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
      successMessage = '';
    });

    try {
      final result = await auth.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      setState(() {
        successMessage = result ?? 'Registration successful! Please login.';
      });
      
      await Future.delayed(Duration(seconds: 2));
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.register),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 40),
                Container(
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
                SizedBox(height: 16),
                Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Track your competitive programming journey', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                SizedBox(height: 40),
                
                if (successMessage.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Expanded(child: Text(successMessage, style: TextStyle(color: Colors.green.shade800))),
                      ],
                    ),
                  ),
                
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
                        Icon(Icons.error, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(child: Text(errorMessage, style: TextStyle(color: Colors.red.shade800))),
                      ],
                    ),
                  ),
                
                Text(AppStrings.email, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'user@example.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email is required';
                    if (!value.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Text(AppStrings.password, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                CustomTextField(
                  controller: _passwordController,
                  hintText: '••••••••',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password is required';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Text('Confirm Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: '••••••••',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Confirm password is required';
                    return null;
                  },
                ),
                SizedBox(height: 32),
                CustomButton(text: AppStrings.register, onPressed: performRegistration, isLoading: isLoading),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.haveAccount),
                    SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      },
                      child: Text(
                        AppStrings.login,
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}