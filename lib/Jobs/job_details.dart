import 'dart:async';
import 'dart:html';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:path/path.dart' as path;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:job_portal_app/Jobs/jobs_screen.dart';
import 'package:job_portal_app/Services/global_methods.dart';
import 'package:job_portal_app/Services/global_variables.dart';
import 'package:job_portal_app/Widgets/Web/FilePick/WebFileModel.dart';
import 'package:job_portal_app/Widgets/comments_widget.dart';
import 'package:uuid/uuid.dart';

import '../Widgets/Web/FilePick/html_nonweb.dart' if (dart.library.js) 'dart:html' as html;

class JobDetailsScreen extends StatefulWidget {
  final String uploadedBy;
  final String jobID;

  const JobDetailsScreen(
      {super.key, required this.uploadedBy, required this.jobID});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> with TickerProviderStateMixin {

  bool _isLoading = false;

  final TextEditingController _commentController = TextEditingController();
  bool _isCommenting = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? authorName;
  String? userImageUrl;
  String? jobCategory;
  String? jobDescription;
  String? jobTitle;
  bool? recruitment;
  Timestamp? postedDateTimestamp;
  Timestamp? deadlineDateTimestamp;
  String? postedDate;
  String? deadLineDate;
  String? locationCompany = '';
  String? emailCompany = '';
  int applicants = 0;
  bool isDeadLineAvailable = false;
  bool showComment = false;
  File? file;
  late WebFileModel fileModel;
  String selectedFileName = '';
  String? mailBtnName = 'Submit Application';

  TextEditingController messageField = TextEditingController(text: '');

  void getJobData() async {
    _isLoading = true;
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uploadedBy)
        .get();

    if (userDoc == null) {
      return;
    } else {
      setState(() {
        authorName = userDoc.get('name');
        userImageUrl = userDoc.get('userImage');
      });
    }

    final DocumentSnapshot jobDatabase = await FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobID)
        .get();

    if (jobDatabase == null) {
      return;
    } else {
      setState(() {
        jobTitle = jobDatabase.get('jobTitle');
        jobDescription = jobDatabase.get('jobDescription');
        recruitment = jobDatabase.get('recruitment');
        emailCompany = jobDatabase.get('email');
        locationCompany = jobDatabase.get('location');
        applicants = jobDatabase.get('applicants');
        postedDateTimestamp = jobDatabase.get('createdAt');
        deadlineDateTimestamp = jobDatabase.get('deadLineDateTimeStamp');
        deadLineDate = jobDatabase.get('deadLineDate');
        var postDate = postedDateTimestamp!.toDate();
        postedDate = '${postDate.year}.${postDate.month}.${postDate.day}';
      });
      var date = deadlineDateTimestamp!.toDate();
      //print('date: $date');
      isDeadLineAvailable = date.isAfter(DateTime.now());
      // print('isDeadLineAvailable: $isDeadLineAvailable');
    }

    _isLoading = false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getJobData();
  }

  @override
  void dispose() {
    messageField.dispose();
    selectedFileName = "";
    mailBtnName = "Submit Application";
  }

  Widget dividerWidget() {
    return const Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  //Apply for job => called on EasyApply
  applyForJob() {
    showBottomSheet();

    /*final Uri params = Uri(
        scheme: 'mailto',
        path: emailCompany,
        query:
            'subject=Applying for $jobTitle&body=Hello, Please attach Resume CV file');*/
    //final url = params.toString();
    //launchUrlString(url);
    //addNewApplicants();
    // Navigator.pop(context);
  }


  // <> Bottom modal
  showBottomSheet(){
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context,state){
          return SizedBox(
            height: 500,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  OutlinedButton(
                    child: const Text('Select Resume'),
                    onPressed: () async {
                      if (kIsWeb) {
                        fileModel = await pickWebFileModel(state);
                      } else {
                        var picked = await FilePicker.platform.pickFiles();
                        if (picked != null) {
                          print(picked.files.first.name);
                        }
                      }
                    },
                  ),
                  Text(selectedFileName!, textAlign: TextAlign.center, ),
                  Container(
                      margin: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        maxLines: 3, //or null
                        decoration: InputDecoration(
                          hintText: "Enter your message here",
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide( color: Colors.black54, ),
                          ),
                        ),
                        controller: messageField,
                      )
                  ),
                  Container(
                    margin: const EdgeInsets.all(5.0),
                    child: OutlinedButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                      ),
                      child: Text(mailBtnName!),
                      onPressed: ()  {
                        sendMailWeb(state, fileModel);
                      },
                    ),
                  )

                ],
              ),
            ),
          );
        });

      },
    );
  }
  //</

  // <> Pick file for web
  Future<WebFileModel> pickWebFileModel(StateSetter state) {
    final completer = Completer<WebFileModel>();
    final html.InputElement input = html.document.createElement('input') as html.InputElement;
    input ..type = 'file';

      // ..accept = 'image/*';
    input.onChange.listen((e) async {
      final List<html.File> files = input.files!;
      final reader = html.FileReader();

      reader.readAsDataUrl(files.first);
      reader.onError.listen(completer.completeError);
      final Future<WebFileModel> resultsFutures = reader.onLoad.first.then((_) => WebFileModel(
                path: reader.result! as String,
                type: files.first.type as String,
                createdAt: DateTime.fromMillisecondsSinceEpoch(
                  files.first.lastModified!,
                ),
                htmlFile: files.first,
              ));
      final results = await resultsFutures;
      state(() {
        selectedFileName = "File Selected"; // path.basename(results.path);
        // print(selectedFileName);
      });
      completer.complete(results);
    });
    input.click();
    return completer.future;
  }
  // </>

  // <> Sending mail
  Future<bool> sendMailWeb(StateSetter state, WebFileModel fileModel) async {

    setState(() {
      _isLoading = true;
    });

    state((){
      mailBtnName = "Sending....";
    });

    final imageBase64 =fileModel.path.substring(fileModel.path.indexOf(',') + 1); //replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');

    final fields = <String, String>{};
    fields["from"] = "helpdesk@cigi.org";
    fields["to"] = emailCompany!;//"gopinath@sygmetiv.com";
    fields["subject"] = "Received application for Position: ${jobTitle!}";
    fields["message"] = messageField.text;
    fields["file"] = imageBase64;

    final response = await http.post(Uri.parse('http://localhost/mail.php'), body:fields);
    final isValid = (response.statusCode == 200);
    if (isValid) {
      // If the server did return a 200 OK response,
      Navigator.pop(context);
      setState(() {
        _isLoading = false;
      });
      resetMailBtn(state);
      // Success toast
      await Fluttertoast.showToast(
        msg: 'Application Submitted Successfully',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      setState(() {
        _isLoading = false;
      });
      resetMailBtn(state);
      // If the server did not return a 200 OK response,
      // then throw an exception.
      // Error toast
      GlobalMethod.showErrorDialog(error: "Application Submission Failed", ctx: context);
      // throw Exception('Failed to load album');
    }


    return isValid;

  }
  // </>

  resetMailBtn(StateSetter state){
    state((){
      mailBtnName = "Submit Application";
    });
  }

  void
      addNewApplicants() async //increment applicants when user applies for a job
  {
    var docRef =
        FirebaseFirestore.instance.collection('jobs').doc(widget.jobID);

    docRef.update({
      'applicants': applicants + 1,
    }); //'applicants' in Firebase

    //Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.lightBlue.shade100, Colors.blueAccent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.2, 0.9]),
        ),
        child: _isLoading? const Center(child: CircularProgressIndicator(),)
        : Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.lightBlue.shade100, Colors.blueAccent],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: const [0.2, 0.9])),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.close,
                size: 40,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const JobScreen()));
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Card(
                    color: Colors.black54,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              jobTitle == null ? '' : jobTitle!,
                              maxLines: 3,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30),
                            ),
                            //if no jobTitle show empty string
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 3,
                                    color: Colors.grey,
                                  ),
                                  shape: BoxShape.rectangle,
                                  image: DecorationImage(
                                    image: NetworkImage(userImageUrl == null
                                        ? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'
                                        : userImageUrl!),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      authorName == null ? '' : authorName!,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      locationCompany!,
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          dividerWidget(),
                          //to create a divider between 2 widgets
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  applicants.toString(),
                                  //Show num of Applicants
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                const SizedBox(width: 6),
                                const Text('Applicants',
                                    style: TextStyle(color: Colors.grey)),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.how_to_reg_sharp,
                                  //Icon to show applicants
                                  color: Colors.grey,
                                )
                              ]),

                          //If its user who is the Recruiter
                          FirebaseAuth.instance.currentUser!.uid !=
                                  widget.uploadedBy
                              ? Container()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    dividerWidget(),
                                    const Text(
                                      'Recruitment',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                            onPressed: () {
                                              User? user = _auth.currentUser;
                                              final _uid = user!.uid;
                                              if (_uid == widget.uploadedBy) {
                                                try {
                                                  FirebaseFirestore.instance
                                                      .collection('jobs')
                                                      .doc(widget.jobID)
                                                      .update({
                                                    'recruitment': true
                                                  });
                                                } catch (error) {
                                                  GlobalMethod.showErrorDialog(
                                                      error:
                                                          'Action cannot be performed',
                                                      ctx: context);
                                                }
                                              } else {
                                                GlobalMethod.showErrorDialog(
                                                    error:
                                                        'You cannot perform this action',
                                                    ctx: context);
                                              }
                                              getJobData();
                                            },
                                            child: const Text(
                                              'ON',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        Opacity(
                                          opacity: recruitment == true ? 1 : 0,
                                          child: const Icon(
                                            Icons.check_box,
                                            color: Colors.green,
                                          ),
                                        ),
                                        const SizedBox(width: 40),
                                        TextButton(
                                            onPressed: () {
                                              User? user = _auth.currentUser;
                                              final _uid = user!.uid;
                                              if (_uid == widget.uploadedBy) {
                                                try {
                                                  FirebaseFirestore.instance
                                                      .collection('jobs')
                                                      .doc(widget.jobID)
                                                      .update({
                                                    'recruitment': false
                                                  });
                                                } catch (error) {
                                                  GlobalMethod.showErrorDialog(
                                                      error:
                                                          'Action cannot be performed',
                                                      ctx: context);
                                                }
                                              } else {
                                                GlobalMethod.showErrorDialog(
                                                    error:
                                                        'You cannot perform this action',
                                                    ctx: context);
                                              }
                                              getJobData();
                                            },
                                            child: const Text(
                                              'OFF',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        Opacity(
                                          opacity: recruitment == false ? 1 : 0,
                                          child: const Icon(
                                            Icons.check_box,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                          dividerWidget(),
                          const Text(
                            'Job Description',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            jobDescription == null ? '' : jobDescription!,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                          dividerWidget(),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Card(
                      color: Colors.black54,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Center(
                                child: Text(
                              isDeadLineAvailable
                                  ? 'Actively Recruiting, Send CV/Resume'
                                  : 'Deadline passed away',
                              style: TextStyle(
                                  color: isDeadLineAvailable
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16),
                            )),
                            const SizedBox(height: 6),
                            Center(
                              child: MaterialButton(
                                onPressed: () {
                                  applyForJob();
                                },
                                color: Colors.blueAccent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Text(
                                    'Easy Apply Now',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                            dividerWidget(),
                            Row(
                              //Display postedDate
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Uploaded On: ',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  postedDate == null ? '' : postedDate!,
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              //Display deadLineDate
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Deadline date: ',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  deadLineDate == null ? '' : deadLineDate!,
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                            dividerWidget(),
                          ],
                        ),
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Card(
                    color: Colors.black54,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(
                              milliseconds: 500,
                            ),
                            child: _isCommenting
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                          flex: 3,
                                          child: TextField(
                                            controller: _commentController,
                                            style: const TextStyle(
                                                color: Colors.white),
                                            maxLength: 200,
                                            keyboardType: TextInputType.text,
                                            maxLines: 6,
                                            decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                enabledBorder:
                                                    const UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.white)),
                                                focusedBorder:
                                                    const OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.pink))),
                                          )),
                                      Flexible(
                                          child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: MaterialButton(
                                              onPressed: () async {
                                                if (_commentController
                                                        .text.length <
                                                    7) {
                                                  GlobalMethod.showErrorDialog(
                                                      error:
                                                          'Comment cannot be less than 7 characters',
                                                      ctx: context);
                                                } else {
                                                  final _generatedID =
                                                      const Uuid().v4();
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('jobs')
                                                      .doc(widget.jobID)
                                                      .update({
                                                    'jobComments':
                                                        FieldValue.arrayUnion([
                                                      {
                                                        'userId': FirebaseAuth
                                                            .instance
                                                            .currentUser!
                                                            .uid,
                                                        'commentId':
                                                            _generatedID,
                                                        'name': name,
                                                        'userImageUrl':
                                                            userImage,
                                                        'commentBody':
                                                            _commentController
                                                                .text,
                                                        'time': Timestamp.now(),
                                                      }
                                                    ]),
                                                  });
                                                  await Fluttertoast.showToast(
                                                    msg:
                                                        'Your comment has been added',
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    backgroundColor:
                                                        Colors.grey,
                                                    fontSize: 18.0,
                                                  );
                                                  _commentController.clear();
                                                }
                                                setState(() {
                                                  showComment = true;
                                                });
                                              },
                                              color: Colors.blueAccent,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: const Text(
                                                'Post',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _isCommenting =
                                                      !_isCommenting;
                                                  showComment = false;
                                                });
                                              },
                                              child: const Text('Cancel'))
                                        ],
                                      ))
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _isCommenting = !_isCommenting;
                                            });
                                          },
                                          icon: const Icon(Icons.add_comment,
                                              color: Colors.blueAccent,
                                              size: 40)),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              showComment = true;
                                            });
                                          },
                                          icon: const Icon(
                                              Icons.arrow_drop_down_circle,
                                              color: Colors.blueAccent,
                                              size: 40))
                                    ],
                                  ),
                          ),
                          showComment == false
                              ? Container()
                              : Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection('jobs')
                                        .doc(widget.jobID)
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else {
                                        if (snapshot.data == null) {
                                          const Center(
                                              child: Text(
                                                  'No comment for this job'));
                                        }
                                      }
                                      return ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          // print(snapshot.data!['jobComments'][index] ['userImageUrl']);
                                          return CommentWidget(
                                            commentId:
                                                snapshot.data!['jobComments']
                                                    [index]['commentId'],
                                            commenterId:
                                                snapshot.data!['jobComments']
                                                    [index]['userId'],
                                            commenterName:
                                                snapshot.data!['jobComments']
                                                    [index]['name'],
                                            commentBody:
                                                snapshot.data!['jobComments']
                                                    [index]['commentBody'],
                                            commenterImageUrl:
                                                snapshot.data!['jobComments']
                                                    [index]['userImageUrl'],
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          return const Divider(
                                            thickness: 1,
                                            color: Colors.grey,
                                          );
                                        },
                                        itemCount: snapshot
                                            .data!['jobComments'].length,
                                      );
                                    }, //end of builder
                                  ),
                                )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
