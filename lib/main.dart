import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '  Image Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _fetchRandomPhotos(20); // Fetch 10 images when the widget is initialized
  }

  Future<void> _fetchRandomPhotos(int count) async {
    final String accessKey = 'j4kSi5afLMnSMng06A2cS5qsnIitd0cbygf8felTvDo'; // Replace with your Unsplash access key
    final String apiUrl = 'https://api.unsplash.com/photos/random?client_id=$accessKey&count=$count';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<String> urls = [];
        List<int> heights = [];
        List<int> widths = [];
        for (var photo in data) {
          urls.add(photo['urls']['regular']);
          heights.add(photo['height']);
          widths.add(photo['width']);
        }
        setState(() {
          _imageUrls = urls;
        });
      } else {
        print('Failed to fetch photos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching photos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unsplash Image Generator'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_imageUrls.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _calculateCrossAxisCount(context),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _imageUrls.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 150, // Set desired width
                      height: 150, // Set desired height
                      child: Image.network(
                        _imageUrls[index],
                        fit: BoxFit.cover, // Ensure images fit within their containers
                      ),
                    );
                  },
                )
              else
                const Text('Loading images...'), // Display loading message while images are fetched
            ],
          ),
        ),
      ),
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth / 200).floor(); // Adjust 200 based on desired image width
    return crossAxisCount > 1 ? crossAxisCount : 1; // Ensure at least 1 image is displayed
  }
}
