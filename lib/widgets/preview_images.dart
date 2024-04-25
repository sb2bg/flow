import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview(
      {super.key, required this.bytes, required this.height, this.onRemove});

  final List<Uint8List> bytes;
  final double height;
  final void Function(Uint8List)? onRemove;

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.bytes.length,
        itemBuilder: (context, index) {
          final uint8List = widget.bytes[index];

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Stack(children: [
                    Image.memory(uint8List),
                    if (widget.onRemove != null)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: IconButton(
                          icon: const Icon(CupertinoIcons.xmark_circle_fill,
                              color: Colors.white,
                              shadows: [Shadow(blurRadius: 5)]),
                          onPressed: () {
                            widget.onRemove!(uint8List);
                          },
                        ),
                      ),
                  ]),
                ),
                onTap: () {
                  showMacosSheet(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return MacosSheet(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(child: Image.memory(uint8List)),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 100,
                                height: 50,
                                child: MacosIconButton(
                                  icon: const Row(
                                    children: [
                                      Icon(CupertinoIcons.xmark),
                                      SizedBox(width: 4),
                                      Text('Close'),
                                    ],
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ));
                      });
                }),
          );
        },
      ),
    );
  }
}
