//TODO: Add retrieval from server when online
//TODO: Update list of retrieved notes when a new note is recieved
//TODO: Send notes that were created offline when online

//files that will be worked with: 
//retrievedNotesIds.json
//retrievedNotes.json
//bufferedNotes.json
import 'package:experiments/components/universalClasses.dart';
import 'package:experiments/components/userStorage.dart';
import 'package:experiments/components/httpRequests.dart';
import 'dart:convert';

class Assignment {

  final String assignment;
  final String notes;
  final String dueBy;
  MongoId id = MongoId("_");
  bool completed = false;
  final DateTime dateSubmitted;
  Assignment(this.assignment, this.notes, this.dueBy, this.id, this.completed, this.dateSubmitted);

  Assignment.fromJson(Map<String, dynamic> json) :
    assignment = json["assignment"],
    notes = json["notes"],
    dueBy = json["dueBy"],
    id = MongoId(json["id"]),
    completed = json["completed"],
    dateSubmitted = DateTime.parse(json["dateSubmitted"]);

  Map<String, dynamic> toJson() {
    return {
      "assignment": this.assignment,
      "notes": this.notes,
      "dueBy": this.dueBy,
      "id": this.id.id,
      "completed": this.completed,
      "dateSubmitted": this.dateSubmitted.toIso8601String(),
    };
  }
  void switchCompleted() {
    this.completed = !this.completed;
  }

}

class Assignments {
  static Future<List<MongoId>> getRetrievedIds(MongoId id) async {
    UserStorage storage = new UserStorage();
    List assignmentIds = await storage.readIdData("retrievedAssignmentsIds${id.id}.json");
    if (assignmentIds == null || assignmentIds.length == 0 || assignmentIds[0] == null) {
      return [];
    } else {
      List<MongoId> returnList = new List<MongoId>();
      for (var i = 0; i < assignmentIds.length; i++) {
        returnList.add(MongoId(assignmentIds[i]));
      }
      return returnList;
    }
  }
  static Future<void> retrieveFromServer(MongoId id) async {
    UserStorage storage = new UserStorage();
    List<MongoId> retrievedIds = await getRetrievedIds(id);
    List storageNotes = await storage.readIdData("retrievedAssignments${id.id}.json");
    var retrievedNotes = await Requests.postRequest("retrieveAssignments?courseID=${id.id}", {"retrievedIDs" : json.encode(retrievedIds)});
    if (retrievedNotes != null && retrievedNotes.length != null) {
      for (var i = 0; i < retrievedNotes.length; i++) {
        retrievedIds.add(MongoId(retrievedNotes[i]["_id"].toString()));
        storageNotes.add(Assignment(retrievedNotes[i]["assignment"], retrievedNotes[i]["notes"], retrievedNotes[i]["due"], MongoId(retrievedNotes[i]["_id"]), false, DateTime.now()));
      }
    }
    await storage.writeIdData(retrievedIds, "retrievedAssignmentsIds${id.id}.json");
    await storage.writeIdData(storageNotes, "retrievedAssignments${id.id}.json");
  }
  static Future<List<Assignment>> retrieveAssignments(MongoId id) async {
    UserStorage storage = new UserStorage();
    List storageAssignments = await storage.readIdData("retrievedAssignments${id.id}.json");
    List<Assignment> noteList = new List<Assignment>();
    if (storageAssignments == null || storageAssignments.length == null) {
      return [];
    } else {
      for (var i = 0; i < storageAssignments.length; i++) {
        noteList.add(Assignment.fromJson(storageAssignments[i]));
      }
    }
    return noteList;
  }
}