import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:experiments/components/appBar.dart';
import 'package:experiments/components/universalClasses.dart';
import 'package:experiments/components/userStorage.dart';
import 'package:experiments/components/notesRetrieval.dart';
import 'package:intl/intl.dart';

class MakeNoteImage extends StatelessWidget {
  final String url;
  final bool darkTheme;
  MakeNoteImage(this.url, this.darkTheme);
  Widget build(BuildContext context) {
    return Container(
      width: 100.0,
      margin: EdgeInsets.only(top: 20.0),
      child: FadeInImage.assetNetwork(
        placeholder: darkTheme ? 'images/eclipseWhite.gif' : 'images/eclipse.gif',
        width: 100.0,
        image: "https://www.pvstudents.ca/public/notesImages/$url",
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
              widget.callBack();
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

Future<Widget> compileNotes(MongoId id, double screenWidth, ThemeColor theme) async {
  await Notes.retrieveFromServer(id);
  List<Note> allNotesList = await Notes.retrieveNotes(id);
  allNotesList.sort((a,b) {
    return b.dateSubmitted.millisecondsSinceEpoch.compareTo(a.dateSubmitted.millisecondsSinceEpoch);
  });
  List<Widget> notesWidgets = new List<Widget>();
  List<Widget> imageLinks = new List<Widget>();
  List<Widget> finalList = new List<Widget>();
  DateTime currentDate = DateTime.now();
  if (allNotesList.length != 0) {
    currentDate = allNotesList[0].dateSubmitted;
  }
  DateFormat formatter = new DateFormat('MMMM dd, yyyy');
  for (var i = 0; i < allNotesList.length; i++) {
    if (!(allNotesList[i].dateSubmitted.year == currentDate.year && allNotesList[i].dateSubmitted.month == currentDate.month && allNotesList[i].dateSubmitted.day == currentDate.day)) {
      finalList.add(Column(
        children: <Widget>[
          
          Container(
            width: screenWidth,
            margin: EdgeInsets.only(top: 10.0),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: 1.0, color: theme.border)),
            ),
            child: Text(
              formatter.format(currentDate),
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 20.0,
                color: theme.textColor,
              ),
            ),

          ),
          Column(
            children: List.from(imageLinks)..addAll(notesWidgets.reversed)
          ),
        ],
      ));
      notesWidgets = List<Widget>();
      imageLinks = List<Widget>();
      currentDate = allNotesList[i].dateSubmitted;
    }
    if (allNotesList[i].noteType == "text") {
      notesWidgets.add(MakeNote(screenWidth, allNotesList[i], theme, () async {
        UserStorage storage = new UserStorage();
        storage.writeIdData(allNotesList, "retrievedNotes${id.id}.json");
      }));
    } else {
      imageLinks.add(
        MakeNoteImage(allNotesList[i].note, theme.mainTheme == 1)
      );
    }
  }
  return Column(
    children: finalList ,
  );
}

class AllNotesPage extends StatelessWidget {
  final AllNotesInfo notesInfo;
  AllNotesPage(this.notesInfo);
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
        color: notesInfo.themeData.bodyBack,
        child: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Text(
              notesInfo.courses[i].course,
            ),
            FutureBuilder(
              future: compileNotes(notesInfo.courses[i].id, screenDimensions.width, notesInfo.themeData),
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
                "Notes",
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