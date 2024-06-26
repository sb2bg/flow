import 'package:flow/main.dart';
import 'package:flow/pages/llm_page.dart';
import 'package:flow/util/ollama/ollama.dart';
import 'package:flow/widgets/loading_state.dart';
import 'package:flow/widgets/side_bar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:uuid/uuid.dart';

class FlowHome extends StatefulWidget {
  const FlowHome({super.key});

  @override
  State<FlowHome> createState() => _FlowHomeState();
}

class _FlowHomeState extends LoadingState<FlowHome> {
  int _pageIndex = 0;
  late List<Model> models;

  @override
  Future<void> onInit() async {
    if (!await isOllama()) {
      return Future.error(
          'Ollama local server cannot be reached. Please start it and try again.');
    }

    final models = await client.listModels();

    if (models.models == null) {
      return Future.error('Could not retrieve models. Please try again later.');
    }

    if (models.models!.isEmpty) {
      return Future.error(
          'No models found. Please pull a model and try again.');
    }

    this.models = models.models!;
  }

  @override
  Widget buildLoaded(BuildContext context) {
    return MacosWindow(
        sidebar: Sidebar(
          dragClosed: false,
          minWidth: 200,
          builder: (context, scrollController) {
            return SidebarItems(
              currentIndex: _pageIndex,
              onChanged: (index) {
                setState(() => _pageIndex = index);
              },
              items: [
                for (var model in models)
                  SidebarItem(
                    leading: const MacosIcon(CupertinoIcons.tray_full_fill),
                    label: Text(model.name ?? const Uuid().v4()),
                    // in the future, if we want indivudal chat history, we can add a disclosure field
                  ),
              ],
            );
          },
          top: MacosTextField(
              controller: TextEditingController(),
              placeholder: 'Search Chats',
              prefix: const MacosIcon(CupertinoIcons.search),
              padding: const EdgeInsets.all(6.0),
              onChanged: (value) {}),
          bottom: Column(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: MacosListTile(
                  leading: const MacosIcon(CupertinoIcons.plus),
                  title: const Text('New Chat'),
                  subtitle: const Text('Start a conversation'),
                  onClick: () async {
                    // for if we ever want to make sub chats
                  },
                ),
              ),
              const SizedBox(height: 15),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: MacosListTile(
                    leading: const MacosIcon(CupertinoIcons.eye_slash),
                    title: const Text('Incognito Mode'),
                    subtitle: const Text('Hide your activity'),
                    onClick: () async {
                      showMacosAlertDialog(
                        context: context,
                        builder: (_) => MacosAlertDialog(
                            appIcon: const Icon(CupertinoIcons.eye_slash),
                            title: const Text('Incognito Mode'),
                            message: const Text(
                                'You are now in incognito mode. Your activity will not be saved.'),
                            primaryButton: PushButton(
                              controlSize: ControlSize.large,
                              child: const Text('Continue'),
                              onPressed: () {
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
                    }),
              ),
              const SizedBox(height: 15),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: MacosListTile(
                    leading: const MacosIcon(CupertinoIcons.arrow_clockwise),
                    title: const Text('Reload Models'),
                    subtitle: const Text('Refresh the list of models'),
                    onClick: () async {
                      await onInit();

                      if (!context.mounted) {
                        return;
                      }

                      showMacosAlertDialog(
                          context: context,
                          builder: (_) {
                            return MacosAlertDialog(
                                appIcon:
                                    const Icon(CupertinoIcons.arrow_clockwise),
                                title: const Text('Reload Models'),
                                message:
                                    const Text('Models have been reloaded.'),
                                primaryButton: PushButton(
                                  controlSize: ControlSize.large,
                                  child: const Text('Continue'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ));
                          });

                      setState(() {});
                    }),
              ),
            ],
          ),
        ),
        child: MacosSideBarContent(
          pageIndex: _pageIndex,
          children: {
            for (var i = 0; i < models.length; i++)
              LLMInterfaceContent(
                model: models[i],
                index: i,
              ): models[i].name ?? const Uuid().v4()
          },
        ));
  }
}
