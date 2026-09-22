import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skf/common/style.dart';
import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/app_types.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/utils.dart';

/// 首页顶部轮播(框架级):数据来自 core `AppRepository.slideshow`,
/// 由适配器提供;加载失败静默隐藏(下拉刷新即重试),不阻塞信息流。
///
/// 桌面/宽屏显示更多卡片(权重断点 <600 / <1000 / 其余),
/// 移动端为主卡+次卡探出的 B 站横幅形态;8s 自动轮播(内置 infinite 环绕),
/// 手动切换后重新计时。
class HomeSlideshow extends StatefulWidget {
  const HomeSlideshow({super.key});

  @override
  State<HomeSlideshow> createState() => _HomeSlideshowState();
}

class _HomeSlideshowState extends State<HomeSlideshow> {
  final _controller = CarouselController();

  Timer? _autoTimer;

  List<CoreSlide> _slides = const [];

  @override
  void initState() {
    super.initState();
    _query();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
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
    _autoTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      if (!mounted || _slides.length < 2 || !_controller.hasClients) return;
      final next = (_controller.leadingItem + 1) % _slides.length;
      await _controller.animateToItem(next);
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
            'cid': 0,
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
    final width = MediaQuery.sizeOf(context).width;
    final (List<int> weights, double height) = switch (width) {
      < 600 => (const [6, 1], 170.0),
      < 1000 => (const [2, 2, 1], 190.0),
      _ => (const [1, 1, 1, 1], 220.0),
    };
    return SizedBox(
      height: height,
      child: CarouselView.weighted(
        controller: _controller,
        flexWeights: weights,
        itemSnapping: true,
        infinite: true,
        elevation: 0,
        padding: EdgeInsets.zero,
        backgroundColor: ColorScheme.of(context).surfaceContainerHighest,
        shape: const RoundedRectangleBorder(borderRadius: Style.mdRadius),
        onIndexChanged: (_) => _restartAutoTimer(),
        onTap: (index) {
          if (index >= 0 && index < _slides.length) {
            _openSlide(_slides[index]);
          }
        },
        children: _slides.map(_buildSlide).toList(),
      ),
    );
  }

  Widget _buildSlide(CoreSlide slide) {
    return Stack(
      fit: .expand,
      children: [
        NetworkImgLayer(src: slide.imgUrl, width: 480, height: 270),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: .bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
