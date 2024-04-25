import 'package:flow/pages/llm_page.dart';
import 'package:flow/widgets/preview_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:macos_ui/macos_ui.dart';

enum MessageType {
  assistant,
  user;

  @override
  String toString() {
    return this == assistant ? 'assistant' : 'user';
  }
}

class ChatHistory extends StatefulWidget {
  const ChatHistory({super.key, required this.messages});

  final MessageHistory messages;

  @override
  State<ChatHistory> createState() => _ChatHistoryState();
}

class _ChatHistoryState extends State<ChatHistory> {
  final _scrollController = ScrollController();
  bool _firstAutoScrollExecuted = false;
  bool _shouldAutoScroll = false;

  void _scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void _scrollListener() {
    _firstAutoScrollExecuted = true;

    if (_scrollController.hasClients &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
      _shouldAutoScroll = true;
    } else {
      _shouldAutoScroll = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      if (_scrollController.hasClients && _shouldAutoScroll) {
        _scrollToBottom();
      }

      if (!_firstAutoScrollExecuted && _scrollController.hasClients) {
        _scrollToBottom();
      }
    });

    return MacosScrollbar(
      controller: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.messages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: SelectionArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.messages[index].$1 == MessageType.assistant
                      ? const Text('Assistant',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: MacosColors.systemBlueColor))
                      : const Text('You',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: MacosColors.systemGreenColor)),
                  const SizedBox(height: 5),
                  widget.messages[index].$1 == MessageType.assistant
                      ? MarkdownBody(
                          // FIXME: Newlines only work in code blocks
                          data: widget.messages[index].$2,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                              color: MacosColors.white,
                            ),
                            a: const TextStyle(
                              color: MacosColors.systemBlueColor,
                            ),
                            listBullet: const TextStyle(
                              color: MacosColors.white,
                            ),
                            h1: const TextStyle(
                              color: MacosColors.white,
                            ),
                            h2: const TextStyle(
                              color: MacosColors.white,
                            ),
                            h3: const TextStyle(
                              color: MacosColors.white,
                            ),
                            h4: const TextStyle(
                              color: MacosColors.white,
                            ),
                            h5: const TextStyle(
                              color: MacosColors.white,
                            ),
                            h6: const TextStyle(
                              color: MacosColors.white,
                            ),
                            blockquote: const TextStyle(
                              color: MacosColors.white,
                            ),
                            blockquoteDecoration: const BoxDecoration(
                              color: MacosColors.systemGrayColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                            tableHead: const TextStyle(
                              color: MacosColors.white,
                            ),
                            tableBody: const TextStyle(
                              color: MacosColors.white,
                            ),
                            tableHeadAlign: TextAlign.center,
                            checkbox: const TextStyle(
                              color: MacosColors.white,
                            ),
                            // FIXME: Selecting text in code blocks works, but the selection doesn't show up
                            code: const TextStyle(
                              color: MacosColors.white,
                              backgroundColor: MacosColors.black,
                            ),
                            codeblockPadding: const EdgeInsets.all(16),
                            codeblockDecoration: const BoxDecoration(
                              color: MacosColors.black,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              if (widget.messages[index].$2.isNotEmpty)
                                Text(widget.messages[index].$2),
                              if (widget.messages[index].$3.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                ImagePreview(
                                  bytes: widget.messages[index].$3,
                                  height: 175,
                                ),
                              ],
                            ]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
