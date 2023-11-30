import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:job_portal_app/user_state.dart';
import 'firebase_options.dart';

void main () async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options:  DefaultFirebaseOptions.currentPlatform,
       );
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,  
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text(
                    'App is being intiialized',
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      //  fontFamily: 'Signatra'),
                    ),
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text(
                    'An error has occured',
                    style: TextStyle(
                        color: Colors.cyan,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      fontFamily: 'Signatra'
                    ),

                  ),

                  ),
                ),
              );

          }
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Cigi Portal',
              theme: ThemeData(
                scaffoldBackgroundColor: Colors.black,
                primarySwatch: Colors.blue,
              ),
              home: UserState());
        });
  }
}
