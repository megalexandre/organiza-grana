import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

Future<Uint8List> captureWidgetAsPng(
  Widget widget, {
  double pixelRatio = 2.0,
  double maxWidth = 1400,
}) async {
  final repaintBoundary = RenderRepaintBoundary();
  final view =
      WidgetsBinding.instance.platformDispatcher.implicitView!;

  final renderView = RenderView(
    view: view,
    child: RenderPositionedBox(child: repaintBoundary),
    configuration: ViewConfiguration(
      logicalConstraints: BoxConstraints(maxWidth: maxWidth),
      devicePixelRatio: pixelRatio,
    ),
  );

  final pipelineOwner = PipelineOwner()..rootNode = renderView;
  renderView.prepareInitialFrame();

  final buildOwner = BuildOwner(focusManager: FocusManager());
  final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
    container: repaintBoundary,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: IntrinsicWidth(child: widget),
    ),
  ).attachToRenderTree(buildOwner);

  buildOwner.buildScope(rootElement);
  buildOwner.finalizeTree();
  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();

  final image = await repaintBoundary.toImage(pixelRatio: pixelRatio);
  final byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
