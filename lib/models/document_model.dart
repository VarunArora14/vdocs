import 'dart:convert';

class DocumentModel {
  final String title;
  final String uid;
  final List content; // list of documents per user, cannot be null or empty
  final DateTime createdAt;
  final String id;
  DocumentModel({
    required this.title,
    required this.uid, // user id
    required this.content,
    required this.createdAt, // time of creation
    required this.id, // document id
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'uid': uid,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'id': id,
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      title: map['title'] ?? '',
      uid: map['uid'] ?? '',
      content: List.from(map['content'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      id: map['_id'] ?? '', // the _id is from mongoose db as it stores as _id not id
    );
  }

  String toJson() => json.encode(toMap());

  factory DocumentModel.fromJson(String source) => DocumentModel.fromMap(json.decode(source)['document']);
  // the schema has {"document":{"uid":"631f82424b900d002c1ae46d","createdAt":1664021264435,"title":"Untitled
// document","content":[],"_id":"632ef310275d376c46b3444a","__v":0}}
}
