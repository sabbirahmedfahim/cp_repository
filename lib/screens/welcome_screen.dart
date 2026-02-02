import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/simple_button.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: isSmallScreen ? 16 : 18, color: Colors.grey.shade900),
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
                      Text('That\'s why we built CP Repository - a simple place to keep all your CP problems organized.', 
                        style: TextStyle(fontSize: isSmallScreen ? 16 : 18, color: Colors.grey.shade800)),
                      SizedBox(height: 24),
                      _greenCheckMark('Add problems from ANY platform', isSmallScreen),
                      SizedBox(height: 12),
                      _greenCheckMark('Mark them as Solved/In Progress', isSmallScreen),
                      SizedBox(height: 12),
                      _greenCheckMark('See your stats grow', isSmallScreen),
                      SizedBox(height: 12),
                      _greenCheckMark('Add tags for topic-wise sorting', isSmallScreen),
                      SizedBox(height: 24),
                      Text('No more scattered solutions. Just clean, focused tracking.', 
                        style: TextStyle(fontSize: isSmallScreen ? 16 : 18, color: Colors.grey.shade800, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),

                SizedBox(height: 40),
                Container(
                  width: isSmallScreen ? 300 : 400,
                  child: SimpleButton(
                    text: 'Back',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                SizedBox(height: 40),
                Container(
                  padding: EdgeInsets.all(20),
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
                        style: TextStyle(
                          fontWeight: FontWeight.w600, 
                          fontSize: isSmallScreen ? 16 : 18, 
                          color: Colors.grey.shade800, 
                          fontStyle: FontStyle.italic),
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
      ),
    );
  }

  Widget _greenCheckMark(String text, bool isSmallScreen) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, size: isSmallScreen ? 20 : 24, color: Colors.green),
        SizedBox(width: 12),
        Expanded(child: Text(text, 
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: isSmallScreen ? 16 : 18))),
      ],
    );
  }
}