import 'package:flow/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class ErrorPage extends StatefulWidget {
  const ErrorPage({super.key, required this.error, this.onRetry});

  final String error;
  final Function()? onRetry;

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  bool _retrying = false;

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      children: [
        ContentArea(
          builder: ((context, scrollController) => _retrying
              ? preloader
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Text(widget.error,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 16)),
                      ),
                      const SizedBox(height: 20),
                      MacosIconButton(
                        onPressed: () async {
                          setState(() {
                            _retrying = true;
                          });

                          final time = DateTime.now();

                          if (widget.onRetry != null) {
                            widget.onRetry!();
                          } else {
                            Navigator.pop(context);
                            return;
                          }

                          // Wait at least 500ms
                          if (DateTime.now().difference(time).inMilliseconds <
                              500) {
                            await Future.delayed(Duration(
                                milliseconds: 500 -
                                    DateTime.now()
                                        .difference(time)
                                        .inMilliseconds));
                          }

                          if (mounted) {
                            setState(() {
                              _retrying = false;
                            });
                          }
                        },
                        icon: const Icon(CupertinoIcons.arrow_clockwise),
                      ),
                    ],
                  ),
                )),
        ),
      ],
    );
  }
}
