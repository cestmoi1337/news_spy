import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/website_provider.dart';
import 'providers/keyword_provider.dart'; // Import the KeywordProvider
import 'screens/website_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Using MultiProvider to provide both WebsiteProvider and KeywordProvider
      providers: [
        ChangeNotifierProvider(create: (context) => WebsiteProvider()),
        ChangeNotifierProvider(
            create: (context) => KeywordProvider()), // Add KeywordProvider
      ],
      child: MaterialApp(
        title: 'News Spy',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: WebsiteScreen(),
      ),
    );
  }
}
