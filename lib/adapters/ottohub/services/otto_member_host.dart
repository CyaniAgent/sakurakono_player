import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/pages/member/member_host.dart';

/// OttoHub stub for [MemberHost].
///
/// OttoHub has no member-page UI of its own (test-only adapter); the
/// Bilibili pages are not reused here. All deep interactions throw
/// `not_implemented` (crash-prevention, consistent with OttoHub stubs).
class OttoMemberHost implements MemberHost {
  Never _err() => throw UnimplementedError('not_implemented');

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
    required RxInt contributeInitialIndex,
  }) =>
      _err();

  @override
  bool canToWebArchive(String heroTag) => false;

  @override
  void toWebArchive({
    required String heroTag,
    required int mid,
    required String username,
  }) =>
      _err();

  @override
  void actionRelationMod(
    BuildContext context, {
    required int mid,
    required bool isFollow,
    required ValueChanged<int> afterMod,
  }) =>
      _err();

  @override
  void shareUser(int mid) => _err();

  @override
  void openLoginDevices() => _err();

  @override
  void openLoginLog() => _err();

  @override
  void openCoinLog() => _err();

  @override
  void openExpLog() => _err();

  @override
  void showReportDialog(
    BuildContext context, {
    required String? name,
    required int mid,
  }) =>
      _err();

  @override
  Future<void> showLiveMedalWall(int mid) => _err();

  @override
  void createShortcut({
    required int mid,
    required String name,
    required String avatar,
  }) =>
      _err();

  @override
  void pushDynFromId(String? id) => _err();

  @override
  void handleWebview(String url) => _err();

  @override
  void pushFromUri(String uri) => _err();

  @override
  void openMemberGuard({
    required int mid,
    required String name,
    required Object? count,
  }) =>
      _err();

  @override
  void openUpowerRank({
    required int mid,
    required String name,
    required Object? count,
  }) =>
      _err();
}
