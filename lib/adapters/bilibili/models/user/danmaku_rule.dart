import 'package:skf/adapters/bilibili/grpc/bilibili/community/service/dm/v1.pb.dart';
import 'package:skf/core/models/danmaku_block.dart';

class RuleFilter {
  static final _regExp = RegExp(r'^/(.*)/$');

  List<String> dmFilterString = [];
  List<RegExp> dmRegExp = [];
  Set<String> dmUid = {};

  int count = 0;

  RuleFilter(this.dmFilterString, this.dmRegExp, this.dmUid, [int? count]) {
    this.count =
        count ?? dmFilterString.length + dmRegExp.length + dmUid.length;
  }

  RuleFilter.fromRuleTypeEntries(List<List<CoreSimpleRule>> rules) {
    dmFilterString = rules[0].map((e) => e.filter).toList();

    dmRegExp = rules[1]
        .map(
          (e) {
            final rule = e;
            return RegExp(
              _regExp.matchAsPrefix(rule.filter)?.group(1) ?? rule.filter,
              caseSensitive: false,
            );
          },
        )
        .toList();

    dmUid = rules[2].map((e) => e.filter).toSet();

    count = dmFilterString.length + dmRegExp.length + dmUid.length;
  }

  RuleFilter.empty();

  bool remove(DanmakuElem elem) {
    return dmUid.contains(elem.midHash) ||
        dmFilterString.any((i) => elem.content.contains(i)) ||
        dmRegExp.any((i) => i.hasMatch(elem.content));
  }
}
