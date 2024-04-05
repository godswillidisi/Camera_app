package com.example.camera_app

import android.content.Context
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.util.SizeF
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.camera_app/focal_length"

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
