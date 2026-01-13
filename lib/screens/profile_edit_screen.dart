import 'package:flutter/material.dart';
import '../database.dart';
import '../widgets/simple_button.dart';

class ProfileEditScreen extends StatefulWidget {
  final String? initialName;
  final String? initialUniversity;

  ProfileEditScreen({this.initialName, this.initialUniversity});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final nameController = TextEditingController();
  final universityController = TextEditingController();
  bool loading = false;
  String error = '';
  String success = '';

  @override
  void initState() {
    super.initState();
    nameController.text = widget.initialName ?? '';
    universityController.text = widget.initialUniversity ?? '';
  }

  Future<void> saveProfile() async {
    setState(() {
      loading = true;
      error = '';
      success = '';
    });

    try {
      await updateUserProfile(
        fullName: nameController.text.isEmpty ? null : nameController.text,
        university: universityController.text.isEmpty ? null : universityController.text,
      );
      
      setState(() => success = 'Profile updated successfully');
      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(context, true);
      
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    universityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (success.isNotEmpty)
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
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        success,
                        style: TextStyle(color: Colors.green.shade800, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            if (error.isNotEmpty)
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
                        error,
                        style: TextStyle(color: Colors.red.shade800, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 20),
            Text('Full Name (Optional)', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'e.g., John Doe',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            SizedBox(height: 20),
            
            Text('University (Optional)', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            TextFormField(
              controller: universityController,
              decoration: InputDecoration(
                hintText: 'e.g., Stanford University',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            SizedBox(height: 32),
            
            SimpleButton(text: 'Save Changes', onPressed: saveProfile, loading: loading),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}