import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:ollama_dart/ollama_dart.dart';

const String ollamaUrl = 'http://localhost:11434';

Future<bool> isOllama() async {
  // http://localhost:11434/
  // we use a timeout of 1 second to check if the server is running

  try {
    final response = await get(Uri.parse(ollamaUrl)).timeout(
      const Duration(seconds: 1),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

class Version {
  final String version;

  Version({required this.version});

  factory Version.fromJson(Map<String, dynamic> json) {
    return Version(
      version: json['version'],
    );
  }
}

Future<String?> getVersion() async {
  // http://localhost:11434/api/version

  try {
    final response = await get(Uri.parse('$ollamaUrl/api/version'));

    if (response.statusCode == 200) {
      return Version.fromJson(jsonDecode(response.body)).version;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

extension DisplayName on Model {
  String? get displayName {
    return name?.split(':').first;
  }
}
