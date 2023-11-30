import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:job_portal_app/Services/global_variables.dart';

class Persistent {
  static List<String> jobCategoryList = [  //List of Job Categories to be displayed on Upload_Job.dart
    'Architecture and Construction',
    'Education and Training',
    'Development - Programming ',
    'Business',
    'IT Information Technology',
    'Human Resources',
    'Marketing',
    'Design',
    'Accounting',
  ];

  void getMyData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
     
      name = userDoc.get('name');
      userImage = userDoc.get('userImage');
      location = userDoc.get('location');
  } 

}
