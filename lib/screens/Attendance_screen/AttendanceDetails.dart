import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AttendanceDetail {
  final String courseName;
  final int totalClasses;
  final int attendedClasses;

  AttendanceDetail({
    required this.courseName,
    required this.totalClasses,
    required this.attendedClasses,
  });
  double calculateAttendancePercentage() {
    if (totalClasses <= 0) {
      return 0.0;
    }

    return (attendedClasses / totalClasses) * 100;
  }
}

class AttendanceDetails extends StatefulWidget {
  static String routeName = 'AttendanceDetails';

  @override
  _AttendanceDetailsState createState() => _AttendanceDetailsState();
}

class _AttendanceDetailsState extends State<AttendanceDetails> {
  AttendanceDetail? attendanceDetail;

  double calculateAttendancePercentage() {
    if (attendanceDetail == null || attendanceDetail!.totalClasses == 0) {
      return 0.0;
    }

    return (attendanceDetail!.attendedClasses /
        attendanceDetail!.totalClasses) *
        100;
  }

  Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  @override
  void initState() {
    super.initState();
    // Step 1: Fetch and display details for courses associated with the user.
    fetchUserCourses(); // Fetch the user's courses.
  }

  Future<void> fetchUserCourses() async {
    try {
      User? user = await getCurrentUser();

      if (user != null) {
        // Access the Courses sub-collection for the specific user
        QuerySnapshot courseSnapshot = await FirebaseFirestore.instance
            .collection('Students')
            .doc(user.uid)
            .collection('Courses')
            .get();

        // Assuming you want to display each course separately
        courseSnapshot.docs.forEach((courseDoc) {
          String courseId = courseDoc.id; // Get the course ID
          Map<String, dynamic>? courseData =
          courseDoc.data() as Map<String, dynamic>?; // Get course data

          if (courseData != null &&
              courseData.containsKey('courseName') &&
              courseData.containsKey('totalClasses') &&
              courseData.containsKey('attendedClasses')) {
            // Use the course data to create an AttendanceDetail object
            AttendanceDetail courseDetail = AttendanceDetail(
              courseName: courseData['courseName'] as String,
              totalClasses: courseData['totalClasses'] as int,
              attendedClasses: courseData['attendedClasses'] as int,
            );

            // Assuming you only want to display details of the first course found
            setState(() {
              attendanceDetail = courseDetail;
            });

            // Break the loop if you only want to display details of the first course found
            return;
          } else {
            print('Invalid or incomplete course data.');
            // Handle cases where course data is incomplete or missing required fields.
          }
        });

        // Once the courses are fetched, perform any necessary actions or set states.
      } else {
        print('User not signed in.');
        // Handle scenarios where the user is not signed in.
      }
    } catch (e) {
      print('Error fetching user courses: $e');
      // Handle any errors encountered during data retrieval.
    }
  }

  @override
  Widget build(BuildContext context) {
    double percentage =
        attendanceDetail?.calculateAttendancePercentage() ?? 0.0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Details'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (attendanceDetail != null)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course Name: ${attendanceDetail!.courseName}',
                      style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Total Classes: ${attendanceDetail!.totalClasses}',
                                style: TextStyle(fontSize: 18.0)),
                            Text(
                                'Attended Classes: ${attendanceDetail!.attendedClasses}',
                                style: TextStyle(fontSize: 18.0)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            SizedBox(height: 16.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance Percentage: ${percentage.toStringAsFixed(2)}%',
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(height: 16.0),
                  LinearProgressIndicator(
                    value: calculateAttendancePercentage() / 100,
                    backgroundColor: Colors.black,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16.0),
                  if (calculateAttendancePercentage() > 75.0)
                    Text(
                      'Warning: Your attendance is below 75%',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
///////////////////////////////////////////////////////////////////////
                },
                child: Text('Report'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AttendanceDetails(),
  ));
}