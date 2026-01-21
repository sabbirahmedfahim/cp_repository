import 'package:flutter/material.dart';
import '../database.dart';
import 'login_screen.dart';
import 'forgot_password_screen.dart';
import 'welcome_screen.dart';
import 'profile_edit_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() => isLoading = true);
    try {
      final profile = await getUserProfile();
      setState(() => userProfile = profile);
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Delete Account?', style: TextStyle(color: Colors.white)),
        content: Text('This will permanently remove all your problems and data. This action cannot be undone.',
          style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete Account', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Logout All Devices?', style: TextStyle(color: Colors.white)),
        content: Text('You will be logged out from all devices and need to login again.',
          style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logoutAll(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Logout Everywhere', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteAccount(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contact Admin!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _logoutAll(BuildContext context) async {
    await logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  void _aboutSection(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => WelcomeScreen()));
  }

  void _helpSection(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Help section'),
        backgroundColor: Colors.grey[900],
      ),
    );
  }

  void _contactSection(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contact support'),
        backgroundColor: Colors.grey[900],
      ),
    );
  }

  void _privacySection(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Privacy policy'),
        backgroundColor: Colors.grey[900],
      ),
    );
  }

  void _termsSection(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Terms of service'),
        backgroundColor: Colors.grey[900],
      ),
    );
  }

  Future<void> _profileEditSection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileEditScreen(
          initialName: userProfile?['full_name'],
          initialUniversity: userProfile?['university'],
        ),
      ),
    );
    
    if (result == true) {
      await loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = userProfile?['full_name'] as String?;
    final university = userProfile?['university'] as String?;
    final userEmail = supabase.auth.currentUser?.email;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Settings', style: TextStyle(color: Colors.white)),
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
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isLoading
                      ? Center(child: CircularProgressIndicator(color: Colors.blue))
                      : Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.person, color: Colors.white, size: 24),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fullName ?? 'User',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    userEmail ?? 'email@example.com',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (university != null && university.isNotEmpty) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      university,
                                      style: TextStyle(
                                        color: Colors.blue.shade300,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, size: 20, color: Colors.blue),
                              onPressed: () => _profileEditSection(context),
                            ),
                          ],
                        ),
                ),
                SizedBox(height: 24),

                Text('SECURITY', 
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade400,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.lock, color: Colors.blue, size: 20),
                        ),
                        title: Text('Change Password', 
                          style: TextStyle(color: Colors.white, fontSize: 15)),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade500),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordScreen())),
                      ),
                      Divider(color: Colors.grey.shade800, height: 0, indent: 16, endIndent: 16),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                Text('ACCOUNT ACTIONS', 
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade400,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.delete, color: Colors.red, size: 20),
                        ),
                        title: Text('Delete Account', 
                          style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.w500)),
                        onTap: () => _showDeleteDialog(context),
                      ),
                      Divider(color: Colors.grey.shade800, height: 0, indent: 16, endIndent: 16),
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.logout, color: Colors.orange, size: 20),
                        ),
                        title: Text('Logout All Devices', 
                          style: TextStyle(color: Colors.orange, fontSize: 15, fontWeight: FontWeight.w500)),
                        onTap: () => _showLogoutDialog(context),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                Text('ABOUT & SUPPORT', 
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade400,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.info, color: Colors.blue, size: 20),
                        ),
                        title: Text('About CP Repository', 
                          style: TextStyle(color: Colors.white, fontSize: 15)),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade500),
                        onTap: () => _aboutSection(context),
                      ),
                      Divider(color: Colors.grey.shade800, height: 0, indent: 16, endIndent: 16),
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.help, color: Colors.green, size: 20),
                        ),
                        title: Text('Help & FAQ', 
                          style: TextStyle(color: Colors.white, fontSize: 15)),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade500),
                        onTap: () => _helpSection(context),
                      ),
                      Divider(color: Colors.grey.shade800, height: 0, indent: 16, endIndent: 16),
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.email, color: Colors.purple, size: 20),
                        ),
                        title: Text('Contact Support', 
                          style: TextStyle(color: Colors.white, fontSize: 15)),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade500),
                        onTap: () => _contactSection(context),
                      ),
                      Divider(color: Colors.grey.shade800, height: 0, indent: 16, endIndent: 16),
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.privacy_tip, color: Colors.teal, size: 20),
                        ),
                        title: Text('Privacy Policy', 
                          style: TextStyle(color: Colors.white, fontSize: 15)),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade500),
                        onTap: () => _privacySection(context),
                      ),
                      Divider(color: Colors.grey.shade800, height: 0, indent: 16, endIndent: 16),
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.brown.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.description, color: Colors.brown, size: 20),
                        ),
                        title: Text('Terms of Service', 
                          style: TextStyle(color: Colors.white, fontSize: 15)),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade500),
                        onTap: () => _termsSection(context),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}