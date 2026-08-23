import 'package:skf/core/repository/dynamics_repository.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';

class DynMentionController
    extends CommonListControllerRiverpod<List<CoreMentionGroup>?, CoreMentionGroup> {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  final focusNode = FocusNode();
  final controller = TextEditingController();

  bool enableClear = false;

  bool showBtn = false;
  Set<CoreMentionItem>? mentionList;

  void updateBtn() {
    showBtn = mentionList?.isNotEmpty == true;
    notifyListeners();
  }

  DynMentionController() {
    queryData();
  }

  @override
  Future<void> onRefresh() {
    mentionList?.clear();
    showBtn = false;
    notifyListeners();
    return super.onRefresh();
  }

  @override
  Future<LoadingState<List<CoreMentionGroup>?>> customGetData() async {
    final result = await (_ref!.read(dynamicsRepositoryProvider)).dynMention(keyword: controller.text);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  void dispose() {
    focusNode.dispose();
    controller.dispose();
    mentionList?.clear();
    mentionList = null;
    super.dispose();
  }

  void onCheck(bool? value, CoreMentionItem item) {
    if (value == true) {
      (mentionList ??= <CoreMentionItem>{}).add(item);
    } else {
      mentionList!.remove(item);
    }
    updateBtn();
  }
}