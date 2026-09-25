import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/app_types.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:skf/utils/utils.dart';

/// 首页顶部轮播(框架级):数据来自 core `AppRepository.slideshow`,
/// 由适配器提供;加载失败静默隐藏(下拉刷新即重试),不阻塞信息流。
///
/// 布局与视觉遵循 Material 3 官方规范与官方示例(Flutter SDK
/// `examples/api/lib/material/carousel/carousel.0.dart`),样式可在设置中
/// 切换、即时生效:
/// - 均匀大卡(默认,`Pref.carouselStyle == 0`):等宽大卡 + 右侧 ~50px
///   窄卡窥视,数量按「视口 − 窄卡」÷ 卡宽偏好动态计算;
/// - 不均匀大卡(`carouselStyle == 1`):官方 multi-browse
///   `[1, 2, 3, 2, 1]`(consumeMaxWeight: false)。
/// - 窄屏(<600)一律 full-screen `[1]`。
/// `padding`/`shape`/`backgroundColor`/`elevation` 一律不覆写,使用组件
/// 默认值:每卡 4px 内边距形成卡片间隙,M3 圆角 28,surface 底、无阴影。
/// 高度不写死:适配器探测首条封面真实尺寸并随 [CoreSlide.width/height]
/// 上报时,按大卡宽度 ÷ 封面比例推导(与官方「窗口高一半」「280 封顶」
/// 取最小,下限 140),未上报则按官方比例与「宽一半」推导。8s 自动轮播
/// (infinite 环绕,逐卡前进),手动切换后重新计时。
class HomeSlideshow extends StatefulWidget {
  const HomeSlideshow({super.key});

  /// 轮播样式(设置页可切换):即时生效。0 = 均匀大卡 + 右侧窄卡窥视,
  /// 1 = 不均匀大卡(Material multi-browse)。
  static final carouselStyle = ValueNotifier<int>(Pref.carouselStyle);

  @override
  State<HomeSlideshow> createState() => _HomeSlideshowState();
}

class _HomeSlideshowState extends State<HomeSlideshow> {
  final _controller = CarouselController();

  Timer? _autoTimer;

  List<CoreSlide> _slides = const [];

  /// 自动轮播的前进基准:最近一次上报的 leading 槽索引。
  /// consumeMaxWeight:false(宽屏)/[1](窄屏)下无主位钳制与槽位偏移,
  /// 索引即条目序号,目标 = leading + 1(infinite 由 SDK 取模)。
  int _leading = 0;

  @override
  void initState() {
    super.initState();
    _query();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _query() async {
    final res = await appRead(appRepositoryProvider).slideshow();
    if (!mounted) return;
    if (res case Success(:final response)) {
      setState(() => _slides = response);
      _restartAutoTimer();
    }
  }

  void _restartAutoTimer() {
    _autoTimer?.cancel();
    if (_slides.length < 2) return;
    _autoTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted || _slides.length < 2 || !_controller.hasClients) return;
      _controller.animateToItem(
        _leading + 1,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeInOutCubicEmphasized,
      );
    });
  }

  void _openSlide(CoreSlide slide) {
    final href = slide.href;
    if (href == null || href.isEmpty) return;
    final video = RegExp(r'/v/(\d+)').firstMatch(href);
    final blog = RegExp(r'/b/(\d+)').firstMatch(href);
    if (video != null) {
      final vid = int.tryParse(video.group(1)!);
      if (vid != null) {
        AppNavigator.toNamed(
          '/videoV',
          preventDuplicates: false,
          arguments: <String, dynamic>{
            'aid': vid,
            'bvid': '$vid',
            'cid': vid,
            'cover': slide.imgUrl,
            'title': slide.title,
            'heroTag': Utils.makeHeroTag(vid),
          },
        );
        return;
      }
    }
    if (blog != null) {
      AppNavigator.toNamed('/blogDetail?bid=${blog.group(1)}');
      return;
    }
    AppNavigator.toNamed(
      '/webview',
      parameters: {'url': href},
    );
  }

  /// 依当前样式与视口宽计算权重布局。
  /// 均匀样式:大卡等宽、数量按「视口 − 窄卡」÷ 卡宽偏好动态计算,
  /// 末位固定 ~50px 窄卡窥视;multi-browse:官方 [1,2,3,2,1] 不均匀;
  /// 窄屏(<600)一律 full-screen [1]。
  ({List<int> weights, double cardWidth, bool consumeMax}) _layoutFor(
    double viewport,
    int style,
    bool compact,
  ) {
    if (compact) {
      return (weights: const <int>[1], cardWidth: viewport, consumeMax: true);
    }
    if (style == 1) {
      return (
        weights: const <int>[1, 2, 3, 2, 1],
        cardWidth: viewport * 3 / 9,
        consumeMax: false,
      );
    }
    const peek = 50.0;
    final count = math.max(1, ((viewport - peek) / Pref.recommendCardWidth).floor());
    final bigWidth = ((viewport - peek) / count).round();
    return (
      weights: <int>[...List<int>.filled(count, bigWidth), peek.round()],
      cardWidth: bigWidth.toDouble(),
      consumeMax: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_slides.isEmpty) return const SizedBox.shrink();
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 600;
    return ValueListenableBuilder<int>(
      valueListenable: HomeSlideshow.carouselStyle,
      builder: (context, style, _) => LayoutBuilder(
        builder: (context, constraints) {
          final viewport = constraints.maxWidth;
          final (:weights, :cardWidth, :consumeMax) =
              _layoutFor(viewport, style, compact);
          // 高度优先由适配器上报的首条封面真实比例推导(大卡完整显示
          // 不裁切),与官方「窗口高一半」「280 封顶」取最小,下限 140;
          // 未上报时按官方比例与「宽一半」推导,不写死。
          final slide = _slides.first;
          final reportedAspect = slide.width != null &&
                  slide.width! > 0 &&
                  slide.height != null &&
                  slide.height! > 0
              ? slide.width! / slide.height!
              : null;
          final double maxHeight = math.min(size.height / 2, 280.0);
          final double height = reportedAspect != null
              ? (cardWidth / reportedAspect).clamp(140.0, maxHeight)
              : math.min(maxHeight, size.width / 2);
          return SizedBox(
            height: height,
            child: CarouselView.weighted(
              controller: _controller,
              flexWeights: weights,
              consumeMaxWeight: consumeMax,
              itemSnapping: true,
              infinite: true,
              onIndexChanged: (index) {
                // consumeMaxWeight:false/[1] 无槽位钳制,index 即条目序号;
                // timer 由 animateToItem 重新计时。
                _leading = index;
                _restartAutoTimer();
              },
              onTap: (index) {
                if (_slides.isNotEmpty) {
                  _openSlide(_slides[index % _slides.length]);
                }
              },
              children: _slides
                  .map((slide) => _buildSlide(slide, cardWidth, height))
                  .toList(),
            ),
          );
        },
      ),
    );
  }

  /// 官方卡片模式:封面经 ClipRect+OverflowBox 按最大卡宽度渲染再裁切,
  /// 整条卡片统一缩放、侧卡中心裁切;标题沿用底部渐隐保证可读性。
  Widget _buildSlide(CoreSlide slide, double cardWidth, double height) {
    return Stack(
      fit: .expand,
      children: [
        ClipRect(
          child: OverflowBox(
            maxWidth: cardWidth,
            minWidth: cardWidth,
            child: NetworkImgLayer(
              src: slide.imgUrl,
              width: cardWidth,
              height: height,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: .bottomCenter,
                end: .topCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
            child: Text(
              slide.title ?? '',
              maxLines: 1,
              overflow: .ellipsis,
              softWrap: false,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: .bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
