import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:experiments/components/appBar.dart';
import 'package:experiments/components/universalClasses.dart';
import 'package:experiments/components/userStorage.dart';
import 'package:intl/intl.dart';




Future<List<Event>> retrieveEventsFromStorage() async {
  List<Event> events= await Event.retrieveAllFromStorage();
  return events;
}
class EventBubble extends StatelessWidget {
  final Event event;
  final ThemeColor theme;
  EventBubble(this.event, this.theme);
  Widget build(BuildContext context) {
    DateFormat formatter = new DateFormat('MMMM dd, yyyy');
    Color currentBack = Color(theme.secondaryTheme[1]);
    return Container(
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(10.0),
      
      decoration: BoxDecoration(
        color: Color.fromARGB(150, currentBack.red, currentBack.green, currentBack.blue),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Event: ",
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 16.0,
                )
              ),
              Text(
                event.longInfo,
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 16.0,
                )
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "date: ",
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 16.0,
                )
              ),
              Text(
                formatter.format(event.date),
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 16.0,
                )
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "school skipped: ",
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 16.0,
                )
              ),
              Text(
                event.schoolSkipped ? "yes" : "no",
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 16.0,
                )
              ),
            ],
          ),
        ],
      ),
    );
  }
}
Future<Widget> makeAllEventsBubbles(ThemeColor theme) async {
  List<Event> eventsList = await retrieveEventsFromStorage();
  eventsList.sort((a,b) {
    return a.date.millisecondsSinceEpoch.compareTo(b.date.millisecondsSinceEpoch);
  });
  List<Widget> eventBubbles = new List<Widget>();
  for (var i = 0; i < eventsList.length; i++) {
    eventBubbles.add(EventBubble(eventsList[i], theme));
  }
  return Column(
    children: eventBubbles,
  );
}




class EventsPage extends StatelessWidget {
  final EventInfo eventInfo;
  EventsPage(this.eventInfo);
  @override
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;
    return Scaffold(
      appBar: makeAppBar(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.chevron_left, size: 30.0,),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            ),
            
            Text(
              "Events",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.0,
              )
            ),
            Container(
              color: Color.fromARGB(0, 0, 0, 0),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.chevron_right, size: 30.0,),
                    color: Color.fromARGB(0, 0, 0, 0),
                    onPressed: () {
                      
                    },
                  ),
                ],
              )
            ),
          ],
        ), 
        screenDimensions.width,
      ),
      body: Container(
        color: eventInfo.themeData.bodyBack,
        child: ListView(
          children: <Widget>[
            FutureBuilder(
              future: makeAllEventsBubbles(eventInfo.themeData),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data;
                } else if (snapshot.hasError) {
                  return CircularProgressIndicator();
                } else {
                  return CircularProgressIndicator();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}