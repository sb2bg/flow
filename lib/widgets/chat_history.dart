import 'package:flow/widgets/preview_images.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:ollama_dart/ollama_dart.dart';

class ChatHistory extends StatefulWidget {
  const ChatHistory(
      {super.key,
      required this.messages,
      required this.images,
      required this.onRegenerateAnswer,
      required this.waiting});

  final List<Message> messages;
  final List<List<Uint8List>> images;
  final Function(int) onRegenerateAnswer;
  final bool waiting;

  @override
  State<ChatHistory> createState() => _ChatHistoryState();
}

class _ChatHistoryState extends State<ChatHistory> {
  final _scrollController = ScrollController();
  bool _firstAutoScrollExecuted = false;
  bool _shouldAutoScroll = false;
  bool _copied = false;
  Future<void>? _dispatched;

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
                  widget.messages[index].role == MessageRole.assistant
                      ? const Text('Assistant',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: MacosColors.systemBlueColor))
                      : const Text('You',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: MacosColors.systemGreenColor)),
                  const SizedBox(height: 5),
                  widget.messages[index].role == MessageRole.assistant
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MarkdownBody(
                              // FIXME: Newlines only work in code blocks
                              data: widget.messages[index].content,
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
                            ),
                            const SizedBox(height: 10),
                            if (widget.messages[index].content.isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: SizedBox(
                                      height: 16,
                                      child: MacosIconButton(
                                        padding: EdgeInsets.zero,
                                        semanticLabel: 'Copy text',
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(
                                              text: widget
                                                  .messages[index].content));

                                          setState(() {
                                            _copied = true;
                                          });

                                          if (_dispatched != null) {
                                            return;
                                          }

                                          _dispatched = Future.delayed(
                                              const Duration(seconds: 2), () {
                                            if (mounted) {
                                              setState(() {
                                                _copied = false;
                                              });

                                              _dispatched = null;
                                            }
                                          });
                                        },
                                        icon: Icon(
                                            _copied
                                                ? CupertinoIcons.checkmark_alt
                                                : CupertinoIcons
                                                    .doc_on_clipboard,
                                            color: MacosColors.systemGrayColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: SizedBox(
                                      height: 16,
                                      child: MacosIconButton(
                                          padding: EdgeInsets.zero,
                                          semanticLabel: 'Regenerate answer',
                                          onPressed: widget.waiting
                                              ? null
                                              : () {
                                                  widget.onRegenerateAnswer(
                                                      index);
                                                },
                                          disabledColor: Colors.transparent,
                                          icon: Icon(
                                              CupertinoIcons.arrow_2_circlepath,
                                              color: widget.waiting
                                                  ? Colors.grey[800]
                                                  : MacosColors
                                                      .systemGrayColor)),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              if (widget.messages[index].content.isNotEmpty)
                                Text(widget.messages[index].content),
                              // divide by 2 because we only store images for the user, but the index is for all messages
                              // therefore, we need to divide by 2 to get the correct index
                              if (widget.images[index ~/ 2].isNotEmpty) ...[
                                const SizedBox(height: 10),
                                ImagePreview(
                                  bytes: widget.images[index ~/ 2],
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
