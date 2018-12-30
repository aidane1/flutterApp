import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:experiments/components/appBar.dart';
import 'package:experiments/components/universalClasses.dart';
import 'package:experiments/components/userStorage.dart';
import 'package:experiments/components/assignmentRetrieval.dart';
import 'package:intl/intl.dart';



class MakeAssignment extends StatefulWidget {
   final double screenWidth;
   Assignment assignment;
   final ThemeColor configData;
   final callBack;
   MakeAssignment(this.screenWidth, this.assignment, this.configData, this.callBack);
   _MakeAssignment createState() {
     return _MakeAssignment();
   }
 }
 class _MakeAssignment extends State<MakeAssignment> {
   Widget build(BuildContext context) {
     return Container(
       width: widget.screenWidth,
       height: 70.0,
       padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
       child: Row(
        children: <Widget>[
          Checkbox(
            onChanged: (val) {
              widget.assignment.completed = val;
              setState(() {
                              
              });
              widget.callBack();
            },
            activeColor: Color(widget.configData.secondaryTheme[1]),
            value: widget.assignment.completed == true,

          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.assignment.assignment != null ? widget.assignment.assignment : "",
                      style: TextStyle(
                        decoration: widget.assignment.completed == true ? TextDecoration.lineThrough : TextDecoration.none,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                        color: widget.assignment.completed == false ? widget.configData.mainTheme == 1 ? Colors.white : Colors.black : Colors.grey,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          ("Due by: " + (widget.assignment.dueBy !=  null ? widget.assignment.dueBy.replaceAll(new RegExp(r"\s+\b|\b\s"), " ") : "")),
                          style: TextStyle(
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            )
          ),
        ],
      ),
     );
   }
 }

Future<Widget> compileAssignments(MongoId id, double screenWidth, ThemeColor theme) async {
  await Assignments.retrieveFromServer(id);
  List<Assignment> allAssignmentsList = await Assignments.retrieveAssignments(id);
  allAssignmentsList.sort((a,b) {
    return b.dateSubmitted.millisecondsSinceEpoch.compareTo(a.dateSubmitted.millisecondsSinceEpoch);
  });
  List<Widget> assignmentsWidget = new List<Widget>();
  DateFormat formatter = new DateFormat('MMMM dd, yyyy');
  for (var i = 0; i < allAssignmentsList.length; i++) {
    assignmentsWidget.add(MakeAssignment(screenWidth, allAssignmentsList[i], theme, () async {
      UserStorage storage = new UserStorage();
      storage.writeIdData(allAssignmentsList, "retrievedAssignments${id.id}.json");
    }));
  }
  return Column(
    children: assignmentsWidget,
  );
}

class AllAssignmentsPage extends StatelessWidget {
  final AllNotesInfo notesInfo;
  AllAssignmentsPage(this.notesInfo);
  @override
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;
    List<Tab> tabList = new List<Tab>();
    List<Container> viewsList = new List<Container>();
    for (var i = 0; i < notesInfo.courses.length; i++) {
      tabList.add(Tab(
        text: notesInfo.courses[i].course,
      ));
      
      viewsList.add(Container(
        child: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Text(
              notesInfo.courses[i].course,
            ),
            FutureBuilder(
              future: compileAssignments(notesInfo.courses[i].id, screenDimensions.width, notesInfo.themeData),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data;
                } else if (snapshot.hasError) {
                  print(snapshot.error);
                  return Column();
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ));
    }
    
    
    return DefaultTabController(
      length: notesInfo.courses.length,
      child: Scaffold(
        appBar: makeAppBar(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.chevron_left, size: 30.0,),
                color: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Text(
                "Assignments",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                )
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, size: 30.0,),
                color: Color.fromARGB(0, 0, 0, 0),
                onPressed: () {
                  
                },
              ),
            ],
          ), 
          screenDimensions.width
        ),
        body: TabBarView(
          children: viewsList,
        ),
      ),
    );
  }
}