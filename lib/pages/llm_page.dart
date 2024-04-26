import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flow/main.dart';
import 'package:flow/util/constants.dart';
import 'package:flow/widgets/chat_history.dart';
import 'package:flow/widgets/preview_images.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:ollama_dart/ollama_dart.dart';

class LLMInterfaceContent extends StatefulWidget {
  const LLMInterfaceContent(
      {super.key, required this.model, required this.index});

  final Model model;
  final int index;

  @override
  State<LLMInterfaceContent> createState() => _LLMInterfaceContentState();
}

class _LLMInterfaceContentState extends State<LLMInterfaceContent> {
  final _chatHistory = List<Message>.empty(growable: true);
  bool _waiting = false;
  final _stops = <int>{};
  final _controller = TextEditingController();
  final Map<String, Uint8List> _pendingImages = {};
  final List<List<Uint8List>> _sentImages = [];
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode(onKeyEvent: (node, event) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (event.logicalKey != LogicalKeyboardKey.shift) {
          _sendMessage();
          return KeyEventResult.handled;
        }
      }

      return KeyEventResult.ignored;
    });

    chatActionNotifier.addListener(_chatActionListener);
  }

  @override
  void dispose() {
    focusNode.dispose();
    chatActionNotifier.removeListener(_chatActionListener);
    super.dispose();
  }

  void _addStop() {
    setState(() {
      _stops.add(_chatHistory.length - 1);
      _waiting = false;
    });
  }

  void _chatActionListener() {
    if (chatActionNotifier.isMarked(widget.index)) {
      if (_waiting) {
        _addStop();
      }

      setState(() {
        _chatHistory.clear();
        _sentImages.clear();
      });

      chatActionNotifier.unmarkChat(widget.index);
    }
  }

  Future<void> _sendMessage() async {
    if (_waiting) {
      return;
    }

    final message = _controller.text.trim();
    _controller.clear();

    final images = _pendingImages.keys.toList();
    final previews = _pendingImages.values.toList();
    _pendingImages.clear();

    if (message.isEmpty && images.isEmpty) {
      return;
    }

    setState(() {
      final userMessage = images.isEmpty
          ? Message(role: MessageRole.user, content: message)
          : Message(role: MessageRole.user, content: message, images: images);

      _chatHistory.add(userMessage);
      _sentImages.add(previews);
      _waiting = true;
    });

    final name = widget.model.name;

    if (name == null) {
      context.showNonFatalError('Model name is null');
      return;
    }

    final stream = client.generateChatCompletionStream(
      request: GenerateChatCompletionRequest(
          model: name, messages: _chatHistory, options: const RequestOptions()),
    );

    _chatHistory.add(const Message(role: MessageRole.assistant, content: ''));
    final id = _chatHistory.length - 1;

    await for (final response in stream) {
      if (_stops.contains(id)) {
        _stops.remove(id);
        break;
      }

      if (response.message == null) {
        context.showNonFatalError('Response message is null');
        break;
      }

      // maybe replace \n with \n\n because our markdown parser doesn't handle single newlines
      final appended = _chatHistory.last.content + response.message!.content;

      setState(() {
        _chatHistory[id] =
            Message(role: MessageRole.assistant, content: appended);
      });
    }

    setState(() {
      _waiting = false;
    });
  }

  bool get canSubmit =>
      _controller.text.trim().isNotEmpty || _pendingImages.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: ChatHistory(messages: _chatHistory, images: _sentImages)),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: KeyboardListener(
            focusNode: focusNode,
            child: Column(
              children: [
                if (_pendingImages.isNotEmpty)
                  ImagePreview(
                      bytes: _pendingImages.values.toList(),
                      height: 150,
                      onRemove: (value) {
                        setState(() {
                          _pendingImages.removeWhere((_, v) => v == value);
                        });
                      }),
                Row(
                  children: [
                    IconButton(
                        onPressed: _waiting
                            ? null
                            : () async {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowMultiple: true,
                                  withData: true,
                                  allowedExtensions: ['jpg', 'png', 'jpeg'],
                                );

                                if (result != null) {
                                  for (final file in result.files) {
                                    final bytes = file.bytes;

                                    if (bytes != null) {
                                      final base64 = base64Encode(bytes);

                                      setState(() {
                                        _pendingImages[base64] = bytes;
                                      });
                                    }
                                  }
                                }
                              },
                        icon: const Icon(CupertinoIcons.photo_fill),
                        disabledColor: Colors.grey[700],
                        padding: const EdgeInsets.all(8)),
                    Expanded(
                      child: MacosTextField(
                        controller: _controller,
                        suffix: null,
                        placeholder: 'Send a message to ${widget.model.name}',
                        padding: const EdgeInsets.all(10.0),
                        maxLines: null,
                        onChanged: (value) {
                          setState(() {});
                        },
                        onSubmitted: (value) {
                          _sendMessage();
                        },
                      ),
                    ),
                    IconButton(
                        icon: _waiting
                            ? const Icon(CupertinoIcons.square_fill)
                            : const Icon(CupertinoIcons.paperplane_fill),
                        disabledColor: Colors.grey[700],
                        onPressed: _waiting
                            ? _addStop
                            : canSubmit
                                ? _sendMessage
                                : null,
                        padding: const EdgeInsets.all(8)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
