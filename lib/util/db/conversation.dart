class Conversation {
  final String model;
  final String name;
  final List<String> messages;
  final String version;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.model,
    required this.name,
    required this.messages,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      model: map['model'],
      name: map['name'],
      messages: List<String>.from(map['messages']),
      version: map['version'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'model': model,
      'name': name,
      'messages': messages,
      'version': version,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
