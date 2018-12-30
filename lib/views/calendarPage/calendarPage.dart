
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:experiments/components/universalClasses.dart';










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
        
      },
      child: Container(
        width: screenWidth*0.95/7,
        height: 60.0,
        decoration: BoxDecoration(
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
  final ThemeColor configData;
  MonthDisplay(this.monthName, this.updater, this.configData);
  void setMonthName(String name) {
    this.monthName = name;
  }
  _MonthDisplay createState() {
    return _MonthDisplay();
  }
}

class _MonthDisplay extends State<MonthDisplay>{
  initState() {
    widget.updater.setPopUp(this);
    super.initState();
  }
  Widget build(BuildContext context) {
    if (widget.updater.getMonthDisplay == null) {
      widget.updater.setPopUp(this);
    }
    return Text(
      widget.monthName,
      style: TextStyle(
        color: widget.configData.textColor,
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
    try {
      currentDayBlocks = userCourseSchedule[week-1]["day" + day.toString()];
    } catch(e) {
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
  _MonthDisplay get getMonthDisplay  {
    return monthDisplay;
  }
  updateState() {
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


//TODO: fix that fucking thing where state is rebuild when you pop back from seperate page, except for some of it.
class CalendarDisplayed extends StatelessWidget {  
  // final CalendarInfo calendarInfo;
  final double screenWidth;
  final double screenHeight;
  final CalendarInfo calendarInfo;
  final List<Map<String, List>> readableSchedule;
  final ThemeColor configData;
  CalendarDisplayed(this.screenWidth, this.screenHeight, this.calendarInfo, this.readableSchedule, this.configData);
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
  final pageController = PageController(
    initialPage: (DateTime.now().month+3)%12,
  );  
  int currentYear = 2018;

  Widget makeCalendarBox(dateAc, int date, List todayInfo) {
    List todayEvents = new List();
    return GestureDetector(
      onTap: () {
        updateBottomPop(dateAc, todayEvents, todayInfo[1] ? todayInfo[0] : -1);
      },
      child: Container(
        width: screenWidth*0.95/7,
        height: 60.0,
        decoration: BoxDecoration(
          
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(
              date.toString(),
              style: TextStyle(
                color: configData.textColor,
              ),
            ),
            Opacity(
              opacity: 0.9,
              child: Text(
                todayInfo[1] == true  ? todayInfo[0] : "",
                style: TextStyle(
                  fontSize: 12.0,
                  color: configData.textColor,
                )
              ),
            ),
            Opacity(
              opacity: todayInfo[2] ? 0.6 : 0.0,
              child: Container(
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  color: configData.textColor,
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
      DateTime currentDate = DateTime(year, month, dates[i][0]);
      if (dates[i][1] == 0) {
        dateBlocks.add(MakeEmptyBox(screenWidth, dates[i][0]));
      } else {
        dateBlocks.add(makeCalendarBox(DateTime(year, month, dates[i][0]), dates[i][0], calendarInfo.dayMap[currentDate]));
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
          border: Border.all(color: configData.border, width: 1.0),
          color: configData.blockBack,
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

    monthDisplay = MonthDisplay(monthNames[currentDay] + " " + currentYear.toString(), monthUpdater, configData);

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
        color: configData.bodyBack,
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
                              color: configData.blockBack,
                              margin: EdgeInsets.only(right: 5.0),
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: Color(configData.secondaryTheme[1]),
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
                              color: configData.blockBack,
                              margin: EdgeInsets.only(left: 5.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Color(configData.secondaryTheme[1]),
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
