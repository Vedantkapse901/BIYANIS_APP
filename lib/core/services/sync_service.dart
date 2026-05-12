import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/logbook/data/datasources/local_datasource.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _supabase = Supabase.instance.client;
  final _localDataSource = LocalDataSource();
  Timer? _syncTimer;

  /// Initializes the sync service, performs an initial sync,
  /// and schedules periodic syncs every 1 hour.
  Future<void> initialize() async {
    debugPrint('🔄 Initializing SyncService...');

    // Perform initial sync immediately on startup
    // We don't await it here so it doesn't block app startup,
    // but it will run in the background.
    syncAllData().then((_) {
      debugPrint('✅ Initial background sync completed.');
    }).catchError((e) {
      debugPrint('❌ Initial background sync failed: $e');
    });

    // Schedule periodic sync every 1 hour
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      syncAllData();
    });

    debugPrint('⏰ Scheduled periodic sync every 1 hour.');
  }

  /// Fetches all required data from Supabase and updates local storage.
  Future<void> syncAllData() async {
    debugPrint('📡 Starting data sync from Supabase...');
    try {
      await _localDataSource.initialize();

      await Future.wait([
        _syncStudents(),
        _syncParents(),
        _syncTeachers(),
        _syncProfiles(),
      ]);

      debugPrint('✅ Data sync from Supabase completed successfully!');
    } catch (e) {
      debugPrint('❌ Data sync from Supabase failed: $e');
    }
  }

  Future<void> _syncStudents() async {
    try {
      final response = await _supabase.from('students').select();
      if (response != null) {
        final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);
        await _localDataSource.bulkAddStudents(data);
        debugPrint('✅ Synced ${data.length} students.');
      }
    } catch (e) {
      debugPrint('Error syncing students: $e');
    }
  }

  Future<void> _syncParents() async {
    try {
      final response = await _supabase.from('parents').select();
      if (response != null) {
        final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);
        await _localDataSource.bulkAddParents(data);
        debugPrint('✅ Synced ${data.length} parents.');
      }
    } catch (e) {
      debugPrint('Error syncing parents: $e');
    }
  }

  Future<void> _syncTeachers() async {
    try {
      final response = await _supabase.from('teachers').select();
      if (response != null) {
        final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);
        await _localDataSource.bulkAddTeachers(data);
        debugPrint('✅ Synced ${data.length} teachers.');
      }
    } catch (e) {
      debugPrint('Error syncing teachers: $e');
    }
  }

  Future<void> _syncProfiles() async {
    try {
      final response = await _supabase.from('profiles').select();
      if (response != null) {
        final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);
        final Map<String, Map> profileMap = {};
        for (var p in data) {
          // Use 'id' (Supabase Auth UUID) as the key for profiles
          final String key = (p['id'] ?? '').toString();
          if (key.isNotEmpty) {
            profileMap[key] = p;
          }
        }
        if (profileMap.isNotEmpty) {
          await _localDataSource.bulkAddProfiles(profileMap);
          debugPrint('✅ Synced ${profileMap.length} user profiles.');
        }
      }
    } catch (e) {
      debugPrint('Error syncing profiles: $e');
    }
  }

  void dispose() {
    _syncTimer?.cancel();
  }
}
