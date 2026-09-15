import 'package:flutter/material.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/pages/member/member_host.dart';

/// OttoHub stub for [MemberHost].
///
/// OttoHub has no member-page UI of its own (test-only adapter); the
/// Bilibili pages are not reused here. All deep interactions degrade to
/// no-op / placeholder (defensive degradation, no exceptions thrown).
class OttoMemberHost implements MemberHost {

  @override
  int get currentUserId => -1;

  @override
  List<CoreSpaceTab2> filterTabs(List<CoreSpaceTab2> tabs) => tabs;

  @override
  String? get preferredTabParam => null;

  @override
  Widget buildTab({
    required String param,
    String? title,
    required String heroTag,
    required int mid,
    required int contributeInitialIndex,
  }) =>
      const SizedBox.shrink();

  @override
  bool canToWebArchive(String heroTag) => false;

  @override
  void toWebArchive({
    required String heroTag,
    required int mid,
    required String username,
  }) {
  }

  @override
  void actionRelationMod(
    BuildContext context, {
    required int mid,
    required bool isFollow,
    required ValueChanged<int> afterMod,
  }) {
  }

  @override
  void shareUser(int mid) {}

  @override
  void pushDynFromId(String? id) {}

  @override
  void handleWebview(String url) {}

  @override
  void pushFromUri(String uri) {}

}
