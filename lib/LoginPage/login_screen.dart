import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:job_portal_app/Services/global_methods.dart';
import 'package:job_portal_app/SignupPage/signup_screen.dart';
import '../Services/global_variables.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:job_portal_app/ForgetPassword/forget_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin  
{
  late Animation<double> _animation;
  late AnimationController _animationController;
  final TextEditingController _emailTextController =
      TextEditingController(text: '');
  final TextEditingController _passTextContoller =
      TextEditingController(text: '');
 
  bool _obscureText = true; //for password field
  
  final FocusNode _passFocusNode = FocusNode(); //handles keyboard events
  final _loginFormKey = GlobalKey<FormState>();
  // ignore: unused_field
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;



  @override
  void dispose() {
    _animationController.dispose();
    _emailTextController.dispose();
    _passTextContoller.dispose();
    _passFocusNode.dispose();
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

void _submitFormOnLogin() async {
    final isValid = _loginFormKey.currentState!.validate(); //checks if Login is succesful
    if (isValid) {
      setState(() {
        _isLoading = true;
      });

      try {
        //Sign in using email and password
        var userCreds = await _auth.signInWithEmailAndPassword(
          email: _emailTextController.text.trim().toLowerCase(),
          password: _passTextContoller.text.trim().toLowerCase(),
        );
        print("Successful");
        print(userCreds.user?.email);
        Navigator.canPop(context) ? Navigator.pop(context) : null; //Removes dialog box if any using Navigator.canPop(context) Else returns Null
      } catch (error) { //Show error dialog in case of error while loging in 
        setState(() {
          _isLoading = false;
        });
        GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
        print('error occured  $error');
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
       body: Stack(
        children: [
          CachedNetworkImage( //The cached network images stores and retrieves files
            imageUrl: logiUrlImage,
            /* placeholder: (context, url) => Image.asset(
              '/assets/imges/wallpaper.jpg',  */
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
          Container(
            color: Colors.black54,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
              child: ListView(
                children:  [
                  Padding(
                    padding: const EdgeInsets.only(left: 80, right: 80),
                    child: Image.asset('assets/images/login.png'),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Form( 
                    key: _loginFormKey,
                      child: Column(
                      children: [
                        TextFormField(
                          textInputAction: TextInputAction.next,
                           onEditingComplete: () => FocusScope.of(context)
                              .requestFocus(_passFocusNode),
                              keyboardType: TextInputType.emailAddress,
                          controller: _emailTextController,
                          validator: (value) {
                            if (value!.isEmpty || !value.contains('@')) {
                              return 'Please enter a valid email address ';
                            } else {
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
 const SizedBox(
                          height: 5,
                        ),
                        TextFormField( //For password
                          textInputAction: TextInputAction.next,
                          focusNode: _passFocusNode,
                          keyboardType: TextInputType.visiblePassword,
                          controller: _passTextContoller,
                          obscureText: !_obscureText, //change it dynamically
                          validator: (value) {
                            if (value!.isEmpty || value.length < 7) {
                              return 'Please enter a valid password ';
                            } else {
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            suffixIcon: GestureDetector( //To hide password text based on visibility button
                              onTap: () {
                                setState(() { //set password visibility based on Icon click
                                  _obscureText = !_obscureText;
                                });
                              },
                              child: Icon(
                                _obscureText //show visibility icon based on icon clicks
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                            ),
                            hintText: 'Password ',
                            hintStyle: const TextStyle(color: Colors.white),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            errorBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                         Align( //Forget Password Button
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ForgetPassword()));
                            },
                            child: const Text(
                              'Forget Password ?',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        MaterialButton(
                          onPressed: _submitFormOnLogin, //also authenticates user
                          color: Colors.cyan,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                             const SizedBox(
                          height: 40,
                        ),
                        Center( //SignUp 
                          child: RichText(
                              text: TextSpan(children: [
                            const TextSpan(
                              text: 'Do not have an account ?',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const TextSpan(text: '     '),
                            TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const SignUp())),
                                //builder: (context) => JobScreen())),
                                text: 'SignUp',
                                style: const TextStyle(
                                  color: Colors.cyan,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ))
                          ])),
                        ),
                        ] //end of children
                      )   
                              ), 
                ]
              )
              )
              )
        ]
       )//end of stack
    ); //end of Scaffold
  }//end of build
}