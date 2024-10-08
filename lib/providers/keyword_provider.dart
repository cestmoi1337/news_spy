import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For encoding/decoding JSON
import '../models/keyword.dart';

class KeywordProvider with ChangeNotifier {
  List<Keyword> _keywords = [];

  // Getter to access the list of keywords
  List<Keyword> get keywords => _keywords;

  // Constructor to load keywords from SharedPreferences when the provider is initialized
  KeywordProvider() {
    _loadKeywords(); // Load keywords from storage when the app starts
  }

  // Method to add a new keyword to the list and save it
  void addKeyword(String keyword) {
    _keywords.add(Keyword(keyword: keyword)); // Add the new keyword
    _saveKeywords(); // Save the updated list to SharedPreferences
    notifyListeners(); // Notify listeners about the change
  }

  // Method to remove a keyword and save the updated list
  void removeKeyword(int index) {
    _keywords.removeAt(index); // Remove the keyword
    _saveKeywords(); // Save the updated list to SharedPreferences
    notifyListeners(); // Notify listeners about the change
  }

  // Method to update an existing keyword and save the updated list
  void updateKeyword(int index, String newKeyword) {
    _keywords[index].keyword = newKeyword; // Update the keyword
    _saveKeywords(); // Save the updated list to SharedPreferences
    notifyListeners(); // Notify listeners about the change
  }

  // Method to load keywords from SharedPreferences
  void _loadKeywords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? keywordsJson =
        prefs.getString('keywords'); // Get the stored keywords in JSON format
    if (keywordsJson != null) {
      List<dynamic> keywordsList =
          jsonDecode(keywordsJson); // Decode the JSON string
      _keywords = keywordsList
          .map((json) => Keyword(keyword: json))
          .toList(); // Convert to Keyword objects
      notifyListeners(); // Notify listeners that the keywords have been loaded
    }
  }

  // Method to save the keywords list to SharedPreferences
  void _saveKeywords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keywordsList = _keywords
        .map((keyword) => keyword.keyword)
        .toList(); // Convert to a list of keyword strings
    String keywordsJson = jsonEncode(keywordsList); // Encode the list as JSON
    prefs.setString(
        'keywords', keywordsJson); // Store the JSON string in SharedPreferences
  }
}
