import 'package:flutter/material.dart';
import 'package:attendance_app/screens/login_screen.dart';
import 'package:attendance_app/screens/register_screen.dart';
import 'package:attendance_app/services/auth_service.dart';
import 'package:attendance_app/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/services/attendance_service.dart';
import 'package:attendance_app/screens/attendance_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, AttendanceService>(
          create: (context) => AttendanceService(context.read<AuthService>()),
          update: (context, auth, previous) => previous ?? AttendanceService(auth),
        ),
      ],
      child: MaterialApp(
        title: 'Attendance App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        home: AuthenticationWrapper(),
        routes: {
          '/attendances': (context) => AttendanceListScreen(),
          '/register': (context) => RegisterScreen(),
        },
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    // Check if user is already logged in
    return FutureBuilder<bool>(
      future: authService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final bool isLoggedIn = snapshot.data ?? false;
        if (isLoggedIn) {
          return HomeScreen();
        }
        return LoginScreen();
      },
    );
  }
}
