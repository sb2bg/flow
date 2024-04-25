import 'package:flutter/cupertino.dart';

class MacosSideBarContent extends StatefulWidget {
  const MacosSideBarContent(
      {super.key, required this.children, required this.pageIndex});

  final Map<Widget, String> children;
  final int pageIndex;

  @override
  State<MacosSideBarContent> createState() => _MacosSideBarContentState();
}

class _MacosSideBarContentState extends State<MacosSideBarContent> {
  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.pageIndex,
      children: widget.children.keys.toList(),
    );
  }
}
