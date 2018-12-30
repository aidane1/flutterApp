import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:experiments/components/userStorage.dart';
import 'package:experiments/components/universalClasses.dart';
import 'package:experiments/components/appBar.dart';
import 'package:intl/intl.dart';

import 'package:flutter/widgets.dart';



const Duration _kExpand = Duration(milliseconds: 200);
class DatePicker extends StatefulWidget {
  const DatePicker({
    Key key,
    this.theme,
  }) : super(key: key);
  final ThemeColor theme;
  @override
  _ExpansionTileState createState() => _ExpansionTileState();
}

class _ExpansionTileState extends State<DatePicker> with SingleTickerProviderStateMixin {
  DateTime date = DateTime.now();
  DateFormat formatter = new DateFormat("MMM d, yyyy");
  DateFormat hourFormatter = new DateFormat().add_jm();
  static final Animatable<double> _easeOutTween = CurveTween(curve: Curves.easeOut);
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween = Tween<double>(begin: 0.0, end: 0.5);
  final ColorTween _borderColorTween = ColorTween();
  final ColorTween _headerColorTween = ColorTween();
  final ColorTween _iconColorTween = ColorTween();
  final ColorTween _backgroundColorTween = ColorTween();
  AnimationController _controller;
  Animation<double> _heightFactor;
  Animation<Color> _backgroundColor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    _backgroundColor = _controller.drive(_backgroundColorTween.chain(_easeOutTween));
    if (_isExpanded)
      _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((void value) {
          if (!mounted)
            return;
          setState(() {
            // Rebuild without widget.children.
          });
        });
      }
      PageStorage.of(context)?.writeState(context, _isExpanded);
    });
  }

  Widget _buildChildren(BuildContext context, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor.value ?? Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: _handleTap,
            child: Container(
              height: 50.0,
              margin: EdgeInsets.only(left: 10.0),
              padding: EdgeInsets.only(right: 5.0),
              decoration: BoxDecoration(
                border: _isExpanded ? Border(bottom: BorderSide(width: 1.0, color: widget.theme.border)) : Border(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Time ",
                    style: TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 18.0,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        formatter.format(date),
                        style: TextStyle(
                          fontSize: 18.0,
                          color: _isExpanded ? CupertinoColors.destructiveRed : CupertinoColors.black,
                        ),
                      ),
                      Container(width: 20.0),
                      Text(
                        hourFormatter.format(date),
                        style: TextStyle(
                          fontSize: 18.0,
                          color: _isExpanded ? CupertinoColors.destructiveRed : CupertinoColors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: Align(
              heightFactor: _heightFactor.value,
              child: Container(
                height: 216.0,
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 22.0,
                    color: CupertinoColors.black,
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.dateAndTime,
                    initialDateTime: DateTime.now(),                
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() => date = newDateTime);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    _borderColorTween
      ..end = theme.dividerColor;
    _headerColorTween
      ..begin = theme.textTheme.subhead.color
      ..end = theme.accentColor;
    _iconColorTween
      ..begin = theme.unselectedWidgetColor
      ..end = theme.accentColor;
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
    );
  }
}


const double _kPickerSheetHeight = 216.0;
const double _kPickerItemHeight = 32.0;
List<String> reminderSubjects = ["Test", "Assignment Due", "Lunch Time Activity", "Before School Activity", "After School Activity", "Performance", "Field Trip"];


class MakeReminders extends StatefulWidget {
  final ThemeColor theme;
  int currentIndex = 0;
  MakeReminders(this.theme);
  _MakeReminders createState() {
    return _MakeReminders();
  }
}
class _MakeReminders extends State<MakeReminders> {
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
  Widget _buildMenu(List<Widget> children) {
    return Container(
      margin: EdgeInsets.only(left: 10.0),
      padding: EdgeInsets.only(right: 5.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1.0, color: widget.theme.border)),
      ),
      height: 50.0,
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
        FixedExtentScrollController(initialItem: 0);
    // _school = schoolNames[_selectedSchoolIndex];
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
                  setState(() {
                    widget.currentIndex = index;
                    // _selectedSchoolIndex = index)
                  });
                  // _school = schoolNames[_selectedSchoolIndex];
                },
                children: List<Widget>.generate(reminderSubjects.length, (int index) {
                  return Center(child:
                    Text(
                      reminderSubjects[index]
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
          Text(
            "Action",
            style: TextStyle(
              fontSize: 18.0,
              color: CupertinoColors.black,
            ),
          ),
          Text(
            reminderSubjects[widget.currentIndex],
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
  Widget build(BuildContext context) {
    return _buildSchoolPicker(context);
  }
}


class PickCourse extends StatefulWidget {
  final ThemeColor theme;
  final List<Course> courses;
  int currentIndex = 0;
  PickCourse(this.theme, this.courses);
  _PickCourse createState() {
    return _PickCourse();
  }
}
class _PickCourse extends State<PickCourse> {
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
  Widget _buildMenu(List<Widget> children) {
    return Container(
      margin: EdgeInsets.only(left: 10.0),
      padding: EdgeInsets.only(right: 5.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1.0, color: widget.theme.border)),
      ),
      height: 50.0,
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
        FixedExtentScrollController(initialItem: 0);
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
                  setState(() {
                    widget.currentIndex = index;
                  });
                },
                children: List<Widget>.generate(widget.courses.length, (int index) {
                  return Center(child:
                    Text(
                      widget.courses[index].course
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
          Text(
            "Course",
            style: TextStyle(
              fontSize: 18.0,
              color: CupertinoColors.black,
            ),
          ),
          Text(
            widget.courses[widget.currentIndex].course,
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
  Widget build(BuildContext context) {
    return _buildSchoolPicker(context);
  }
}

Widget makeCheckIcon(bool filled) {
  return Container(
    width: 50.0,
    height: 50.0,
  );
}

class ReminderChoice extends StatefulWidget {
  final String choice;
  final double screenWidth;
  final bool isLast;
  final ThemeColor theme;
  ReminderChoice(this.choice, this.screenWidth, this.isLast, this.theme);
  _ReminderChoice createState() {
    return _ReminderChoice();
  }
}
class _ReminderChoice extends State<ReminderChoice> {
  Widget build(BuildContext context) {
    return Container(
      width: widget.screenWidth,
      height: 50.0,
      child: Row(
        children: <Widget>[
          makeCheckIcon(false),
          Container(
            width: widget.screenWidth - 50.0,
            height: 50.0,
            decoration: BoxDecoration(
              border: widget.isLast ? Border() : Border(bottom: BorderSide(width: 1.0, color: widget.theme.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.choice,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: widget.theme.textColor,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MakeReminderBar extends StatelessWidget {
  final double screenWidth;
  final ThemeColor theme;
  MakeReminderBar(this.screenWidth, this.theme);
  List<String> reminderChoices = ["1 hour", "30 minutes", "15 minutes", "10 minutes", "5 minutes", "1 minute"];
  Widget build(BuildContext context) {
    List<Widget> reminderBars = new List<Widget>.generate(reminderChoices.length, (int index) => ReminderChoice(reminderChoices[index], screenWidth, index == reminderChoices.length-1, theme));
    return Column(
      children: reminderBars,
    );
  }
}
class ReminderPage extends StatelessWidget {
  final RemindersInfo remindersInfo;
  ReminderPage(this.remindersInfo);
  Widget build(BuildContext context) {
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
              "Reminders",
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
        child: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 20.0),
                  decoration: BoxDecoration(
                    color: remindersInfo.themeData.blockBack,
                    border: Border(top: BorderSide(width: 1.0, color: remindersInfo.themeData.border), bottom: BorderSide(width: 1.0, color: remindersInfo.themeData.border)),
                  ),
                  child: Column(
                    children: <Widget>[
                      MakeReminders(remindersInfo.themeData),
                      PickCourse(remindersInfo.themeData, remindersInfo.courses),
                      DatePicker(theme: remindersInfo.themeData),
                    ],
                  ),
                ),
                Container(
                  width: screenDimensions.width,
                  margin: EdgeInsets.only(top: 20.0),
                  child: Text(
                    // "Remind Me in Advance",
                    "REMIND ME IN ADVANCE",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: remindersInfo.themeData.blockBack,
                    border: Border(top: BorderSide(width: 1.0, color: remindersInfo.themeData.border), bottom: BorderSide(width: 1.0, color: remindersInfo.themeData.border)),
                  ),
                  child: Column(
                    children: <Widget>[
                      MakeReminderBar(screenDimensions.width, remindersInfo.themeData),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}