  //import 'package:firebase_auth/firebase_auth.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:job_portal_app/Persistent/persistent.dart';
import 'package:job_portal_app/Search/search_job.dart';
  import 'package:job_portal_app/Widgets/bottom_nav_bar.dart';
import 'package:job_portal_app/Widgets/job_widget.dart';


  class JobScreen extends StatefulWidget {
  const JobScreen({super.key});


    @override
      State<JobScreen> createState() => _JobScreenState();
  }

  class _JobScreenState extends State<JobScreen> {

      String? jobCategoryFilter;

    //final FirebaseAuth _auth = FirebaseAuth.instance;

_showTaskCategoriesDialog({required Size size}) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: Colors.black54,
            title: const Text(
              'Job Category',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            content: Container(
              width: size.width * 0.9,
              child: ListView.builder(
                  shrinkWrap: true, //Creates a scrollable, linear array of widgets
                  itemCount: Persistent.jobCategoryList.length,
                  itemBuilder: (ctx, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          jobCategoryFilter = Persistent.jobCategoryList[index];

                        });
                       Navigator.canPop(context)
                            ? Navigator.pop(context)
                            : null;
                        print(
                            'jobCategoryList[index], ${Persistent.jobCategoryList[index]}');
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_right_alt_outlined,
                            color: Colors.grey,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              Persistent.jobCategoryList[index],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton(
                  onPressed: () {
                    setState(() {
                      jobCategoryFilter = null;  //Since we cancel filter, filter is now Null
                    });

                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                  },
                  child: const Text(
                    'Cancel Filter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  )),
            ],
          );
        });
  }


@override
  void initState() {
    // TODO: implement initState
      super.initState();
       Persistent persistentObject = Persistent();
      persistentObject.getMyData();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> buildUrl(){

    Stream<QuerySnapshot<Map<String, dynamic>>> data = Stream.empty();
    try {
      print("Category is not empty");
      print(jobCategoryFilter);
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('jobs').where("deadLineDateTimeStamp", isGreaterThanOrEqualTo: DateTime.now());
      print("buildUrl is called");
      if(jobCategoryFilter != null && jobCategoryFilter!.isNotEmpty){
        query = FirebaseFirestore.instance.collection('jobs').where("deadLineDateTimeStamp", isGreaterThanOrEqualTo: DateTime.now()).where('jobCategory', whereIn: [jobCategoryFilter]).orderBy("deadLineDateTimeStamp", descending: false);
      }
      data = query.snapshots();
    }on Exception catch(_){
      print("Error Occurred ::::::::::::::::::::");
    }

    // query = query.orderBy('deadLineDateTimeStamp', descending: false);
    return data;
  }


    @override
    Widget build(BuildContext context) {
         Size size = MediaQuery.of(context).size;
      return Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.lightBlue.shade100, Colors.blueAccent],
        begin: Alignment.centerLeft, end: Alignment.centerRight, stops: const [0.2, 0.9])),
        child: Scaffold(
  bottomNavigationBar: BottomNavigationBarForApp(indexNum: 0),

          backgroundColor: Colors.transparent,

          appBar: AppBar(flexibleSpace: Container(
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.lightBlue.shade100, Colors.blueAccent],
        begin: Alignment.centerLeft, end: Alignment.centerRight, stops: const [0.2, 0.9])),
          ),
          automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(
                Icons.filter_list_rounded,
                color: Colors.black,
              ),
              onPressed: () {
                _showTaskCategoriesDialog(size: size);
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.search_outlined,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (c) => SearchScreen()));
                },
              )
            ],
          ),

       body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: buildUrl(),
              builder: (context, AsyncSnapshot snapshot) {
               // print(snapshot.connectionState);
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.connectionState == ConnectionState.active) {

               //   print('snapshot.data?.docs.isNotEmpty: ${snapshot.data?.docs.isNotEmpty}');
               //   print('snapshot.data?.docs: ${snapshot.data?.docs}');
                  if (snapshot.data?.docs.isNotEmpty == true) {
                    return ListView.builder(
                        itemCount: snapshot.data?.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          return JobWidget(
                            jobTitle: snapshot.data?.docs[index]['jobCategory'],
                            jobDesciption: snapshot.data?.docs[index]
                                ['jobDescription'],
                            jobID: snapshot.data?.docs[index]['jobId'],
                            uploadedBy: snapshot.data?.docs[index]
                                ['uploadedby'],
                            userImage: snapshot.data?.docs[index]['userImage'],
                            name: snapshot.data?.docs[index]['name'],
                            recruitment: snapshot.data?.docs[index]
                                ['recruitment'],
                            email: snapshot.data?.docs[index]['email'],
                            location: snapshot.data?.docs[index]['location'],
                          );
                        });
                  } else {
                    return const Center(
                      child: Text('Currently No Job Openings!'),
                    );
                  }
                }
                return const Center(
                  child: Text(
                    'something went wrong',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                );
              })
        ),
      );
    }
  }