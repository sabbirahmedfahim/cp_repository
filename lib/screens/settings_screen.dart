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
  bool loadingProfile = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() => loadingProfile = true);
    try {
      final profile = await getUserProfile();
      setState(() => userProfile = profile);
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      setState(() => loadingProfile = false);
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account?'),
        content: Text('This will permanently remove all your problems and data. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount(context);
            },
            child: Text('Delete Account', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout All Devices?'),
        content: Text('You will be logged out from all devices and need to login again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logoutAll(context);
            },
            child: Text('Logout Everywhere'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Account deletion not implemented')),
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

  void _openAbout(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => WelcomeScreen()));
  }

  void _openHelp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Help section')),
    );
  }

  void _openContact(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contact support')),
    );
  }

  void _openPrivacy(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Privacy policy')),
    );
  }

  void _openTerms(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terms of service')),
    );
  }

  Future<void> _openEditProfile(BuildContext context) async {
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('⚙️ ACCOUNT SETTINGS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            
            loadingProfile
                ? Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      Icon(Icons.person, color: Colors.blue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName ?? 'User',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 2),
                            Text(
                              userEmail ?? 'email@example.com',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            if (university != null && university.isNotEmpty) ...[
                              SizedBox(height: 2),
                              Text(
                                university,
                                style: TextStyle(color: Colors.blue.shade600, fontSize: 13),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, size: 18, color: Colors.blue),
                        onPressed: () => _openEditProfile(context),
                      ),
                    ],
                  ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 24),

            Text('🔒 SECURITY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.lock, color: Colors.blue),
              title: Text('Change Password'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordScreen())),
            ),
            Divider(),

            SizedBox(height: 24),
            Text('⚠️ ACCOUNT ACTIONS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Account', style: TextStyle(color: Colors.red)),
              onTap: () => _showDeleteDialog(context),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.orange),
              title: Text('Logout All Devices'),
              onTap: () => _showLogoutDialog(context),
            ),
            Divider(),

            SizedBox(height: 24),
            Text('ℹ️ ABOUT & SUPPORT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.info, color: Colors.blue),
              title: Text('About CP Repository'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _openAbout(context),
            ),
            ListTile(
              leading: Icon(Icons.help, color: Colors.green),
              title: Text('Help & FAQ'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _openHelp(context),
            ),
            ListTile(
              leading: Icon(Icons.email, color: Colors.purple),
              title: Text('Contact Support'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _openContact(context),
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip, color: Colors.teal),
              title: Text('Privacy Policy'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _openPrivacy(context),
            ),
            ListTile(
              leading: Icon(Icons.description, color: Colors.brown),
              title: Text('Terms of Service'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _openTerms(context),
            ),
          ],
        ),
      ),
    );
  }
}