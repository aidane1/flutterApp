import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:experiments/components/appBar.dart';
import 'package:experiments/components/universalClasses.dart';


Map<String, Color> scheduleColors = {
  "A": Colors.red,
  "B": Colors.blue,
  "C": Colors.green,
  "D": Colors.purple,
  "E": Colors.orange,
};



bool isDark(Color color) {
  // double darkness = 1-(0.299*Color.red(color) + 0.587*Color.green(color) + 0.114*Color.blue(color))/255
  return false;
}
class SchedulePage extends StatelessWidget {
  ReadableSchedule schedule;
  final screenDimensions;
  SchedulePage(this.schedule, this.screenDimensions);

  makeWeekSchedule(ReadableScheduleWeek weekSchedule) {
    List<Widget> scheduleColumns = new List<Widget>();
    weekSchedule.days.forEach((k,v) {
      List<Widget> scheduleBlocks = new List<Widget>();
      ReadableScheduleDay currentRow = weekSchedule.days[k];
      scheduleBlocks.add(
        Container(
          width: 90.0,
          height: 30.0,
          child: Text(
            currentRow.title != null ? currentRow.title : "",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
      for (var i = 0; i < currentRow.blocks.length; i++) {
        // print(currentRow.blocks[i].course.course);
        scheduleBlocks.add(
          Container(
            width: 90.0,
            height: currentRow.blocks[i].time.lengthInMinutes().toDouble()*1.2 > 44.0 ? currentRow.blocks[i].time.lengthInMinutes().toDouble()*1.2 : 44.0,
            decoration: BoxDecoration(
              color: scheduleColors[currentRow.blocks[i].course.block] != null ? scheduleColors[currentRow.blocks[i].course.block] : Colors.white,
              border: Border.all(color: Colors.black, width: 1.0)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  currentRow.blocks[i].course.course,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.0,
                  )
                ),
                Text(
                  currentRow.blocks[i].time.toString(),
                  style: TextStyle(
                    fontSize: 12.0,
                  ),
                ),
                currentRow.blocks[i].course.isReal ? Text(
                  currentRow.blocks[i].course.teacher,
                  style: TextStyle(
                    fontSize: 12.0,
                  )
                ) : Container(width: 0.0, height: 0.0),
              ],
            ),
          ),
        );
      }
      scheduleColumns.add(
        Container(
          width: 90.0,
          child: Column(
            children: scheduleBlocks,
          ),
        ),
      );
    });
    return Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: scheduleColumns,
        ),
      ),
    );
  }


  Widget build(BuildContext context) {
    List<Widget> fullScheduleWidgets = new List<Widget>();
    for (var i = 0; i < schedule.schedule.length; i++) {
      fullScheduleWidgets.add(makeWeekSchedule(schedule.schedule[i]));
    }
    return Container(
        // color: Color.fromARGB(255, 90, 80, 80),
        child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: screenDimensions.width,
          height: screenDimensions.height-100.0,
          child: Container(
            decoration: BoxDecoration(

            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: fullScheduleWidgets,
              ),
            ),
          ),
        ),
      ),
    );
  }
}