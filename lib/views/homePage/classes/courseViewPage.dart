import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:experiments/views/notes/notesPage.dart';
import 'package:experiments/components/userStorage.dart';
import 'package:experiments/components/universalClasses.dart';

Map classIcons = {
  "science": [MdiIcons.beaker, Colors.green[300]],
  "math": [MdiIcons.calculator, Colors.blue[300]],
  "socials": [MdiIcons.map, Colors.yellow[300]],
  "english": [MdiIcons.bookOpenPageVariant, Colors.red[300]],
  "language": [MdiIcons.bookOpenPageVariant, Colors.red[300]],
  "french": [MdiIcons.bookOpenPageVariant, Colors.red[300]],
  "auto": [MdiIcons.car, Colors.grey],
  "accounting": [MdiIcons.office, Colors.purple[300]],
  "other": [MdiIcons.cloudQuestion, Colors.white],
};

Future returnCourseById(String ids) async {
  UserStorage storage = new UserStorage();
  Map courseData = await storage.readUserData("coursesData.json");
  List courseList = courseData["courses"];
  for (var i = 0; i < courseList.length; i++) {
    if (courseList[i]["_id"] == ids) {
      return courseList[i]  ;
    }
  }
  return {};
}



class MakeCourseBlock extends StatelessWidget {

  final Course course;
  final ScheduleTime time;
  final double screenWidth;
  final bool isLast;
  final ThemeColor theme;
  MakeCourseBlock(this.course, this.time, this.screenWidth, this.isLast, this.theme);

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (course.id.id != "_") {  
          final newCourse = await CourseManipulation.retrieveCourseById(course.id);
          if (newCourse.id.equalsID(course.id)) {
            NoteInfo info = NoteInfo(newCourse, theme);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotesPage(info)),
            );
          } else {

          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.blockBack,
        ),
        width: screenWidth,
        child: Row(
          children: <Widget>[
           SchoolIcons.makeBlock(course.category),
            Container(
              width: screenWidth - 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                border: isLast ? Border(bottom: BorderSide(width: 1.0, color: theme.border)) : Border(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          course.course,
                          style: TextStyle(
                            fontSize: 18.0,
                            color: theme.textColor,
                          ),
                        ),
                        Text(
                          course.teacher,
                          style: TextStyle(
                            fontSize: 10.0,
                            color: Color.fromARGB(255, 150, 150, 150),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(right: 5.0),
                        child: Text(
                          time.toString(),
                          style: TextStyle(
                            fontSize: 18.0,
                            color: theme.textColor,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: !course.isReal ? Color.fromARGB(0, 0, 0, 0): Color(theme.secondaryTheme[1]),
                      ),
                    ],
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



class CourseViewPage extends StatelessWidget {
  
  final List<DayBlock> courses;
  final screenDimensions;
  final ThemeColor configData;
  CourseViewPage(this.courses, this.screenDimensions, this.configData);

  Widget build(BuildContext context) {
    
    List<Widget> courseBlocks = new List<Widget>();
    for (var i = 0; i < courses.length; i++) {
      courseBlocks.add(MakeCourseBlock(courses[i].course, courses[i].time, screenDimensions.width, i < courses.length-1, configData));
    }
    
    return Container(
      height: screenDimensions.height - 70.0,
      color: configData.bodyBack,
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: ListView(
        scrollDirection: Axis.vertical,
        physics: ClampingScrollPhysics(),
        children: <Widget>[
          Column(
            children: <Widget>[
              GestureDetector(
                onTap:() async {
                  Navigator.of(context).pushNamed("/courses");
                },
                child: Text(
                  "Today",
                  style: TextStyle(
                    fontSize: 29.0,
                    color: configData.textColor,
                    fontWeight: FontWeight.w100,
                  )
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(width: 1.0, color: configData.border),bottom: BorderSide(width: 1.0, color: configData.border)),
                ),
                child: Column(  
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: courseBlocks
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


