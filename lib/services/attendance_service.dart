import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_app/models/attendance.dart';
import 'package:attendance_app/services/auth_service.dart';

class AttendanceService extends ChangeNotifier {
  final AuthService _authService;
  final String baseUrl = 'https://api.emishopping.com/digital_attendance/api/';
  
  AttendanceResponse? _attendances;
  bool _isLoading = false;
  String? _error;

  AttendanceService(this._authService);

  AttendanceResponse? get attendances => _attendances;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMyAttendances() async {
    if (_authService.token == null) {
      throw Exception('Not authenticated');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}event/attendance/my_attendances/'),
        headers: {
          'Authorization': 'Bearer ${_authService.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _attendances = AttendanceResponse.fromJson(data);
        _error = null;
      } else {
        _error = 'Failed to fetch attendances';
        _attendances = null;
      }
    } catch (e) {
      _error = e.toString();
      _attendances = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Event> fetchEventByShortCode(String shortCode) async {
    if (_authService.token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('${baseUrl}event/events/event_by_short_code/'),
      headers: {
        'Authorization': 'Bearer ${_authService.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'short_code': shortCode,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Event.fromJson(data);
    } else {
      throw Exception('Failed to fetch event details');
    }
  }

  Future<void> createAttendance({
    required String eventPk,
    required String signatureBase64,
    String? displayName,
  }) async {
    if (_authService.token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('${baseUrl}event/events/$eventPk/attendance/'),
      headers: {
        'Authorization': 'Bearer ${_authService.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'display_name': displayName ?? '',
        'signature_base64': signatureBase64,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create attendance');
    }
  }
}