import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For encoding/decoding JSON
import '../models/website.dart';

class WebsiteProvider with ChangeNotifier {
  List<Website> _websites = [];

  // Getter to access the list of websites
  List<Website> get websites => _websites;

  // Constructor to load websites from SharedPreferences when the provider is initialized
  WebsiteProvider() {
    _loadWebsites(); // Load websites from storage when the app starts
  }

  // Method to add a new website to the list and save it
  void addWebsite(String url) {
    _websites.add(Website(url: url)); // Add the website
    _saveWebsites(); // Save the updated list to SharedPreferences
    notifyListeners(); // Notify listeners about the change
  }

  // Method to remove a website and save the updated list
  void removeWebsite(int index) {
    _websites.removeAt(index); // Remove the website
    _saveWebsites(); // Save the updated list to SharedPreferences
    notifyListeners(); // Notify listeners about the change
  }

  // Method to update an existing website's URL and save the updated list
  void updateWebsite(int index, String newUrl) {
    _websites[index].url = newUrl; // Update the website URL
    _saveWebsites(); // Save the updated list to SharedPreferences
    notifyListeners(); // Notify listeners about the change
  }

  // Method to load websites from SharedPreferences
  void _loadWebsites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? websitesJson =
        prefs.getString('websites'); // Get the stored websites in JSON format
    if (websitesJson != null) {
      List<dynamic> websitesList =
          jsonDecode(websitesJson); // Decode the JSON string
      _websites = websitesList
          .map((json) => Website(url: json))
          .toList(); // Convert to Website objects
      notifyListeners(); // Notify listeners that the websites have been loaded
    }
  }

  // Method to save the websites list to SharedPreferences
  void _saveWebsites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> websitesList = _websites
        .map((website) => website.url)
        .toList(); // Convert to a list of URLs
    String websitesJson = jsonEncode(websitesList); // Encode the list as JSON
    prefs.setString(
        'websites', websitesJson); // Store the JSON string in SharedPreferences
  }
}
