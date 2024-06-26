import 'dart:async';
import 'dart:io';

import 'package:flow/pages/home_page.dart';
import 'package:flow/util/action_notifier.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:ollama_dart/ollama_dart.dart';

Future<void> main() async {
  // config can only be applied on macOS
  if (Platform.isMacOS) {
    const config = MacosWindowUtilsConfig();
    config.apply();
  }

  runApp(const MyApp());
}

final chatActionNotifier = ActionNotifier();
final client = OllamaClient();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const FlowHome(),
    );
  }
}
