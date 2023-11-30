import 'package:flutter/material.dart';
import 'package:job_portal_app/Jobs/jobs_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_portal_app/Widgets/job_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreentState();
}

class _SearchScreentState extends State<SearchScreen> {
  
  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = 'Search Query' ;

  Widget _buildSearchField()
  {
    return TextField(
      controller:  _searchQueryController,
      autocorrect: true,
      decoration: const InputDecoration(
        hintText: 'Search for jobs...',
        border: InputBorder.none,
      hintStyle: TextStyle(color: Colors.white)
      ),
      style: const TextStyle(color: Colors.white, fontSize:16.0),
      onChanged: (query) => _updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions()
  {
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: (){
          _clearSearchQuery();
        },
      ),
    ];
  }
  
  void _clearSearchQuery()
  {
    setState(()
    {
      _searchQueryController.clear();
      _updateSearchQuery('');
    });
  }

    void _updateSearchQuery(String newQuery)
  {
    setState(()
    {
     searchQuery = newQuery;
     print(searchQuery);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightBlue.shade100, Colors.blueAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.2, 0.9],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.lightBlue.shade100, Colors.blueAccent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.2, 0.9],
              ), //LinearGradient
            ),//BoxDecoration
          ),//Container
          leading: IconButton(
            onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> JobScreen()));

            },
            icon: const Icon(Icons.arrow_back),
          ),//IconButton
          title: _buildSearchField(),
          actions: _buildActions(),
        ),//AppBar
        body: StreamBuilder<QuerySnapshot<Map<String,dynamic>>>
        (
              stream: FirebaseFirestore.instance.collection('jobs').where('jobTitle', isGreaterThanOrEqualTo: searchQuery) 
              .where('recruitment', isEqualTo: true).snapshots(),
              builder: (context, AsyncSnapshot snapshot)
              {
                  if(snapshot.connectionState==ConnectionState.waiting)
                  {
                    return Center(child: CircularProgressIndicator(),);
                  }
                  else if(snapshot.connectionState==ConnectionState.active)
                  {
                    if(snapshot.data?.docs.isNotEmpty == true)
                    {
                        return ListView.builder(
                          itemCount: snapshot.data?.docs.length,
                          itemBuilder: (BuildContext context, int index)
                          {
                            return JobWidget(
                              jobTitle: snapshot.data?.docs[index]['jobTitle'],
                              jobDesciption: snapshot.data?.docs[index]['jobDescription'],
                              jobID: snapshot.data?.docs[index]['jobId'],
                              uploadedBy: snapshot.data?.docs[index]['uploadedby'],
                              userImage: snapshot.data?.docs[index]['userImage'],
                              name: snapshot.data?.docs[index]['name'],
                              recruitment: snapshot.data?.docs[index]['recruitment'],
                              email: snapshot.data?.docs[index]['email'],
                              location: snapshot.data?.docs[index]['location'],

                            ); //JobWidget
                          }//itemBuilder
                        );//builder
                    }//if
                    else
                    {
                      return Center(
                        child: Text('Currently, There are No Openings!')
                      );
                    }
                  }
                  return Center(
                      child: Text('Something went wrong!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0))

                  );
              },

        ),

      ),//Scaffold
    );
  }
}
