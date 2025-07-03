import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/screens/biometric/Biometric.dart';

import 'AttendanceDetails.dart';

class Attendance extends StatefulWidget {
  static String routeName = 'Attendance';

  @override
  _AttendanceState createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  late Future<List<Courses>> coursesFuture;

  @override
  void initState() {
    super.initState();
    coursesFuture = fetchCourses();
  }

  Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<List<Courses>> fetchCourses() async {
    try {
      User? user = await getCurrentUser();

      if (user != null) {
        QuerySnapshot coursesSnapshot = await FirebaseFirestore.instance
            .collection('Students')
            .doc(user.uid)
            .collection('Courses')
            .get();

        return coursesSnapshot.docs
            .map((doc) => Courses(courseName: doc['courseName']))
            .toList();

      } else {
        print('User not signed in');
        return [];
      }
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subjects'),
      ),
      body: FutureBuilder<List<Courses>>(
        future: coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No courses found.'));
          } else {
            List<Courses> courses = snapshot.data!;
            return ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3.0,
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      courses[index].courseName,
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    //subtitle: Text('Course id: ${courses[index].id}'),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Biometric.routeName,
                        arguments: courses[index],
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle submitting the attendance data (save to database, etc.)
          print('Attendance Submitted');
        },
        child: Icon(Icons.check),
      ),
    );
  }
}

class Courses {
  final String courseName;

  Courses({
    required this.courseName,
  });
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Attendance(),
  ));
}
