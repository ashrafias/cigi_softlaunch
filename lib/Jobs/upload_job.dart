

//import 'package:job_portal_app/Persistent/persistent.dart';
import 'package:job_portal_app/Persistent/persistent.dart';
import 'package:job_portal_app/Widgets/bottom_nav_bar.dart';
import 'package:job_portal_app/services/global_methods.dart';
import 'package:job_portal_app/services/global_variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

class UploadJobNow extends StatefulWidget {
  const UploadJobNow({super.key});

  @override
  State<UploadJobNow> createState() => _UploadJobNowState();
}

class _UploadJobNowState extends State<UploadJobNow> {
  final TextEditingController _jobCategoryController =
      TextEditingController(text: 'Select Job Category ');
  final TextEditingController _jobTitleController = TextEditingController();

  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  final TextEditingController _JobDescriptionController =
      TextEditingController();
  final TextEditingController _deadlineController =
      TextEditingController(text: 'Job Deadline Date ');

  final _formkey = GlobalKey<FormState>();
  DateTime? picked;
  Timestamp? deadlineDateTimeStamp;
  

  void dispose()
  {
    super.dispose();
    _jobCategoryController.dispose();
    _jobTitleController.dispose();
    _JobDescriptionController.dispose();
    _deadlineController.dispose();
  }

  bool _isLoading = false;

  Widget _textTitle({required String label}) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _textFormFields({
    required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required Function fct,
    required int maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () {
          fct();
        },
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return 'value is missing';
            }
            return null;
          },
          controller: controller,
          enabled: enabled,
          key: ValueKey(valueKey),
          style: const TextStyle(
          color: Colors.white,
          ),
          maxLines: valueKey == 'job description' ? 4 : 1, //Num of lines for TextField
          maxLength: maxLength,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
          filled: true,
          fillColor: Colors.black54,
          enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
            ),
          focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
            ),
          errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  _showTaskCategoriesDialog({required Size size}) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: Colors.black54,
            title: const Text(
              'Job Category',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white),
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
                          _jobCategoryController.text =
                              Persistent.jobCategoryList[index];
                        });
                        Navigator.pop(context);
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
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        });
  }

  void _pickDateDialog() async {
    picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 0),
      ),
      lastDate: DateTime(2100),  
    );
    print('picked: $picked');
    print('updated ::::::::::::::::');
    if (picked != null) {
      setState(() {
        _deadlineController.text =
            '${picked!.year} - ${picked!.month} -${picked!.day}';

        deadlineDateTimeStamp = Timestamp.fromMicrosecondsSinceEpoch(picked!.microsecondsSinceEpoch);//Constructs a new DateTime instance with the given millisecondsSinceEpoch.
            print('deadlineDateTimeStamp: $deadlineDateTimeStamp');
      });
    }
   
  }

  void _uploadTask() async { //Upload job details Only if form is valid
    final jodId = Uuid().v4();
    User? user = FirebaseAuth.instance.currentUser;
    final _uid = user!.uid;
    final isValid = _formkey.currentState!.validate();

    if (isValid) {
      if (_deadlineController.text == 'Choose job Deadline date' ||
          _jobCategoryController.text == 'Choose job category') {
        GlobalMethod.showErrorDialog(
            error: 'Please pick everything', ctx: context);
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseFirestore.instance.collection('jobs').doc(jodId).set({
          'jobId': jodId,
          'uploadedby': _uid,
          'email': user.email,
          'companyName': _companyNameController.text,
          'jobTitle': _jobTitleController.text,
          'jobDescription': _JobDescriptionController.text,
          'deadLineDate': _deadlineController.text,
          'deadLineDateTimeStamp': deadlineDateTimeStamp, // picked?.millisecondsSinceEpoch, // deadlineDateTimeStamp?.millisecondsSinceEpoch,
          'jobCategory': _jobCategoryController.text,
          'jobComments': [],
          'city': _cityController.text,
          'country': _countryController.text,
          'recruitment': true,
          'createdAt': Timestamp.now(),
          'name': name,
          'userImage': userImage,
          'location': location,
          'applicants': 0,
        });

        await Fluttertoast.showToast(
          msg: 'the task has been uploaded ',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 16.0,
        );
        _jobTitleController.clear();
        _JobDescriptionController.clear();
        setState(() {
          _jobCategoryController.text = 'Choose job category ';
          _deadlineController.text = 'choose job Deadline date';
        });
      } catch (error) {
        {
          setState(() {
            _isLoading = false;
          });
          GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('Its not valid');
    }
  }
   void getMyData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
     setState(() {
      name = userDoc.get('name');
      userImage = userDoc.get('userImage');
      location = userDoc.get('location');
     });

  }
//added The below code for fixing Job Screen issue
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyData();
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
          indexNum: 2,
        ),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Card(
              color: Colors.white10,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Please fill all fields',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: _formkey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _textTitle(label: 'Company Name: '),
                            _textFormFields(
                              valueKey: 'Company Name',
                              controller: _companyNameController,
                              enabled: true,
                              fct: () {},
                              maxLength: 100,
                            ),
                            _textTitle(label: 'Job Category: '),
                            _textFormFields(
                              valueKey: 'Job Category ',
                              controller: _jobCategoryController,
                              enabled: false,
                              fct: () { //click event
                                _showTaskCategoriesDialog(size: size);
                              },
                              maxLength: 100,
                            ),
                            _textTitle(label: 'Job Title: '),
                            _textFormFields(
                              valueKey: 'Job Title',
                              controller: _jobTitleController,
                              enabled: true,
                              fct: () {},
                              maxLength: 100,
                            ),
                            _textTitle(label: 'Job Description : '),
                            _textFormFields(
                              valueKey: 'Job Description',
                              controller: _JobDescriptionController,
                              enabled: true,
                              fct: () {},
                              maxLength: 100,
                            ),
                            _textTitle(label: 'Job Deadline Date  : '),
                            _textFormFields(
                              valueKey: 'Deadline',
                              controller: _deadlineController,
                              enabled: false,  //dont display keyboard
                              fct: () {
                                _pickDateDialog();
                              },
                              maxLength: 100,
                            ),
                            _textTitle(label: 'City: '),
                            _textFormFields(
                              valueKey: 'City',
                              controller: _cityController,
                              enabled: true,
                              fct: () {},
                              maxLength: 100,
                            ),
                            _textTitle(label: 'Country: '),
                            _textFormFields(
                              valueKey: 'Country',
                              controller: _countryController,
                              enabled: true,
                              fct: () {},
                              maxLength: 100,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 30),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : MaterialButton(
                                onPressed: () {
                                  _uploadTask();
                                },
                                color: Colors.black,
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Post Now',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          //fontFamily: 'Signatra';
                                        ),
                                      ),
                                      SizedBox(
                                        width: 9,
                                      ),
                                      Icon(
                                        Icons.upload_file,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
