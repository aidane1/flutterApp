import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:experiments/components/universalClasses.dart';

class UserStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  Future<File> _localFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }
  Future<Map> readUserData(String fileName) async {
    try {
      final userInfo = await _localFile(fileName);
      String stringifiedData = await userInfo.readAsString();
      Map decodedData = json.decode(stringifiedData);
      return decodedData;
    } catch (e) {
      return ({});
    }
  }
  Future<File> writeUserData(Map data, String fileName) async {
    final userInfo = await _localFile(fileName);
    try {
      String stringifiedData = await userInfo.readAsString();
      Map decodedData = json.decode(stringifiedData);
      data.forEach((k, v) {
        decodedData[k] = v;
      });
      return userInfo.writeAsString(jsonEncode(decodedData));
    } catch (e) {
      return userInfo.writeAsString(jsonEncode(data));
    }
  }
  Future<List> readIdData(String fileName) async {
    try {
      final userInfo = await _localFile(fileName);
      String stringifiedData = await userInfo.readAsString();
      List decodedData = json.decode(stringifiedData);
      return decodedData;
    } catch (e) {
      return ([]);
    }
  }
  Future<File> writeIdData(List ids, String fileName) async {
    final userInfo = await _localFile(fileName);
    try {
      return userInfo.writeAsString(jsonEncode(ids));
    } catch(e) {
      return userInfo;
    }
  }
}