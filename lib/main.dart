import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/animation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:cupertino_icons/cupertino_icons.dart';



schoolFromObject(Map school) {
  return {
    "blockOrder": school["blockOrder"],
    "name": school["name"],
    "categories": school["categories"],
    "constantBlocks": school["constantBlocks"],
    "constantBlockSchedule": school["constantBlockSchedule"],
    "spareName": school["spareName"],
    "blockNames": school["blockNames"],
  };
}
coursesFromObject(List courses) {
  return {"courses": courses};
}
eventsFromObject(List events) {
  List dayRolled = new List();
  List schoolSkipped = new List();
  for (var i = 0; i < events.length; i++) {
    if (events[i]["dayRolled"] == true) {
      dayRolled.add(events[i]);
      schoolSkipped.add(events[i]);
    } else if (events[i]["schoolSkipped"] == true) {
      schoolSkipped.add(events[i]);
    }
  }
  dayRolled.sort((a,b) {
    return DateTime.parse(a["date"]).millisecondsSinceEpoch.compareTo(DateTime.parse(b["date"]).millisecondsSinceEpoch);
  });
  schoolSkipped.sort((a,b) {
    return DateTime.parse(a["date"]).millisecondsSinceEpoch.compareTo(DateTime.parse(b["date"]).millisecondsSinceEpoch);
  });
  return {"events": events, "rolledDays" : dayRolled, "schoolSkipped" : schoolSkipped};
}

List<List<dynamic>> colourThemes = [["Coquelicot", 0xffff3800, "Sure red is cool, but you're cooler"], ["Smaragdine", 0xff50c875, "Grass is fun"], ["Mikado", 0xffffc40c, "For when normal yellow is too intimidating"], ["Glaucous", 0xff6082b6, "Cloudy days"], ["Wenge", 0xff645452, "Not quite black"], ["Fulvous", 0xffe48400, "Socials binder from grade 5"], ["Amaranth", 0xffe52b50, "Very pretty, very nice"]];
Future<Map<String, dynamic>> compileAllHomeInfo(storage) async {
  List<List<String>> dayBlocks = await getDayBlocks(storage);
  List<List<String>> currentNext = await currentNextBlock(storage);
  Map events = await getAllEvents(storage);
  Map school = await storage._readUserData("schoolData.json");
  Map userData = await storage._readUserData("userData.json");
  Map courseData = await storage._readUserData("coursesData.json");
  Map configData = {"mainTheme": 1, "secondaryTheme": [0, 0xffff3800]};
  Map configDataMap = await storage._readUserData("configData.json");
  if (configDataMap["mainTheme"] != null && configDataMap["secondaryTheme"] != null) {
    configData = configDataMap;
  }
  List<Map> courses;
  if(courseData["courses"] != null && userData["courses"] != null) {
    courses = returnCoursesById(courseData["courses"], userData["courses"]);
  } else {
    courses = [];
  }
  Map courseMap = returnCourseBlockMap(courses, {}, school["blockNames"]);
  return {
    "dayBlocks": dayBlocks,
    "currentNext": currentNext,
    "events": events["events"] != null ? events["events"] : [],
    "rolledDays": events["rolledDays"] != null ? events["rolledDays"] : [],
    "schoolSkipped": events["schoolSkipped"] != null ? events["schoolSkipped"] : [],
    "readableCourseMap": makeReadableSchedule(courseMap, school),
    "config": configData,
  };
}

Future<Map<String, dynamic>> compileCourseSelectInfo(storage) async {
  List<Map> courses;
  Map userData = await storage._readUserData("userData.json");
  Map courseData = await storage._readUserData("coursesData.json");
  Map schoolData = await storage._readUserData("schoolData.json");
  Map configData = {"mainTheme": 1, "secondaryTheme": [0, 0xffff3800]};
  Map configDataMap = await storage._readUserData("configData.json");
  if (configDataMap["mainTheme"] != null && configDataMap["secondaryTheme"] != null) {
    configData = configDataMap;
  }
  if(courseData["courses"] != null && userData["courses"] != null) {
    courses = returnCoursesById(courseData["courses"], userData["courses"]);
  } else {
    courses = [];
  }
  Map courseMap = returnCourseBlockMap(courses, {}, schoolData["blockNames"]);
  return {
    "courses": courseMap,
    "courseMap": userData["courses"],
    "courseData": courseData["courses"],
    "blockNames": schoolData["blockNames"],
    "config": configData,
  };
}

Map<String, dynamic> returnCourseBlockMap(List courses, Map userCourseNames, List allBlocks) {
  
  Map<String, dynamic> returnObject = new Map<String, dynamic>();
  for (var i = 0; i < allBlocks.length; i++) {
    if (allBlocks[i][1] == "changing") {
      returnObject[allBlocks[i][0]] = {"course": "LC's", "teacher": "", "block": allBlocks[i][0]};
    } else {
      returnObject[allBlocks[i][0]] = {"course": allBlocks[i][0], "teacher": "", "block": allBlocks[i][0]};
    }
  }
  for (var i = 0; i < courses.length; i++) {
    returnObject[courses[i]["block"]] = courses[i];
  }
  userCourseNames.forEach((k, v) {
    returnObject[k]["course"] = v;
  });
  return returnObject;
}

List<Map> returnCoursesById(List courses, Map ids) {
  List<Map> returnList = new List<Map>();
  for (var i = 0; i < courses.length; i++) {
    ids.forEach((k, v) {
      if (courses[i]["_id"] == v) {
        returnList.add(courses[i]);
      }
    });
  }
  return returnList;
}

Future<Map> courseMapFromList(List courses, List ids) async {
  Map returnList = new Map();
  for (var i = 0; i < courses.length; i++) {
    for (var j = 0; j < ids.length; j++) {
      if (courses[i]["_id"] == ids[j]) {
        returnList[courses[i]["block"]] = ids[i];
      }
    }
  }
  return returnList;
}

Future<Map> fetchFromServer(schoolId, username, password) async {
  final response = await http.get('http://localhost:15651/UserInfo?schoolId=$schoolId&username=$username&password=$password');
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    return {};
  }
}

Future<void> updateInfo() async {
  Map serverObject = await fetchFromServer("5b9dc8db4f05f3c638ac0147", "AidanEglin", "AidanEglin2002school");
  Map schoolObject = schoolFromObject(serverObject["school"]);
  Map coursesObject = coursesFromObject(serverObject["courses"]);
  Map eventsObject = eventsFromObject(serverObject["events"]);
  UserStorage storage = new UserStorage();
  await storage._writeUserData(schoolObject, "schoolData.json");
  await storage._writeUserData(coursesObject, "coursesData.json");
  await storage._writeUserData(eventsObject, "eventsData.json");
  await storage._writeUserData({"mainTheme": "dark", "secondaryTheme": [0, 0xffff3800]}, "configData.json");
}

Future<List> fetchSchoolList() async {
  final response = await http.get('http://localhost:15651/schoolList');
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    return [];
  }
}


Future<Map> compileAllConfigureInfo(storage) async {
  Map userData = await storage._readUserData("userData.json");
  Map courseData = await storage._readUserData("coursesData.json");
  List<Map> courses;
  Map configData = {"mainTheme": 1, "secondaryTheme": [0, 0xffff3800]};;
  Map configDataMap = await storage._readUserData("configData.json");
  if (configDataMap["mainTheme"] != null && configDataMap["secondaryTheme"] != null) {
    configData = configDataMap;
  }
  if(courseData["courses"] != null && userData["courses"] != null) {
    courses = returnCoursesById(courseData["courses"], userData["courses"]);
  } else {
    courses = [];
  }
  return {"courses": courses, "config": configData};
}

class UserStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  Future<File> _localFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }
  Future<Map> _readUserData(String fileName) async {
    try {
      final userInfo = await _localFile(fileName);
      String stringifiedData = await userInfo.readAsString();
      Map decodedData = json.decode(stringifiedData);
      return decodedData;
    } catch (e) {
      return ({});
    }
  }
  Future<File> _writeUserData(Map data, String fileName) async {
    final userInfo = await _localFile(fileName);
    try {
      String stringifiedData = await userInfo.readAsString();
      Map decodedData = json.decode(stringifiedData);
      data.forEach((k, v) {
        decodedData[k] = v;
      });
      return userInfo.writeAsString(json.encode(decodedData));
      // return userInfo.writeAsString(json.encode({}));
    } catch (e) {
      return userInfo.writeAsString(json.encode(data));
    }
  }
}

final ThemeData kIOSTheme = new ThemeData(
  fontFamily: "SF-PRO",
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = new ThemeData(
  fontFamily: "SF-PRO",
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);

String blockArrayToTime(List<dynamic> timeArray) {
  String timeString = "";
  timeString += ((timeArray[0]-1)%12+1).toString();
  timeString += ":";
  timeString += (timeArray[1].toString().length == 1 ? "0" + timeArray[1].toString() : timeArray[1].toString());
  timeString += " - ";
  timeString += ((timeArray[2]-1)%12+1).toString();
  timeString += ":";
  timeString += (timeArray[3].toString().length == 1 ? "0" + timeArray[3].toString() : timeArray[3].toString());
  return timeString;
}

Future<List<List<String>>> getDayBlocks(UserStorage storage) async {
  final int currentDay = 1;
  final int currentWeek = 1;
  final UserStorage storage = new UserStorage();
  Map school = await storage._readUserData("schoolData.json");
  Map userData = await storage._readUserData("userData.json");
  Map courseData = await storage._readUserData("coursesData.json");
  List<Map> courses;
  if(courseData["courses"] != null && userData["courses"] != null) {
    courses = returnCoursesById(courseData["courses"], userData["courses"]);
  } else {
    courses = [];
  }
  Map courseMap = returnCourseBlockMap(courses, {}, school["blockNames"]);
  List<List<String>> dayBlocks = new List<List<String>>();
  if (school["constantBlocks"]) {
    final List blockTimes = school["constantBlockSchedule"]["blockSchedule"];
    final List blockSchedule = school["constantBlockSchedule"]["schedule"];
    final Map currentWeekSchedule = blockSchedule[currentWeek-1];
    final List currentDaySchedule = currentWeekSchedule["day" + currentDay.toString()];
    for (var i = 0; i < currentDaySchedule.length; i++) {
      String nameString;
      String teacher;
      String category;
      if (currentDaySchedule[i][1] == "changing") {
        nameString = courseMap[currentDaySchedule[i][0]]["course"];
        teacher = courseMap[currentDaySchedule[i][0]]["teacher"];
        category = courseMap[currentDaySchedule[i][0]]["category"];
      } else {
        nameString = currentDaySchedule[i][0];
        teacher = "";
        category = "other";
      }
      dayBlocks.add([blockArrayToTime(blockTimes[i]), nameString, teacher, category]);
    }
  } else {
    List blockSchedule = school["blockOrder"];
    final Map currentWeekSchedule = blockSchedule[currentWeek-1];
    final List currentDaySchedule = currentWeekSchedule["day" + currentDay.toString()];   
    for (var i = 0; i < currentDaySchedule.length; i++) {
      String nameString;
      String teacher;
      String category;
      if (currentDaySchedule[i][1] == "changing") {
        nameString = courseMap[currentDaySchedule[i][0]]["course"];
        teacher = courseMap[currentDaySchedule[i][0]]["teacher"];
        category = courseMap[currentDaySchedule[i][0]]["category"];
      } else {
        nameString = currentDaySchedule[i][0];
        teacher = "";
        category = "";
      }
      dayBlocks.add([blockArrayToTime(currentDaySchedule[i].sublist(1,5)), nameString, teacher, category]);
    }
  }
  return dayBlocks;
}

List<Map<String, List>> makeReadableSchedule(Map<String, dynamic> courseBlockMap, Map school) {
  //format is: Array[all the schedules as objects]; schedules: {keys are days, values are arrays containing arrays of the blocks in format [Name, start hour, start minute, end hour, end minute, block]};
  List<Map<String, List>> readableSchedule = new List<Map<String, List>>();
  if (school["constantBlocks"]) {
    final List blockTimes = school["constantBlockSchedule"]["blockSchedule"];
    final List blockSchedule = school["constantBlockSchedule"]["schedule"];
    for (var i = 0; i < blockSchedule.length; i++) {
      Map<String, List> weekSchedule = Map<String, List>();
      blockSchedule[i].forEach((k,v) {
        List<List> currentDay = List<List>();
        for (var j = 0; j < blockSchedule[i][k].length; j++) {
          if (blockSchedule[i][k][j][1] == "constant") {
            currentDay.add([blockSchedule[i][k][j][0], blockTimes[j][0], blockTimes[j][1], blockTimes[j][2], blockTimes[j][3], ""]);
          } else {
            currentDay.add([courseBlockMap[blockSchedule[i][k][j][0]]["course"], blockTimes[j][0], blockTimes[j][1], blockTimes[j][2], blockTimes[j][3], courseBlockMap[blockSchedule[i][k][j][0]]["teacher"]]);
          }
        }
        weekSchedule[k] = currentDay;
      });
      readableSchedule.add(weekSchedule);
    }
  } else {
    List blockSchedule = school["blockOrder"];
    for (var i = 0; i < blockSchedule.length; i++) {
      Map<String, List> weekSchedule = Map<String, List>();
      blockSchedule[i].forEach((k,v) {
        List<List> currentDay = List<List>();
        for (var j = 0; j < blockSchedule[i][k].length; j++) {
          if (blockSchedule[i][k][j][1] == "constant") {
            currentDay.add([blockSchedule[i][k][j][0], blockSchedule[i][k][j][1], blockSchedule[i][k][j][2], blockSchedule[i][k][j][3], blockSchedule[i][k][j][0]]);
          } else {
            currentDay.add([courseBlockMap[blockSchedule[i][k][j][0]]["course"], blockSchedule[i][k][j][1], blockSchedule[i][k][j][2], blockSchedule[i][k][j][3], blockSchedule[i][k][j][0]]);
          }
        }
        weekSchedule[k] = currentDay;
      });
      readableSchedule.add(weekSchedule);
    }
  }
  return readableSchedule;
}

Future<List<List<String>>> currentNextBlock(UserStorage storage) async {
  DateTime currentTime = DateTime.now();
  final int currentDay = 1;
  final int currentWeek = 1;
  final UserStorage storage = new UserStorage();
  Map school = await storage._readUserData("schoolData.json");
  Map userData = await storage._readUserData("userData.json");
  Map courseData = await storage._readUserData("coursesData.json");
  List<Map> courses;
  if(courseData["courses"] != null && userData["courses"] != null) {
    courses = returnCoursesById(courseData["courses"], userData["courses"]);
  } else {
    courses = [];
  }
  Map courseMap = returnCourseBlockMap(courses, {}, school["blockNames"]);
  List<List<String>> currentAndNext = [[], []];
  if (school["constantBlocks"] == true) {
    final List blockTimes = school["constantBlockSchedule"]["blockSchedule"];
    final List blockSchedule = school["constantBlockSchedule"]["schedule"];
    final Map currentWeekSchedule = blockSchedule[currentWeek-1];
    final List currentDaySchedule = currentWeekSchedule["day" + currentDay.toString()];
    currentAndNext[0] = ["current", "Nothing!"];
    currentAndNext[1] = [blockArrayToTime(blockTimes[0]), currentDaySchedule[0][1] == "changing" ? courseMap[currentDaySchedule[0][0]]["course"] : currentDaySchedule[0][0]];
    for (var i = blockTimes.length-1; i >= 0; i--) {
      final sumEndTime = blockTimes[i][2]*60+blockTimes[i][3];
      if ((currentTime.hour*60 + currentTime.minute) > sumEndTime) {
        if (i >= blockTimes.length-1) {
          currentAndNext[0] = ["current", "Nothing!"];
          currentAndNext[1] = ["next", "Nothing!"];
        } else if (i == blockTimes.length-2) {
          currentAndNext[0] = [blockArrayToTime(blockTimes[i+1]), currentDaySchedule[i][1] == "changing" ? courseMap[currentDaySchedule[i][0]]["course"] : currentDaySchedule[i][0]];
          currentAndNext[1] = ["next", "Nothing!"];
        } else {
          currentAndNext[0] = [blockArrayToTime(blockTimes[i+1]), currentDaySchedule[i][1] == "changing" ? courseMap[currentDaySchedule[i][0]]["course"] : currentDaySchedule[i][0]];
          currentAndNext[0] = [blockArrayToTime(blockTimes[i+2]), currentDaySchedule[i][1] == "changing" ? courseMap[currentDaySchedule[i][0]]["course"] : currentDaySchedule[i][0]];
        }
        break;
      }
    }
  } else {
    List blockSchedule = school["blockOrder"];
    final Map currentWeekSchedule = blockSchedule[currentWeek-1];
    final List currentDaySchedule = currentWeekSchedule["day" + currentDay.toString()];   
    currentAndNext[0] = ["", "Nothing!"];
    currentAndNext[1] = [blockArrayToTime(currentDaySchedule[0].sublist(1,5)), currentDaySchedule[0][5] == "changing" ? courseMap[currentDaySchedule[0][0]]["course"] : currentDaySchedule[0][0]];
    for (var i = 0; i < currentDaySchedule.length; i++) {
      final sumEndTime = currentDaySchedule[i][3]*60+currentDaySchedule[i][4];
      if ((currentTime.hour*60 + currentTime.minute) > sumEndTime) {
        if (i >= currentDaySchedule.length-1) {
          currentAndNext[0] = ["", "Nothing!"];
          currentAndNext[1] = ["", "Nothing!"];
        } else if (i == currentDaySchedule.length-2) {
          currentAndNext[0] = [blockArrayToTime(currentDaySchedule[i+1].sublist(1,5)), currentDaySchedule[i][4] == "changing" ? courseMap[currentDaySchedule[i][0]]["course"] : currentDaySchedule[i][0]];
          currentAndNext[1] = ["", "Nothing!"];
        } else {
          currentAndNext[0] = [blockArrayToTime(currentDaySchedule[i+1].sublist(1,5)), currentDaySchedule[i][4] == "changing" ? courseMap[currentDaySchedule[i][0]]["course"] : currentDaySchedule[i][0]];
          currentAndNext[0] = [blockArrayToTime(currentDaySchedule[i+2].sublist(1,5)), currentDaySchedule[i][4] == "changing" ? courseMap[currentDaySchedule[i][0]]["course"] : currentDaySchedule[i][0]];
        }
        break;
      }
    }
  }
  return currentAndNext;
}

Future<Map> getAllEvents(UserStorage storage) async {
  Map events = await storage._readUserData("eventsData.json");
  return events;
}


void  main() async {
  final UserStorage storage = new UserStorage();
  Map userData = await storage._readUserData("userData.json");
  Map courseData = await storage._readUserData("coursesData.json");
  List<Map> courses;
  if(courseData["courses"] != null && userData["courses"] != null) {
    courses = returnCoursesById(courseData["courses"], userData["courses"]);
  } else {
    courses = [];
  }
  Map<String, dynamic> homeInfo = await compileAllHomeInfo(storage);
  runApp(MyApp(storage, homeInfo, courses, courseData["courses"]));
}


class MyApp extends StatelessWidget {
  final UserStorage storage;
  final Map<String, dynamic> homeInfo;
  final List<Map> courses;
  final courseData;
  MyApp(this.storage, this.homeInfo, this.courses, this.courseData);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Test",
      theme: Theme.of(context).platform == TargetPlatform.iOS ? kIOSTheme : kDefaultTheme,
      initialRoute: "/",
      routes: <String, WidgetBuilder> {
        '/': (BuildContext context) {
          return FutureBuilder(
            future: compileAllHomeInfo(storage),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return HomePage(snapshot.data);
              } else if (snapshot.hasError) {
                return HomePage(homeInfo);
              } else {
                return CircularProgressIndicator();
              }
            },
          );
        },
        "/login": (BuildContext context) {
          return FutureBuilder(
            future: fetchSchoolList(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return LoginPage(snapshot.data);
              } else if (snapshot.hasError) {
                return LoginPage([]);
              } else {
                return CircularProgressIndicator();
              }
            },
          );
        },
        "/configure": (BuildContext context) {
          return FutureBuilder(
            future: compileAllConfigureInfo(storage),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ConfigurePage(snapshot.data);
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return ConfigurePage({"courses": []});
              } else {
                return CircularProgressIndicator();
              }
            },
          );
        },
        "/courses": (BuildContext context) {
          return FutureBuilder(
            future: compileCourseSelectInfo(storage),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SelectCourses(snapshot.data);
              } else if (snapshot.hasError) {
                return SelectCourses({"courses" : courses});
              } else {
                return CircularProgressIndicator();
              }
            }
          );
        },
        "/account": (BuildContext context) {
          return AccountPage();
        }
      }
    );
  }
}

const double _kPickerSheetHeight = 216.0;
const double _kPickerItemHeight = 32.0;

Map classIcons = {
  "science": [MdiIcons.beaker, Colors.green[300]],
  "math": [MdiIcons.calculator, Colors.blue[300]],
  "socials": [MdiIcons.map, Colors.yellow[300]],
  "english": [MdiIcons.book, Colors.red[300]],
  "auto": [MdiIcons.car, Colors.grey],
  "accounting": [MdiIcons.office, Colors.purple[300]],
  "other": [MdiIcons.cloudQuestion, Colors.white],
};


class ColoursPick extends StatefulWidget {
  double screenWidth;
  int selectedColor;
  ColoursPick(this.screenWidth, this.selectedColor);
  _ColoursPick createState() => _ColoursPick();
}
class _ColoursPick extends State<ColoursPick>{
  
  Widget build(BuildContext context) {
    List<Widget> colourThemeWidgets = new List<Widget>();
    Widget checkMark = Container(
      margin: EdgeInsets.only(right: 5.0),
      width: 25.0,
      height: 50.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Icon(
            Icons.check,
            size: 20.0,
            color: Colors.blue,
          ),
        ],
      ),
    );
    for (var i = 0; i < colourThemes.length; i++) {
      colourThemeWidgets.add(
        GestureDetector(
          onTap: () {
            widget.selectedColor = i;
            setState(() {
                          
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 20, 20, 20),
            ),
            width: widget.screenWidth,
            child: Row(
              children: <Widget>[
                Container(
                  width: 30.0,
                  height: 30.0, 
                  margin: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Color(colourThemes[i][1]),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                ),
                Container(
                  width: widget.screenWidth - 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    border: i != colourThemes.length-1 ? Border(bottom: BorderSide(color: Colors.grey, width: 1.0)) : Border(),
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
                              colourThemes[i][0],
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              colourThemes[i][2],
                              style: TextStyle(
                                fontSize: 10.0,
                                color: Color.fromARGB(255, 150, 150, 150),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      (i == widget.selectedColor ? checkMark : Container()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 1.0), bottom: BorderSide(color: Colors.grey, width: 1.0)),
      ),
      child: Column(
        children: colourThemeWidgets,
      ),
    );
  }
}

class CoursesCorrect extends StatefulWidget {
  double screenWidth;
  List courses;
  CoursesCorrect(this.courses, this.screenWidth);
  _CoursesCorrect createState() => _CoursesCorrect();
}

class _CoursesCorrect extends State<CoursesCorrect> {
  Widget build(BuildContext context) {
    List<Widget> displayedCourses = new List<Widget>();
    for (var i = 0; i < widget.courses.length; i++) {
      displayedCourses.add(Container(
        height: 50.0,
        width: widget.screenWidth,
        color: Color.fromARGB(255, 20, 20, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 50.0,
              height: 50.0,
            ),
            Container(
              width: widget.screenWidth-50.0,
              height: 50.0,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.courses[i]["course"],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    )
                  ),
                  Text(
                    widget.courses[i]["teacher"] + ", block " + widget.courses[i]["block"],
                    style: TextStyle(
                      color: Color.fromARGB(255, 150, 150, 150),
                      fontSize: 12.0,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ));
    }
    displayedCourses.add(GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/courses");
      },
      child:Container(
        height: 50.0,
        width: widget.screenWidth,
        color: Color.fromARGB(255, 20, 20, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 50.0,
              height: 50.0,
            ),
            Container(
              width: widget.screenWidth-50.0,
              height: 50.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Edit Courses",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                  Container(
                    child: Icon(
                      Icons.chevron_right,
                      size: 30.0,
                      color: Colors.blue,
                    ),
                    margin: EdgeInsets.only(right: 5.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
    return Container(
      margin: EdgeInsets.only(top: 30.0),
      child: Column(
        children: <Widget>[
          Text(
            "Courses",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            )
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey, width: 1.0), bottom: BorderSide(color: Colors.grey, width: 1.0)),
            ),
            child: Column(
              children: displayedCourses,
            ),
          ),
        ],
      ),
    );
  }
}

class ThemePicker extends StatefulWidget {
  int lightOrDark;
  ThemePicker(this.lightOrDark);
  _ThemePicker createState() => _ThemePicker();
}

class _ThemePicker extends State<ThemePicker> {
  Widget build(BuildContext context) {
    return Container(
      width: 120.0,
      child: CupertinoSegmentedControl(
        onValueChanged: (value) {
          widget.lightOrDark = value;
          setState(() {
            
          });
        },
        groupValue: widget.lightOrDark,
        children: <dynamic, Widget>{
          0: Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Text("Light"),
          ),
          1: Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Text("Dark"),
          ),
        },
      ),
    );
  }
}

class ConfigurePage extends StatelessWidget {
  Map configData;
  ConfigurePage(this.configData);
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;
    ColoursPick colourPickPage = ColoursPick(screenDimensions.width, configData["config"]["secondaryTheme"][0]);
    ThemePicker themePickPage = ThemePicker(configData["config"]["mainTheme"]);
    return Scaffold(
      body: Container(
        width: screenDimensions.width,
        height: screenDimensions.height,
        color: Colors.black,
        padding: EdgeInsets.only(top: 20.0),
        child: ListView(
          children: <Widget>[
            Center(
              child: Text(
                "Theme",
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
            ),
            themePickPage,
            colourPickPage,
            CoursesCorrect(configData["courses"], screenDimensions.width),
            Container(
              margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Center(
                child: Material(
                  color: Color.fromARGB(255, 20, 20, 20),
                  child: InkWell(
                    onTap: () async {
                      Map newColoursObject = {
                        "mainTheme": themePickPage.lightOrDark,
                        "secondaryTheme": [colourPickPage.selectedColor, colourThemes[colourPickPage.selectedColor][1]],
                      };
                      UserStorage storage = new UserStorage();
                      await storage._writeUserData(newColoursObject, "configData.json");
                      Navigator.pushNamedAndRemoveUntil(context,"/", (_) => false);
                    },
                    child: Container(
                      width:85.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        border: Border.all(color: Colors.blue, width: 1.0),
                        
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Ok",
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class FormLogin extends StatefulWidget {
  double screenWidth;
  List schoolList;
  FormLogin(this.screenWidth, this.schoolList);
  _FormLogin createState() => _FormLogin();
}

class _FormLogin extends State<FormLogin> {
  String _username;
  String _password;
  dynamic _school;

  Widget _buildBottomPicker(Widget picker) {
    return Container(
      height: _kPickerSheetHeight,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }
  int _selectedSchoolIndex = 0;
  List schoolNames;
  @override
  initState() {
    schoolNames = widget.schoolList;   
  }
  Widget _buildMenu(List<Widget> children) {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      decoration: const BoxDecoration(
        
      ),
      height: 44.0,
      child: SafeArea(
        top: false,
        bottom: false,
        child: DefaultTextStyle(
          style: const TextStyle(
            letterSpacing: -0.24,
            fontSize: 17.0,
            color: CupertinoColors.black,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          ),
        ),
      ),
      
    );
  }

  Widget _buildSchoolPicker(BuildContext context) {
    final FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: _selectedSchoolIndex);
    _school = schoolNames[_selectedSchoolIndex];
    return GestureDetector(
      onTap: () async {
        await showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) {
            return _buildBottomPicker(
              CupertinoPicker(
                scrollController: scrollController,
                itemExtent: _kPickerItemHeight,
                backgroundColor: CupertinoColors.white,
                onSelectedItemChanged: (int index) {
                  setState(() => _selectedSchoolIndex = index);
                  _school = schoolNames[_selectedSchoolIndex];
                },
                children: List<Widget>.generate(schoolNames.length, (int index) {
                  return Center(child:
                    Text(
                      '${schoolNames[index]["name"]}${schoolNames[index]["district"] != null ? " (" + schoolNames[index]["district"] + ")" : ""}'
                    ),
                  );
                }),
              ),
            );
          },
        );
      },
      child: _buildMenu(
        <Widget>[
          Icon(Icons.school),
          Text(
            '${schoolNames[_selectedSchoolIndex]["name"]}',
            style: const TextStyle(
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  String validateUsername(String value) {
    RegExp userMatcher = RegExp(
      "^[a-zA-Z0-9]+([_ -]?[a-zA-Z0-9])",
    );
    if (userMatcher.hasMatch(value)) {
      return null;
    } else {
      return "Please enter a valid username";
    }
  }
  String validatePassword(String value) {
    RegExp passMatcher = RegExp(
      "^[a-zA-Z0-9]+([_ -]?[a-zA-Z0-9])",
    );
    if (passMatcher.hasMatch(value)) {
      return null;
    } else {
      return "Please enter a valid password";
    }
  }
  Widget build(BuildContext context) {
    return Container(
      width: widget.screenWidth * 0.9,
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              keyboardType: TextInputType.text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
              decoration: InputDecoration(
                icon: Icon(Icons.person_outline),
                hintText: "Username",
                errorStyle: TextStyle(
                  color: Colors.yellow,
                ),
                hintStyle: TextStyle(
                  // fontSize: 22.0,
                  // color: Colors.white,
                ),
              ),
              validator: validateUsername,
              onSaved: (val) {
                _username = val;
              },
            ),
            TextFormField(
              obscureText: true,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
              decoration: InputDecoration(
                icon: Icon(Icons.lock_outline),
                hintText: "Password",
                errorStyle: TextStyle(
                  color: Colors.yellow,
                ),
                hintStyle: TextStyle(
                  // fontSize: 22.0,
                  // color: Colors.white,
                ),
              ),
              validator: validatePassword,
              onSaved: (val) {
                _password = val;
              },
            ),
            _buildSchoolPicker(context),
            GestureDetector(
              onTap: () async {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  Map userInfo  = await (fetchFromServer(_school["id"], _username, _password));
                  if (userInfo["user"] != null) {
                    Map userPass = {
                      "school": _school,
                      "username": _username,
                      "password": _password,
                    };
                    UserStorage storage = new UserStorage();
                    Map schoolObject = schoolFromObject(userInfo["school"]);
                    Map coursesObject = coursesFromObject(userInfo["courses"]);
                    Map eventsObject = eventsFromObject(userInfo["events"]);
                    Map courseIdObject = await courseMapFromList(coursesObject["courses"], userInfo["user"]["courses"]);
                    await storage._writeUserData(schoolObject, "schoolData.json");
                    await storage._writeUserData(coursesObject, "coursesData.json");
                    await storage._writeUserData(eventsObject, "eventsData.json");
                    await storage._writeUserData({"courses": courseIdObject}, "userData.json");
                    await storage._writeUserData((userPass), "userPass.json");
                    Navigator.pushNamedAndRemoveUntil(context,"/configure", (_) => false);
                  }
                }
              },
              child: Container(
                width: widget.screenWidth*0.95,
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                margin: EdgeInsets.only(top: 20.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [0.2, 1.0],
                    colors: [
                      Color.fromARGB(255, 0, 153, 153),
                      Color.fromARGB(255, 0, 130, 209),
                    ],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(7.0)),
                ),
                child: Center(
                  child: Text(
                    "LOGIN",
                    style: TextStyle(
                      fontSize: 22.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class LoginPage extends StatelessWidget {
  List schoolList;
  LoginPage(this.schoolList);
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: screenDimensions.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.2, 1.0],
            colors: [
              Color.fromARGB(255, 255, 102, 0),
              Color.fromARGB(255, 153, 0, 51),
            ],
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Image.asset(
                    "schoolrLogos/logo_transparent.png",
                    width: screenDimensions.width*0.5,
                  ),
                  FormLogin(screenDimensions.width, schoolList),
                ],
              ),
            ), 
          ],
        ),
      )
    );
  }
}

//Start of Homepage classes
class BoxView extends StatelessWidget {
  final String title;
  final String content;
  final double screenWidth;
  BoxView(this.title, this.content, this.screenWidth);
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontSize: 22.0,
            color: Colors.white,
            // color: Color.fromARGB(255, 229, 238, 193),
          ),
        ), 
        Container(
          width: screenWidth*0.85,
          margin: EdgeInsets.only(top: 10.0),
          child: Card(
            child: Container(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                decoration: BoxDecoration(
                border: Border.all(color: Color.fromARGB(255, 255, 149, 0), width: 2.0),
                color: Color.fromARGB(255, 20, 20, 20),
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                boxShadow: <BoxShadow>[
                  
                ],
              ),
              child: Center(
                child: Text(
                  content,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Color.fromARGB(255, 255, 149, 0),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]
    );
  }
}

class EventView extends StatelessWidget {
  final String title;
  final List<String>events;
  final double screenWidth;
  EventView(this.title, this.events, this.screenWidth);
  Widget build(BuildContext context) {
    List<Widget> eventWidgets = new List<Widget>();
    for (var i = 0; i < events.length; i++) {
      if (i == 0) {
        eventWidgets.add(
          Container(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            margin: EdgeInsets.only(top: 0.0, bottom: 5.0),
            decoration: BoxDecoration(
              border: Border.all(color: Color.fromARGB(255, 255, 149, 0), width: 2.0),
              color: Color.fromARGB(255, 20, 20, 20),
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              boxShadow: <BoxShadow>[
                
              ],
            ),
            child: Center(
              child: Text(
                events[i],
                style: TextStyle(
                  fontSize: 20.0,
                  color: Color.fromARGB(255, 255, 149, 0)
                ),
              ),
            ),
          ),
        );
      } else if (i == events.length-1) {
        eventWidgets.add(
          Container(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            margin: EdgeInsets.only(top: 5.0),
            decoration: BoxDecoration(
              border: Border.all(color: Color.fromARGB(255, 255, 149, 0), width: 2.0),
              color: Color.fromARGB(255, 20, 20, 20),
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              boxShadow: <BoxShadow>[
                
              ],
            ),
            child: Center(
              child: Text(
                events[i],
                style: TextStyle(
                  fontSize: 20.0,
                  color: Color.fromARGB(255, 255, 149, 0)
                ),
              ),
            ),
          ),
        );
      } else if (i == 0 && i == events.length-1) {
        eventWidgets.add(
          Container(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            margin: EdgeInsets.only(top: 0.0, bottom: 0.0),
            decoration: BoxDecoration(
              border: Border.all(color: Color.fromARGB(255, 255, 149, 0), width: 2.0),
              color: Color.fromARGB(255, 20, 20, 20),
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              boxShadow: <BoxShadow>[
                
              ],
            ),
            child: Center(
              child: Text(
                events[i],
                style: TextStyle(
                  fontSize: 20.0,
                  color: Color.fromARGB(255, 255, 149, 0)
                ),
              ),
            ),
          ),
        );
      } else {
        eventWidgets.add(
          Container(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
            decoration: BoxDecoration(
              border: Border.all(color: Color.fromARGB(255, 255, 149, 0), width: 2.0),
              color: Color.fromARGB(255, 20, 20, 20),
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              boxShadow: <BoxShadow>[
                
              ],
            ),
            child: Center(
              child: Text(
                events[i],
                style: TextStyle(
                  fontSize: 20.0,
                  color: Color.fromARGB(255, 255, 149, 0)
                ),
              ),
            ),
          ),
        );
      }
    }
    
    return Column(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontSize: 22.0,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        Container(
          height: 55.0,
          margin: EdgeInsets.only(top: 10.0),
          width: screenWidth*0.85,
          child: ListView(
            children: eventWidgets
          )
        )
      ]
    );
  }
}

class HomeViewPage extends StatelessWidget {
  final String day;
  final List<String> currentClassName;
  final List<String> nextClassName;
  final Map configData;
  final screenDimensions;
  HomeViewPage(this.day, this.currentClassName, this.nextClassName, this.configData, this.screenDimensions);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: configData["mainTheme"] == 1 ? Color.fromARGB(255, 0, 0, 0) : Color.fromARGB(255, 255, 255, 255),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text(
            'Day ' + day,
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 40.0,
            )
          ),
          EventView("Upcoming Events: ", ["idek man", "yeee i hate everything"], screenDimensions.width),
          BoxView("Current Class: ", '${currentClassName[0]} : ${currentClassName[1]}', screenDimensions.width),
          BoxView("Next Class: ", '${nextClassName[0]} : ${nextClassName[1]}', screenDimensions.width),
        ]
      )
    );
  }
}
//End of homepage classes


//Start of courses classes
class MakeIconBlock extends StatelessWidget {
  final dynamic icon;
  final Color color;
  MakeIconBlock(this.icon, this.color);
  Widget build(BuildContext context) {
    return Container(
      width: 30.0,
      height: 30.0,
      margin: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 20.0),
        ],
      ),
    );
  }
}

class MakeCourseBlock extends StatelessWidget {
  final String course;
  final String time;
  final String teacher;
  final String category;
  final double screenWidth;
  final bool isLast;
  final Map theme;
  MakeCourseBlock(this.course, this.time, this.teacher, this.category, this.screenWidth, this.isLast, this.theme);
  Widget build(BuildContext context) {
    List<dynamic> iconData = classIcons["other"];
    if (category != null && classIcons[category.toLowerCase()] != null) {
      iconData = classIcons[category.toLowerCase()];
    }
    return Container(
      decoration: BoxDecoration(
        color: theme["mainTheme"] == 1 ? Color.fromARGB(255, 20, 20, 20) : Color.fromARGB(255, 255, 255, 255),
      ),
      width: screenWidth,
      child: Row(
        children: <Widget>[
          MakeIconBlock(iconData[0], iconData[1]),
          Container(
            width: screenWidth - 50.0,
            height: 50.0,
            decoration: BoxDecoration(
              border: isLast ? Border(bottom: BorderSide(width: 1.0, color: theme["mainTheme"] == 1 ? Color.fromARGB(255, 60, 60, 60) : Color.fromARGB(255, 230, 230, 230))) : Border(),
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
                        course,
                        style: TextStyle(
                          fontSize: 18.0,
                          color: theme["mainTheme"] == 1 ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        teacher,
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
                        time,
                        style: TextStyle(
                          fontSize: 18.0,
                          color: theme["mainTheme"] == 1 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: teacher == "Free" ? Color.fromARGB(0, 0, 0, 0): Color(theme["secondaryTheme"][1]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class CourseViewPage extends StatefulWidget {
  final List<List<String>> courses;
  final screenDimensions;
  final Map configData;
  CourseViewPage(this.courses, this.screenDimensions, this.configData);
  _CourseViewPage createState() => _CourseViewPage();
}

class _CourseViewPage extends State<CourseViewPage> {
  
  Widget build(BuildContext context) {
    List<Widget> courseBlocks = new List<Widget>();
    for (var i = 0; i < widget.courses.length; i++) {
      courseBlocks.add(MakeCourseBlock(widget.courses[i][1], widget.courses[i][0], widget.courses[i][2] != "" ? widget.courses[i][2] : "Free", widget.courses[i][3], widget.screenDimensions.width, i < widget.courses.length-1, widget.configData));
    }
    return Container(
      height: widget.screenDimensions.height,
      color: widget.configData["mainTheme"] == 1 ? Color.fromARGB(255, 0, 0, 0) : Color.fromARGB(255, 240, 240, 240),
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          GestureDetector(
            onTap:() async {
              Navigator.of(context).pushNamed("/configure");
            },
            child: Text(
              "Today",
              style: TextStyle(
                fontSize: 29.0,
                color: widget.configData["mainTheme"] == 1 ? Color.fromARGB(255, 255, 255, 255) : Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.w100,
              )
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(width: 1.0, color: widget.configData["mainTheme"] == 1 ? Color.fromARGB(255, 60, 60, 60) : Color.fromARGB(255, 230, 230, 230)),bottom: BorderSide(width: 1.0, color: widget.configData["mainTheme"] == 1 ? Color.fromARGB(255, 60, 60, 60) : Color.fromARGB(255, 230, 230, 230))),
            ),
            child: Column(  
              mainAxisAlignment: MainAxisAlignment.start,
              children: courseBlocks
            ),
          ),
        ],
      ),
    );
  }
}
//End of courses classes



//Start of calendar classes


class MakeCalendarBox extends StatelessWidget {
  final DateTime dateAc;
  final List events;
  final double screenWidth;
  final int date;
  MakeCalendarBox(this.dateAc,this.events, this.screenWidth, this.date);
  Widget build(BuildContext context) {
    bool eventShown = false;
    for (var i = 0; i < events.length; i++) {
      DateTime parsedDate = DateTime.parse(events[i]["date"]);
      if (parsedDate.year == dateAc.year && parsedDate.month == dateAc.month && parsedDate.day == dateAc.day) {
        eventShown = true;
      }
    }
    return GestureDetector(
      onTap: () {
        print(dateAc);
      },
      child: Container(
        width: screenWidth*0.95/7,
        height: 60.0,
        decoration: BoxDecoration(
          // border: Border.all(color: Colors.black),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(
              date.toString()
            ),
            Opacity(
              opacity: eventShown ? 0.3 : 0.0,
              child: Container(
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}

class MakeEmptyBox extends StatelessWidget {
  final double screenWidth;
  final int displayedDate;
  MakeEmptyBox(this.screenWidth, this.displayedDate);
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth*0.95/7,
      height: 60.0,
      decoration: BoxDecoration(
        // border: Border.all(color: Colors.black),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text(
            displayedDate.toString(),
            style: TextStyle(
              color: Color.fromARGB(255, 120, 120, 120),
            ),
          ),
          Opacity(
            opacity: 0.9,
            child: Text(
             "",
              style: TextStyle(
                fontSize: 10.0,
                color: Color.fromARGB(255, 200, 200, 200),
              )
            ),
          ),
          Opacity(
            opacity: 0.0,
            child: Container(
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 200, 200, 200),
                shape: BoxShape.circle,
              ),
            )
          ),
        ],
      ),
    );
  }
}

class MakeCalendarTitleTile extends StatelessWidget {
  final double screenWidth;
  final String day;
  MakeCalendarTitleTile(this.screenWidth, this.day);
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth*0.95/7,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(
              day,
              style: TextStyle(
                color: Color.fromARGB(255, 255, 149, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MakeCalendarTitle extends StatelessWidget {
  final double screenWidth;
  MakeCalendarTitle(this.screenWidth);
  Widget build(BuildContext context) {
    return Container(
      height: 30.0,
      width: screenWidth*0.95,
      child: Row(
        children: <Widget>[
          MakeCalendarTitleTile(screenWidth, "Sun"),
          MakeCalendarTitleTile(screenWidth, "Mon"),
          MakeCalendarTitleTile(screenWidth, "Tue"),
          MakeCalendarTitleTile(screenWidth, "Wed"),
          MakeCalendarTitleTile(screenWidth, "Thu"),
          MakeCalendarTitleTile(screenWidth, "Fri"),
          MakeCalendarTitleTile(screenWidth, "Sat"),
        ],
      ),
    );
  }
}

class MakeCalendarScrollBar extends StatelessWidget {
  final double screenWidth;
  final String title;
  MakeCalendarScrollBar(this.screenWidth, this.title);
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth*0.95,
      height: 50.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget> [
          GestureDetector(
            onTap: () {
              print("yeet1");
            },
            child: Icon(
              Icons.arrow_back_ios,
            )
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 22.0,
            )
          ),
          GestureDetector(
            onTap: () {
              print("yeet2");
            },
            child: Icon(
              Icons.arrow_forward_ios,
            )
          ),
        ],
      ),
    );
  }
}

class MonthDisplay extends StatefulWidget {
  String monthName;
  final UpdateMonth updater;
  MonthDisplay(this.monthName, this.updater);
  void setMonthName(String name) {
    this.monthName = name;
  }
  _MonthDisplay createState() {
    return _MonthDisplay();
  }
}
class _MonthDisplay extends State<MonthDisplay>{
  initState() {
    super.initState();
    widget.updater.setPopUp(this);
  }
  Widget build(BuildContext context) {
    print(widget.monthName);
    return Text(
      widget.monthName,
      style: TextStyle(
        color: Color.fromARGB(255, 255, 255, 255),
        fontSize: 25.0,
      ),
    );
  }
}

class AnimatedBottom extends AnimatedWidget {
  AnimatedBottom({Key key, Animation<double> animation}) : super(key : key, listenable : animation);
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Container(
      width: animation.value,
      height: animation.value,
      decoration: BoxDecoration(
        color: Colors.red,
      ),
    );
  }
}

class BottomPopUp extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  List events = [];
  bool extended = false;
  String dateText;
  UpdateBlock updateBlock;
  List userEvents = [];
  List<Map<String, List>> userCourseSchedule;
   List currentDayBlocks = [];
  BottomPopUp(this.screenWidth, this.screenHeight, this.dateText, this.updateBlock, this.userCourseSchedule);

  void setText(String text) {
    dateText = text;
  }
  void setEvents(List eventList) {
    events = eventList;
  }
  void extendPage() {
    extended = true;
  }
  void removePage() {
    extended = false;
  }
  void setUserEvents(List events) {
    userEvents = events;
  }
  void setScheduleDay(int week, int day) {
    if (userCourseSchedule[week-1]["day" + day.toString()] != null) {
      currentDayBlocks = userCourseSchedule[week-1]["day" + day.toString()];
    } else {
      currentDayBlocks = [];
    }
  }
  _BottomPopUp createState() {
    return _BottomPopUp();
  }
}

class UpdateMonth {
  _MonthDisplay monthDisplay;
  bool hasContent = false;
  setPopUp(_MonthDisplay display) {
    hasContent = true;
    monthDisplay = display;
  }
  updateState() {
    print(this.monthDisplay);
    if (hasContent == true) {
      monthDisplay.setState(() {
        return null;
      }); 
    }
  }
}

class UpdateBlock {
  _BottomPopUp popUp;
  bool hasContent = false;
  setPopUp(_BottomPopUp pop) {
    hasContent = true;
    popUp = pop;
  }
  updateStateOfPopUp() {
    if (hasContent == true) {
      popUp.setState(() {

      }); 
    }
  }
}

class _BottomPopUp extends State<BottomPopUp> with SingleTickerProviderStateMixin {
  List<String> colorList = ['0x60FF6633', '0x60FFB399', '0x60FF33FF', '0x60FFFF99', '0x6000B3E6', 
		  '0x60E6B333', '0x603366E6', '0x60999966', '0x6099FF99', '0x60B34D4D',
		  '0x6080B300', '0x60809900', '0x60E6B3B3', '0x606680B3', '0x6066991A', 
		  '0x60FF99E6', '0x60CCFF1A', '0x60FF1A66', '0x60E6331A', '0x6033FFCC',
		  '0x6066994D', '0x60B366CC', '0x604D8000', '0x60B33300', '0x60CC80CC', 
		  '0x6066664D', '0x60991AFF', '0x60E666FF', '0x604DB3FF', '0x601AB399',
		  '0x60E666B3', '0x6033991A', '0x60CC9999', '0x60B3B31A', '0x6000E680', 
		  '0x604D8066', '0x60809980', '0x60E6FF80', '0x601AFF33', '0x60999933',
		  '0x60FF3380', '0x60CCCC00', '0x6066E64D', '0x604D80CC', '0x609900B3', 
		  '0x60E64D66', '0x604DB380', '0x60FF4D4D', '0x6099E6E6', '0x606666FF'];
  AnimationController controller;
  Animation<double> animation;
  initState() {
    super.initState();
    widget.updateBlock.setPopUp(this);
    controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    animation = Tween(begin: 0.0, end: 300.0).animate(controller);
    animation.addListener(() {
      setState(() {
              
      });
    });
    if (widget.extended) {
      startAnimation();
    } else {
      endAnimation();
    }
  }
  startAnimation() {
    controller.forward();
    setState(() {
          
    });
  }
  endAnimation() {
    controller.reverse();
    setState(() {
          
    });
  }

  Widget makeEventBlock(event) {
    return Container(
      width: widget.screenWidth,
      margin: EdgeInsets.only(top: 5.0),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffcccccc), width: 5.0),
      ),
      child: Row(
        children: <Widget>[
          Container(
            color: Color(0xffcccccc),
            padding: EdgeInsets.all(3.0),
            child: Text(
              "9:10 - 10:12",
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Color(0xffcdffc4),
              padding: EdgeInsets.all(3.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, 
                child: Text(
                  event["info"],
                  style: TextStyle(
                    color: Color(0xff2d9b30),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget createHourMarker(String text) {
    return Container(
      height: 50.0,
      width: widget.screenWidth,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black, width: 1.0)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: TextStyle(
          
        )
      ),
    );
  }
  Widget makeUserEvent(event, color) {
    return Positioned(
      top: event["startMinute"].toDouble()*(5/6),
      left: 0.0,
      right: 0.0,
      child: Container(
        color: Color(int.tryParse(color)),
        padding: EdgeInsets.only(left: 40.0, right: 20.0),
        height: event["length"].toDouble()*(5/6),
        child: Opacity(
          opacity: 1.0,
          child: Text(
            event["info"],
          ),
        ),
      ),
    );
  }
  Widget build(BuildContext context) {
    List<Widget> eventsList = List<Widget>();
    List<Widget> hourMarkers = List<Widget>();
    List<Widget> userEvents = List<Widget>();
    for (var i = 0; i < 24; i++) {
      //false for am, true for pm
      bool amOrPm = i > 11;
      int newHour = (i+12-1)%12+1;
      hourMarkers.add(createHourMarker("$newHour ${!amOrPm ? 'AM' : 'PM'}"));
    }
    for (var i = 0; i < widget.events.length; i++) {
      eventsList.add(makeEventBlock(widget.events[i]));
    } 
    if (widget.events.length == 0) {
      eventsList.add(makeEventBlock({"info": "No events!"}));
    }
    if (widget.extended) {
      startAnimation();
    } else {
      endAnimation();
    }
    userEvents.add(
      Positioned(
        top: 0.0,
        left: 0.0,
        bottom: 0.0,
        right: 0.0,
        child: Column(
          children: hourMarkers,
        ),
      )
    );
    for (var i = 0; i < widget.userEvents.length; i++) {
      userEvents.add(makeUserEvent(widget.userEvents[i], colorList[i%colorList.length]));
    }
    for (var i = 0; i < widget.currentDayBlocks.length; i++) {
      if ((widget.currentDayBlocks[i][3])*60 + (widget.currentDayBlocks[i][4]) - ((widget.currentDayBlocks[i][1])*60 + (widget.currentDayBlocks[i][2])) > 30) {
        userEvents.add(makeUserEvent({
          "startMinute": (widget.currentDayBlocks[i][1])*60 + (widget.currentDayBlocks[i][2]),
          "length": (widget.currentDayBlocks[i][3])*60 + (widget.currentDayBlocks[i][4]) - ((widget.currentDayBlocks[i][1])*60 + (widget.currentDayBlocks[i][2])),
          "info": widget.currentDayBlocks[i][0],
        }, colorList[(i+widget.userEvents.length)%colorList.length]));
      }
    }
    final int percent = (controller.value * 100.0).round();
    return Positioned(
      top: widget.screenHeight+50-widget.screenHeight/100*percent,
      left: 0.0,
      child: SizedBox(
        width: widget.screenWidth,
        height: widget.screenHeight-120,
        child: Card(
          clipBehavior: Clip.hardEdge,
          child: Container(
            decoration: BoxDecoration(

            ),
            child: ListView(              
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    widget.extended = false;
                    endAnimation();
                  },
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 30.0,
                  ),
                ),
                Center(
                  child: Text(
                    widget.dateText,
                    style: TextStyle(
                      fontSize: 22.0,
                    )
                  ),
                ),
                Column(
                  children: eventsList,
                ),
                Container(
                  width: widget.screenWidth,
                  height: 24*50.0,
                  child: Stack(
                    children: userEvents,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  dispose() {
    controller.dispose();
    super.dispose();
  }
}

class CalendarDisplayed extends StatelessWidget {  
  final double screenWidth;
  final double screenHeight;
  final List events;
  final List rolledDays;
  final List schoolSkipped;
  final List<Map<String, List>> readableSchedule;
  CalendarDisplayed({Key key, this.screenWidth, this.screenHeight, this.events, this.schoolSkipped, this.rolledDays, this.readableSchedule}) : super(key: key);
  final updaterBlock = UpdateBlock();
  final monthUpdater = UpdateMonth();
  BottomPopUp popUp;
  MonthDisplay monthDisplay;
  int totalBlockRolls = 0;
  List<String> monthNames = ["January", "Febuary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  List<int> monthLengths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  @override
  final DateTime firstDay = DateTime(2018, 8, 1);
  int currentDay = DateTime.now().month-1;
  int currentPage = (DateTime.now().month+3)%12;
  final pageController = PageController(
    initialPage: (DateTime.now().month+3)%12,
  );  
  int currentYear = 2018;

  Widget makeCalendarBox(dateAc, int date, int middleDescription, bool dayIsDisplayed) {
    bool eventShown = false;
    List todayEvents = new List();
    for (var i = 0; i < events.length; i++) {
      DateTime parsedDate = DateTime.parse(events[i]["date"]);
      if (events[i]["displayedEvent"] == true && parsedDate.year == dateAc.year && parsedDate.month == dateAc.month && parsedDate.day == dateAc.day) {
        todayEvents.add(events[i]);
        eventShown = true;
      }
    }
    return GestureDetector(
      onTap: () {
        updateBottomPop(dateAc, todayEvents, dayIsDisplayed ? middleDescription : -1);
      },
      child: Container(
        width: screenWidth*0.95/7,
        height: 60.0,
        decoration: BoxDecoration(
          // border: Border.all(color: Colors.black),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(
              date.toString(),
              style: TextStyle(
                color: Color.fromARGB(255, 250, 250, 250),
              ),
            ),
            Opacity(
              opacity: 0.9,
              child: Text(
                middleDescription != 0 && dayIsDisplayed ? "Day " + middleDescription.toString() : "",
                style: TextStyle(
                  fontSize: 12.0,
                  color: Color.fromARGB(255, 250, 250, 250),
                )
              ),
            ),
            Opacity(
              opacity: eventShown ? 0.6 : 0.0,
              child: Container(
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 200, 200, 200),
                  shape: BoxShape.circle,
                ),
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget makeCalendarRow(year, month, List<List<int>> dates) {
    List<Widget> dateBlocks = new List<Widget>();
    for (var i = 0; i < dates.length; i++) {
      bool dayIsDisplayed = true;
      for (var j = 0; j < rolledDays.length; j++) {
        DateTime parsedDate = DateTime.parse(rolledDays[j]["date"]);
        if (parsedDate.year == year && parsedDate.month == month && parsedDate.day == dates[i][0]) {
          totalBlockRolls++;
          dayIsDisplayed = false;
        }
      }
      for (var j = 0; j < schoolSkipped.length; j++) {
        DateTime parsedDate = DateTime.parse(schoolSkipped[j]["date"]);
        if (parsedDate.year == year && parsedDate.month == month && parsedDate.day == dates[i][0]) {
          dayIsDisplayed = false;
        }
      }
      if (dates[i][1] == 0) {
        dateBlocks.add(MakeEmptyBox(screenWidth, dates[i][0]));
      } else {
        int day = DateTime(year, month, dates[i][0]).weekday;
        int dayDisplayed;
        if (day == 6 || day == 7) {
          dayDisplayed = 0;
        } else {
          dayDisplayed = ((day-1-totalBlockRolls%5)+5)%5+1;
        }
        dateBlocks.add(makeCalendarBox(DateTime(year, month, dates[i][0]), dates[i][0], dayDisplayed, dayIsDisplayed));
      }
    }
    return Container(
      child: Row(
        children: dateBlocks
      ), 
    );
  }

  Widget makeCalendarBody(year, month, startOffset, monthLength, lastMonthLength) {
    int secondOffset = startOffset;
    List<Widget> monthRows = new List<Widget>();
    for (var i = 0; i < 6; i++) {
      List<List<int>> dayNums = new List<List<int>>();
      for (var j = 1; j <= 7; j++) {
        if (secondOffset > 0) {
          secondOffset = secondOffset-1;
          dayNums.add([lastMonthLength-secondOffset, 0]);
        } else {
          if (i*7+j-startOffset > monthLength) {
            dayNums.add([(i*7+j-startOffset) % monthLength, 0]);
          } else {
            dayNums.add([i*7+j-startOffset, 1]);
          }
        }
      }
      monthRows.add(makeCalendarRow(year, month, dayNums));
    }
    
    return Card(
      child: Container(
        width: screenWidth*0.95,
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromARGB(255, 50, 50, 50), width: 2.0),
          color: Color.fromARGB(255, 20, 20, 20),
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          boxShadow: <BoxShadow>[      
          ],
        ),
        child: Center(
          child: Column(
            children: monthRows,
          ),
        ),
      ),
    );
  }
  
  void updateBottomPop(DateTime text, List events, int day) {
    DateFormat formattedDate = DateFormat("MMMM dd, yyyy");
    popUp.setText(formattedDate.format(text));
    popUp.setEvents(events);
    popUp.setScheduleDay(1, day);
    popUp.extendPage();
    updaterBlock.updateStateOfPopUp();
  }
  
  Widget build(BuildContext context) {
    popUp = BottomPopUp(screenWidth, screenHeight, "", updaterBlock, readableSchedule);
    monthDisplay = MonthDisplay(monthNames[currentDay] + " " + currentYear.toString(), monthUpdater);
    List<Widget> calendarBodies = new List<Widget>();
    totalBlockRolls = 0;
    int currentOffset = (firstDay.weekday+1+monthLengths[firstDay.month])%7;
    for (int i = 0; i < 10; i++) {
      calendarBodies.add(makeCalendarBody(firstDay.year + ((firstDay.month+i+1)/12).floor(), (firstDay.month+i+1)%12, currentOffset, monthLengths[(firstDay.month+i)%12], monthLengths[(firstDay.month+i-1)%12]));
      currentOffset += monthLengths[(i+firstDay.month)%12];
      currentOffset%=7;
    } 
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 0, 0, 0),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0.0,
            top: 0.0,
            width: screenWidth,
            child: Column(
              children: <Widget>[
                Container(
                  width: screenWidth*0.95,
                  height: 50.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget> [
                      monthDisplay,
                      Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              pageController.previousPage(duration: Duration(milliseconds: 100), curve: Cubic(1.0, 1.0, 1.0, 1.0));
                            },
                            child: Container(
                              width: 20.0,
                              height: 20.0,
                              color: Color.fromARGB(255, 50, 50, 50),
                              margin: EdgeInsets.only(right: 5.0),
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: Color.fromARGB(255, 62, 172, 168),
                                size: 16.0,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              pageController.nextPage(duration: Duration(milliseconds: 100), curve: Cubic(1.0, 1.0, 1.0, 1.0));
                            },
                            child: Container(
                              width: 20.0,
                              height: 20.0,
                              color: Color.fromARGB(255, 50, 50, 50),
                              margin: EdgeInsets.only(left: 5.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Color.fromARGB(255, 62, 172, 168),
                                size: 16.0,
                              ),
                            ),
                          ),
                        ]
                      ),
                    ],
                  ),
                ),
                MakeCalendarTitle(screenWidth),
                Container(
                  height: 372.0,
                  child: PageView(
                    controller: pageController,
                    children: calendarBodies,
                    onPageChanged: (int) {
                      currentDay = (int+8)%12;
                      if (int+9 > 12) {
                        currentYear = 2019;
                      } else {
                        currentYear = 2018;
                      }
                      monthDisplay.setMonthName(monthNames[currentDay] + " " + currentYear.toString());
                      monthUpdater.updateState();
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          popUp,
        ],
      )
    );
  }
}
//End of calendar classes


class CustomAppBar extends StatelessWidget {
  final Row barTop;
  final double screenWidth;
  final double screenHeight;
  CustomAppBar(this.barTop, this.screenWidth,  this.screenHeight);
  PreferredSize build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size(screenWidth, 70.0),
      child: Container(
        padding: EdgeInsets.only(top: 10.0, bottom: 5.0, left: 10.0, right: 10.0),
        width: screenHeight,
        height: 70.0,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [0.2, 1.0],
            colors: [
              Color.fromARGB(255, 0, 153, 153),
              Color.fromARGB(255, 0, 130, 209),
            ],
          ),
        ),
        child: barTop,
      ),
    );
  }
}
PreferredSize makeAppBar(Row barTop, double screenWidth) {
  return PreferredSize(
    preferredSize: Size(screenWidth, 70.0),
    child: Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 5.0, left: 10.0, right: 10.0),
      width: screenWidth,
      height: 70.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.2, 1.0],
          colors: [
            Color.fromARGB(255, 0, 153, 153),
            Color.fromARGB(255, 0, 130, 209),
          ],
        ),
      ),
      child: barTop,
    ),
  );
}

class HomePage extends StatelessWidget {
  final Map<String, dynamic> homeInfo;
  HomePage(this.homeInfo);
  @override
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;
    makeFullSchedulePage(List<Map> fullSchedule) {
      makeWeekSchedule(Map weekSchedule) {
        List<Widget> scheduleColumns = new List<Widget>();
        weekSchedule.forEach((k,v) {
          List<Widget> scheduleBlocks = new List<Widget>();
          List<List> currentRow = weekSchedule[k];
          for (var i = 0; i < currentRow.length; i++) {
            scheduleBlocks.add(
              Container(
                width: 90.0,
                height: 90.0,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.0)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(
                      currentRow[i][0],
                      style: TextStyle(
                        fontSize: 12.0,
                      )
                    ),
                    Text(
                      "${((currentRow[i][1]-1)%12+1)}:${(currentRow[i][2].toString().length == 1 ? "0" + currentRow[i][2].toString() : currentRow[i][2].toString())} - ${((currentRow[i][3]-1)%12+1)}:${(currentRow[i][4].toString().length == 1 ? "0" + currentRow[i][4].toString() : currentRow[i][4].toString())}",
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                    Text(
                      currentRow[i][5],
                      style: TextStyle(
                        fontSize: 12.0,
                      )
                    ),
                  ],
                ),
              ),
            );
          }
          scheduleColumns.add(
            Container(
              width: 90.0,
              child: Column(
                children: scheduleBlocks,
              ),
            ),
          );
        });
        return Container(
          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: scheduleColumns,
            ),
          ),
        );
      }
      List<Widget> fullScheduleWidgets = new List<Widget>();
      for (var i = 0; i < fullSchedule.length; i++) {
        fullScheduleWidgets.add(makeWeekSchedule(fullSchedule[i]));
      }
      
      return Container(
          // color: Color.fromARGB(255, 90, 80, 80),
          child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: screenDimensions.width,
            height: screenDimensions.height-100.0,
            child: Container(
              decoration: BoxDecoration(

              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: fullScheduleWidgets,
                ),
              ),
            ),
          ),
        ),
      );
    }
    final pageController = PageController(
      initialPage: 1,
    );
    return Scaffold(
      appBar: makeAppBar(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                Navigator.of(context).pushNamed("/courses");
              },
            ),
            Text(
              "Home",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.0,
              )
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context,"/", (_) => false);
              },
            ),
          ],
        ), 
        screenDimensions.width,
      ),
      body: PageView(
        controller: pageController,
        children: <Widget>[
          makeFullSchedulePage(homeInfo["readableCourseMap"]),
          HomeViewPage("1", homeInfo["currentNext"][0], homeInfo["currentNext"][1], homeInfo["config"], screenDimensions),
          CourseViewPage(homeInfo["dayBlocks"], screenDimensions, homeInfo["config"]),
          CalendarDisplayed(screenWidth: screenDimensions.width, screenHeight: screenDimensions.height, events: homeInfo["events"], rolledDays: homeInfo["rolledDays"], schoolSkipped: homeInfo["schoolSkipped"], readableSchedule: homeInfo["readableCourseMap"]),
        ]
      ),
    );
  }
}


// courses select page

class SelectCourses extends StatelessWidget {
  final Map userData;
  SelectCourses(this.userData);
  @override
  Widget build(BuildContext context) {
    print(userData["config"]);
    List notDisplayedblocks = [];
    userData["courseMap"].forEach((k,v) {
      notDisplayedblocks.add(k);
    });
    DropdownTiles tiles = DropdownTiles(userData["courseData"], notDisplayedblocks, userData["blockNames"], userData["courses"], userData["courseMap"], userData["config"]);
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
              "Courses",
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
        color: userData["config"]["mainTheme"] == 1 ? Color.fromARGB(255, 0, 0, 0) : Color.fromARGB(255, 240, 240, 240),
        child: ListView(
          children: <Widget>[
            tiles,
          ],
        ),
      ),
    );
  }
}

class DropdownTiles extends StatefulWidget {
  List courses;
  List removedBlocks;
  List blockList;
  Map coursesMap;
  Map blockIdPairs;
  Map config;
  DropdownTiles(this.courses, this.removedBlocks, this.blockList, this.coursesMap, this.blockIdPairs, this.config);
  _DropdownTiles createState() {
    return _DropdownTiles();
  }
}
class _DropdownTiles extends State<DropdownTiles> {
  void update() {
    setState(() {

    });
  }
  Container makeTilesDropDown() {
    Map<String, List> dropDownBlocks = new Map<String, List>();
    for (var i = 0; i < widget.courses.length; i++) {
      if (dropDownBlocks[widget.courses[i]["category"]] != null) {
        if (widget.removedBlocks.contains(widget.courses[i]["block"])) {

        } else {
          dropDownBlocks[widget.courses[i]["category"]].add(widget.courses[i]);
        }
        
      } else {
        if (widget.removedBlocks.contains(widget.courses[i]["block"])) {
          dropDownBlocks[widget.courses[i]["category"]] = [];
        } else {
          dropDownBlocks[widget.courses[i]["category"]] = [widget.courses[i]];
        }
      }
    }
    List<Widget> dropDownList = new List<Widget>();
    dropDownBlocks.forEach((k,v) {
      List<Widget> currentDropDown = new List<Widget>();
      for (var i = 0; i < dropDownBlocks[k].length; i++) {
        currentDropDown.add(
          GestureDetector(
            onTap: () {
              print(dropDownBlocks[k][i]);
              widget.coursesMap[dropDownBlocks[k][i]["block"]] = dropDownBlocks[k][i];
              widget.blockIdPairs[dropDownBlocks[k][i]["block"]] = dropDownBlocks[k][i]["_id"];
              widget.removedBlocks.add(dropDownBlocks[k][i]["block"]);
              update();
            },
            child: Container(
              child: Text(
                dropDownBlocks[k][i]["teacher"] + "'s " + dropDownBlocks[k][i]["course"] + " block " + dropDownBlocks[k][i]["block"],
                style: TextStyle(
                  color: widget.config["mainTheme"] == 1 ? Colors.white : Colors.black,
                ),
              )
            )
          )
        );
      }
      dropDownList.add(
        Container(
          color: widget.config["mainTheme"] == 1 ? Color.fromARGB(255, 20, 20, 20) : Color.fromARGB(255, 255, 255, 255),
          child: ExpansionTile(
            title: Container(
              child: Text(
                k,
                style: TextStyle(
                  color: widget.config["mainTheme"] == 1 ? Colors.white : Colors.black,
                ),
              ),
            ),
            children: currentDropDown,
          )
        ),
      );
    });
    return Container(
      child: Column(
        children: dropDownList,
      ),
    );
  }
  Container makeColumn() {
    List<Container> columnBlocks = new List<Container>();
    widget.blockList.sort((a,b) {
      return a[0].compareTo(b[0]);
    });
    for (var i = 0; i < widget.blockList.length; i++) {
      if (widget.blockList[i][1] == "changing") {
        if (widget.blockIdPairs[widget.blockList[i][0]] != null) {
          columnBlocks.add(Container(
            width: 110.0,
            padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.black),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  widget.coursesMap[widget.blockList[i][0]]["course"],
                ),
                IconButton(
                  onPressed: () {
                    widget.blockIdPairs.remove(widget.blockList[i][0]);
                    widget.coursesMap.remove(widget.blockList[i][0]);
                    widget.removedBlocks.remove(widget.blockList[i][0]);
                    update();
                  },
                  icon: Icon(
                    Icons.highlight_off,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ));
        } else {
          columnBlocks.add(Container(
            width: 110.0,
            padding: EdgeInsets.only(top: 25.0, bottom: 25.0),
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.black),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  "LC's",
                ),
              ],
            ),
          ));
        }
      } else {

      }
    }
    return Container(
      child: Column(
        children: columnBlocks,
      ),
      margin: EdgeInsets.only(bottom: 20.0),
    );
  }
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        makeTilesDropDown(),
        makeColumn(),
        Center(
          child: Material(
            // color: Color.fromARGB(255, 20, 20, 20),
            child: InkWell(
              onTap: () async {
                UserStorage storage = UserStorage();
                storage._writeUserData({"courses": widget.blockIdPairs}, "userData.json");
                Navigator.pushNamedAndRemoveUntil(context,"/", (_) => false);
              },
              child: Container(
                width:85.0,
                height: 40.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  border: Border.all(color: Colors.blue, width: 1.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Ok",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}







// account page

class AccountPage extends StatelessWidget {
  
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;
    return Imager();
  }
}

class Imager extends StatefulWidget {
  _Imager createState() => _Imager();
}

class _Imager extends State<Imager> {
  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Image Picker Example'),
      ),
      body: new Center(
        child: _image == null
            ? new Text('No image selected.')
            : new Image.file(_image),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: new Icon(Icons.add_a_photo),
      ),
    );
  }
}



