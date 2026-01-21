import 'package:flutter/material.dart';
import '../database.dart';
import '../widgets/simple_button.dart';

class ProfileEditScreen extends StatefulWidget {
  final String? initialName;
  final String? initialUniversity;

  const ProfileEditScreen({this.initialName, this.initialUniversity});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _controllers = [TextEditingController(), TextEditingController()];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controllers[0].text = widget.initialName ?? '';
    _controllers[1].text = widget.initialUniversity ?? '';
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      await updateUserProfile(
        fullName: _controllers[0].text.trim(),
        university: _controllers[1].text.trim(),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration _textFieldDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade500),
    border: _border(Colors.grey.shade700),
    enabledBorder: _border(Colors.grey.shade700),
    focusedBorder: _border(Colors.blue),
    fillColor: Colors.grey.shade900,
    filled: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color),
  );

  Widget _buildTextField(int index, String label, String hint) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
      SizedBox(height: 8),
      TextFormField(
        controller: _controllers[index],
        style: TextStyle(color: Colors.white),
        decoration: _textFieldDecoration(hint),
      ),
    ],
  );

  @override
  void dispose() {
    _controllers.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Edit Profile', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24),
                _buildTextField(0, 'Full Name', 'Your name'),
                SizedBox(height: 20),
                _buildTextField(1, 'University', 'Your university (optional)'),
                SizedBox(height: 32),
                SimpleButton(text: 'Save Profile', onPressed: _saveProfile, loading: _isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}