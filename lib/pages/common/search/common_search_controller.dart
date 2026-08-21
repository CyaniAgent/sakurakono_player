import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:flutter/material.dart';

abstract class CommonSearchController<R, T> extends CommonListControllerRiverpod<R, T> {
  final editController = TextEditingController();
  final focusNode = FocusNode();

  void onClear() {
    if (editController.text.isNotEmpty) {
      editController.clear();
    } else {
      AppNavigator.back();
    }
  }

  @override
  Future<void> onRefresh() {
    if (editController.value.text.isEmpty) {
      return Future.syncValue(null);
    }
    return super.onRefresh();
  }

  List<T>? get dataList {
    final state = loadingState;
    if (state case Success(:final response)) return response;
    return null;
  }

  void notifyStateChanged() => notifyListeners();

  @override
  void dispose() {
    editController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
