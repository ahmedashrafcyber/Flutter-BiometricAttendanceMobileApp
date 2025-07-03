import 'package:flutter/material.dart';
import 'package:project/screens/Attendance_screen/AttendanceDetails.dart';
import 'authentication.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Biometric(),
    );
  }
}

class Biometric extends StatefulWidget {
  static String routeName = 'Biometric';
  const Biometric({super.key});

  @override
  State<Biometric> createState() => _BiometricState();
}

class _BiometricState extends State<Biometric> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 4, 52, 134),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Virify yourself",
                  style: TextStyle(fontSize: 45, color: Colors.white)),
              SizedBox(height: 28),
              SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () async {
                  bool auth = await Authentication.authentication();
                  print("Can authenticate: $auth");
                  if (auth) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AttendanceDetails()));
                  }
                },
                icon: Icon(Icons.fingerprint),
                label: Text("Authenticate"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.lightBlue, // text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
