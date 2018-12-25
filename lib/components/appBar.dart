
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

PreferredSize makeAppBar(Row barTop, double screenWidth) {
  return PreferredSize(
    preferredSize: Size(screenWidth, 70.0),
    child: Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 5.0, left: 10.0, right: 10.0),
      width: screenWidth,
      height: 70.0,
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
      ),
      child: barTop,
    ),
  );
}
