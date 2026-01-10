import 'package:flutter/material.dart';
import '../database.dart';
import '../widgets/simple_button.dart';
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

  WidgetSpan _clickableSpan(String text, String url) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: GestureDetector(
        onTap: () => openUrl(url),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        SizedBox(height: 40),
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue.shade50,
                          backgroundImage: AssetImage('assets/images/logo.png'),
                        ),
                        SizedBox(height: 16),
                        Text('CP Repository', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                        SizedBox(height: 8),
                        Text('All your CP problems. One place.', style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 40),
                        
                        if (error.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(12),
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.red.shade200)
                            ),
                            child: Row(children: [
                              Icon(Icons.error, color: Colors.red, size: 16),
                              SizedBox(width: 8),
                              Expanded(child: Text(error, style: TextStyle(color: Colors.red.shade800, fontSize: 12))),
                            ]),
                          ),
                        
                        Text('Email', style: TextStyle(fontWeight: FontWeight.w500)),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          child: TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'your.email@example.com',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        
                        Text('Password', style: TextStyle(fontWeight: FontWeight.w500)),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordScreen())),
                            child: Text('Forgot password?', style: TextStyle(color: Colors.blue, fontSize: 12)),
                          ),
                        ),
                        
                        SizedBox(height: 24),
                        SimpleButton(text: 'See My Progress', onPressed: doLogin, loading: loading),
                        
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
                ),
              ),
              
              Container(width: 1, color: Colors.grey.shade300, margin: EdgeInsets.symmetric(vertical: 40)),
              
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 60),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade900, fontWeight: FontWeight.w500),
                          children: [
                            TextSpan(text: 'Ever lost track of which problems you\'ve solved across '),
                            _clickableSpan('Codeforces', 'https://codeforces.com'),
                            TextSpan(text: ', '),
                            _clickableSpan('LeetCode', 'https://leetcode.com'),
                            TextSpan(text: ', or '),
                            _clickableSpan('HackerRank', 'https://hackerrank.com'),
                            TextSpan(text: '?'),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      Text('We\'ve been there too. That\'s why we built CP Repository - a simple place to keep all your CP problems organized.', style: TextStyle(fontSize: 16, color: Colors.grey.shade800)),
                      SizedBox(height: 32),
                      Column(
                        children: [
                          _feature('Add problems from ANY platform'),
                          SizedBox(height: 16),
                          _feature('Mark them as Solved/In Progress'),
                          SizedBox(height: 16),
                          _feature('See your stats grow'),
                          SizedBox(height: 16),
                          _feature('Add notes for later review'),
                        ],
                      ),
                      SizedBox(height: 32),
                      Text('No more scattered solutions. Just clean, focused tracking of your CP journey.', style: TextStyle(fontSize: 16, color: Colors.grey.shade800, fontStyle: FontStyle.italic)),
                      SizedBox(height: 48),
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300)
                        ),
                        child: Column(children: [
                          Icon(Icons.format_quote, color: Colors.grey.shade600),
                          SizedBox(height: 12),
                          Text('A competitive programmer is someone who gets excited about things that no one else cares about.', style: TextStyle(fontSize: 17, color: Colors.grey.shade800, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
                        ]),
                      ),
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

  Widget _feature(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, size: 20, color: Colors.green),
        SizedBox(width: 12),
        Expanded(child: Text(text, style: TextStyle(color: Colors.grey.shade800))),
      ],
    );
  }
}