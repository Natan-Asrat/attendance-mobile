import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/services/attendance_service.dart';
import 'package:attendance_app/models/attendance.dart';
import 'package:signature/signature.dart';

class CreateAttendanceScreen extends StatefulWidget {
  @override
  _CreateAttendanceScreenState createState() => _CreateAttendanceScreenState();
}

class _CreateAttendanceScreenState extends State<CreateAttendanceScreen> {
  final TextEditingController _shortCodeController = TextEditingController();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  Event? _event;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _shortCodeController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _fetchEventDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _event = null;
    });

    try {
      final attendanceService = Provider.of<AttendanceService>(context, listen: false);
      final event = await attendanceService.fetchEventByShortCode(_shortCodeController.text);
      setState(() {
        _event = event;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createAttendance() async {
    if (_event == null) {
      setState(() {
        _errorMessage = 'Please fetch event details first.';
      });
      return;
    }

    if (_signatureController.isEmpty) {
      setState(() {
        _errorMessage = 'Please provide a signature.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final signatureImage = await _signatureController.toPngBytes();
      if (signatureImage == null) {
        throw Exception('Failed to get signature image.');
      }
      final signatureBase64 = 'data:image/png;base64,' + base64Encode(signatureImage);

      final attendanceService = Provider.of<AttendanceService>(context, listen: false);
      await attendanceService.createAttendance(
        eventPk: _event!.id,
        signatureBase64: signatureBase64,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance created successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Attendance'),
        backgroundColor: Colors.indigo[600],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _shortCodeController,
              decoration: InputDecoration(
                labelText: 'Event Short Code',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _fetchEventDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[600],
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Fetch Event Details', style: TextStyle(fontSize: 16)),
                  ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_event != null) ...[
              SizedBox(height: 24),
              Text(
                'Event Details:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Title: ${_event!.title}', style: TextStyle(fontSize: 16)),
              Text('Description: ${_event!.description}', style: TextStyle(fontSize: 16)),
              Text('Organization: ${_event!.program.organization.name}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 24),
              Text(
                'Signature:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Signature(
                  controller: _signatureController,
                  backgroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () => _signatureController.clear(),
                    tooltip: 'Clear Signature',
                  ),
                ],
              ),
              SizedBox(height: 16),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _createAttendance,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Create Attendance', style: TextStyle(fontSize: 16)),
                    ),
            ],
          ],
        ),
      ),
    );
  }
}