import 'package:skf/core/repository/dynamics_repository.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';

class DynMentionController
    extends CommonListController<List<CoreMentionGroup>?, CoreMentionGroup> {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  final focusNode = FocusNode();
  final controller = TextEditingController();

  final RxBool enableClear = false.obs;

  final RxBool showBtn = false.obs;
  Set<CoreMentionItem>? mentionList;

  void updateBtn() {
    showBtn.value = mentionList?.isNotEmpty == true;
  }

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  Future<void> onRefresh() {
    mentionList?.clear();
    showBtn.value = false;
    return super.onRefresh();
  }

  @override
  Future<LoadingState<List<CoreMentionGroup>?>> customGetData() async {
    final result = await (_ref?.read(dynamicsRepositoryProvider) ?? Get.find<DynamicsRepository>()).dynMention(keyword: controller.text);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  void onClose() {
    focusNode.dispose();
    controller.dispose();
    mentionList?.clear();
    mentionList = null;
    super.onClose();
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