
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:experiments/components/userStorage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomeInfo {
  final List<DayBlock> dayblocks;
  final List<UpcomingBlock> upcomingBlocks;
  final List events;
  final List rolledDays;
  final List schoolSkipped;
  final ThemeColor themeData;
  final ReadableSchedule readableSchedule;
  HomeInfo(this.dayblocks, this.upcomingBlocks, this.events, this.rolledDays, this.schoolSkipped, this.themeData, this.readableSchedule);
}

class NoteInfo {
  final Course course;
  final ThemeColor themeColor;
  NoteInfo(this.course, this.themeColor);
}

class  CourseInfo {
  final BasicList userCourses;
  final List<Course> allCourses;
  final ThemeColor themeData;
  final Map<String, MongoId> idPairs;
  final List blockNames;
  CourseInfo(this.userCourses, this.allCourses, this.themeData, this.blockNames, this.idPairs);
}

class ConfigInfo {
  final List<Course> courses;
  final ThemeColor themeData;
  ConfigInfo(this.courses, this.themeData);
}

class ReadableScheduleBlock {
  final Course course;
  final ScheduleTime time;
  ReadableScheduleBlock(this.course, this.time);
}

//format for a day is just an array of blocks ex. [[block1...], [block2...], [block3...]]
class ReadableScheduleDay {
  String title;
  List<ReadableScheduleBlock> blocks = new List<ReadableScheduleBlock>();
}

//format for week from object is: {day1: [...], day2: [...], day3: [...], day4: [...], day5: [...]}
//each day is just an array of blocks
class ReadableScheduleWeek {
  Map<String, ReadableScheduleDay> days = new Map<String, ReadableScheduleDay>();
}

//format for a whole schedule is [{week1...}, {week2...}], etc
class ReadableSchedule {
  List<ReadableScheduleWeek> schedule = [];
}
// }

class DayBlock {
  final ScheduleTime time;
  final Course course;
  DayBlock(this.time, this.course);
}

class UserColors {
  List<Color> baseColorList = [Colors.red, Colors.blue, Colors.green, Colors.purple, Colors.orange];
  Map<String, Color> blockColorPairs = new Map();
  final List blockNames;
  UserColors(this.blockNames) {

  }
}

class UpcomingBlock {
  final ScheduleTime time;
  final Course course;
  final String title;
  final bool inSchoolHours;
  UpcomingBlock(this.time, this.course, this.title, this.inSchoolHours);
}

class Course {
  String course = "LC's";
  MongoId id = MongoId("_");
  String block = "";
  String teacher = "Free";
  String category = "other";
  MongoId school = MongoId("_");
  List<MongoId> assignments = [];
  List<MongoId> notes = [];
  bool isReal = false;
  Course();
  Course.fromJson(Map<String, dynamic> json) {

    List<MongoId> assignmentList = new List<MongoId>();
    if (json["assignments"] != null) {
      for (var i = 0; i < json["assignments"].length; i++) {
        assignmentList.add(MongoId(json["assignments"][i]));
      }
    }
    List<MongoId> notesList = new List<MongoId>();
    if (json["notes"] != null) {
      for (var i = 0; i < json["notes"].length; i++) {
        notesList.add(MongoId(json["notes"][i]));
      }
    }
    
    course = json["course"];
    id = MongoId(json["id"]);
    block = json["block"];
    teacher = json["teacher"];
    category = json["category"];
    school = MongoId(json["school"]);
    assignments = assignmentList;
    notes = notesList;
    isReal = true;
  }

  Map<String, dynamic> toJson() {
    return {
      "course": this.course,
      "id": this.id.id,
      "block": this.block,
      "teacher": this.teacher,
      "school": this.school.id,
      "category": this.category,
      "assignments": this.assignments.map((assignment) => assignment.id).toList(),
      "notes": this.notes.map((note) => note.id).toList(),
    };
  }
  void populateData(Map courseData) {
    bool allThere = true;
    if (courseData["course"] != null) {
      this.course = courseData["course"];
    } else {
      allThere = false;
    }
    if (courseData["_id"] != null) {
      this.id = MongoId(courseData["_id"]);
    } else {
      allThere = false;
    }
    if (courseData["block"] != null) {
      this.block = courseData["block"];
    } else {
      allThere = false;
    }
    if (courseData["teacher"] != null) {
      this.teacher = courseData["teacher"];
    } else {
      allThere = false;
    }
    if (courseData["school"] != null) {
      this.school = MongoId(courseData["school"]);
    } else {
      allThere = false;
    }
    if (courseData["category"] != null) {
      this.category = courseData["category"];
    } else {
      allThere = false;
    }
    if (allThere) {
      isReal = true;
    }
  }
  void setNonReal() {
    this.isReal = false;
  }

}

class SchoolIcons {
  static makeBlock(category) {
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
      "music": [Icons.music_note, Colors.orange[300]],
      "trades": [MdiIcons.wrench, Colors.grey],
    };
    List<dynamic> iconData = classIcons["other"];
    if (category != null && classIcons[category.toLowerCase()] != null) {
      iconData = classIcons[category.toLowerCase()];
    }
    return Container(
      width: 30.0,
      height: 30.0,
      margin: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: iconData[1],
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(iconData[0], size: 20.0),
        ],
      ),
    );
  }
}

class BasicList {
  final List<Course> courses;
  final List allBlocks;
  final Map<String, String> blockNames;
  Map<String, Course> blocks = {};
  BasicList(this.courses, this.allBlocks, this.blockNames) {
    for (var i = 0; i < courses.length; i++) {
      this.blocks[courses[i].block] = courses[i];
    }
    this.blockNames.forEach((k,v) {
      if (this.blocks[k] != null) {
        this.blocks[k].course = v;
      }
    });
  }
}

class CourseList {
  final List<Course> courses;
  final List allBlocks;
  final Map<String, String> blockNames;
  Map<String, Course> blocks = {};
  CourseList(this.courses, this.allBlocks, this.blockNames) {
    for (var i = 0; i < allBlocks.length; i++) {
      this.blocks[allBlocks[i][0]] = new Course();
      this.blocks[allBlocks[i][0]].populateData({"block": allBlocks[i][0]});
      if (allBlocks[i][1] == "constant") {
        this.blocks[allBlocks[i][0]].course = allBlocks[i][0];
      }
    }
    for (var i = 0; i < courses.length; i++) {
      this.blocks[courses[i].block] = courses[i];
    }
    this.blockNames.forEach((k,v) {
      if (this.blocks[k] != null) {
        this.blocks[k].course = v;
      }
    });
  }
}

class CourseManipulation {
  static List<Course> mapListToCourseList(List<Map> courses) {
    List<Course> courseList = new List<Course>();
    for (var i = 0; i < courses.length; i++) {
      Course currentCourse = new Course();
      currentCourse.populateData(courses[i]);
      courseList.add(currentCourse);
    }
    return courseList;
  }
  static Future<List<Course>> retrieveCoursesById(List<MongoId> ids) async {
    List<Course> courses = await retrieveAllFromStorage();
    List<Course> returnCourses = new List<Course>();
    for (var i = 0; i < courses.length; i++) {
      for (var j = 0; j < ids.length; j++) {
        if (courses[i].id.equalsID(ids[j])) {
          returnCourses.add(courses[i]);
        }
      }
    }
    return returnCourses;
  }
  static Future<List<Course>> retrieveAllFromStorage() async {
    UserStorage storage = new UserStorage();
    Map courses = await storage.readUserData("coursesData.json");
    List<Course> courseList = new List<Course>();
    if (courses["courses"] != null) {
      for (var i = 0; i < courses["courses"].length; i++) {
        Course currentCourse = Course.fromJson(courses["courses"][i]);
        courseList.add(currentCourse);
      }
    }
    return courseList;
  }
  static Future<Course> retrieveCourseById(MongoId id) async {
    List<Course> courses = await retrieveAllFromStorage();
    Course returnCourse = new Course();
    for (var i = 0; i < courses.length; i++) {
      if (courses[i].id.equalsID(id)) {
        returnCourse = courses[i];
      }
    }
    return returnCourse;
  }
}

class ThemeColor {
  int mainTheme = 1;
  List<dynamic> secondaryTheme = [0, 0xffff3800];
  Color bodyBack = Color.fromARGB(255, 0, 0, 0);
  Color border = Color.fromARGB(255, 100, 100, 100);
  Color blockBack = Color.fromARGB(255, 20, 20, 20);
  Color textColor = Colors.white;
  ThemeColor(mainThemeData, secondaryThemeData) {
    if (mainThemeData != null) {
      this.mainTheme = mainThemeData;
    }
    if (secondaryThemeData != null) {
      this.secondaryTheme = secondaryThemeData;
    }
  }
  ThemeColor.fromJson(Map<String, dynamic> json) :
    mainTheme = json["mainTheme"],
    secondaryTheme = json["secondaryTheme"];
    
  Map<String, dynamic> toJson() {
    return {
      "mainTheme": mainTheme,
      "secondaryTheme": secondaryTheme
    };
  }
  void update() {
    if (mainTheme == 1) {
      this.bodyBack = Color.fromARGB(255, 0, 0, 0);
      this.border = Color.fromARGB(255, 100, 100, 100);
      this.blockBack = Color.fromARGB(255, 20, 20, 20);
      this.textColor = Colors.white;
    } else {
      this.bodyBack = Color.fromARGB(255, 240, 240, 240);
      this.border = Color.fromARGB(255, 200, 200, 200);
      this.blockBack = Color.fromARGB(255, 255, 255, 255);
      this.textColor = Colors.black;
    }
  }
}

class MongoId {
  final String id;
  MongoId(this.id);
  bool equalsID(MongoId otherID) {
    if (otherID.id == this.id) {
      return true;
    } else {
      return false;
    }
  }
  String toJson() {
    return this.id;
  }
}

class ScheduleTime {
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  ScheduleTime(this.startHour, this.startMinute, this.endHour, this.endMinute);
  int calculateStartMinute() {
    return this.startHour*60 + this.startMinute;
  }
  int calculateEndMinute() {
    return this.endHour*60 + this.endMinute;
  }
  String toString() {
    return "${(this.startHour-1)%12+1}:${this.startMinute.toString().length == 1 ? '0' + this.startMinute.toString() : this.startMinute.toString()} - ${(this.endHour-1)%12+1}:${this.endMinute.toString().length == 1 ? '0' + this.endMinute.toString() : this.endMinute.toString()}";
  }
  int lengthInMinutes() {
    return (this.calculateEndMinute() - this.calculateStartMinute());
  }
}

// format for a block within a day: [block, startHour, startMinute, endHour, endMinute, changing?] ex. ["A", 9, 10, 10, 12, false]
class ScheduleBlock {
  bool changing;
  final String block;
  final ScheduleTime time;
  ScheduleBlock(this.block, this.changing, this.time);
}

//format for a day is just an array of blocks ex. [[block1...], [block2...], [block3...]]
class ScheduleDay {
  String title;
  List<ScheduleBlock> blocks = new List<ScheduleBlock>();
  ScheduleDay(this.title, this.blocks);
  ScheduleDay.makeDay(dayTitle, day) {
    this.title = dayTitle;
    for (var i = 0; i < day.length; i++) {
      blocks.add(ScheduleBlock(
        day[i][0],
        day[i][5],
        ScheduleTime(day[i][1], day[i][2], day[i][3], day[i][4]),
      ));
    }
  }
}

//format for week from object is: {day1: [...], day2: [...], day3: [...], day4: [...], day5: [...]}
//each day is just an array of blocks
class ScheduleWeek {
  Map<String, ScheduleDay> days = new Map<String, ScheduleDay>();
  ScheduleWeek(this.days);
  ScheduleWeek.makeWeek(week) {
    week.forEach((key,day){
      this.days[key] = (ScheduleDay.makeDay(
        key,
        day
      ));
    });
  }
}

//format for a whole schedule is [{week1...}, {week2...}], etc
class Schedule {
  List<ScheduleWeek> schedule = new List<ScheduleWeek>();
  Schedule(this.schedule);
  Schedule.makeSchedule(List blockSchedule) {
    for (var i = 0; i < blockSchedule.length; i++) {
      schedule.add(ScheduleWeek.makeWeek(
        blockSchedule[i]
      ));
    }
  }
}
class School {
  Schedule schedule;
  School.scheduleFromServer(Map serverObject) {
    serverObject.forEach((k,v) {
      
    });
    List newSchedule = [];
    try {
      if (serverObject["constantBlocks"] == true) {   
        List constantBlockTimes = serverObject["constantBlockSchedule"]["blockSchedule"];
        List constantBlockSchedule = serverObject["constantBlockSchedule"]["schedule"];
        for (var i = 0; i < constantBlockSchedule.length; i++) {
          Map currentWeek = new Map();
          constantBlockSchedule[i].forEach((key, day) {
            List currentDay = new List();
            for (var j = 0; j < constantBlockSchedule[i][key].length; j++) {
              currentDay.add([
                day[j][0],
                constantBlockTimes[j][0],
                constantBlockTimes[j][1],
                constantBlockTimes[j][2],
                constantBlockTimes[j][3],
                day[j][1] == "changing",
              ]);
            }
            currentWeek[key] = currentDay;
          });
          newSchedule.add(currentWeek);
        }
      } else {
        for (var i = 0; i < serverObject["blockOrder"].length; i++) {
          serverObject["blockOrder"][i].forEach((k,v) {
            for (var j = 0; j < serverObject["blockOrder"][i][k].length; j++) {
              serverObject["blockOrder"][i][k][j][5] = serverObject["blockOrder"][i][k][j][5] == "changing";
            }
          });
        }
        newSchedule = serverObject["blockOrder"];
      }
      this.schedule = Schedule.makeSchedule(newSchedule);

      
    } catch(e) {
      print(e);
    }
    
  }
  School.setSchedule(Map allSchoolData) {
    
  }
}
class Event {

}
class Note {

}
class Assignment {

  final String assignment;
  final String notes;
  final String dueBy;
  MongoId id = MongoId("_");
  bool completed = false;
  final DateTime dateSubmitted;
  Assignment(this.assignment, this.notes, this.dueBy, this.id, this.completed, this.dateSubmitted);

  Assignment.fromJson(Map<String, dynamic> json) :
    assignment = json["assignment"],
    notes = json["notes"],
    dueBy = json["dueBy"],
    id = MongoId(json["id"]),
    completed = json["completed"],
    dateSubmitted = DateTime.parse(json["dateSubmitted"]);

  Map<String, dynamic> toJson() {
    return {
      "assignment": this.assignment,
      "notes": this.notes,
      "dueBy": this.dueBy,
      "id": this.id.id,
      "completed": this.completed,
      "dateSubmitted": this.dateSubmitted.toIso8601String(),
    };
  }
  void switchCompleted() {
    this.completed = !this.completed;
  }

}

class User {
  List<MongoId> courses = [];
  List<MongoId> retrievedAssignments = [];
  User();
  void setCoursesFromList(List<String> courseList) {
    this.courses = [];
    for (var i = 0; i < courseList.length; i++) {
      this.courses.add(MongoId(courseList[i]));
    }
  }
  void setCoursesFromMap(Map<dynamic, String> courseMap) {
    this.courses = [];
    courseMap.forEach((k,v) {
      this.courses.add(MongoId(v));
    });
  }

  void populateData(Map data) {

  }

  User.fromJson(Map<String, dynamic> json) {
    List<MongoId> courseList = new List<MongoId>();
    for (var i = 0; i < json["courses"].length; i++) {
      courseList.add(MongoId(json["courses"][i]));
    }
    List<MongoId> assignmentList = new List<MongoId>();
    for (var i = 0; i < json["retrievedAssignments"].length; i++) {
      assignmentList.add(MongoId(json["retrievedAssignments"][i]));
    }
    courses = courseList;
    retrievedAssignments = assignmentList;
  }
    

  Map<String, dynamic> toJson() {
    return {
      "courses": this.courses.map((x) => x.id),
      "retrievedAssignments": this.retrievedAssignments.map((x) => x.id),
    };
  }
  
}