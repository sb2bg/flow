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

    // ignore: deprecated_member_use
    focusNode = FocusNode(onKey: (node, event) {
      if (HardwareKeyboard.instance
          .isLogicalKeyPressed(LogicalKeyboardKey.enter)) {
        if (!HardwareKeyboard.instance.isShiftPressed) {
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

  Future<void> _queryWith(List<Message> messages) async {
    final name = widget.model.name;

    if (name == null) {
      context.showNonFatalError('Model name is null');
      return;
    }

    setState(() {
      _waiting = true;
    });

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

  Future<void> _sendMessage() async {
    if (_waiting) {
      return;
    }

    final message = _controller.text.trim();

    if (message.isEmpty && _pendingImages.isEmpty) {
      return;
    }

    _controller.clear();

    final images = _pendingImages.keys.toList();
    final previews = _pendingImages.values.toList();
    _pendingImages.clear();

    setState(() {
      final userMessage = images.isEmpty
          ? Message(role: MessageRole.user, content: message)
          : Message(role: MessageRole.user, content: message, images: images);

      _chatHistory.add(userMessage);
      _sentImages.add(previews);
    });

    await _queryWith(_chatHistory);
  }

  Future<void> regenerateFrom(int index) async {
    // remove all messages, images, and stops after the index
    setState(() {
      _chatHistory.removeRange(index, _chatHistory.length);
      // have to divide image index by 2 because we only store images for the user which is every other message
      _sentImages.removeRange((index ~/ 2) + 1, _sentImages.length);
    });

    await _queryWith(_chatHistory);
  }

  bool get canSubmit =>
      _controller.text.trim().isNotEmpty || _pendingImages.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: ChatHistory(
                messages: _chatHistory,
                images: _sentImages,
                onRegenerateAnswer: regenerateFrom,
                waiting: _waiting)),
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
