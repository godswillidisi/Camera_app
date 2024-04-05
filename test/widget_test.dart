// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// import 'package:camera_app/main.dart';

// void main() {
//   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(const MyApp(cameras: cameras));

//     // Verify that our counter starts at 0.
//     expect(find.text('0'), findsOneWidget);
//     expect(find.text('1'), findsNothing);

//     // Tap the '+' icon and trigger a frame.
//     await tester.tap(find.byIcon(Icons.add));
//     await tester.pump();

//     // Build your app and trigger a frame for the CameraScreen widget.
//     await tester.pumpWidget(CameraScreen(cameras: cameras));


//     // Verify that our counter has incremented.
//     expect(find.text('0'), findsNothing);
//     expect(find.text('1'), findsOneWidget);
//   });
// }

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camera_app/main.dart';
import 'package:camera/camera.dart';


void main() {
  testWidgets('Camera preview display', (WidgetTester tester) async {
    // Mock cameras for testing purposes
    cameras = <CameraDescription>[];

    // Build your app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    // Verify that your counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

     // Verify that the CameraApp widget is present
    expect(find.byType(CameraApp), findsOneWidget);

    // Verify that the CameraPreview widget is present
    expect(find.byType(CameraPreview), findsOneWidget);
    // Additional tests for the CameraScreen widget can be performed here.
  });
}
