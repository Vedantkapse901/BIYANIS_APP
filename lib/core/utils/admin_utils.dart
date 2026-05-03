import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../features/logbook/data/datasources/local_datasource.dart';

class AdminUtils {
  // Replace this with your actual Google Sheet CSV Export URL
  static const String googleSheetUrl = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQrwzIHXNuynkduMQm9VKH_Ci1VWBPA0cVMyfKHPd-VMxGT_Mhwq7f22IA0hXy0Njkvh-o-IQK8d0_O/pub?gid=0&single=true&output=csv";

  /// Downloads the latest student list from Google Sheets and updates Hive.
  static Future<void> syncFromGoogleSheets() async {
    if (googleSheetUrl.contains("YOUR_GOOGLE_SHEET")) {
      debugPrint('AdminUtils: No Google Sheet URL provided. Skipping sync.');
      return;
    }

    try {
      final dio = Dio();
      final response = await dio.get(googleSheetUrl);

      if (response.statusCode == 200) {
        await bulkUploadFromCsv(response.data.toString());
        debugPrint('AdminUtils: Sync completed successfully.');
      }
    } catch (e) {
      debugPrint('AdminUtils: Sync failed: $e');
    }
  }

  /// Bulk uploads approved students from a CSV string.
  /// CSV format: name,phone,email,batch
  static Future<void> bulkUploadFromCsv(String csvContent) async {
    final localDataSource = LocalDataSource();
    await localDataSource.initialize();

    final List<String> lines = const LineSplitter().convert(csvContent);
    final List<Map<String, dynamic>> students = [];

    // Skip header if it exists
    int startIndex = 0;
    if (lines.isNotEmpty && lines[0].toLowerCase().contains('name')) {
      startIndex = 1;
    }

    for (int i = startIndex; i < lines.length; i++) {
      final List<String> fields = lines[i].split(',');
      if (fields.length >= 2) {
        students.add({
          'name': fields[0].trim(),
          'phone': fields[1].trim(),
          'email': fields.length > 2 ? fields[2].trim() : '',
          'batch': fields.length > 3 ? fields[3].trim() : 'ICSE 9', // Default batch if not provided
          'is_registered': false,
        });
      }
    }

    if (students.isNotEmpty) {
      await localDataSource.bulkAddApprovedStudents(students);
      debugPrint('AdminUtils: Successfully uploaded ${students.length} students.');
    }
  }

  /// Helper to seed some data manually for testing
  static Future<void> seedInitialApprovedStudents() async {
    final localDataSource = LocalDataSource();
    await localDataSource.initialize();
    
    await localDataSource.bulkAddApprovedStudents([
      {
        'name': 'ICSE Student',
        'phone': '1111111111',
        'email': 'icse@example.com',
        'batch': 'ICSE 9',
        'is_registered': false,
      },
      {
        'name': 'CBSE Student',
        'phone': '2222222222',
        'email': 'cbse@example.com',
        'batch': 'CBSE 9',
        'is_registered': false,
      },
    ]);
  }
}
