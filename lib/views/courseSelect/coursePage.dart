
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:experiments/components/userStorage.dart';
import 'package:experiments/components/appBar.dart';
import 'package:experiments/components/universalClasses.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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

class SelectCourses extends StatelessWidget {
  final CourseInfo courseInfo;
  SelectCourses(this.courseInfo);
  @override
  Widget build(BuildContext context) {
    List notDisplayedblocks = [];
    
    courseInfo.userCourses.blocks.forEach((k,v) {
      notDisplayedblocks.add(k);
    });

    DropdownTiles tiles = DropdownTiles(courseInfo.allCourses, notDisplayedblocks, courseInfo.blockNames, courseInfo.userCourses, courseInfo.idPairs, courseInfo.themeData);
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
        color: courseInfo.themeData.bodyBack,
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
  List<Course> courses;
  List removedBlocks;
  List blockList;
  BasicList coursesMap;
  Map<String, MongoId> blockIdPairs;
  ThemeColor config;
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
    Map<String, List<Course>> dropDownBlocks = new Map<String, List<Course>>();
    for (var i = 0; i < widget.courses.length; i++) {
      if (dropDownBlocks[widget.courses[i].category] != null) {
        if (widget.removedBlocks.contains(widget.courses[i].block)) {

        } else {
          dropDownBlocks[widget.courses[i].category].add(widget.courses[i]);
        }
        
      } else {
        if (widget.removedBlocks.contains(widget.courses[i].block)) {
          dropDownBlocks[widget.courses[i].category] = [];
        } else {
          dropDownBlocks[widget.courses[i].category] = [widget.courses[i]];
        }
      }
    }
    List<Widget> dropDownList = new List<Widget>();
    dropDownBlocks.forEach((k,v) {
      dropDownBlocks[k].sort((a,b) {
        return a.teacher.compareTo(b.teacher);
      });
      List<Widget> currentDropDown = new List<Widget>();
      for (var i = 0; i < dropDownBlocks[k].length; i++) {
        
        currentDropDown.add(
          GestureDetector(
            onTap: () {
              widget.coursesMap.blocks[dropDownBlocks[k][i].block] = dropDownBlocks[k][i];
              widget.blockIdPairs[dropDownBlocks[k][i].block] = dropDownBlocks[k][i].id;
              widget.removedBlocks.add(dropDownBlocks[k][i].block);
              update();
            },
            child: Container(
              height: 40.0,
              padding: EdgeInsets.only(left: 10.0),
              // margin: EdgeInsets.only(left: 10.0),
              decoration: BoxDecoration(
                border: Border(top: i == 0 ? BorderSide(width: 1.0, color: widget.config.border) : BorderSide(width: 0.0, color: widget.config.blockBack)),
                color: widget.config.blockBack,
              ),
              child: Container(
                padding: EdgeInsets.only(right: 10.0),
                decoration: BoxDecoration(
                  border: i == dropDownBlocks[k].length-1 ? Border() : Border(bottom: BorderSide(width: 1.0, color: widget.config.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      dropDownBlocks[k][i].teacher,
                      style: TextStyle(
                        color: widget.config.textColor,
                        fontSize: 16.0,
                      ),
                    ),
                    Text(
                      dropDownBlocks[k][i].course,
                      style: TextStyle(
                        color: widget.config.textColor,
                        fontSize: 16.0,
                      ),
                    ),
                    Text(
                      dropDownBlocks[k][i].block,
                      style: TextStyle(
                        color: widget.config.textColor,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                )
              ),
            )
          )
        );
      }

      dropDownList.add(
        Container(
          decoration: BoxDecoration(
            color: widget.config.bodyBack,
            // border: Border.all(width: 1.0, color: widget.config.border),
          ),
          child: ExpansionTile(
            title: Container(
              // color: widget.config.bodyBack,
              child: Row(
                children: <Widget>[
                  SchoolIcons.makeBlock(k),
                  Text(
                    k,
                    style: TextStyle(
                      color: widget.config.textColor,
                    ),
                  ),
                ],
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
            padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0),
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: widget.config.border),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  widget.coursesMap.blocks[widget.blockList[i][0]].course,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: widget.config.textColor,
                    
                  ),
                ),
                IconButton(
                  onPressed: () {
                    widget.blockIdPairs.remove(widget.blockList[i][0]);
                    widget.coursesMap.blocks.remove(widget.blockList[i][0]);
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
              border: Border.all(width: 1.0, color: widget.config.border),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  "LC's",
                  style: TextStyle(
                    color: widget.config.textColor,
                  ),
                ),
              ],
            ),
          ));
        }
      } else {

      }
    }
    return Container(
      color: widget.config.blockBack,
      margin: EdgeInsets.only( top: 20.0),
      child: Column(
        children: columnBlocks,
      ),
    );
  }
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        makeTilesDropDown(),
        makeColumn(),
        Container(
          margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
          child: Center(
            child: Material(
              color: widget.config.blockBack,
              child: InkWell(
                onTap: () async {
                  UserStorage storage = UserStorage();
                  List<MongoId> ids = new List<MongoId>();
                  widget.blockIdPairs.forEach((k,v) {
                    ids.add(v);
                  });
                  storage.writeUserData({"courses": ids}, "userData.json");
                  await Future.delayed(Duration(milliseconds: 50));
                  Navigator.pushNamedAndRemoveUntil(context,"/", (_) => false);
                },
                child: Container(
                  width:85.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(color: Color(widget.config.secondaryTheme[1]), width: 1.0),
                    
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Ok",
                        style: TextStyle(
                          color: Color(widget.config.secondaryTheme[1]),
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
    );
  }
}
