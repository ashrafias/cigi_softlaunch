import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:job_portal_app/Jobs/job_details.dart';
import 'package:job_portal_app/Services/global_methods.dart';

class JobWidget extends StatefulWidget {
  final String jobTitle;
  final String jobDesciption;
  final String jobID;
  final String uploadedBy;
  final String userImage;
  final String name;
  final bool recruitment;
  final String email;
  final String location;

  const JobWidget({
    required this.jobTitle,
    required this.jobDesciption,
    required this.jobID,
    required this.uploadedBy,
    required this.userImage,
    required this.name,
    required this.recruitment,
    required this.email,
    required this.location,

    //super.key});
  });


 

  @override
  State<JobWidget> createState() => _JobWidgetState();
}

class _JobWidgetState extends State<JobWidget> {
 @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
final FirebaseAuth _auth = FirebaseAuth.instance;

//Method to delete job post
_deleteDialog()
{

User? user = _auth.currentUser;
final _uid = user!.uid;
showDialog(context: context, 
builder: (ctx){
  return AlertDialog(
    actions: [TextButton(onPressed: () async {

      //Actual Deletion
      try{
          if(widget.uploadedBy == _uid)
          {
            await FirebaseFirestore.instance.collection('jobs').doc(widget.jobID).delete();
            await Fluttertoast.showToast(
              msg: 'Job has been deleted', 
              toastLength: Toast.LENGTH_LONG, 
              backgroundColor: Colors.grey, 
              fontSize: 18.0);
              Navigator.canPop(ctx) ? Navigator.pop(ctx) : null;
          }
          else{
            GlobalMethod.showErrorDialog(error: 'You cannot perform this action', ctx: ctx);


          }

      }
      catch (error)
      {
          GlobalMethod.showErrorDialog(error: error.toString(), ctx: ctx);
         // GlobalMethod.showErrorDialog(error: 'This task cannot be deleted', ctx: ctx);

      }
    }, 
    child: const Row(mainAxisAlignment: MainAxisAlignment.center, 
    children: [Icon(Icons.delete, color: Colors.red),
    Text('Delete', style: TextStyle(color: Colors.red)),],))],
  );

});

}


  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white24,
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ListTile(
        onTap: () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> JobDetailsScreen(uploadedBy: widget.uploadedBy,jobID: widget.jobID,)));},
        onLongPress: () {_deleteDialog();},
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.only(right: 12),
          decoration:
              const BoxDecoration(border: Border(right: BorderSide(width: 1))),
          child: Image.network(widget.userImage),
        ),
        title: Text(
          widget.jobTitle,  //This displays job title
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              widget.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              widget.jobDesciption,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.keyboard_arrow_right,
          size: 30,
          color: Colors.black,
        ),
      ),
    );
  }
}
