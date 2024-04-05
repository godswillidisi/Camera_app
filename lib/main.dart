import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:camera_app/pages/preview_screen.dart';
import 'pages/intro_page.dart';

late List<CameraDescription> cameras; // Define cameras here at the global scope
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: IntroPage(),
    );
  }
}

class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController _controller;
  FlutterTts flutterTts = FlutterTts();
  int photoCount = 0;
  List<String> imagePaths = []; // Store all image paths here
  String currentInstruction = '';
  bool _flashOn = false;

  List<String> instructionMessages = [
    // audio messages that guides the user to take the photos
    "position the camera towards your left ear, capturing your side profile and press take photo",
    "Tilt the camera at 30 degrees upwards at the middle of your face, take photo",
    "adjust a little and take another photo",
    "Take photo again",
    "Hold steady for a moment and take photo.",
    "Gently bring the camera to capture your left cheek and take photo.",
    "position the camera 11 degrees in front of your face and take photo",
    "Smile broadly at the camera and take photo",
    "Elevate the camera to get your entire face in the frame and take photo",
    "hold steady and take photo",
    "keep pushing to the right slowly and take photo ",
    "Slowly pan the camera downwards at minus 15 degrees and take photo",
    "Now, lower the camera to chin level and take photo",
    "youre almost there, take photo again",
    "youre doing great, adjust to the right and take photo",
    "Start moving the camera towards your right cheek and take photo",
    "Rotate the camera to focus on your right ear, getting a clear side profile",
    "You've done great! Finish by bringing the camera back in front of your face",
  ];

  void _processCameraImage(CameraImage image) {
    final int totalIntensity =
        image.planes[0].bytes.reduce((value, element) => value + element);
    final double avgIntensity = totalIntensity / (image.width * image.height);

    if (avgIntensity < 128) {
      // brighness threshold
      _speak("The lighting is too low. Please move to a well-lit area.");
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front),
      ResolutionPreset.max,
    );
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      _startPhotoSequence();
    }).catchError((Object e) {
      if (e is CameraException) {
        print(e.description);
      }
    });
  }

  Future<void> _startPhotoSequence() async {
    await _speak(instructionMessages[0]);
  }

  Future<void> _speakInstruction(String instructionMessages) async {
    await flutterTts.speak(instructionMessages);
  }

  String lastImagePath = '';

  Future<void> _speak(String instructionMessages) async {
    setState(() {
      currentInstruction =
          instructionMessages; // Set the current instruction to the message
    });
    await flutterTts.speak(instructionMessages);
  }

  Future<void> _takePhoto() async {
    if (!_controller.value.isInitialized) {
      return;
    }
    if (_controller.value.isTakingPicture) {
      // A capture is already pending, do not take another
      return;
    }

    try {
      setState(() {
        _flashOn = true;
      });

      // Wait a bit to simulate the flash effect
      await Future.delayed(const Duration(milliseconds: 100));

      // Turn off the flash effect
      setState(() {
        _flashOn = false;
      });

      XFile file = await _controller.takePicture();
      lastImagePath = file.path;

      // Optionally save the image to the gallery
      await ImageGallerySaver.saveFile(lastImagePath);

      setState(() {
        photoCount += 1;
        imagePaths.add(lastImagePath);
      });

      if (photoCount < 18) {
        await _speak(instructionMessages[
            photoCount]); // Speak the next message after each photo
      } else if (photoCount == 18) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Take extra pictures'),
              content: const Text('Do you want to take 3 extra pictures?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _speak('Please take the first extra picture.');
                  },
                ),
                TextButton(
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ImagePreviewScreen(imagePaths: imagePaths),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      } else if (photoCount >= 19 && photoCount < 20) {
        await _speak('Please take the next extra picture.');
      } else if (photoCount == 20) {
        await _speak('Please take the last extra picture.');
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImagePreviewScreen(imagePaths: imagePaths),
          ),
        );
      }
    } on CameraException catch (e) {
      print("Camera Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Photo Sequence"),
      ),
      body: Stack(
        children: <Widget>[
          CameraPreview(_controller),
          if (_flashOn)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.9,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.5,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              color: Colors.white,
              width: MediaQuery.of(context)
                  .size
                  .width, // Set the width to the full screen width
              child: Text(
                currentInstruction,
                textAlign:
                    TextAlign.center, // Add textAlign for center alignment
                style: const TextStyle(color: Colors.black, fontSize: 24),
              ), // Display the current instruction
            ),
          ),
          Positioned(
            bottom: 0,
            child: ElevatedButton(
              onPressed: () async {
                if (photoCount < 21) {
                  await _takePhoto();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ImagePreviewScreen(imagePaths: imagePaths),
                    ),
                  );
                }
              },
              child: const Text('Take Photo'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
