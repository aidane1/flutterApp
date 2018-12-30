import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:experiments/components/universalClasses.dart';



//Start of Homepage classes
class BoxView extends StatelessWidget {
  final String title;
  final String content;
  final double screenWidth;
  final ThemeColor configData;
  BoxView(this.title, this.content, this.screenWidth, this.configData);
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontSize: 22.0,
            color: configData.textColor,
          ),
        ), 
        Container(
          width: screenWidth*0.85,
          margin: EdgeInsets.only(top: 10.0),
          child: Card(
            child: Container(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              decoration: BoxDecoration(
                border: Border.all(color: configData.border, width: 1.0),
                color: configData.blockBack,
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                boxShadow: <BoxShadow>[
                  
                ],
              ),
              child: Center(
                child: Text(
                  content,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: configData.textColor,
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
  final List<String> events;
  final double screenWidth;
  final ThemeColor configData;
  EventView(this.title, this.events, this.screenWidth, this.configData);
  Widget build(BuildContext context) {
    List<Widget> eventWidgets = new List<Widget>();
    for (var i = 0; i < events.length; i++) {
      eventWidgets.add(
        Container(
          width: screenWidth*0.85,
          child: Card(
            child: Container(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              decoration: BoxDecoration(
                border: Border.all(color: configData.border, width: 1.0),
                color: configData.blockBack,
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                boxShadow: <BoxShadow>[
                  
                ],
              ),
              child: Center(
                child: Text(
                  events[i],
                  style: TextStyle(
                    fontSize: 20.0,
                    color: configData.textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } 
    return Column(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontSize: 22.0,
            color: configData.textColor,
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
  final UpcomingBlock currentBlock;
  final UpcomingBlock nextBlock;
  final ThemeColor themeData;
  final screenDimensions;
  HomeViewPage(this.day, this.currentBlock, this.nextBlock, this.themeData, this.screenDimensions);
  @override
  Widget build(BuildContext context) {
    return Container(
      
      decoration: BoxDecoration(
        color: themeData.bodyBack,
        // gradient: LinearGradient(
        //     begin: Alignment.topRight,
        //     end: Alignment.bottomLeft,
        //     stops: [0.2, 1.0],
        //     colors: [
        //       Color.fromARGB(255, 255, 102, 0),
        //       Color.fromARGB(255, 153, 0, 51),
        //     ],
        //   )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text(
            'Day ' + day,
            style: TextStyle(
              color: themeData.textColor,
              fontSize: 40.0,
            )
          ),
          EventView("Upcoming Events: ", ["Tomorrow: Bake Sale!", "yeee i hate everything"], screenDimensions.width, themeData),
          currentBlock.inSchoolHours ? BoxView(currentBlock.title, '${currentBlock.time.toString()} : ${currentBlock.course.course}', screenDimensions.width, themeData) :  BoxView("Current Block: ", "Nothing!", screenDimensions.width, themeData),
          nextBlock.inSchoolHours ? BoxView(nextBlock.title, '${nextBlock.time.toString()} : ${nextBlock.course.course}', screenDimensions.width, themeData) : BoxView("Next Block", "Nothing!", screenDimensions.width, themeData),
        ]
      )
    );
  }
}

