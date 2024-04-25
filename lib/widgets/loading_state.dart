import 'package:flow/util/constants.dart';
import 'package:flow/widgets/error_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class LoadingState<T extends StatefulWidget> extends State<T> {
  bool _loading = true;
  String? _error;

  setLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  @override
  @nonVirtual
  initState() {
    super.initState();
    _initStateLogic();
  }

  _initStateLogic() {
    _error = null;
    final start = DateTime.now();

    onInit().then((_) {
      debugPrint(
          'Loaded ${toString()} in ${DateTime.now().difference(start).inMilliseconds}ms');

      if (mounted) {
        setState(() {
          _loading = false;
        });
      }

      afterInit();
    }).catchError((e, _) {
      debugPrint('Failed to load ${toString()}: $e');

      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    });
  }

  Future<void> onInit();
  afterInit() {}

  @override
  @nonVirtual
  Widget build(BuildContext context) {
    return _error != null
        ? ErrorPage(error: _error!, onRetry: _initStateLogic)
        : _loading
            ? preloader
            : buildLoaded(context);
  }

  Widget buildLoaded(BuildContext context);
}
