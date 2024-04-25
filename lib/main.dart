import 'dart:async';

import 'package:flow/pages/home_page.dart';
import 'package:flow/util/action_notifier.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  const config = MacosWindowUtilsConfig();
  await config.apply();
  await initDatabase();

  runApp(const MyApp());
}

late final Database database;
final chatActionNotifier = ChatActionNotifier();

Future<void> initDatabase() async {
  database = await openDatabase(
    'flow.db',
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS conversations (
          model TEXT NOT NULL UNIQUE PRIMARY KEY,
          name TEXT NOT NULL,
          version TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS messages (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          conversation_id INTEGER NOT NULL,
          message TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (conversation_id) REFERENCES conversations (id)
        )
      ''');
    },
  );
}

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
