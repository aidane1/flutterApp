import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:experiments/components/userStorage.dart';
import 'package:experiments/components/universalClasses.dart';


const double _kPickerSheetHeight = 216.0;
const double _kPickerItemHeight = 32.0;



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
    super.initState();
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
            Center(
              child: Container(
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
                child: Material(
                  color: Color.fromARGB(0, 0, 0, 0),
                  child: InkWell(
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
                          List<Course> courseList = new List<Course>();
                          for (var i = 0; i < userInfo["courses"].length; i++) {
                            Course currentCourse = new Course();
                            currentCourse.populateData(userInfo["courses"][i]);
                            courseList.add(currentCourse);
                          }
                          UserStorage storage = new UserStorage();
                          Map schoolObject = schoolFromObject(userInfo["school"]);
                          Map coursesObject = {"courses": courseList};
                          List<Map> eventList = new List<Map>();
                          for (var i = 0; i < userInfo["events"].length; i++) {
                            if (userInfo["events"][i]["info"] == null)  {
                              userInfo["events"][i]["info"] = "";
                            }
                            Event currentEvent = Event.fromJson({"date": userInfo["events"][i]["date"], "time": userInfo["events"][i]["time"], "shortInfo": userInfo["events"][i]["info"], "longInfo": userInfo["events"][i]["longInfo"], "schoolSkipped": userInfo["events"][i]["schoolSkipped"], "dayRolled": userInfo["events"][i]["dayRolled"], "eventShown": userInfo["events"][i]["displayedEvent"]});
                            if (currentEvent.isReal) {
                              eventList.add(currentEvent.toJson());
                            } else {
                              print(userInfo["events"][i]);
                            }
                          }
                          await storage.writeUserData(schoolObject, "schoolData.json");
                          await storage.writeUserData(coursesObject, "coursesData.json");
                          await storage.writeUserData({"events": eventList}, "eventsData.json");
                          await storage.writeUserData({"courses": userInfo["user"]["courses"], "retrievedAssignments": []}, "userData.json");
                          await storage.writeUserData(userPass, "userPass.json");
                          Navigator.pushNamedAndRemoveUntil(context,"/configure", (_) => false);
                        }
                      }
                    },
                    child: Container(
                      width: widget.screenWidth*0.95,
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
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
                ),
              ),
            ),
            // GestureDetector(
            //   onTap: () async {
            //     if (_formKey.currentState.validate()) {
            //       _formKey.currentState.save();
            //       Map userInfo  = await (fetchFromServer(_school["id"], _username, _password));
            //       if (userInfo["user"] != null) {
            //         Map userPass = {
            //           "school": _school,
            //           "username": _username,
            //           "password": _password,
            //         };

            //         List<Course> courseList = new List<Course>();
            //         for (var i = 0; i < userInfo["courses"].length; i++) {
            //           Course currentCourse = new Course();
            //           currentCourse.populateData(userInfo["courses"][i]);
            //           courseList.add(currentCourse);
            //         }

            //         UserStorage storage = new UserStorage();
            //         Map schoolObject = schoolFromObject(userInfo["school"]);
            //         Map coursesObject = {"courses": courseList};
            //         List<Map> eventList = new List<Map>();

            //         for (var i = 0; i < userInfo["events"].length; i++) {
            //           Event currentEvent = Event.fromJson({"date": userInfo["events"][i]["date"], "time": userInfo["events"][i]["time"], "shortInfo": userInfo["events"][i]["info"], "longInfo": userInfo["events"][i]["longInfo"], "schoolSkipped": userInfo["events"][i]["schoolSkipped"], "dayRolled": userInfo["events"][i]["dayRolled"], "eventShown": userInfo["events"][i]["displayedEvent"]});
            //           if (currentEvent.isReal) {
                        
            //             eventList.add(currentEvent.toJson());
            //           }
            //         }
            //         await storage.writeUserData(schoolObject, "schoolData.json");
            //         await storage.writeUserData(coursesObject, "coursesData.json");
            //         await storage.writeUserData({"events": eventList}, "eventsData.json");
            //         await storage.writeUserData({"courses": userInfo["user"]["courses"], "retrievedAssignments": []}, "userData.json");
            //         await storage.writeUserData(userPass, "userPass.json");
            //         Navigator.pushNamedAndRemoveUntil(context,"/configure", (_) => false);
            //       }
            //     }
            //   },
            //   child: Container(
            //     width: widget.screenWidth*0.95,
            //     padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            //     margin: EdgeInsets.only(top: 20.0),
            //     decoration: BoxDecoration(
            //       gradient: LinearGradient(
            //         begin: Alignment.centerLeft,
            //         end: Alignment.centerRight,
            //         stops: [0.2, 1.0],
            //         colors: [
            //           Color.fromARGB(255, 0, 153, 153),
            //           Color.fromARGB(255, 0, 130, 209),
            //         ],
            //       ),
            //       borderRadius: BorderRadius.all(Radius.circular(7.0)),
            //     ),
            //     child: Center(
            //       child: Text(
            //         "LOGIN",
            //         style: TextStyle(
            //           fontSize: 22.0,
            //           color: Colors.white,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
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
