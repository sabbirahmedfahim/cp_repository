import 'package:flutter/material.dart';
import '../database.dart';
import '../widgets/simple_button.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';
import 'welcome_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  String error = '';

  Future<void> doLogin() async {
    if (emailController.text.isEmpty) {
      setState(() => error = 'Email required');
      return;
    }
    if (!emailController.text.contains('@')) {
      setState(() => error = 'Valid email needed');
      return;
    }
    if (passwordController.text.isEmpty) {
      setState(() => error = 'Password required');
      return;
    }

    setState(() {
      loading = true;
      error = '';
    });

    try {
      await login(emailController.text.trim(), passwordController.text.trim());
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } catch (e) {
      String msg = e.toString();
      if (msg.contains('Invalid login')) msg = 'Wrong email/password';
      setState(() => error = msg);
    } finally {
      setState(() => loading = false);
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      contentPadding: EdgeInsets.symmetric(horizontal: 26, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // title: Text('CP Repository'),
        backgroundColor: Colors.blue.shade100,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue.shade50,
              backgroundImage: AssetImage('assets/images/logo.png'),
            ),
            SizedBox(height: 24),
            Text('CP Repository', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue)),
            SizedBox(height: 8),
            Text('Track Your CP Progress', style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
            SizedBox(height: 30),

            if (error.isNotEmpty)
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error,
                        style: TextStyle(color: Colors.red.shade800, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            Text('Email', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Container(
              width: 300,
              child: TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('your.email@example.com'),
              ),
            ),
            SizedBox(height: 20),

            Text('Password', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Container(
              width: 300,
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: _inputDecoration('••••••••'),
              ),
            ),
            SizedBox(height: 8),

            Container(
              width: 300,
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordScreen())),
                  child: Text('Forgotten password?', style: TextStyle(color: Colors.blue, fontSize: 12)),
                ),
              ),
            ),
            SizedBox(height: 24),

            Container(
              width: 300,
              child: SimpleButton(text: 'Sign in', onPressed: doLogin, loading: loading),
            ),
            SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('First time?'),
                SizedBox(width: 4),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen())),
                  child: Text('Sign up', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}