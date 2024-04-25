import 'dart:async';
import 'dart:convert';

import 'package:flow/util/ollama/message_model.dart';
import 'package:flow/util/ollama/model_response.dart';
import 'package:flow/util/ollama/version_response.dart';
import 'package:http/http.dart';

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

Future<ModelList?> getLocalModels() async {
  // http://localhost:11434/api/tags

  try {
    final response = await get(Uri.parse('$ollamaUrl/api/tags'));

    if (response.statusCode == 200) {
      return ModelList.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Stream<MessageResponse> sendMessage(MessageRequest request) async* {
  // http://localhost:11434/api/chat
  final client = Client();

  try {
    final ollamaRequest = Request('POST', Uri.parse('$ollamaUrl/api/chat'));
    ollamaRequest.body = jsonEncode(request.toJson());
    ollamaRequest.headers['Content-Type'] = 'application/json';

    final streamedResponse = await client.send(ollamaRequest);

    await for (var value in streamedResponse.stream.transform(utf8.decoder)) {
      final json = jsonDecode(value);
      yield MessageResponse.fromJson(json);

      if (json['done'] == true) {
        break;
      }
    }
  } catch (e) {
    return;
  } finally {
    client.close();
  }
}
