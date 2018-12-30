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

class Note {
  final String note;
  MongoId id = MongoId("_");
  bool completed = false;
  final DateTime dateSubmitted;
  final String noteType;
  Note(this.note, this.id, this.completed, this.dateSubmitted, this.noteType);
  Note.fromJson(Map<String, dynamic> json) :
    note = json["note"],
    id = MongoId(json["id"]),
    completed = json["completed"],
    dateSubmitted = DateTime.parse(json["dateSubmitted"]),
    noteType = json["noteType"];
  Map<String, dynamic> toJson() {
    return {
      "note": this.note,
      "id": this.id,
      "completed": this.completed,
      "dateSubmitted": this.dateSubmitted.toIso8601String(),
      "noteType": this.noteType,
    };
  }
  void switchCompleted() {
    this.completed = !this.completed;
  }
}

class Notes {
  static Future<List<MongoId>> getRetrievedIds(MongoId id) async {
    UserStorage storage = new UserStorage();
    List noteIds = await storage.readIdData("retrievedNotesIds${id.id}.json");
    if (noteIds == null || noteIds.length == 0 || noteIds[0] == null) {
      return [];
    } else {
      List<MongoId> returnList = new List<MongoId>();
      for (var i = 0; i < noteIds.length; i++) {
        returnList.add(MongoId(noteIds[i]));
      }
      return returnList;
    }
  }
  static Future<void> retrieveFromServer(MongoId id) async {
    UserStorage storage = new UserStorage();
    List<MongoId> retrievedIds = await getRetrievedIds(id);
    List storageNotes = await storage.readIdData("retrievedNotes${id.id}.json");
    var retrievedNotes = await Requests.postRequest("retrieveNotes?courseID=${id.id}", {"retrievedIDs" : json.encode(retrievedIds)});
    if (retrievedNotes != null && retrievedNotes.length != null) {
      for (var i = 0; i < retrievedNotes.length; i++) {
        retrievedIds.add(MongoId(retrievedNotes[i]["_id"].toString()));
        storageNotes.add(Note.fromJson({"noteType": retrievedNotes[i]["noteType"], "note": retrievedNotes[i]["text"], "id": retrievedNotes[i]["_id"], "dateSubmitted": retrievedNotes[i]["date"], "completed": false}).toJson());
      }
    }
    await storage.writeIdData(retrievedIds, "retrievedNotesIds${id.id}.json");
    await storage.writeIdData(storageNotes, "retrievedNotes${id.id}.json");
  }
  static Future<List<Note>> retrieveNotes(MongoId id) async {
    UserStorage storage = new UserStorage();
    List storageNotes = await storage.readIdData("retrievedNotes${id.id}.json");
    List<Note> noteList = new List<Note>();
    if (storageNotes == null || storageNotes.length == null) {
      return [];
    } else {
      for (var i = 0; i < storageNotes.length; i++) {
        noteList.add(Note.fromJson(storageNotes[i]));
      }
    }
    return noteList;
  }
}