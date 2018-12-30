

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:experiments/components/appBar.dart';
import 'package:experiments/components/userStorage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:experiments/components/universalClasses.dart';
import 'package:experiments/components/notesRetrieval.dart';
import 'package:experiments/components/assignmentRetrieval.dart';





List allAssignmentsToOne(List allAssignments, String courseID) {
  List newList = new List();
  for (var i = 0; i < allAssignments.length; i++) {
    if (allAssignments[i]["forCourse"] == courseID) {
      newList.add(allAssignments[i]);
    }
  }
  return newList;
}

Future<Column> makeAssignmentsColumn(String id, double screenWidth, ThemeColor configData) async {
  await Assignments.retrieveFromServer(MongoId(id));
  List<Assignment> allAssignmentsList = await Assignments.retrieveAssignments(MongoId(id));
  List<Widget> assignmentList = new List<Widget>();
  for (var i = 0; i < allAssignmentsList.length; i++) {
    assignmentList.add(
      MakeAssignment(screenWidth, allAssignmentsList[i], configData, () async {
        UserStorage storage = new UserStorage();
        storage.writeIdData(allAssignmentsList, "retrievedAssignments$id.json");
      })
    );
  }
  if (allAssignmentsList.length == 0) {
    assignmentList.add(
      MakeAssignment(screenWidth, Assignment("No assignments yet!", "", "", MongoId("_"), false, DateTime.now()), configData, (){})
    );
  }
  return Column(
    children: assignmentList,
  );
}

Future<Column> makeNotesColumn(String id, double screenWidth, ThemeColor configData) async {
  await Notes.retrieveFromServer(MongoId(id));
  List<Note> allNotesList = await Notes.retrieveNotes(MongoId(id));
  allNotesList.sort((a,b) {
    return b.dateSubmitted.millisecondsSinceEpoch.compareTo(a.dateSubmitted.millisecondsSinceEpoch);
  });
  List<Widget> notesList = new List<Widget>();
  for (var i = 0; i < allNotesList.length; i++) {
    notesList.add(MakeNote(screenWidth, allNotesList[i], configData, () async {
      UserStorage storage = new UserStorage();
      storage.writeIdData(allNotesList, "retrievedNotes$id.json");
    }));
  }
  return Column(
    children: notesList,
  );
}



class NotesPage extends StatelessWidget {
  
  final NoteInfo notesData;
  NotesPage(this.notesData);
  Widget build(BuildContext context) {
    
    

    Course course = notesData.course;
    ThemeColor theme = notesData.themeColor;
    theme.update();
    final screenDimensions = MediaQuery.of(context).size;
    return Scaffold(
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
              course.course,
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
       body: Container(
         color: theme.bodyBack,
         child: ListView(
           scrollDirection: Axis.vertical,
           children: <Widget>[
             Container(
               margin: EdgeInsets.only(top: 10.0),
               child: Column(
                 children: <Widget>[
                   Container(
                     decoration: BoxDecoration(
                      color: theme.blockBack,
                      border: Border(top: BorderSide(width: 1.0, color: theme.border)),
                    ),
                     child: Row(
                       children: <Widget>[
                         Container(
                           width: 50.0,
                           height: 50.0,
                           child: Container(
                             width: 30.0,
                             height: 30.0,
                             decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                              color: theme.textColor,
                            ),
                             margin: EdgeInsets.all(10.0),
                             child: Icon(
                               Icons.person,
                               color: theme.mainTheme == 1 ? Colors.black : Colors.white,
                             ),
                           ),
                         ),
                         Container(
                           width: screenDimensions.width-50.0,
                           height: 50.0,
                           padding: EdgeInsets.only(right: 10.0),
                           decoration: BoxDecoration(
                             border: Border(bottom: BorderSide(width: 1.0, color: theme.border)),
                           ),
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: <Widget>[
                               Text(
                                 "Teacher: ",
                                 style: TextStyle(
                                   fontSize: 18.0,
                                   color: theme.textColor,
                                 ),
                               ),
                               Text(
                                 course.teacher,
                                 style: TextStyle(
                                   fontSize: 18.0,
                                   fontWeight: FontWeight.w100,
                                   color: Colors.grey,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ],
                     ),
                   ),
                   Container(
                     decoration: BoxDecoration(
                      color: theme.blockBack,
                    ),
                     child: Row(
                       children: <Widget>[
                         Container(
                           width: 50.0,
                           height: 50.0,
                           child: Container(
                             width: 30.0,
                             height: 30.0,
                             decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                              color: theme.mainTheme == 1 ? Colors.white : Colors.black,
                            ),
                             margin: EdgeInsets.all(10.0),
                             child: Icon(
                               MdiIcons.bookOpenPageVariant,
                               color: theme.mainTheme == 1 ? Colors.black : Colors.white,
                             ),
                           ),
                         ),
                         Container(
                           width: screenDimensions.width-50.0,
                           height: 50.0,
                           padding: EdgeInsets.only(right: 10.0),
                           decoration: BoxDecoration(
                             border: Border(bottom: BorderSide(width: 1.0, color: theme.border)),
                           ),
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: <Widget>[
                               Text(
                                 "Class: ",
                                 style: TextStyle(
                                   fontSize: 18.0,
                                   color: theme.textColor,
                                 ),
                               ),
                               Text(
                                 course.course,
                                 style: TextStyle(
                                   fontSize: 18.0,
                                   fontWeight: FontWeight.w100,
                                   color: Colors.grey,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ],
                     ),
                   ),
                   Container(
                     decoration: BoxDecoration(
                      color: theme.blockBack,
                      border: Border(bottom: BorderSide(width: 1.0, color: theme.border)),
                    ),
                     child: Row(
                       children: <Widget>[
                         Container(
                           width: 50.0,
                           height: 50.0,
                           child: Container(
                             width: 30.0,
                             height: 30.0,
                             decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                              color: theme.textColor,
                            ),
                             margin: EdgeInsets.all(10.0),
                             child: Icon(
                               MdiIcons.cube,
                               color: theme.mainTheme == 1 ? Colors.black : Colors.white,
                             ),
                           ),
                         ),
                         Container(
                           width: screenDimensions.width-50.0,
                           height: 50.0,
                           padding: EdgeInsets.only(right: 10.0),
                           decoration: BoxDecoration(
                            
                           ),
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: <Widget>[
                               Text(
                                 "Block: ",
                                 style: TextStyle(
                                   fontSize: 18.0,
                                   color: theme.textColor,
                                 ),
                               ),
                               Text(
                                 course.block,
                                 style: TextStyle(
                                   fontSize: 18.0,
                                   fontWeight: FontWeight.w100,
                                   color: Colors.grey,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ],
                     ),
                   ),
                 ],
               )
             ),
            Container(
              width: screenDimensions.width,
              margin: EdgeInsets.only(top: 20.0,),
              decoration: BoxDecoration(
                color: theme.blockBack,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 10.0),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1.0, color: theme.border)),
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: screenDimensions.width,
                          padding: EdgeInsets.all(10.0,),
                          child: Text(
                            "Assignments",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 20.0, 
                              color: theme.textColor
                            ),
                          ),
                        ),
                        FutureBuilder(
                          future: makeAssignmentsColumn(course.id.id, screenDimensions.width, theme),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
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
                        Container(
                          width: screenDimensions.width,
                          padding: EdgeInsets.only(top: 5.0, right: 10.0),
                          child: Text(
                            "Add Assignment...",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 15.0,
                              fontStyle: FontStyle.italic
                            ),
                          )
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: screenDimensions.width,
                          padding: EdgeInsets.all(10.0,),
                          child: Text(
                            "Notes",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 18.0,
                              color: theme.textColor
                            ),
                          ),
                        ),
                        FutureBuilder(
                          future: makeNotesColumn(course.id.id, screenDimensions.width, theme),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
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
                  ),
                ],
              ),
            ),
           ],
         ),
       ),
    );
  }
}
class MakeNote extends StatefulWidget {
  final double screenWidth;
  Note note;
  final ThemeColor theme;
  final callBack;
  MakeNote(this.screenWidth, this.note, this.theme, this.callBack);
  _MakeNote createState() {
    return _MakeNote();
  }
}
class _MakeNote extends State<MakeNote> {
  Widget build(BuildContext context) {
    return Container(
      width: widget.screenWidth,
      height: 53.0,
      padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: Row(
      children: <Widget>[
        Checkbox(
          onChanged: (val) async {
            widget.note.completed = val;
            setState(() {
                            
            });
            await widget.callBack();
          },
          activeColor: Color(widget.theme.secondaryTheme[1]),
          value: widget.note.completed == true,
        ),
        Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.note.note != null ? widget.note.note : "",
                    style: TextStyle(
                      decoration: widget.note.completed == true ? TextDecoration.lineThrough : TextDecoration.none,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      color: widget.note.completed == false ? widget.theme.mainTheme == 1 ? Colors.white : Colors.black : Colors.grey,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[

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
            onChanged: (val) async {
              widget.assignment.completed = val;
              setState(() {
                              
              });
              await widget.callBack();
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


