import 'package:flow/pages/llm_page.dart';
import 'package:flow/util/db/conversation.dart';
import 'package:flow/util/ollama/model_response.dart';
import 'package:flow/util/ollama/ollama.dart';
import 'package:flow/widgets/loading_state.dart';
import 'package:flow/widgets/side_bar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

class FlowHome extends StatefulWidget {
  const FlowHome({super.key});

  @override
  State<FlowHome> createState() => _FlowHomeState();
}

class _FlowHomeState extends LoadingState<FlowHome> {
  int _pageIndex = 0;
  late Map<Model, List<Conversation>> _conversations;

  @override
  Future<void> onInit() async {
    if (!await isOllama()) {
      return Future.error(
          'Ollama local server cannot be reached. Please start it and try again.');
    }

    final models = await getLocalModels();

    if (models == null) {
      return Future.error(
          'Failed to load models from Ollama. Please try again.');
    }

    _conversations = {
      for (var model in models.models) model: await model.getConversations(),
    };

    if (_conversations.isEmpty) {
      return Future.error(
          'No conversations found. Please start a conversation and try again.');
    }
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
                for (var model in _conversations.keys)
                  SidebarItem(
                    leading: const MacosIcon(CupertinoIcons.tray_full_fill),
                    label: Text(model.displayName),
                    disclosureItems: _conversations[model]!.isEmpty
                        ? null
                        : [
                            for (var conversation in _conversations[model]!)
                              SidebarItem(
                                leading: const MacosIcon(
                                    CupertinoIcons.chat_bubble_fill),
                                label: Text(conversation.name),
                              ),
                          ],
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
              MacosListTile(
                leading: const MacosIcon(CupertinoIcons.plus),
                title: const Text('New Chat'),
                subtitle: const Text('Start a conversation'),
                onClick: () async {
                  // TODO: implement new chat
                },
              ),
              const SizedBox(height: 15),
              MacosListTile(
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
              const SizedBox(height: 15),
              MacosListTile(
                  leading: const MacosIcon(CupertinoIcons.arrow_clockwise),
                  title: const Text('Reload Models'),
                  subtitle: const Text('Refresh the list of models'),
                  onClick: () async {}),
            ],
          ),
        ),
        child: MacosSideBarContent(
          pageIndex: _pageIndex,
          children: {
            // TODO: eventually, this will be a list of chats
            for (int i = 0; i < _conversations.keys.length; i++)
              LLMInterfaceContent(
                model: _conversations.keys.elementAt(i),
                index: i,
              ): _conversations.keys.elementAt(i).displayName,
          },
        ));
  }
}
