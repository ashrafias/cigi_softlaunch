// ignore_for_file: prefer_if_null_operators

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:job_portal_app/Widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:job_portal_app/user_state.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:fluttericon/font_awesome_icons.dart';

class ProfileScreen extends StatefulWidget {

final String userId;

const ProfileScreen({required this.userId});


  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
 final FirebaseAuth _auth = FirebaseAuth.instance;

 String? name;
 String email = '';
 String phoneNumber = '';
 String imageUrl = '';
 String joinedAt = '';
 bool _isLoading = false;
 bool _isSameUser = false;


  void getUserData() async
  {
      try
      {
        _isLoading = true;
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users')
                                                    .doc(widget.userId).get(); //get data for specific userId

        if(userDoc == null)
        {
             print('inside userdoc NUll');
          return;
        }
        else
        {
            //contains user data
            setState(() {
              name = userDoc.get('name');
              email = userDoc.get('email');
              phoneNumber = userDoc.get('phoneNumber');
              imageUrl = userDoc.get('userImage');
              Timestamp joinedAtTimeStamp = userDoc.get('createdAt');
              var joinedDate = joinedAtTimeStamp.toDate();
              joinedAt = '${joinedDate.year} - ${joinedDate.month} - ${joinedDate.day}';
            });

            User? user = _auth.currentUser;
            final _uid = user!.uid;
            setState(() {
              _isSameUser = _uid == widget.userId;
            });

        }
      }
      catch(error)
      {

      }
      finally{
        _isLoading = false;
      }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  Widget userInfo({required IconData icon, required String content})
  {
    return Row(
        children: [
          Icon(icon, color: Colors.white,),
           Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
          child:  Text(content, style: const TextStyle(color: Colors.white54),)),

        ],
    );
  }

Widget _contactBy({required Color color, required Function fct, required IconData icon})
{
  return CircleAvatar(
    backgroundColor: color,
    radius: 25,
    child: CircleAvatar(radius: 23,
          backgroundColor: Colors.white,
          child: IconButton(icon: Icon(icon,color: color),
                            onPressed: (){fct();},

          
          ),
    ),
  );

}


void _openWhatsAppChat() async
{
  var url = 'https://wa.me/$phoneNumber?text=HelloWorld';
  launchUrlString(url);
}
void _mailTo() async
{ 
  final Uri params = Uri(
    scheme: 'mailTo',
    path: email,
    query: 'subject=Write subject here, Please &body=Hello, Please write details here',
  ) ;
  final url = params.toString();
  print('url: $url');
  launchUrlString(url);

}
void _callPhoneNumber() async
{
  var url = 'tel://$phoneNumber';
  launchUrlString(url);
}

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightBlue.shade100, Colors.blueAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.2, 0.9],
        ),
      ),
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBarForApp(
          indexNum: 3,
        ),
        backgroundColor: Colors.transparent,
        
        body: Center(
                      child: _isLoading? 
                                          const Center(child: CircularProgressIndicator(),)
                                          :
                                          SingleChildScrollView(
                                                      child: Padding(padding: const EdgeInsets.only(top: 0),
                                                        child: Stack(children: [
                                                          Card(
                                                            color: Colors.white10,
                                                            margin: const EdgeInsets.all(30),
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                            child:  Padding(padding: const EdgeInsets.all(8.0),
                                                                      child: Column(
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        children: [
                                                                              const SizedBox(height: 100,),
                                                                              Align(alignment: Alignment.center,
                                                                              child: Text(name == null ? 'Name here'
                                                                                                      : name!,
                                                                                          style: const TextStyle(color: Colors.white, fontSize: 24),
                                                                              ),
                                                                              ),
                                                                              const SizedBox(height: 15,),
                                                                              const Divider(thickness: 1, color: Colors.white, ),
                                                                              const SizedBox(height: 30,),
                                                                              const Padding(padding: EdgeInsets.all(10.0), 
                                                                                           child: Text('Account Information', 
                                                                                                  style:  TextStyle(color: Colors.white54, fontSize: 22),),
                                                                                            ),
                                                                                            const SizedBox(height: 15),
                                                                                            Padding(padding: const EdgeInsets.only(left: 10), 
                                                                                                      child: userInfo(icon: Icons.email, content: email),
                                                                                              ),    
                                                                                              Padding(padding: const EdgeInsets.only(left: 10), 
                                                                                                      child: userInfo(icon: Icons.phone, content: phoneNumber),
                                                                                              ),
                                                                                              const SizedBox(height: 15),
                                                                                              const Divider(thickness: 1, color: Colors.white, ),
                                                                                              const SizedBox(height: 35),
                                                                                              _isSameUser ? Container()
                                                                                                          : Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                                          children: [
                                                                                                            _contactBy(color: Colors.green,
                                                                                                          fct: (){_openWhatsAppChat();}
                                                                                                          , icon: FontAwesome.whatsapp,
                                                                                                          ),
                                                                                                           _contactBy(color: Colors.red,
                                                                                                          fct: (){_mailTo();}
                                                                                                          , icon: Icons.mail_outline,
                                                                                                          ),
                                                                                                             _contactBy(color: Colors.purple,
                                                                                                          fct: (){_callPhoneNumber();}
                                                                                                          , icon: Icons.call,
                                                                                                          ),
                                                                                                          ]),
                                                                                            
                                                                                              !_isSameUser ? Container() 
                                                                                                           : Center(
                                                                                                            child: Padding(padding:  const EdgeInsets.only(bottom: 30),
                                                                                                                  child:  MaterialButton(onPressed: ()
                                                                                                                  {
                                                                                                                    _auth.signOut();
                                                                                                                    Navigator.push(context, MaterialPageRoute(builder: (context)=> UserState(),
                                                                                                                    
                                                                                                                    ));


                                                                                                                  }, 
                                                                                                                  color: Colors.black,
                                                                                                                  elevation: 8,
                                                                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                                                                                  child: const Padding(padding: EdgeInsets.symmetric(vertical: 14),
                                                                                                                  child:  Row(
                                                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                    children: [
                                                                                                                      Text('Logout', 
                                                                                                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, 
                                                                                                                     // fontFamily: 'Signatra'
                                                                                                                      ),    
                                                                                                                      ),
                                                                                                                      SizedBox(width: 8),
                                                                                                                      Icon(Icons.logout, color: Colors.white,)
                                                                                                                    ]),),
                                                                                                                  ),
                                                                                                            ),
                                                                                                           ),
                                                                                                            ],
                                                                      ),
                                                                    ),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Container(
                                                                width: size.width * 0.2,
                                                                height: size.width*0.26,
                                                                decoration: BoxDecoration(
                                                                  color: Colors.red,
                                                                  shape: BoxShape.circle,
                                                                  border: Border.all(
                                                                    width: 8,
                                                                    color: Theme.of(context).scaffoldBackgroundColor, 
                                                                  ),
                                                                  image:DecorationImage(image: NetworkImage(imageUrl == null
                                                                                                                  ? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'
                                                                                                                  : imageUrl,
                                                                  ), fit: BoxFit.fill) ,
                                                                  
                                                                ),
                                                              ),
                                                            ],
                                                          ),

                                                        ],),
                                                      
                                                      ),


                                          ),


        ),

      ),
    );
  }
}
