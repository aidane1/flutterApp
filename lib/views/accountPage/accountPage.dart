import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:experiments/components/appBar.dart';
import 'package:experiments/components/universalClasses.dart';








class AccountPage extends StatelessWidget {
  
  final AccountInfo accountInfo;
  AccountPage(this.accountInfo);
  @override
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;
    GestureDetector makeAccountRoute(String title, String icon, bool isLast, callBack) {
      return GestureDetector(
        onTap: () {
          callBack();
        },
        child: Container(
          width: screenDimensions.width,
          height: 50.0,
          color: accountInfo.themeData.blockBack,
          child: Row(
            children: <Widget> [
              SchoolIcons.makeBlock(icon),
              Container(
                width: screenDimensions.width-50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  border: isLast == false ? Border(bottom: BorderSide(width: 1.0, color: accountInfo.themeData.border)) : Border(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: accountInfo.themeData.textColor,
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
        ),
      );
    }
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
              "Account",
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
        screenDimensions.width,
      ),
      body: Container(
        color: accountInfo.themeData.bodyBack,
        child: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 20.0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(width: 1.0, color: accountInfo.themeData.border), bottom: BorderSide(width: 1.0, color: accountInfo.themeData.border)),
              ),
              child: Column(
                children: <Widget>[
                  makeAccountRoute("Theme", "theme", false, () {
                    Navigator.pushNamed(context, "/configure");
                  }),
                  makeAccountRoute("Courses", "courses", false, () {
                    Navigator.pushNamed(context, "/courses");
                  }),
                  makeAccountRoute("Events", "events", false, () {
                    Navigator.pushNamed(context, "/events");
                  }),
                  makeAccountRoute("Logout", "logout", true, () {
                    Navigator.pushNamedAndRemoveUntil(context,"/login", (_) => false);
                  }),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20.0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(width: 1.0, color: accountInfo.themeData.border), bottom: BorderSide(width: 1.0, color: accountInfo.themeData.border)),
              ),
              child: Column(
                children: <Widget>[
                  makeAccountRoute("Notes", "notes", false, () {
                    Navigator.pushNamed(context, "/allNotes");
                  }),
                  makeAccountRoute("Assignments", "assignments", false, () {
                    Navigator.pushNamed(context, "/allAssignments");
                  }),
                  makeAccountRoute("Reminders", "reminders", true, () {
                    Navigator.pushNamed(context, "/reminders");
                  }),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20.0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(width: 1.0, color: accountInfo.themeData.border), bottom: BorderSide(width: 1.0, color: accountInfo.themeData.border)),
              ),
              child: Column(
                children: <Widget>[
                  makeAccountRoute("Block Colours", "colours", false, () {
                    Navigator.pushNamed(context, "/configure");
                  }),
                  makeAccountRoute("Block Names", "names", false, () {
                    Navigator.pushNamed(context, "/courses");
                  }),
                  makeAccountRoute("Day Titles", "titles", true, () {
                    Navigator.pushNamed(context, "/events");
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}