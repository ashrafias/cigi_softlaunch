import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:job_portal_app/Jobs/jobs_screen.dart';
import 'package:job_portal_app/LoginPage/login_screen.dart';

class UserState extends StatelessWidget {
  const UserState({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, userSnapshot)
      {
        print(userSnapshot.data);
        if(userSnapshot.data == null) //if no user data => display login screen
        {
          print('user is not logged in yet');
          return Login();
        }
        else if(userSnapshot.hasData)
        {
           print('user is already logged in');
           return JobScreen();
        }
        else if(userSnapshot.hasError) 
        {
          return const Scaffold(body: Center(child: Text('An Eror has been occurred. Try again later ')),);
        }
        else if(userSnapshot.connectionState == ConnectionState.waiting) 
        {
          return const Scaffold(body: Center(child: CircularProgressIndicator()),);
        }

        return Scaffold(body: Center(child: const Text('Something went wrong')),);
      },
    );
  }
}