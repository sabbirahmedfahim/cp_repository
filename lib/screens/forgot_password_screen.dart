import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  void _copyEmailToClipboard(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Email copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Icon(Icons.admin_panel_settings, size: 80, color: Colors.blue),
            SizedBox(height: 24),
            Text('Password Reset', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Need to reset your password? Contact our admin team.', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            SizedBox(height: 40),
            
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.email, color: Colors.blue),
                      SizedBox(width: 12),
                      Text('Contact Admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text('Email our admin team at:', style: TextStyle(color: Colors.grey.shade700, fontSize: 15)),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _copyEmailToClipboard(context),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.content_copy, size: 16, color: Colors.blue),
                          SizedBox(width: 8),
                          Expanded(
                            child: SelectableText(
                              'dev.sabbirfahim@gmail.com',
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Instructions:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                  SizedBox(height: 8),
                  Text(
                    '1. Send an email to the address above\n'
                    '2. Include your registered email address\n'
                    '3. Mention your desired new password\n'
                    '4. We will reset it manually and confirm',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.6),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Response time: Usually within 24 hours',
                    style: TextStyle(color: Colors.green.shade700, fontStyle: FontStyle.italic, fontSize: 13),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 40),
            CustomButton(
              text: 'I Understand',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
            
            SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text('Back to Login', style: TextStyle(color: Colors.blue, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}