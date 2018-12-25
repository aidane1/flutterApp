import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'classes/homeViewPage.dart';
import 'classes/courseViewPage.dart';
import 'classes/calendarViewPage.dart';
import 'classes/scheduleViewPage.dart';
import 'package:experiments/components/appBar.dart';
import 'package:experiments/components/universalClasses.dart';








class HomePage extends StatelessWidget {
  final HomeInfo homeInfo;
  HomePage(this.homeInfo);
  @override
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;
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
                Navigator.of(context).pushNamed("/configure");
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
          SchedulePage(homeInfo.readableSchedule, screenDimensions),
          HomeViewPage("1", homeInfo.upcomingBlocks[0], homeInfo.upcomingBlocks[1], homeInfo.themeData, screenDimensions),
          CourseViewPage(homeInfo.dayblocks, screenDimensions, homeInfo.themeData),
          CalendarDisplayed(screenWidth: screenDimensions.width, screenHeight: screenDimensions.height, events: homeInfo.events, rolledDays: homeInfo.rolledDays, schoolSkipped: homeInfo.schoolSkipped, readableSchedule: [], configData: homeInfo.themeData).build(context),
        ]
      ),
    );
  }
}