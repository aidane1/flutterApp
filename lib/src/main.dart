import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../views/homePage/homePage.dart';
import '../views/eventsPage/eventsPage.dart';
import '../views/themeSelect/themePage.dart';
import '../views/loginPage/loginPage.dart';
import '../views/courseSelect/coursePage.dart';
import '../views/remindersPage/remindersPage.dart';
import '../views/allNotesPage/allNotesPage.dart';
import '../views/allAssignmentsPage/allAssignmentsPage.dart';
import '../views/accountPage/accountPage.dart';
import 'package:experiments/components/userStorage.dart';
import 'package:experiments/components/universalClasses.dart';





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

Future<HomeInfo> compileAllHomeInfo(UserStorage storage, CalendarInfo calendarInfo) async {

  List<DayBlock> dayBlocks = await getDayBlocks(storage);

  List<UpcomingBlock> currentNext = currentNextBlock(dayBlocks);

  Map events = await getAllEvents(storage);

  Map userData = await storage.readUserData("userData.json");

  User user = new User.fromJson({"courses": userData["courses"], "retrievedAssignments": []});
    
  List<Course> courses = await CourseManipulation.retrieveCoursesById(user.courses);

  Map schoolData = await storage.readUserData("schoolData.json");
  
  CourseList courseList = CourseList(courses, schoolData["blockNames"], {});
    
  if (schoolData["blockNames"] == null) {
    schoolData["blockNames"] = [];
  }    

  School school = School.scheduleFromServer(schoolData);
  ReadableSchedule readableSchedule = new ReadableSchedule();
  for (var i = 0; i < school.schedule.schedule.length; i++) {
    ReadableScheduleWeek currentWeek = new ReadableScheduleWeek();
    school.schedule.schedule[i].days.forEach((k,v) {
      ReadableScheduleDay currentDay = new ReadableScheduleDay();
      for (var j = 0; j < school.schedule.schedule[i].days[k].blocks.length; j++) {
         ReadableScheduleBlock currentBlock;
         currentBlock = ReadableScheduleBlock(courseList.blocks[school.schedule.schedule[i].days[k].blocks[j].block], school.schedule.schedule[i].days[k].blocks[j].time);
         currentDay.blocks.add(currentBlock);
         currentDay.title = school.schedule.schedule[i].days[k].title;
      }
      currentWeek.days[k] = currentDay;
    });
    readableSchedule.schedule.add(currentWeek);
  }

  Map configDataMap = await storage.readUserData("configData.json");
  ThemeColor themeColor = ThemeColor(configDataMap["mainTheme"], configDataMap["secondaryTheme"]);
  themeColor.update();

  

  // CourseList courseList = CourseList(courses, school["blockNames"], {});

  return HomeInfo(
    dayBlocks,
    currentNext,
    calendarInfo,
    themeColor,
    readableSchedule,
  );
  // return {
  //   "dayBlocks": dayBlocks,
  //   "currentNext": currentNext,
  //   "events": events["events"] != null ? events["events"] : [],
  //   "rolledDays": events["rolledDays"] != null ? events["rolledDays"] : [],
  //   "schoolSkipped": events["schoolSkipped"] != null ? events["schoolSkipped"] : [],
  //   "readableCourseMap": makeReadableSchedule(courseMap, school),
  //   "config": configData,
  // };
  
}

Future<CourseInfo> compileCourseSelectInfo(storage) async {
  Map userData = await storage.readUserData("userData.json");
  User user = new User.fromJson({"courses": userData["courses"], "retrievedAssignments": []});
  List<Course> courses = await CourseManipulation.retrieveCoursesById(user.courses);
  List<Course> allCourses = await CourseManipulation.retrieveAllFromStorage();
  Map schoolData = await storage.readUserData("schoolData.json");
  BasicList courseBlocks = BasicList(courses, schoolData["blockNames"], {});
  Map configDataMap = await storage.readUserData("configData.json");
  ThemeColor themeColor = ThemeColor(configDataMap["mainTheme"], configDataMap["secondaryTheme"]);
  themeColor.update();
  Map<String, MongoId> idPairs = new Map<String, MongoId>();
  courseBlocks.blocks.forEach((k,v) {
    idPairs[k] = v.id;
  });
  return CourseInfo(courseBlocks, allCourses, themeColor, schoolData["blockNames"], idPairs);
}

Map<String, dynamic> returnCourseBlockMap(List courses, Map userCourseNames, List allBlocks) {
  
  Map<String, dynamic> returnObject = new Map<String, dynamic>();
  for (var i = 0; i < allBlocks.length; i++) {
    if (allBlocks[i][1] == "changing") {
      returnObject[allBlocks[i][0]] = {"course": "LC's", "teacher": "", "block": allBlocks[i][0], "_id" : "_"};
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

List<Map> returnCoursesById(List courses, List ids) {
  List<Map> returnList = new List<Map>();
  for (var i = 0; i < courses.length; i++) {
    for (var j = 0; j < ids.length; j++) {
      if (courses[i]["_id"] == ids[j]) {
        returnList.add(courses[i]);
      }
    }
  }
  return returnList;
}

Future<Map> returnCourseById(String ids) async {
  UserStorage storage = new UserStorage();
  Map courseData = await storage.readUserData("coursesData.json");
  List courseList = courseData["courses"];
  for (var i = 0; i < courseList.length; i++) {
    if (courseList[i]["_id"] == ids) {
      return courseList[i]["_id"];
    }
  }
  return {};
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
  final response = await http.get('http://159.65.72.108:15651/UserInfo?schoolId=$schoolId&username=$username&password=$password');
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
  await storage.writeUserData(schoolObject, "schoolData.json");
  await storage.writeUserData(coursesObject, "coursesData.json");
  await storage.writeUserData(eventsObject, "eventsData.json");
  await storage.writeUserData({"mainTheme": "dark", "secondaryTheme": [0, 0xffff3800]}, "configData.json");
}

Future<List> fetchSchoolList() async {
  final response = await http.get('http://159.65.72.108:15651/schoolList');
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    return [];
  }
}

Future<ConfigInfo> compileAllConfigureInfo(storage) async {
  Map userData = await storage.readUserData("userData.json");
  User user = User.fromJson(userData);
  
  
  
  List<Course> courses;
  Map configDataMap = await storage.readUserData("configData.json");
  ThemeColor themeColor = ThemeColor(configDataMap["mainTheme"], configDataMap["secondaryTheme"]);
  themeColor.update();
  
  courses = await CourseManipulation.retrieveCoursesById(user.courses);

  return ConfigInfo(courses, themeColor);
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

Future<List<DayBlock>> getDayBlocks(UserStorage storage) async {

  try {
    

    final int currentDayInt = 1;

    final int currentWeek = 1;

    final UserStorage storage = new UserStorage();
    

    Map userData = await storage.readUserData("userData.json");

    User user = new User.fromJson({"courses": userData["courses"], "retrievedAssignments": []});
    
    List<Course> courses = await CourseManipulation.retrieveCoursesById(user.courses);
    
    Map schoolData = await storage.readUserData("schoolData.json");

    if (schoolData["blockNames"] == null) {
      schoolData["blockNames"] = [];
    }    

    School school = School.scheduleFromServer(schoolData);
    
    CourseList courseList = CourseList(courses, schoolData["blockNames"], {});

    List<DayBlock> dayBlocks = new List<DayBlock>();

    ScheduleDay currentDay = school.schedule.schedule[currentWeek-1].days["day" + currentDayInt.toString()];
    for (var i = 0; i < currentDay.blocks.length; i++) {
      dayBlocks.add(DayBlock(
        currentDay.blocks[i].time,
        courseList.blocks[currentDay.blocks[i].block],
      ));
    }
    return dayBlocks;
  } catch(e) {
    print(e);
    return [];
  }
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

List<UpcomingBlock> currentNextBlock(List<DayBlock> dayBlocks)  {
  DateTime currentTime = DateTime.now();
  int currentMinute = currentTime.hour*60 + currentTime.minute;
  UpcomingBlock currentBlock = UpcomingBlock(ScheduleTime(0, 0, 0, 0), Course(), "Current Block: ", false);
  UpcomingBlock nextBlock = UpcomingBlock(ScheduleTime(0, 0, 0, 0), Course(), "Next Block: ", false);
  if (currentMinute < dayBlocks[0].time.calculateStartMinute()) {
    currentBlock = UpcomingBlock(dayBlocks[0].time, dayBlocks[0].course, "Current Block: ", false);
    nextBlock = UpcomingBlock(dayBlocks[0].time, dayBlocks[0].course, "Next Block: ", true);
  }
  for (var i = 0; i < dayBlocks.length; i++) {
    int currentStartTime = dayBlocks[i].time.calculateStartMinute();
    int currentEndTime = dayBlocks[i].time.calculateEndMinute();
    if (currentEndTime > currentMinute && currentStartTime < currentMinute) {
      currentBlock = UpcomingBlock(dayBlocks[i].time, dayBlocks[i].course, "Current Block: ", true);
      if (i < dayBlocks.length-2) {
        nextBlock = UpcomingBlock(dayBlocks[i+1].time, dayBlocks[i+1].course, "Next Block: ", true);
      } else {
        nextBlock = UpcomingBlock(dayBlocks[i].time, dayBlocks[i].course, "Next Block: ", false);
      }
    }
  }
  if (currentMinute > dayBlocks[dayBlocks.length-1].time.calculateEndMinute()) {
    currentBlock = UpcomingBlock(dayBlocks[0].time, dayBlocks[0].course, "Current Block: ", false);
    nextBlock = UpcomingBlock(dayBlocks[0].time, dayBlocks[0].course, "Next Block: ", false);
  }
  return [currentBlock, nextBlock];
}

Future<Map> getAllEvents(UserStorage storage) async {
  Map events = await storage.readUserData("eventsData.json");
  return events;
}

Future<AccountInfo> compileAllAccountInfo(UserStorage storage) async {
  Map configDataMap = await storage.readUserData("configData.json");
  ThemeColor themeColor = ThemeColor(configDataMap["mainTheme"], configDataMap["secondaryTheme"]);
  themeColor.update();
  return AccountInfo(themeColor);
}

Future<AllNotesInfo> compileAllAllNotesInfo(UserStorage storage) async {
  User user = await User.retrieveFromStorage();
  Map configDataMap = await storage.readUserData("configData.json");
  ThemeColor themeColor = ThemeColor(configDataMap["mainTheme"], configDataMap["secondaryTheme"]);
  themeColor.update();
  return AllNotesInfo(await CourseManipulation.retrieveCoursesById(user.courses), themeColor);
}

Future<AllNotesInfo> compileAllAllAssignmentsInfo(UserStorage storage) async {
  User user = await User.retrieveFromStorage();
  Map configDataMap = await storage.readUserData("configData.json");
  ThemeColor themeColor = ThemeColor(configDataMap["mainTheme"], configDataMap["secondaryTheme"]);
  themeColor.update();
  return AllNotesInfo(await CourseManipulation.retrieveCoursesById(user.courses), themeColor);
}

Future<CalendarInfo> compileAllCalendarInfo(UserStorage storage) async {
  // Map events = await getAllEvents(storage);
  // Map configDataMap = await storage.readUserData("configData.json");
  // ThemeColor themeColor = ThemeColor(configDataMap["mainTheme"], configDataMap["secondaryTheme"]);
  // themeColor.update();
  // return CalendarInfo(
  //   events["events"] != null ? events["events"] : [],
  //   events["rolledDays"] != null ? events["rolledDays"] : [],
  //   events["schoolSkipped"] != null ? events["schoolSkipped"] : [],
  //   themeColor,
  // );
}
Future<RemindersInfo> compileAllReminderInfo(UserStorage storage) async {
  Map configDataMap = await storage.readUserData("configData.json");
  ThemeColor themeColor = ThemeColor(configDataMap["mainTheme"], configDataMap["secondaryTheme"]);
  themeColor.update();
  User user = await User.retrieveFromStorage();
  return RemindersInfo(themeColor, await CourseManipulation.retrieveCoursesById(user.courses));
}

Future<EventInfo> compileAllEventInfo(UserStorage storage) async {
  Map configDataMap = await storage.readUserData("configData.json");
  ThemeColor themeColor = ThemeColor(configDataMap["mainTheme"], configDataMap["secondaryTheme"]);
  themeColor.update();
  return EventInfo(themeColor);
}
void  main() async {
  //sets first month to september
  //TODO: make this a configurable feature, client side
  List<Event> events = await Event.retrieveAllFromStorage();
  DateTime startDate = DateTime(2018, 9, 3);
  DateTime endDate = DateTime(2019, 6, 30);
  Duration yearLength = endDate.difference(startDate);
  Map<String, List> dates = new Map<String, List>();
  events.sort((a,b) {
    return a.date.millisecondsSinceEpoch.compareTo(b.date.millisecondsSinceEpoch);
  });
  List<Event> daysRolled = events.where((i) => i.dayRolled && i.date.add(Duration(days: 1)).millisecondsSinceEpoch >= startDate.millisecondsSinceEpoch).toList();
  List<Event> schoolSkipped = events.where((i) => i.schoolSkipped&& i.date.millisecondsSinceEpoch >= startDate.millisecondsSinceEpoch).toList();
  int currentDay = 0;
  int currentIndex = 0;
  int currentSkippedIndex = 0;
  int currentEventIndex = 0;
  List<String> dayNames = ["day 1", "day 2", "day 3", "day 4", "day 5"];  
  // print(yearLength.inDays);
  for (var i = 0; i < yearLength.inDays; i++) {
    //what the current 'day' is, if the 'day' value is displayed, and if there is an event on that day
    List currentDayList = ["day 1", true, false, []];
    DateTime currentDate = startDate.add(Duration(days: i));
    if (currentDate.weekday == 6 || currentDate.weekday == 7) {
      currentDayList[1] = false;
      currentDayList[2] = false;
    }
    while(currentEventIndex < events.length && DateTime(events[currentEventIndex].date.year, events[currentEventIndex].date.month, events[currentEventIndex].date.day).millisecondsSinceEpoch <= currentDate.millisecondsSinceEpoch) {
      if (events[currentEventIndex].date.year == currentDate.year && events[currentEventIndex].date.month == currentDate.month && events[currentEventIndex].date.day == currentDate.day && events[currentEventIndex].eventShown) {
        currentDayList[3].add(events[currentEventIndex]);
        currentDayList[2] = true;
      }
      currentEventIndex++;
    }
    while(currentSkippedIndex < schoolSkipped.length && DateTime(schoolSkipped[currentSkippedIndex].date.year, schoolSkipped[currentSkippedIndex].date.month, schoolSkipped[currentSkippedIndex].date.day).millisecondsSinceEpoch <= currentDate.millisecondsSinceEpoch) {
      if (schoolSkipped[currentSkippedIndex].date.year == currentDate.year && schoolSkipped[currentSkippedIndex].date.month == currentDate.month && schoolSkipped[currentSkippedIndex].date.day == currentDate.day) {
        currentDayList[1] = false;
      }
      currentSkippedIndex++;
    }
    while(currentIndex < daysRolled.length && daysRolled[currentIndex].date.millisecondsSinceEpoch < currentDate.millisecondsSinceEpoch) {
      if (daysRolled[currentIndex].date.year == currentDate.year && daysRolled[currentIndex].date.month == currentDate.month && daysRolled[currentIndex].date.day == currentDate.day) {
        // print(daysRolled[currentIndex].date);  
        currentDayList[1] = false;
      }
      //rolls the day
      currentDay -= 1;
      //makes sure it isnt negative
      currentDay += 5;
      //takes it mod 5 to be a day of the week
      currentDay %= 5;
      currentIndex++;
    }
    currentDayList[0] = currentDay;
    dates[[currentDate.year, currentDate.month, currentDate.day].toString()] = currentDayList;    
    if (currentDate.weekday != 6 && currentDate.weekday != 7) {
      currentDay += 1;
      currentDay %= 5;
    } else {
      currentDayList[1] = false;
    }
  }

  //TODO: Pre-load all the days for blocks, and make a function to get what day a certain date is
  
  //Map format wi
  UserStorage storage = new UserStorage();
  Map courseData = await storage.readUserData("userPass.json");
  String initRoute = "/";
  if (courseData["school"] != null) {

  } else {
    initRoute = "/login";
  }
  
  runApp(MyApp(storage, initRoute, CalendarInfo(dates, events)));
}


class MyApp extends StatelessWidget {
  final UserStorage storage;
  final String initRoute;
  final CalendarInfo calendarInfo;
  MyApp(this.storage, this.initRoute, this.calendarInfo);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Test",
      theme: Theme.of(context).platform == TargetPlatform.iOS ? kIOSTheme : kDefaultTheme,
      initialRoute: initRoute,
      routes: <String, WidgetBuilder> {
        '/': (BuildContext context) {
          // return calendar;
          return HomePage(compileAllHomeInfo(storage, calendarInfo));
          // return FutureBuilder(
          //   future: compileAllHomeInfo(storage),
          //   builder: (context, snapshot) {
          //     if (snapshot.hasData) {
          //       return HomePage(snapshot.data);
          //     } else if (snapshot.hasError) {
          //       return CircularProgressIndicator();
          //     } else {
          //       return CircularProgressIndicator();
          //     }
          //   },
          // );
        },
        // "/calendar": (BuildContext context) {
        //   return FutureBuilder(
        //     future: compileAllCalendarInfo(storage),
        //     builder: (context, snapshot) {
        //       if (snapshot.hasData) {
        //         return ReminderPage(snapshot.data);
        //       } else if (snapshot.hasError) {
        //         return CircularProgressIndicator();
        //       } else {
        //         return CircularProgressIndicator();
        //       }
        //     },
        //   );
        // },
        '/reminders': (BuildContext context) {
          return FutureBuilder(
            future: compileAllReminderInfo(storage),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ReminderPage(snapshot.data);
              } else if (snapshot.hasError) {
                return CircularProgressIndicator();
              } else {
                return CircularProgressIndicator();
              }
            },
          );
        },
        "/allNotes": (BuildContext context) {
          return FutureBuilder(
            future: compileAllAllNotesInfo(storage),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return AllNotesPage(snapshot.data);
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return CircularProgressIndicator();
              } else {
                return CircularProgressIndicator();
              }
            }
          );
        },
        "/allAssignments": (BuildContext context) {
          return FutureBuilder(
            future: compileAllAllAssignmentsInfo(storage),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return AllAssignmentsPage(snapshot.data);
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return CircularProgressIndicator();
              } else {
                return CircularProgressIndicator();
              }
            }
          );
        },
        "/events": (BuildContext context) {
          return FutureBuilder(
            future: compileAllEventInfo(storage),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return EventsPage(snapshot.data);
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return CircularProgressIndicator();
              } else {
                return CircularProgressIndicator();
              }
            }
          );
        },
        "/login": (BuildContext context) {
          return FutureBuilder(
            future: fetchSchoolList(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return LoginPage(snapshot.data);
              } else if (snapshot.hasError) {
                return CircularProgressIndicator();
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
                return CircularProgressIndicator();
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
                print(snapshot.error);
                return CircularProgressIndicator();
              } else {
                return CircularProgressIndicator();
              }
            }
          );
        },
        "/account": (BuildContext context) {
          return FutureBuilder(
            future: compileAllAccountInfo(storage),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return AccountPage(snapshot.data);
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return CircularProgressIndicator();
              } else {
                return CircularProgressIndicator();
              }
            }
          );
        },
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





// class AccountPage extends StatelessWidget {
  
//   Widget build(BuildContext context) {
//     final screenDimensions = MediaQuery.of(context).size;
//     return Imager();
//   }
// }

// class Imager extends StatefulWidget {
//   _Imager createState() => _Imager();
// }

// class _Imager extends State<Imager> {
//   File _image;

//   Future getImage() async {
//     var image = await ImagePicker.pickImage(source: ImageSource.camera);
//     setState(() {
//       _image = image;
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(
//       appBar: new AppBar(
//         title: new Text('Image Picker Example'),
//       ),
//       body: new Center(
//         child: _image == null
//             ? new Text('No image selected.')
//             : new Image.file(_image),
//       ),
//       floatingActionButton: new FloatingActionButton(
//         onPressed: getImage,
//         tooltip: 'Pick Image',
//         child: new Icon(Icons.add_a_photo),
//       ),
//     );
//   }
// }



