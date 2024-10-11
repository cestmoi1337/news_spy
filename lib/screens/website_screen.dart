import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher for opening links
import '../providers/website_provider.dart';
import '../providers/keyword_provider.dart'; // Import KeywordProvider
import '../services/web_scraper.dart'; // Import WebScraper
import 'keyword_screen.dart'; // Import the KeywordScreen
import '../models/website.dart'; // Import the Website model
import '../models/keyword.dart'; // Import the Keyword model

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

  List<Map<String, String>> _matchedArticles =
      []; // List to store matching articles (title and URL)

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
            // Form to add a website
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

            // Expanded list of websites
            Expanded(
              child: ListView.builder(
                itemCount:
                    websiteProvider.websites.length, // Number of websites
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(websiteProvider
                        .websites[index].url), // Display website URL
                    trailing: Row(
                      mainAxisSize:
                          MainAxisSize.min, // Minimize row size to fit buttons
                      children: [
                        // Edit button
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editWebsiteDialog(context, index,
                                websiteProvider); // Open edit dialog
                          },
                        ),
                        // Delete button
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            websiteProvider
                                .removeWebsite(index); // Remove website
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Display matched articles
            Expanded(
              child: _matchedArticles.isEmpty
                  ? Center(
                      child: Text(
                          'No matching articles found')) // Display if no articles
                  : ListView.builder(
                      itemCount: _matchedArticles
                          .length, // Number of matching articles
                      itemBuilder: (context, index) {
                        final article = _matchedArticles[index];
                        final title = article['title']!;
                        final url = article['url']!;

                        return ListTile(
                          title: Text(
                            title,
                            style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration
                                    .underline), // Style as a link
                          ),
                          onTap: () async {
                            // Open the article URL in the default browser
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              print('Could not launch $url');
                            }
                          },
                        );
                      },
                    ),
            ),

            // Spacer to push the button to the bottom
            SizedBox(height: 24),

            // Search for Articles button placed at the bottom
            ElevatedButton(
              onPressed: () async {
                await _scrapeWebsites(websiteProvider.websites,
                    keywordProvider.keywords); // Start scraping
              },
              child: Text('Search for Articles'),
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
        .cast<Keyword>()
        .map((keyword) => keyword.keyword)
        .toList(); // Convert keywords to a list of strings
    List<Map<String, String>> allMatchedArticles =
        []; // Store matched articles with title and URL

    print('Starting to scrape websites...');

    for (var website in websites) {
      // Ensure the URL starts with http:// or https://
      String url = website.url.startsWith('http')
          ? website.url
          : 'https://${website.url}';

      print('Fetching content from: $url');
      // Fetch website content
      String? content = await _webScraper.fetchWebsiteContent(url);

      if (content != null) {
        print('Successfully fetched content from: $url');

        // Extract article titles from the content
        List<String> articleTitles = _webScraper.extractArticleTitles(content);
        print('Extracted ${articleTitles.length} article titles from: $url');

        // Filter articles that match any of the keywords
        for (var title in articleTitles) {
          if (keywordList.any((keyword) =>
              title.toLowerCase().contains(keyword.toLowerCase()))) {
            allMatchedArticles.add(
                {'title': title, 'url': url}); // Add matching article with URL
          }
        }
      } else {
        print('Failed to fetch content from: $url');
      }
    }

    // Update the state to display the matched articles
    setState(() {
      _matchedArticles = allMatchedArticles;
      print('Updated matched articles: $_matchedArticles');
    });

    if (allMatchedArticles.isEmpty) {
      print('No articles matched the keywords');
    }
  }

  // Dialog to edit website URL
  void _editWebsiteDialog(
      BuildContext context, int index, WebsiteProvider websiteProvider) {
    final _editUrlController = TextEditingController(
      text: websiteProvider
          .websites[index].url, // Pre-fill the text field with the current URL
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Website URL'), // Title of the dialog
          content: FormBuilder(
            child: FormBuilderTextField(
              name: 'editUrl',
              controller: _editUrlController, // Controller for the edit field
              decoration: InputDecoration(
                labelText: 'Website URL', // Input label
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a website URL'; // Validator for empty input
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without saving
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_editUrlController.text.isNotEmpty) {
                  websiteProvider.updateWebsite(
                      index, _editUrlController.text); // Update the website URL
                  Navigator.of(context).pop(); // Close the dialog after saving
                }
              },
              child: Text('Save'), // Button to save changes
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _urlController
        .dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }
}
