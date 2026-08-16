import 'package:flutter/widgets.dart';

Widget fromHero({
  required Object tag,
  required Widget child,
}) => Hero(
  tag: tag,
  createRectTween: createEndRectTween,
  child: child,
);

RectTween createEndRectTween(Rect? begin, Rect? end) {
  if (begin != null && end != null) {
    final endWidth = end.width;
    final endHeight = end.height;
    // NOTE: the hero flight only knows the widget rects (begin/end); the
    // image's own rect inside the source widget is not available here, so
    // center the destination size within the source rect as an
    // approximation of the visible image area.
    final beginRect = Rect.fromLTWH(
      begin.left + (begin.width - endWidth) / 2,
      begin.top + (begin.height - endHeight) / 2,
      endWidth,
      endHeight,
    );
    return RectTween(begin: beginRect, end: end);
  }
  return RectTween(begin: begin, end: end);
}
