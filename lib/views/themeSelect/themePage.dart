
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:experiments/components/userStorage.dart';
import 'package:experiments/components/universalClasses.dart';

import 'package:experiments/components/appBar.dart';


List<List<dynamic>> colourThemes = [["Coquelicot", 0xffff3800, "Sure red is cool, but you're cooler"], ["Smaragdine", 0xff50c875, "Grass is fun"], ["Mikado", 0xffffc40c, "For when normal yellow is too intimidating"], ["Glaucous", 0xff6082b6, "Cloudy days"], ["Wenge", 0xff645452, "Not quite black"], ["Fulvous", 0xffe48400, "Socials binder from grade 5"], ["Amaranth", 0xffe52b50, "Very pretty, very nice"]];



class ColoursPick extends StatefulWidget {
  double screenWidth;
  int selectedColor;
  final ThemeColor theme;
  ColoursPick(this.screenWidth, this.selectedColor, this.theme);
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
              color: widget.theme.blockBack,
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
                    border: i != colourThemes.length-1 ? Border(bottom: BorderSide(color: widget.theme.border, width: 1.0)) : Border(),
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
                                color: widget.theme.textColor,
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
        border: Border(top: BorderSide(color: widget.theme.border, width: 1.0), bottom: BorderSide(color:widget.theme.border, width: 1.0)),
      ),
      child: Column(
        children: colourThemeWidgets,
      ),
    );
  }
}

class CoursesCorrect extends StatefulWidget {
  double screenWidth;
  List<Course> courses;
  ThemeColor theme;
  CoursesCorrect(this.courses, this.screenWidth, this.theme);
  _CoursesCorrect createState() => _CoursesCorrect();
}

class _CoursesCorrect extends State<CoursesCorrect> {
  Widget build(BuildContext context) {
    List<Widget> displayedCourses = new List<Widget>();
    for (var i = 0; i < widget.courses.length; i++) {
      displayedCourses.add(Container(
        height: 50.0,
        width: widget.screenWidth,
        color: widget.theme.blockBack,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: SchoolIcons.makeBlock(widget.courses[i].category),
            ),
            Container(
              width: widget.screenWidth-50.0,
              height: 50.0,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: widget.theme.border, width: 1.0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.courses[i].course,
                    style: TextStyle(
                      color: widget.theme.textColor,
                      fontSize: 18.0,
                    )
                  ),
                  Text(
                    widget.courses[i].teacher + ", block " + widget.courses[i].block,
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
        color: widget.theme.blockBack,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 10.0,
              height: 50.0,
            ),
            Container(
              width: widget.screenWidth-10.0,
              height: 50.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Edit Courses",
                    style: TextStyle(
                      color: widget.theme.textColor,
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
              color: widget.theme.textColor,
              fontSize: 20.0,
            )
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: widget.theme.border, width: 1.0), bottom: BorderSide(color: widget.theme.border, width: 1.0)),
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
  final ThemeColor theme;
  final _ConfigurePage page;
  ThemePicker(this.lightOrDark, this.theme, this.page);
  _ThemePicker createState() => _ThemePicker();
}

class _ThemePicker extends State<ThemePicker> {
  Widget build(BuildContext context) {
    return Container(
      width: 120.0,
      margin: EdgeInsets.only(top: 20.0),
      child: CupertinoSegmentedControl(
        onValueChanged: (value) {
          widget.lightOrDark = value;
          widget.page.widget.configData.themeData.mainTheme = value;
          widget.page.widget.configData.themeData.update();
          widget.page.setState(() {

          });
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

class ConfigurePage extends StatefulWidget {
  final ConfigInfo configData;
  ConfigurePage(this.configData);
  _ConfigurePage createState() {
    return _ConfigurePage();
  }
}
class _ConfigurePage extends State<ConfigurePage> {

  

  Widget build(BuildContext context) {
    
    final screenDimensions = MediaQuery.of(context).size;
    ColoursPick colourPickPage = ColoursPick(screenDimensions.width, widget.configData.themeData.secondaryTheme[0], widget.configData.themeData);
    ThemePicker themePickPage = ThemePicker(widget.configData.themeData.mainTheme, widget.configData.themeData, this);
    return Scaffold(
      appBar: makeAppBar(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(
              "Theme",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.0,
              )
            ),
          ],
        ), 
        screenDimensions.width
      ),
      body: Container(
        width: screenDimensions.width,
        height: screenDimensions.height,
        color: widget.configData.themeData.bodyBack,
        // margin: EdgeInsets.only(top: 20.0),
        child: ListView(
          children: <Widget>[
            themePickPage,
            colourPickPage,
            CoursesCorrect(widget.configData.courses, screenDimensions.width, widget.configData.themeData),
            Container(
              margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Center(
                child: Material(
                  color: widget.configData.themeData.blockBack,
                  child: InkWell(
                    onTap: () async {
                      Map newColoursObject = {
                        "mainTheme": themePickPage.lightOrDark,
                        "secondaryTheme": [colourPickPage.selectedColor, colourThemes[colourPickPage.selectedColor][1]],
                      };
                      UserStorage storage = new UserStorage();
                      await storage.writeUserData(newColoursObject, "configData.json");
                      await Future.delayed(Duration(milliseconds: 50));
                      
                      Navigator.pushNamedAndRemoveUntil(context,"/", (_) => false);
                    },
                    child: Container(
                      width:85.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        border: Border.all(color: Color(widget.configData.themeData.secondaryTheme[1]), width: 1.0),
                        
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Ok",
                            style: TextStyle(
                              color: Color(widget.configData.themeData.secondaryTheme[1]),
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
