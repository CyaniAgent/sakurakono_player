import 'package:flutter_test/flutter_test.dart';
import 'package:ottohub_sdk_dart_example/main.dart';

void main() {
  testWidgets('App renders login button', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('登录'), findsOneWidget);
    expect(find.text('获取随机视频'), findsOneWidget);
  });
}

