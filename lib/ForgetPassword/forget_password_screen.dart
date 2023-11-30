// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:job_portal_app/LoginPage/login_screen.dart';
import 'package:job_portal_app/Services/global_variables.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPassword();
}

class _ForgetPassword extends State<ForgetPassword> with TickerProviderStateMixin  
 {

  
  late Animation<double> _animation;
  late AnimationController _animationController;
  final TextEditingController _forgetPassTextController =
      TextEditingController(text: '');

  final FirebaseAuth _auth = FirebaseAuth.instance;


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

@override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.linear)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((animationStatus) { 
            if (animationStatus == AnimationStatus.completed) {
              _animationController.reset();
              _animationController.forward();
            }
          });

             _animationController.forward();
    super.initState();
  } //end of initState


  void _forgetPassSubmitForm() async {

        try{
          await _auth.sendPasswordResetEmail(email: _forgetPassTextController.text);
          // ignore: prefer_const_constructors
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> Login())); //After user provides Reset Password email link

        }
        catch(error)
        {
          Fluttertoast.showToast(msg: error.toString());//display error msg to user
        }

  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(children: [
        CachedNetworkImage
          (
            imageUrl: forgetUrlImage,
            placeholder: (context, url) => Image.asset(
              'assets/images/wallpaper.jpg',
              fit: BoxFit.fill,
            ),
             errorWidget: (context, url, error) => const Icon(Icons.error),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: FractionalOffset(_animation.value, 0),
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              children: [SizedBox(height: size.height*0.1),
              const Text('Forget Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 55, fontFamily: 'Signatra'),),
              const SizedBox(height: 20,),
              const Text('Email Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontStyle: FontStyle.italic),),
              const SizedBox(height: 20,),
              TextField(
                controller: _forgetPassTextController,
                decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white54,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                        focusedBorder: UnderlineInputBorder(   
                          borderSide: BorderSide(color: Colors.white),)

                ),
              ),
                const SizedBox(height: 20,),
              MaterialButton(onPressed: (){
                    _forgetPassSubmitForm();

              },
              color: Colors.cyan,
              elevation: 8,
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text('Reset Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, fontStyle: FontStyle.italic ),),
              ),
              )

              ],
            )
            )
      
      ]),
    );
  }
}
