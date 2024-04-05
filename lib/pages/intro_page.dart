// intro_page.dart
import 'package:flutter/material.dart';
import 'package:camera_app/main.dart'; // Import your main.dart file

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  // Add your instructions here
  final List<String> _instructions = [
    'Welcome to the Facial Acquisition Application. Swipe to the next page to get started.',
    'In this app you will be guided to take 18 photos of your face and will receive an optional prompt for 3 extra images if you have special facial features. Take note of the angles in the images above. Swipe to the next page.',
    'Basically, you will take pictures of your face from the left side through to the middle and finally to the right side of your face. Swipe to the next page to get started.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: 3, // Number of pages in your tutorial
        itemBuilder: (context, index) {
          return Column(
            children: <Widget>[
              Image.asset('assets/download_$index.jpg'), // Replace with your tutorial images
              Text(_instructions[index], style: const TextStyle(fontSize: 20),), // Replace with your instructions
            ],
          );
        },
        onPageChanged: (value) {
          setState(() {
            _currentPage = value;
          });
        },
      ),
      floatingActionButton: _currentPage == 2 // Show the button on the last page
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const CameraApp()),
                  (Route<dynamic> route) => false, // This makes sure that no routes remain in the stack
                );
              },
              child: const Icon(Icons.arrow_forward),
            )
          : null,
    );
  }
}