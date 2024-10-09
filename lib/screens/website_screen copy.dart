import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:news_spy/screens/keyword_screen.dart';
import '../providers/website_provider.dart';
import '../providers/keyword_provider.dart'; // Import KeywordProvider
import '../services/web_scraper.dart'; // Import WebScraper
import '../models/website.dart'; // Import the Website model
import '../models/keyword.dart'; // Import the Keyword model
import 'keyword_screen.dart'; // Import the KeywordScreen


class WebsiteScreen extends StatefulWidget {
  @override
  _WebsiteScreenState createState() => _WebsiteScreenState();
}

class _WebsiteScreenState extends State<WebsiteScreen> {
  final _formKey =
      GlobalKey<FormBuilderState>(); // Global key to manage the form
  final _urlController =
      TextEditingController(); // Controller to manage text input for adding websites
  final WebScraper _webScraper = WebScraper(); // Instance of WebScraper

  List<String> _matchedArticles = []; // List to store matching articles

  @override
  Widget build(BuildContext context) {
    final websiteProvider =
        Provider.of<WebsiteProvider>(context); // Access the WebsiteProvider
    final keywordProvider =
        Provider.of<KeywordProvider>(context); // Access the KeywordProvider

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Websites'),
        actions: [
          IconButton(
            icon: Icon(Icons
                .list), // Button to navigate to the keyword management screen
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        KeywordScreen()), // Navigate to KeywordScreen
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FormBuilder(
              key: _formKey, // Key to manage the form state
              child: Column(
                children: [
                  FormBuilderTextField(
                    name: 'url',
                    controller:
                        _urlController, // Controller for the URL input field
                    decoration: InputDecoration(
                      labelText: 'Website URL', // Input label
                      border:
                          OutlineInputBorder(), // Adds a border to the input field
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a website URL'; // Validator for empty input
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        websiteProvider
                            .addWebsite(_urlController.text); // Add website
                        _urlController
                            .clear(); // Clear the input field after adding
                      }
                    },
                    child: Text('Add Website'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await _scrapeWebsites(websiteProvider.websites,
                    keywordProvider.keywords); // Start scraping
              },
              child: Text('Search for Articles'),
            ),
            SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount:
                    _matchedArticles.length, // Number of matching articles
                itemBuilder: (context, index) {
                  return ListTile(
                    title:
                        Text(_matchedArticles[index]), // Display article title
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to scrape all websites and filter articles based on keywords
  Future<void> _scrapeWebsites(
      List<Website> websites, List<Keyword> keywords) async {
    List<String> keywordList = keywords
        .map((keyword) => keyword.keyword)
        .toList(); // Convert keywords to a list of strings
    List<String> allMatchedArticles = []; // Store all matched articles

    for (var website in websites) {
      // Fetch website content
      String? content = await _webScraper.fetchWebsiteContent(website.url);

      if (content != null) {
        // Extract article titles from the content
        List<String> articleTitles = _webScraper.extractArticleTitles(content);

        // Filter articles that match any of the keywords
        List<String> matchedArticles =
            _webScraper.filterArticlesByKeyword(articleTitles, keywordList);

        // Add the matched articles to the result list
        allMatchedArticles.addAll(matchedArticles);
      }
    }

    // Update the state to display the matched articles
    setState(() {
      _matchedArticles = allMatchedArticles;
    });
  }

  @override
  void dispose() {
    _urlController
        .dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }
}
