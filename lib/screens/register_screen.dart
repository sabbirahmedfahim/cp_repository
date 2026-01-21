import 'package:flutter/material.dart';
import '../database.dart';
import '../widgets/simple_button.dart';
import '../widgets/message_widget.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool isLoading = false;
  String successMsg = '';
  String errorMsg = '';

  Future<void> doRegister() async {
    if (emailController.text.isEmpty) {
      setState(() => errorMsg = 'Email required');
      return;
    }
    if (!emailController.text.contains('@')) {
      setState(() => errorMsg = 'Valid email needed');
      return;
    }
    if (passwordController.text.isEmpty) {
      setState(() => errorMsg = 'Password required');
      return;
    }
    if (passwordController.text.length < 6) {
      setState(() => errorMsg = 'Need 6+ characters');
      return;
    }
    if (confirmController.text.isEmpty) {
      setState(() => errorMsg = 'Confirm password');
      return;
    }
    if (passwordController.text != confirmController.text) {
      setState(() => errorMsg = 'Passwords don\'t match');
      return;
    }

    setState(() {
      isLoading = true;
      errorMsg = '';
      successMsg = '';
    });

    try {
      await register(
          emailController.text.trim(), passwordController.text.trim());
      setState(() => successMsg = 'Success! Please login.');
      await Future.delayed(Duration(seconds: 2));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginScreen()));
    } catch (e) {
      setState(() => errorMsg = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CircleAvatar(
                  radius: isSmallScreen ? 60 : 80,
                  backgroundColor: Colors.blue.shade50,
                  backgroundImage: AssetImage('assets/images/logo.png'),
                ),
                SizedBox(height: 16),
                Text('Create Account',
                    style: TextStyle(fontSize: isSmallScreen ? 24 : 28, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Track your competitive programming journey',
                    style: TextStyle(color: Colors.grey, fontSize: isSmallScreen ? 14 : 16)),
                SizedBox(height: 40),
                if (successMsg.isNotEmpty)
                  MessageWidget(
                    message: successMsg,
                    isError: false,
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                if (errorMsg.isNotEmpty)
                  MessageWidget(message: errorMsg, isError: true),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email', style: TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'your.email@example.com',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Password', style: TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Confirm Password',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: confirmController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                      ),
                    ),
                    SizedBox(height: 32),
                    SimpleButton(
                        text: 'Sign Up', onPressed: doRegister, loading: isLoading),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account?'),
                        SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => LoginScreen())),
                          child: Text('Sign in',
                              style: TextStyle(
                                  color: Colors.blue, fontWeight: FontWeight.w600)),
                        ),
                      ],
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