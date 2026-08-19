import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/utils/utils.dart';

class CreateReserveState {
  const CreateReserveState({
    this.subType = 0,
    this.title = '',
    required this.date,
    this.canCreate = false,
  });

  final int subType;
  final String title;
  final DateTime date;
  final bool canCreate;

  CreateReserveState copyWith({
    int? subType,
    String? title,
    DateTime? date,
    bool? canCreate,
  }) {
    return CreateReserveState(
      subType: subType ?? this.subType,
      title: title ?? this.title,
      date: date ?? this.date,
      canCreate: canCreate ?? this.canCreate,
    );
  }
}

class CreateReserveNotifier extends StateNotifier<CreateReserveState> {
  CreateReserveNotifier(this._ref, this.sid)
      : super(CreateReserveState(
          date: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 1,
            20,
          ),
        )) {
    if (sid != null) {
      queryData();
    }
  }

  final Ref _ref;
  final int? sid;
  final DateTime now = DateTime.now();
  late final DateTime end = now.copyWith(day: now.day + 90);
  String key = Utils.generateRandomString(6);

  void updateSubType(int value) {
    state = state.copyWith(subType: value);
  }

  void updateTitle(String value) {
    state = state.copyWith(title: value);
    _updateCanCreate();
  }

  void updateDate(DateTime value) {
    state = state.copyWith(date: value);
  }

  void _updateCanCreate() {
    state = state.copyWith(canCreate: state.title.trim().isNotEmpty);
  }

  Future<void> queryData() async {
    final res = await _ref
        .read(dynamicsRepositoryProvider)
        .reserveInfo(sid: sid);
    if (res case Success(:final response)) {
      key = Utils.generateRandomString(6);
      state = state.copyWith(
        title: response.title!,
        date: DateTime.fromMillisecondsSinceEpoch(
          response.livePlanStartTime! * 1000,
        ),
        canCreate: true,
      );
    } else {
      res.toast();
    }
  }

  Future<CoreReserveInfoData?> onCreate() async {
    final livePlanStartTime = state.date.millisecondsSinceEpoch ~/ 1000;
    final repository = _ref.read(dynamicsRepositoryProvider);
    final res = sid == null
        ? await repository.createReserve(
            title: state.title,
            subType: state.subType,
            livePlanStartTime: livePlanStartTime,
          )
        : await repository.updateReserve(
            sid: sid!,
            subType: state.subType,
            title: state.title,
            livePlanStartTime: livePlanStartTime,
          );
    if (res case Success(:final response)) {
      return CoreReserveInfoData(
        id: response,
        title: state.title,
        livePlanStartTime: livePlanStartTime,
      );
    } else {
      res.toast();
      return null;
    }
  }
}

final createReserveProvider =
    StateNotifierProvider.family<CreateReserveNotifier, CreateReserveState, int?>(
  (ref, sid) => CreateReserveNotifier(ref, sid),
);
