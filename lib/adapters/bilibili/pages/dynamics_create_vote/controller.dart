import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/utils/utils.dart';

class CreateVoteState {
  CreateVoteState({
    this.key = '',
    this.title = '',
    this.desc = '',
    this.type = 0,
    List<CoreOption>? options,
    this.choiceCnt = 1,
    required this.endtime,
    this.canCreate = false,
  }) : options = options ??
            [
              CoreOption(optDesc: '', imgUrl: ''),
              CoreOption(optDesc: '', imgUrl: ''),
            ];

  final String key;
  final String title;
  final String desc;
  final int type;
  final List<CoreOption> options;
  final int choiceCnt;
  final DateTime endtime;
  final bool canCreate;

  CreateVoteState copyWith({
    String? key,
    String? title,
    String? desc,
    int? type,
    List<CoreOption>? options,
    int? choiceCnt,
    DateTime? endtime,
    bool? canCreate,
  }) {
    return CreateVoteState(
      key: key ?? this.key,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      type: type ?? this.type,
      options: options ?? this.options,
      choiceCnt: choiceCnt ?? this.choiceCnt,
      endtime: endtime ?? this.endtime,
      canCreate: canCreate ?? this.canCreate,
    );
  }
}

class CreateVoteNotifier extends StateNotifier<CreateVoteState> {
  CreateVoteNotifier(this._ref, this._voteId)
      : super(CreateVoteState(
          key: Utils.generateRandomString(6),
          endtime: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 1,
            DateTime.now().hour,
            DateTime.now().minute,
          ),
        )) {
    if (_voteId != null) {
      queryData();
    }
  }

  final Ref _ref;
  final int? _voteId;
  final DateTime _now = DateTime.now();
  late final DateTime _end = _now.copyWith(day: _now.day + 90);

  int? get voteId => _voteId;
  DateTime get now => _now;
  DateTime get end => _end;

  void _updateCanCreate() {
    bool canCreate;
    if (state.type == 0) {
      canCreate =
          state.title.isNotEmpty &&
          state.options.every((e) => e.optDesc?.isNotEmpty == true);
    } else {
      canCreate =
          state.title.isNotEmpty &&
          state.options.every(
            (e) =>
                e.optDesc?.isNotEmpty == true && e.imgUrl?.isNotEmpty == true,
          );
    }
    if (state.canCreate != canCreate) {
      state = state.copyWith(canCreate: canCreate);
    }
  }

  Future<void> queryData() async {
    final res = await _ref
        .read(dynamicsRepositoryProvider)
        .voteInfo(_voteId!);
    if (res case Success(:final response)) {
      final newKey = Utils.generateRandomString(6);
      state = state.copyWith(
        key: newKey,
        title: response.title!,
        desc: response.desc ?? '',
        type: response.options.first.imgUrl?.isNotEmpty == true ? 1 : 0,
        options: response.options,
        choiceCnt: response.choiceCnt!,
        endtime: DateTime.fromMillisecondsSinceEpoch(
          response.endTime! * 1000,
        ),
        canCreate: true,
      );
    } else {
      res.toast();
    }
  }

  void onDel(int i) {
    final newOptions = List<CoreOption>.from(state.options)..removeAt(i);
    var newChoiceCnt = state.choiceCnt;
    if (newChoiceCnt > newOptions.length) {
      newChoiceCnt = newOptions.length;
    }
    state = state.copyWith(options: newOptions, choiceCnt: newChoiceCnt);
    _updateCanCreate();
  }

  void updateTitle(String value) {
    state = state.copyWith(title: value);
    _updateCanCreate();
  }

  void updateDesc(String value) {
    state = state.copyWith(desc: value);
  }

  void updateType(int value) {
    state = state.copyWith(type: value);
    _updateCanCreate();
  }

  void updateChoiceCnt(int value) {
    state = state.copyWith(choiceCnt: value);
  }

  void updateEndtime(DateTime value) {
    state = state.copyWith(endtime: value);
  }

  void addOption() {
    state = state.copyWith(
      options: [...state.options, CoreOption(optDesc: '', imgUrl: '')],
    );
    _updateCanCreate();
  }

  void updateOptionDesc(int index, String value) {
    state.options[index].optDesc = value;
    state = state.copyWith();
    _updateCanCreate();
  }

  Future<CoreVoteInfo?> onCreate() async {
    final voteInfo = CoreVoteInfo(
      title: state.title,
      desc: state.desc,
      type: state.type,
      duration: state.endtime.difference(_now).inSeconds,
      options: state.options,
      onlyFansLevel: 0,
      choiceCnt: state.choiceCnt,
      votePublisher: Accounts.main.mid,
      voteId: _voteId,
    );
    final res = await (_voteId == null
        ? _ref.read(dynamicsRepositoryProvider).createVote(voteInfo)
        : _ref.read(dynamicsRepositoryProvider).updateVote(voteInfo));
    if (res case Success(:final response)) {
      voteInfo.voteId = response;
      return voteInfo;
    } else {
      res.toast();
      return null;
    }
  }

  Future<void> onUpload(int index, String path) async {
    final res = await _ref.read(msgRepositoryProvider).uploadBfs(
      path: path,
      category: 'daily',
      biz: 'vote',
    );
    if (res case Success(:final response)) {
      state.options[index].imgUrl = response.imageUrl;
      state = state.copyWith();
      _updateCanCreate();
    } else {
      res.toast();
    }
  }
}

final createVoteProvider =
    StateNotifierProvider.family<CreateVoteNotifier, CreateVoteState, int?>(
  CreateVoteNotifier.new,
);
