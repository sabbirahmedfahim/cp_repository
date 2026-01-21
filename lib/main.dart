import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://daurmqazalgomkpnkamh.supabase.co',
    anonKey: 'sb_publishable_u44juBKuRLtlpEc3g2d56A__hVz4cU5',
  );
  
  runApp(myApp());
}

class myApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CP Repository',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}