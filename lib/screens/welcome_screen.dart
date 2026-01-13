import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.all(24),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade900),
                      children: [
                        TextSpan(text: 'Ever lost track of problems solved across '),
                        TextSpan(
                          text: 'Codeforces',
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => launchUrl(Uri.parse('https://codeforces.com')),
                        ),
                        TextSpan(text: ', '),
                        TextSpan(
                          text: 'LeetCode',
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => launchUrl(Uri.parse('https://leetcode.com')),
                        ),
                        TextSpan(text: ', or any Online Judges?'),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('That\'s why we built CP Repository - a simple place to keep all your CP problems organized.', style: TextStyle(fontSize: 16, color: Colors.grey.shade800)),
                  SizedBox(height: 24),
                  _featureRow('Add problems from ANY platform'),
                  SizedBox(height: 12),
                  _featureRow('Mark them as Solved/In Progress'),
                  SizedBox(height: 12),
                  _featureRow('See your stats grow'),
                  SizedBox(height: 12),
                  _featureRow('Add tags for topic-wise sorting'),
                  SizedBox(height: 24),
                  Text('No more scattered solutions. Just clean, focused tracking.', style: TextStyle(fontSize: 16, color: Colors.grey.shade800, fontStyle: FontStyle.italic)),
                ],
              ),
            ),

            SizedBox(height: 40),
            Container(
              width: 300,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text('Back to Sign in', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),

            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Icon(Icons.format_quote, color: Colors.black, size: 30),
                  SizedBox(height: 12),
                  Text(
                    'A competitive programmer is someone who gets excited about things that no one else cares about.',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.grey.shade800, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _featureRow(String text) {
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