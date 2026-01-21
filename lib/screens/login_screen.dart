import 'package:flutter/material.dart';
import '../database.dart';
import '../widgets/simple_button.dart';
import '../widgets/message_widget.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String errorMsg = '';

  Future<void> doLogin() async {
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

    setState(() {
      isLoading = true;
      errorMsg = '';
    });

    try {
      await login(emailController.text.trim(), passwordController.text.trim());
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } catch (e) {
      String msg = e.toString();
      if (msg.contains('Invalid login')) msg = 'Wrong email/password';
      setState(() => errorMsg = msg);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.blue.shade100),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: isSmallScreen ? 60 : 80,
                  backgroundColor: Colors.blue.shade50,
                  backgroundImage: AssetImage('assets/images/logo.png'),
                ),
                SizedBox(height: 24),
                Text('CP Repository', 
                  style: TextStyle(fontSize: isSmallScreen ? 30 : 36, 
                  fontWeight: FontWeight.bold, color: Colors.blue)),
                SizedBox(height: 8),
                Text('Track Your CP Progress', 
                  style: TextStyle(fontSize: isSmallScreen ? 15 : 18, 
                  color: Colors.grey.shade600)),
                SizedBox(height: 30),

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
                    SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(context, 
                          MaterialPageRoute(builder: (_) => ForgotPasswordScreen())),
                        child: Text('Forgotten password?', 
                          style: TextStyle(color: Colors.blue, 
                          fontSize: isSmallScreen ? 12 : 14)),
                      ),
                    ),
                    SizedBox(height: 24),

                    SimpleButton(text: 'Sign in', onPressed: doLogin, loading: isLoading),
                    SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('First time?'),
                        SizedBox(width: 4),
                        TextButton(
                          onPressed: () => Navigator.push(context, 
                            MaterialPageRoute(builder: (_) => RegisterScreen())),
                          child: Text('Sign up', 
                            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
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