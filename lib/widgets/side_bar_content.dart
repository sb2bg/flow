import 'package:flow/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

class MacosSideBarContent extends StatefulWidget {
  const MacosSideBarContent(
      {super.key, required this.children, required this.pageIndex});

  final Map<Widget, String> children;
  final int pageIndex;

  @override
  State<MacosSideBarContent> createState() => _MacosSideBarContentState();
}

ToolBar _kToolBar(context, title, index) => ToolBar(
      title: Text(title),
      titleWidth: 200.0,
      leading: MacosTooltip(
        message: 'Toggle Sidebar',
        useMousePosition: false,
        child: MacosIconButton(
          icon: MacosIcon(
            CupertinoIcons.sidebar_left,
            color: MacosTheme.brightnessOf(context).resolve(
              const Color.fromRGBO(0, 0, 0, 0.5),
              const Color.fromRGBO(255, 255, 255, 0.5),
            ),
            size: 20.0,
          ),
          boxConstraints: const BoxConstraints(
            minHeight: 20,
            minWidth: 20,
            maxWidth: 48,
            maxHeight: 38,
          ),
          onPressed: () => MacosWindowScope.of(context).toggleSidebar(),
        ),
      ),
      actions: [
        ToolBarIconButton(
            label: 'Delete',
            icon: const MacosIcon(
              CupertinoIcons.trash,
            ),
            onPressed: () {
              showMacosAlertDialog(
                barrierDismissible: true,
                context: context,
                builder: (_) => MacosAlertDialog(
                    horizontalActions: false,
                    appIcon: const Icon(CupertinoIcons.trash),
                    title: const Text('Delete'),
                    message: const Text(
                        'Are you sure you want to delete this chat?'),
                    primaryButton: PushButton(
                      controlSize: ControlSize.large,
                      child: const Text('Continue'),
                      onPressed: () {
                        chatActionNotifier.deleteChat(index);
                        Navigator.of(context).pop();
                      },
                    ),
                    secondaryButton: PushButton(
                        controlSize: ControlSize.large,
                        secondary: true,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'))),
              );
            },
            showLabel: false),
        ToolBarIconButton(
            label: 'Settings',
            icon: const MacosIcon(
              CupertinoIcons.settings,
            ),
            onPressed: () => debugPrint("Settings"),
            showLabel: false)
      ],
    );

class _MacosSideBarContentState extends State<MacosSideBarContent> {
  @override
  Widget build(BuildContext context) {
    return IndexedStack(
        index: widget.pageIndex,
        children: widget.children
            .map((body, title) {
              return MapEntry(
                title,
                MacosScaffold(
                  toolBar: _kToolBar(context, title, widget.pageIndex),
                  children: [
                    ContentArea(
                      builder: ((context, scrollController) => body),
                    ),
                  ],
                ),
              );
            })
            .values
            .toList());
  }
}
