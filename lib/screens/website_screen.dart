import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../providers/website_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final websiteProvider =
        Provider.of<WebsiteProvider>(context); // Access the WebsiteProvider

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
            Expanded(
              // Expanded widget allows the list to take up remaining space
              child: ListView.builder(
                itemCount:
                    websiteProvider.websites.length, // Number of websites
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(websiteProvider
                        .websites[index].url), // Display website URL
                    trailing: Row(
                      mainAxisSize: MainAxisSize
                          .min, // Minimize row size to fit buttons only
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit), // Edit icon button
                          onPressed: () {
                            _editWebsiteDialog(context, index,
                                websiteProvider); // Open edit dialog
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete), // Delete icon button
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
          ],
        ),
      ),
    );
  }

  // Function to display a dialog for editing the website URL
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
