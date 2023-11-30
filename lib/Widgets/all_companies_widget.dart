// ignore_for_file: prefer_if_null_operators

import 'package:flutter/material.dart';
import 'package:job_portal_app/Persistent/persistent.dart';
import 'package:job_portal_app/Search/profile_company.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AllWorkersWidget extends StatefulWidget {

  final String userID;
  final String userName;
  final String userEmail;
  final String phoneNumber;
  final String userImageUrl;

  AllWorkersWidget({required this.userID,required this.userName, 
                    required this.userEmail, required this.phoneNumber, required this.userImageUrl});


  @override
  State<AllWorkersWidget> createState() => _AllWorkersWidgetState();
}

class _AllWorkersWidgetState extends State<AllWorkersWidget> {

  void _mailTo() async
  {
    var mailUrl = '${widget.userEmail}';
    print('widget.userEmail: ${widget.userEmail}');


    final Uri params = Uri(scheme:'mailTo',path: mailUrl,query: 'subject=Write subject here, Please &body=Hello, Please write details here',
  ) ;
  print('Uri: ${params}');
  final url = params.toString();
  launchUrlString(url); 
/* //Org code: Mail Not working
    if(await canLaunchUrlString(mailUrl))
    {
      await launchUrlString(mailUrl);
    }
    else
    {
      print('Error');
      throw 'Error Occurred';
    } */
 
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
       Persistent persistentObject = Persistent();
      persistentObject.getMyData(); 
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        onTap: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> ProfileScreen(userId: widget.userID)));
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(padding: const EdgeInsets.only(right: 12),
        decoration: const BoxDecoration(border: Border(right: BorderSide(width: 1)),
        ),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 20,
          child: Image.network(widget.userImageUrl == null? 
                                                          'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'
                                                          :
                                                          widget.userImageUrl
                                                          ),
        ),
        ),
        title: Text(
          widget.userName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,

          ),
        ),
        subtitle: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Visit Profile',
               maxLines: 2,
               overflow: TextOverflow.ellipsis,
                 style: TextStyle(
           // fontWeight: FontWeight.bold,
            color: Colors.grey,

          ),
          
            ),
          ]),
          trailing: IconButton(icon: Icon(Icons.mail_outline, size: 30, color: Colors.grey,
          ),
            onPressed: (){
              _mailTo();
            },
          )
     
      ),
    );
  }
}