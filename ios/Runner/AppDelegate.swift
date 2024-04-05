import UIKit
import Flutter
 
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// import UIKit
// import Flutter
// import AVFoundation

// @UIApplicationMain
// @objc class AppDelegate: FlutterAppDelegate {
//   private let channelName = "com.example.camera_app/focal_length"

//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//     let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
//     let cameraChannel = FlutterMethodChannel(name: channelName,
//                                               binaryMessenger: controller.binaryMessenger)
    
//     cameraChannel.setMethodCallHandler({
//       [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
//       // Check the method being called
//       if call.method == "getFocalLength" {
//         self?.getFocalLength(result: result)
//       } else if call.method == "getSensorInfoPhysicalSize" {
//         self?.getSensorInfoPhysicalSize(result: result)
//       } else {
//         result(FlutterMethodNotImplemented)
//       }
//     })
    
//     GeneratedPluginRegistrant.register(with: self)
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }

//   private func getFocalLength(result: FlutterResult) {
//     guard let device = AVCaptureDevice.default(for: .video) else {
//       result(0.0) // Or handle the error appropriately
//       return
//     }
    
//     // Fetch the current focal length
//     if let currentFocalLength = device.activeFormat.videoZoomFactorUpscaleThreshold {
//       result(Double(currentFocalLength))
//     } else {
//       result(0.0) // Or handle the lack of value appropriately
//     }
//   }

//   private func getSensorInfoPhysicalSize(result: FlutterResult) {
//     guard let device = AVCaptureDevice.default(for: .video) else {
//       result(["width": 0.0, "height": 0.0])
//       return
//     }

//     let format = device.activeFormat
//     let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
//     let sensorWidth = Double(dimensions.width)
//     let sensorHeight = Double(dimensions.height)

//     let sensorInfo: [String: Double] = ["width": sensorWidth, "height": sensorHeight]
//     result(sensorInfo)
//   }
// }


// import UIKit
// import Flutter
// import AVFoundation

// @UIApplicationMain
// @objc class AppDelegate: FlutterAppDelegate {
//   private let channelName = "com.example.camera_app/camera_details"

//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//     let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
//     let cameraChannel = FlutterMethodChannel(name: channelName,
//                                               binaryMessenger: controller.binaryMessenger)
    
//     cameraChannel.setMethodCallHandler({
//       [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
//       // Check the method being called
//       if call.method == "getLensIntrinsicCalibration" {
//         self?.getLensIntrinsicCalibration(result: result)
//       } else if call.method == "getSensorInfoPhysicalSize" {
//         self?.getSensorInfoPhysicalSize(result: result)
//       } else {
//         result(FlutterMethodNotImplemented)
//       }
//     })
    
//     GeneratedPluginRegistrant.register(with: self)
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }

//   private func getLensIntrinsicCalibration(result: FlutterResult) {
//     // Placeholder for actual implementation
//     let calibrationData: [Double] = [1.0, 2.0, 3.0] // Example calibration data
//     result(calibrationData)
//   }

//   private func getSensorInfoPhysicalSize(result: FlutterResult) {
//     guard let device = AVCaptureDevice.default(for: .video) else {
//       result(["width": 0.0, "height": 0.0])
//       return
//     }

//     // Example method to fetch sensor size, replace with actual method to get sensor dimensions
//     let format = device.activeFormat
//     let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
//     let sensorWidth = Double(dimensions.width)
//     let sensorHeight = Double(dimensions.height)

//     let sensorInfo: [String: Double] = ["width": sensorWidth, "height": sensorHeight]
//     result(sensorInfo)
//   }
// }

