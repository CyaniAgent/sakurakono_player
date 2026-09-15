import 'package:skf/core/models/member_types.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/adapters/bilibili/models/common/member/archive_sort_type_app.dart';
import 'package:skf/adapters/bilibili/models_new/member/season_web/archive.dart';
import 'package:skf/adapters/bilibili/models_new/member/season_web/data.dart';
import 'package:skf/adapters/bilibili/pages/member_video_web/base/view.dart';
import 'package:skf/adapters/bilibili/pages/member_video_web/base/controller.dart';
import 'package:skf/adapters/bilibili/pages/member_video_web/season_series/controller.dart';
import 'package:flutter/material.dart';

class MemberSSWeb extends StatefulWidget {
  const MemberSSWeb({super.key});

  @override
  State<MemberSSWeb> createState() => _MemberSSWebState();

  static Future<void>? toMemberSSWeb({
    required CoreWebSsType type,
    required Object id,
    required Object mid,
    required String name,
  }) {
    return AppNavigator.toNamed(
      '/ssWeb',
      arguments: {
        'type': type,
        'id': id,
        'mid': mid,
        'name': name,
      },
    );
  }
}

class _MemberSSWebState
    extends
        BaseVideoWebState<
          MemberSSWeb,
          SeasonWebData,
          SeasonArchive,
          ArchiveSortTypeApp
        > {
  late final MemberSSWebCtr _ssCtr = MemberSSWebCtr();

  @override
  BaseVideoWebCtr<SeasonWebData, SeasonArchive, ArchiveSortTypeApp> get controller =>
      _ssCtr as BaseVideoWebCtr<SeasonWebData, SeasonArchive, ArchiveSortTypeApp>;


  @override
  List<ArchiveSortTypeApp> get values => ArchiveSortTypeApp.values;
}
