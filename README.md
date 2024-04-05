# camera_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


package com.example.camera_app

import android.os.Bundle
import android.content.Context
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "com.example.camera/focal_length")
            .setMethodCallHandler { call, result ->
                if (call.method == "getFocalLength") {
                    val focalLength = getFocalLength(this)
                    if (focalLength != null) {
                        result.success(focalLength)
                    } else {
                        result.error("UNAVAILABLE", "Focal length not available.", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun getFocalLength(context: Context): Float? {
        val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
        val cameraId = cameraManager.cameraIdList[0] // get the first camera
        val characteristics = cameraManager.getCameraCharacteristics(cameraId)
        val focalLengths = characteristics.get(CameraCharacteristics.LENS_INFO_AVAILABLE_FOCAL_LENGTHS)
        return focalLengths?.get(0) // get the first focal length
    }
}






switch camera simpler
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:camera_app/pages/camera_screen.dart';

const platform = MethodChannel('com.example.camera_app/focal_length');

late List<CameraDescription> cameras;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraApp(),
    );
  }
}

class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController _controller;
  int selectedCameraIndex = 0; // Add this line
  
  void switchCamera() { // Add this function
    selectedCameraIndex = selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    _controller = CameraController(
      selectedCamera,
      ResolutionPreset.max,
    );
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      cameras[selectedCameraIndex],
      ResolutionPreset.max,
    );
    _controller.initialize().then((_) async {
      if (!mounted) {
        return;
      }
      setState(() {});
      print('Camera resolution width: ${_controller.value.previewSize?.width}');
      print('Camera resolution height: ${_controller.value.previewSize?.height}');

      double focalLength;
      try {
        focalLength = await platform.invokeMethod('getFocalLength');
        print('Focal length: $focalLength');
      } on PlatformException catch (e) {
        print("Failed to get focal length: '${e.message}'.");
      }
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print("access denied");
            break;
          default:
            print(e.description);
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          height: double.infinity,
          child: CameraPreview(_controller),
        ),
        Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                    margin: EdgeInsets.all(20.0),
                    child: MaterialButton(
                      onPressed: switchCamera, // Add this line
                      color: Colors.white,
                      child: Text("Switch Camera"), // Add this line
                    )),
              ),
              Center(
                child: Container(
                    margin: EdgeInsets.all(20.0),
                    child: MaterialButton(
                      onPressed: () async {
                        if (!_controller.value.isInitialized) {
                          return null;
                        }
                        if (_controller.value.isTakingPicture) {
                          return null;
                        }

                        try {
                          
                          XFile file = await _controller.takePicture();

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ImagePreview(file)));
                        } on CameraException catch (e) {
                          debugPrint("Error occured while taking picture: $e");
                          return null;
                        }
                      },
                      color: Colors.white,
                      child: Text("Take Picture"),
                    )),
              )
            ])
      ]),
    );
  }
}



package com.example.camera_app

import android.content.Context
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.util.SizeF
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.camera_app/camera_details"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getFocalLength" -> {
                    val focalLength = getCameraDetail("focalLength")
                    if (focalLength != null) {
                        result.success(focalLength)
                    } else {
                        result.error("UNAVAILABLE", "Focal length not available.", null)
                    }
                }
                "getSensorInfoPhysicalSize" -> {
                    val sensorSize = getCameraDetail("sensorSize") as SizeF?
                    if (sensorSize != null) {
                        result.success(mapOf("width" to sensorSize.width, "height" to sensorSize.height))
                    } else {
                        result.error("UNAVAILABLE", "Sensor info physical size not available.", null)
                    }
                }
                "getLensIntrinsicCalibration" -> {
                    val calibration = getCameraDetail("calibration") as FloatArray?
                    if (calibration != null) {
                        result.success(calibration.toList())
                    } else {
                        result.error("UNAVAILABLE", "Lens intrinsic calibration not available.", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getCameraDetail(detailType: String): Any? {
        val manager = getSystemService(Context.CAMERA_SERVICE) as CameraManager
        for (cameraId in manager.cameraIdList) {
            val characteristics = manager.getCameraCharacteristics(cameraId)
            val cameraDirection = characteristics.get(CameraCharacteristics.LENS_FACING)
            if (cameraDirection != null && cameraDirection == CameraCharacteristics.LENS_FACING_FRONT) {
                return when (detailType) {
                    "focalLength" -> {
                        val focalLengths = characteristics.get(CameraCharacteristics.LENS_INFO_AVAILABLE_FOCAL_LENGTHS)
                        focalLengths?.get(0) // Return the first available focal length
                    }
                    "sensorSize" -> {
                        characteristics.get(CameraCharacteristics.SENSOR_INFO_PHYSICAL_SIZE) // Get the sensor's physical size
                    }
                    "calibration" -> {
                        characteristics.get(CameraCharacteristics.LENS_INTRINSIC_CALIBRATION) // Get the lens intrinsic calibration
                    }
                    else -> null
                }
                
            }
        }
        return null
    }
}

Future<List<double>> getLensIntrinsicCalibration() async {
  try {
    final List calibration = await platform.invokeMethod('getLensIntrinsicCalibration');
    return calibration.cast<double>();
  } on PlatformException catch (e) {
    print("Failed to get lens intrinsic calibration: '${e.message}'.");
    return [];
  }
}