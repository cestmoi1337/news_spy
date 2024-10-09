import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'dart:async';

class WebScraper {
  // Method to fetch the HTML content from a website
  Future<String?> fetchWebsiteContent(String url) async {
    try {
      final response =
          await http.get(Uri.parse(url)); // Make the HTTP GET request
      if (response.statusCode == 200) {
        return response.body; // Return the HTML content of the page
      } else {
        print("Failed to load website: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching website: $e");
      return null;
    }
  }

  // Method to extract article titles from the website HTML content
  List<String> extractArticleTitles(String htmlContent) {
    var document = parse(htmlContent); // Parse the HTML content
    List<String> articleTitles = [];

    // Example: Assuming article titles could be in <h2> or <h3> tags
    var articleElements =
        document.querySelectorAll('h2, h3'); // Find all <h2> and <h3> tags
    for (var element in articleElements) {
      String? title = element.text;
      if (title.isNotEmpty) {
        articleTitles.add(title); // Add the article title to the list
      }
    }

    return articleTitles;
  }

  // Method to filter articles based on keywords
  List<String> filterArticlesByKeyword(
      List<String> articleTitles, List<String> keywords) {
    List<String> matchingArticles = [];

    for (var title in articleTitles) {
      for (var keyword in keywords) {
        if (title.toLowerCase().contains(keyword.toLowerCase())) {
          matchingArticles.add(title); // Add the matching article to the list
          break; // Stop searching for other keywords once a match is found
        }
      }
    }

    return matchingArticles;
  }
}

