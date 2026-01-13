import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  void copyEmail(BuildContext context) {
    Clipboard.setData(ClipboardData(text: 'admin@gmail.com'));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.admin_panel_settings, size: 80, color: Colors.blue),
            SizedBox(height: 18),
            Text('Password Reset', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Need to reset password? Contact admin.', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 30),
            
            Center(
              child: Container(
                width: 300,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade100)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.email, color: Colors.blue),
                      SizedBox(width: 12),
                      Text('Contact Admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                    ]),
                    SizedBox(height: 16),
                    Text('Email our admin team:', style: TextStyle(color: Colors.grey.shade700)),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => copyEmail(context),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade200)),
                        child: Row(children: [
                          Icon(Icons.content_copy, size: 16, color: Colors.blue),
                          SizedBox(width: 8),
                          Expanded(child: SelectableText('admin@gmail.com', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500))),
                        ]),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Instructions:', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Text('1. Send email with your registered email\n2. Mention desired new password\n3. We reset manually and confirm', style: TextStyle(color: Colors.grey.shade700)),
                    SizedBox(height: 12),
                    Text('Response: Usually within 24 hours', style: TextStyle(color: Colors.green, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 40),
            Center(
              child: Container(
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
            ),
          ],
        ),
      ),
    );
  }
}