import 'package:attendance_app/screens/attendance_detail_screen.dart';
import 'package:attendance_app/screens/create_attendance_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/services/attendance_service.dart';
import 'package:attendance_app/models/attendance.dart';

class AttendanceListScreen extends StatefulWidget {
  @override
  _AttendanceListScreenState createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceService>().fetchMyAttendances();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Attendances'),
        backgroundColor: Colors.indigo[600],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateAttendanceScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.indigo[600],
      ),
      body: Consumer<AttendanceService>(
        builder: (context, attendanceService, child) {
          if (attendanceService.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (attendanceService.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${attendanceService.error}',
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      attendanceService.fetchMyAttendances();
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final attendances = attendanceService.attendances?.results ?? [];

          if (attendances.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No attendances found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => attendanceService.fetchMyAttendances(),
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: attendances.length,
              itemBuilder: (context, index) {
                final attendance = attendances[index];
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AttendanceDetailScreen(attendance: attendance),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  attendance.event.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: attendance.valid
                                      ? Colors.green[100]
                                      : Colors.red[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  attendance.valid ? 'Valid' : 'Invalid',
                                  style: TextStyle(
                                    color: attendance.valid
                                        ? Colors.green[800]
                                        : Colors.red[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            attendance.event.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.business,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 4),
                              Text(
                                attendance.event.program.organization.name,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 4),
                              Text(
                                attendance.createdAt.toLocal().toString().split('.')[0],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AttendanceDetailScreen(attendance: attendance),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo[600],
                              minimumSize: Size(double.infinity, 36),
                            ),
                            child: Text('View Details'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
