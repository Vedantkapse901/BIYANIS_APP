import 'dart:io';
import 'dart:typed_data';
import 'package:minio/minio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class B2StorageService {
  // Backblaze B2 S3 settings
  // You can find these in your Backblaze B2 Cloud Storage bucket settings
  static const String endpoint = 's3.us-west-004.backblazeb2.com'; // e.g. s3.us-west-004.backblazeb2.com
  static const String accessKey = 'YOUR_B2_APPLICATION_KEY_ID';
  static const String secretKey = 'YOUR_B2_APPLICATION_KEY';
  static const String bucketName = 'your-b2-bucket-name';
  static const String region = 'us-west-004';

  late Minio _minio;

  B2StorageService() {
    _minio = Minio(
      endPoint: endpoint,
      accessKey: accessKey,
      secretKey: secretKey,
      region: region,
    );
  }

  /// Upload a file to Backblaze B2
  Future<String?> uploadFile({
    required String path,
    required String filePath,
    String contentType = 'application/octet-stream',
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final size = await file.length();
      final stream = file.openRead().map((chunk) => Uint8List.fromList(chunk));

      await _minio.putObject(
        bucketName,
        path,
        stream,
        size: size,
        metadata: {'Content-Type': contentType},
      );

      // Construct the public URL (B2 Friendly URL format or S3 format)
      // Note: Bucket must be public for this URL to work directly
      return 'https://$bucketName.$endpoint/$path';
    } catch (e) {
      print('B2 Upload Error: $e');
      return null;
    }
  }

  /// Delete a file from Backblaze B2
  Future<void> deleteFile(String path) async {
    try {
      await _minio.removeObject(bucketName, path);
    } catch (e) {
      print('B2 Delete Error: $e');
    }
  }
}

final b2StorageServiceProvider = Provider<B2StorageService>((ref) {
  return B2StorageService();
});
