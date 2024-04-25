import 'package:flow/main.dart';
import 'package:flow/util/db/conversation.dart';

class Model {
  final String name;
  final String displayName;
  final String version;
  final DateTime modifiedAt;
  final int size;
  final String digest;
  final Details details;

  Model(
      {required this.name,
      required this.displayName,
      required this.version,
      required this.modifiedAt,
      required this.size,
      required this.digest,
      required this.details});

  factory Model.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final split = name.split(':');

    return Model(
      name: name,
      displayName: split[0],
      version: split[1],
      modifiedAt: DateTime.parse(json['modified_at']),
      size: json['size'],
      digest: json['digest'],
      details: Details.fromJson(json['details']),
    );
  }

  @override
  String toString() {
    return name;
  }

  Future<List<Conversation>> getConversations() async {
    final conversations = <Conversation>[];

    for (var conversation in await database.query(
      'conversations',
      where: 'model = ?',
      whereArgs: [name],
    )) {
      conversations.add(Conversation.fromMap(conversation));
    }

    return conversations;
  }
}

class Details {
  final String format;
  final String family;
  final String parameterSize;
  final String quantizationLevel;

  Details(
      {required this.format,
      required this.family,
      required this.parameterSize,
      required this.quantizationLevel});

  factory Details.fromJson(Map<String, dynamic> json) {
    return Details(
      format: json['format'],
      family: json['family'],
      parameterSize: json['parameter_size'],
      quantizationLevel: json['quantization_level'],
    );
  }
}

class ModelList {
  final List<Model> models;

  ModelList({required this.models});

  factory ModelList.fromJson(Map<String, dynamic> json) {
    var modelsJson = json['models'] as List;
    List<Model> modelsList =
        modelsJson.map((modelJson) => Model.fromJson(modelJson)).toList();
    return ModelList(models: modelsList);
  }

  @override
  String toString() {
    return models.toString();
  }
}
