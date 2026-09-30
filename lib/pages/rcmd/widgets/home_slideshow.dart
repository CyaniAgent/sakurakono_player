import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/app_types.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/common/style.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:skf/utils/utils.dart';

/// 首页顶部轮播(框架级):数据来自 core `AppRepository.slideshow`,
/// 由适配器提供;加载失败静默隐藏(下拉刷新即重试),不阻塞信息流。
///
/// 布局与视觉遵循 Material 3 官方规范与官方示例(Flutter SDK
/// `examples/api/lib/material/carousel/carousel.0.dart`),样式可在设置中
/// 切换、即时生效:
/// - 均匀大卡(默认,`Pref.carouselStyle == 0`):卡宽固定 = 高度 × 16/9
///   (封面 16:9 完整,与卡片数量解耦),数量 = 视口内能容纳的整卡数,
///   剩余宽度全部归右缘窄卡窥视条;
/// - 不均匀大卡(`carouselStyle == 1`):官方 multi-browse
///   `[1, 2, 3, 2, 1]`(consumeMaxWeight: false)。
/// - 窄屏(<600)一律 full-screen `[1]`。
/// `padding`/`shape`/`backgroundColor`/`elevation` 一律不覆写,使用组件
/// 默认值:每卡 4px 内边距形成卡片间隙,M3 圆角 28,surface 底、无阴影。
/// 高度与下方信息流「整卡」高度逐像素对齐(用与首页网格相同的列数/
/// 列宽/文字区公式计算)。
/// 上限「窗口高一半 ÷ 280 封顶」,下限 140。
/// 8s 自动轮播(infinite 环绕,逐卡前进),手动切换后重新计时。
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
          // 列数/列宽:与首页信息流网格完全相同的公式,轮播卡与下方卡片
          // 逐列对齐、宽度一致。
          const spacing = Style.cardSpace;
          final feedCols = math.max(
            1,
            ((viewport - spacing) / (Pref.recommendCardWidth + spacing))
                .ceil(),
          );
          final feedCardWidth =
              (viewport - spacing * (feedCols - 1)) / feedCols;
          // 高度 = 信息流「整卡」高度(列宽 ÷ 比例 + 文字区),逐像素一致;
          // 上限「窗口高一半 ÷ 280 封顶」,下限 140。
          final double maxHeight = math.min(size.height / 2, 280.0);
          final double height =
              (feedCardWidth / Style.aspectRatio +
                      MediaQuery.textScalerOf(context).scale(90))
                  .clamp(140.0, maxHeight);
          // 布局:卡宽固定 = 高度 × 16/9(封面完整不裁切,与卡片数量解耦),
          // 数量 = 视口内能容纳的整卡数,剩余宽度全部归右缘窄卡窥视;
          // multi-browse 不均匀卡;窄屏 full-screen。
          final bool multiBrowse = style == 1;
          final List<int> weights;
          final double cardWidth;
          final bool consumeMax;
          if (compact) {
            weights = const <int>[1];
            cardWidth = viewport;
            consumeMax = true;
          } else if (multiBrowse) {
            weights = const <int>[1, 2, 3, 2, 1];
            cardWidth = viewport * 3 / 9;
            consumeMax = false;
          } else {
            const peek = 50.0;
            final slideWidth = height * 16 / 9;
            if (viewport < slideWidth + peek) {
              // 过渡态(窗口最小化动画等)视口可能瞬间归零:退化为
              // full-screen 单卡,避免出现非正权重(SDK 构建断言)。
              weights = const <int>[1];
              cardWidth = viewport;
              consumeMax = true;
            } else {
              final count = math.max(
                1,
                ((viewport - peek) / slideWidth).floor(),
              );
              // 余量不并入卡宽:卡宽恒为 高度×16/9,数量增减只改变窥视条宽度。
              final peekWidth = math.max(1.0, viewport - count * slideWidth);
              weights = <int>[
                ...List<int>.filled(count, slideWidth.round()),
                peekWidth.round(),
              ];
              cardWidth = slideWidth;
              consumeMax = false;
            }
          }
          return SizedBox(
            height: height,
            child: CarouselView.weighted(
              // flexWeights 变化(窗口缩放/样式切换)时 SDK didUpdateWidget 会在
              // position 未 attach 时断言(carousel.dart:555),改用 key 重建。
              key: ValueKey<String>(weights.join('_')),
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
