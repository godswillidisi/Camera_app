import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:googleapis/storage/v1.dart' as storage;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter/services.dart';

const platform = MethodChannel('com.example.camera_app/focal_length');// this is the channed name that gets the characteristics of the camera

final _credentials = auth.ServiceAccountCredentials.fromJson({
  // the json details of the service account
  "private_key_id": "980d203b0fd18720a0d37d08f5ea485cfac7cb45",
  "private_key":
      "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCkZHhlQUek+PxM\nZvat9J47hbIrHIhwze7jaAe2RdWJ39bbJmy4vliAdWTExDEl15eW3M6hIzyuJIMF\n3O9aIqp8K6qKWAmkGn4vHxZ6Fk8hcP8J1JkmvhyNj3xQB/vXR6Ldb7Ujia+if0mi\nrF4VovGf+zAFc09dFGqf08UQf2rI6NuE+xOioAOxnJ+/3+zlcIYX9AENbnPNKZ/v\nn94pAUtzX4T7qZZMgrR+T56u33iCdr+T0JSdnOyy4uyj46p4LLci8Ep/lL6/CEV6\n4ws/pGKjsbAeF73pXznfscfqlgFvI/OYC70UNwml8ivH4wjUfn/PQZVLd1O1PjPK\nZXSv4HInAgMBAAECggEABrii4YTvQHP7oMYO7OLU+1sGg1O50l7hFwQgWJf3WJlB\nyBkElfMWXD4wfgkFd2YeqQjjG9x8dSRCBSHY2WcUcFo6sUhTMJXytcuAGELEPnpH\nuyepkVdxhGoq63zAE7e2lXYlQkw1VZ/9qzx/5kOQvHlBJ9/kjUox59H5OyjyfT9T\nNm0Uk6DJEH86W/tMpYMfMoVrVxZZeTrhMc/RjARlHqRBMoSTUK9xNqlfIt0BXffU\ncABCZX6Qb3LUCXA3JhCuLNwyJBgD/0vRCYLC+QRaGKXbGs37DWv4+mkzKLkVjIC3\nYvuYE3A/RSwrc3TIkkm0lkSS1NC+IHq/HvYQ0fyALQKBgQDbPvE94sW8dN4Wd+2N\n6Eg2gfaeTbCpPtFxcD+FvNdVHb6tfLEC1S8pDveIyIvxtN7wS7U8mz6+qKd5C7YY\ny7QDi1q+ZDuG+ny/1hAKJjJsbZQYEr6Ro0kROZvMr5KPBxmWZQgTLbCswOyLwmPQ\npCtIJ76+DWieH3CR0hw64QznGwKBgQC/83az6ISn5aGmKXRLInC12Rh8EQcpCacz\nWhEPfkY6pGnHOmUT8Vq4R/kvh6HlMwmz4LaneXZn76WZHcRSu9JwR7mQ2y2kjuq+\naUYt+gd4q+vXUwsI4qyxI5vTlrV1yi7Gg2nKYYy+fyJSt6g0Hxnz93aBsl7fgY+R\n2fthpKmV5QKBgQCUipaDqUrzHfMCIgrOpFuYooDmTBiu8iKQys4e3AzAXEC95cc/\n9hPXq45GHCnEfxi0kXafM0dVgYrF1gtvzUOPSzEV4W77SmaOyodfePWcxLkbfkej\nAJAWnYNTMHkJcnQBkz3fUIts3+Dj57Ycu72fS15OAWOqDf8ErOf3dFZ7lQKBgQCd\n89ElIFww8QRBAHHC9hc7fObqCPUUbu4Ykq/hSO6viOXGXKYacAxQAmHqG7k8KvB8\nBZkoXQnzYz+orNcFoar8W/k2WzXG6RgAEg7+/HUzdn1+1cYJzMWAiqXKyoSN5g7x\nqefe8sDnbSSoXpraMRGhMWxiM45ga3Ph+Dck1WP7hQKBgFd2Wmeydky8T3FgbQNf\nkCjGSFlIzU9lnW1mWHlgH964bwYqOKEk8Tezvbkmx3Yfab/ejYp6OGK14piN9e2d\np1bfSNbUEZivZqz8r2IzsB2wXLjnYSiHADaT6cJS3OtCNxl3t/JZf/JFzlufobpe\nhVmkZmILbHg7LR8/XmVqb2Z8\n-----END PRIVATE KEY-----\n",
  "client_email": "camera@solar-center-415615.iam.gserviceaccount.com",
  "client_id": "114811803212874203921",
  "type": "service_account"
});

final _scopes = [storage.StorageApi.devstorageReadWriteScope];

class ImagePreviewScreen extends StatefulWidget {
  final List<String> imagePaths;

  const ImagePreviewScreen({Key? key, required this.imagePaths})
      : super(key: key);

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreviewScreen> {
  
  Future<List<double>> getLensIntrinsicCalibration() async {
    try {
      final List calibration =
          await platform.invokeMethod('getLensIntrinsicCalibration');
      return calibration.cast<double>();
    } on PlatformException catch (e) {
      print("Failed to get lens intrinsic calibration: '${e.message}'.");
      return [];
    }
  }

  Future<Map<String, double>> getSensorInfoPhysicalSize() async {
    try {
      final Map sensorSize =
          await platform.invokeMethod('getSensorInfoPhysicalSize');
      return {'width': sensorSize['width']!, 'height': sensorSize['height']!};
    } on PlatformException catch (e) {
      print("Failed to get sensor info physical size: '${e.message}'.");
      return {'width': 0.0, 'height': 0.0};
    }
  }

  Future<void> uploadImage() async {

    showDialog(// this is to show the dialog box when the images are being uploaded
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const AlertDialog(
        title: Text('Upload in progress'),
        content: CircularProgressIndicator(),
      );
    },
  );
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
   
    String? deviceId; //  androidId for uniqueness
    if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    deviceId = androidInfo.device;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    deviceId = iosInfo.identifierForVendor; // unique ID on iOS
  }


    final client = await auth.clientViaServiceAccount(_credentials, _scopes);
    final storageApi = storage.StorageApi(client);
    const bucketName =
        'camera_buc'; // the google cloud bucket name where the images are to be stored
    
    for (String imagePath in widget.imagePaths) {
      File picture = File(imagePath);

      List<double> lensIntrinsicCalibration =
          await getLensIntrinsicCalibration();
      final image = await decodeImageFromList(await picture.readAsBytes());
      int imageWidth = image.width;
      int imageHeight = image.height;
      double? focalLength = await platform.invokeMethod('getFocalLength');
      Map<String, double> sensorSize = await getSensorInfoPhysicalSize();

      // Upload the image
      final media = storage.Media(
        http.ByteStream(Stream.castFrom(picture.openRead())),
        await picture.length(),
      );

      try {
        await storageApi.objects.insert(
          storage.Object()..name = '$deviceId/${path.basename(picture.path)}',
          bucketName,
          uploadMedia: media,
        );

        // Metadata
        final metadata = {
          'focalLength': focalLength,
          'imageHeight': imageHeight,
          'imageWidth': imageWidth,
          'sensorWidth': sensorSize['width'],
          'sensorHeight': sensorSize['height'],
          'lensIntrinsicCalibration': lensIntrinsicCalibration,
        };

        final metadataFile = File('${picture.path}.txt');
        await metadataFile.writeAsString(json.encode(metadata));

        final metadataMedia = storage.Media(
          http.ByteStream(Stream.castFrom(metadataFile.openRead())),
          await metadataFile.length(),
        );

        await storageApi.objects.insert(
          storage.Object()
            ..name =
                '$deviceId/${path.basenameWithoutExtension(picture.path)}.txt',
          bucketName,
          uploadMedia: metadataMedia,
        );
        
      } catch (e) {
        print("Error uploading file: $e");
      }
    }
    Navigator.of(context).pop(); // Dismiss the "upload in progress" dialog

    _showUploadCompleteDialog();
  }
  
  Future<void> _showUploadCompleteDialog() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap button to close the dialog
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Upload Complete'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Your images have been successfully uploaded.'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Preview'),
      ),
      body: ListView.builder(
        itemCount: widget.imagePaths.length,
        itemBuilder: (context, index) {
          return Image.file(File(widget.imagePaths[index]));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: uploadImage,
        child: const Icon(Icons.cloud_upload),
      ),
    );
  }
  
}

