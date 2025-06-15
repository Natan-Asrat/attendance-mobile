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
    exportBackgroundColor: Colors.transparent,
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mark Attendance', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(context, 
              title: 'Find Event',
              child: Column(
                children: [
                  TextField(
                    controller: _shortCodeController,
                    decoration: InputDecoration(
                      hintText: 'Enter Event Short Code',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.qr_code_scanner, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoading && _event == null
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _fetchEventDetails,
                            icon: const Icon(Icons.search),
                            label: const Text('Fetch Event Details'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.deepPurpleAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.1),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red[700], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_event != null) ...[
              const SizedBox(height: 20),
              _buildSection(context, 
                title: 'Event Details',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailItem(Icons.event, 'Title', _event!.title),
                    _buildDetailItem(Icons.description, 'Description', _event!.description),
                    _buildDetailItem(Icons.corporate_fare, 'Organization', _event!.program.organization.name),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSection(context, 
                title: 'Provide Signature',
                child: Column(
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!)
                      ),
                      child: Signature(
                        controller: _signatureController,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text('Clear'),
                        onPressed: () => _signatureController.clear(),
                        style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _isLoading && _event != null
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _createAttendance,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Submit Attendance'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )
                        ),
                      ),
                    ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 24, thickness: 0.5),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepPurpleAccent, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}