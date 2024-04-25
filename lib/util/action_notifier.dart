import 'package:flutter/cupertino.dart';

class ChatActionNotifier extends ChangeNotifier {
  ChatActionNotifier();

  final Set<int> _markedChats = {};

  void deleteChat(int index) {
    _markedChats.add(index);
    notifyListeners();
  }

  void unmarkChat(int index) {
    _markedChats.remove(index);
    notifyListeners();
  }

  bool isMarked(int index) {
    return _markedChats.contains(index);
  }
}
