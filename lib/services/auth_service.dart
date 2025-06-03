import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance_app/models/user.dart';

class AuthService extends ChangeNotifier {
  final String baseUrl = 'https://api.emishopping.com/digital_attendance/api/';
  User? _currentUser;
  String? _token;
  String? _refreshToken;

  User? get currentUser => _currentUser;
  String? get token => _token;

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final refreshToken = prefs.getString('refreshToken');

    if (token != null && refreshToken != null) {
      _token = token;
      _refreshToken = refreshToken;

      // Load user data if available
      final userData = prefs.getString('user');
      if (userData != null) {
        _currentUser = User.fromJson(jsonDecode(userData));
      }

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register({
    required String name,
    required String phone,
    required String email,
    required String signatureBase64,
    required String signatureStroke, // <- This is stroke data as a JSON string
  }) async {
    try {
      print(
          'AuthService - Sending register request to ${baseUrl}account/users/');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}account/users/'),
      );

      request.fields['name'] = name;
      request.fields['phone'] = phone;
      request.fields['email'] = email;
      request.fields['signature_base64'] = signatureBase64;
      request.fields['signature_stroke'] = signatureStroke;

      print('Request fields:');
      print(request.fields);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('\nResponse Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        notifyListeners();
        return true;
      } else {
        var errorMessage = 'Registration failed';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData != null && errorData['error'] != null) {
            errorMessage = errorData['error'].toString();
          }
        } catch (e) {
          print('Error parsing error response: $e');
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Register error: $e');
      throw e;
    }
  }

  // Login with phone and signature
  Future<bool> login({
    required String phone,
    required String signatureBase64,
  }) async {
    try {
      print(
          'AuthService - Sending login request to ${baseUrl}account/users/phone_login/');

      // Create FormData using MultipartRequest
      var request = http.MultipartRequest(
          'POST', Uri.parse('${baseUrl}account/users/phone_login/'));

      // Add form fields matching the React implementation
      request.fields['phone'] = phone;
      request.fields['signature_base64'] = signatureBase64;

      print('Request fields:');
      print(request.fields);

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('\nResponse Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save tokens matching React implementation
        _token = data['access_token'];
        _refreshToken = data['refresh_token'];

        // Save user data
        if (data['user'] != null) {
          _currentUser = User(
            id: data['user']['id'],
            name: data['user']['name'],
            email: data['user']['email'],
            phone: data['user']['phone'],
          );
        }

        // Store in shared preferences (Flutter equivalent of localStorage)
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', _token!);
        prefs.setString('refreshToken', _refreshToken!);
        if (_currentUser != null) {
          prefs.setString('user', jsonEncode(_currentUser!.toJson()));
        }

        notifyListeners();
        return true;
      } else {
        // Error handling matching React implementation
        var errorMessage = 'Login failed';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData != null && errorData['error'] != null) {
            errorMessage = errorData['error'].toString();
          }
        } catch (e) {
          print('Error parsing error response: $e');
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Login error: $e');
      throw e; // Re-throw to handle in UI
    }
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _refreshToken = null;

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('refreshToken');
    prefs.remove('user');

    notifyListeners();
  }
}
