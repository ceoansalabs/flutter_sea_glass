import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sea_glass/src/internal/flutter_gpu_geometry_renderer.dart';
import 'package:flutter_sea_glass/src/internal/multi_shader_builder.dart';
import 'package:flutter_sea_glass/src/liquid_glass.dart';
import 'package:flutter_sea_glass/src/shaders.dart';

/// Implementation of [LiquidGlass.precache].
///
/// Without it the first glass on screen paints its fallback for a frame or
/// two while the programs load: fake glass without its surface shader, real
/// glass as fake glass. Call it once, for example before `runApp` or on a
/// splash screen, and glass renders fully from its first frame.
///
/// Loads the fake-glass surface program everywhere, and the real-glass
/// programs plus the Flutter GPU geometry bundle where shader filters are
/// supported. On Android, the GPU part initializes the widgets binding if
/// needed and waits for the first rasterized frame, so it never blocks the
/// UI thread on the engine's deferred Impeller context. That context comes
/// with the first frame, which cannot come while `main` is still awaiting
/// this before `runApp`, so on Android the returned future completes at
/// once and everything loads right after the first frame; elsewhere it
/// completes when everything is loaded.
/// Failures are reported through
/// [FlutterError] and never thrown; the layers fall back the same way they
/// would without precaching.
Future<void> precacheLiquidGlass() {
  // On Android the engine creates its Impeller context with the first
  // frame, and asking whether shader filters are supported or loading a
  // shader program before that blocks on it. Awaited before runApp, that
  // frame would never come and the app would stay on its splash, so
  // everything loads once the first frame is drawn and the returned future
  // completes at once.
  if (FlutterGpuGeometryRenderer.gpuContextAwaitsFirstFrame) {
    unawaited(
      WidgetsFlutterBinding.ensureInitialized().waitUntilFirstFrameRasterized
          .then((_) => _load()),
    );
    return Future<void>.value();
  }
  return _load();
}

Future<void> _load() {
  final shaders = Future.wait<void>([
    MultiShaderBuilder.precacheShaders([ShaderKeys.fakeGlassSurface]),
    if (!kIsWeb && ui.ImageFilter.isShaderFilterSupported)
      MultiShaderBuilder.precacheShaders([
        ShaderKeys.liquidGlassRender,
        ShaderKeys.liquidGlassMaterialRender,
        ShaderKeys.liquidGlassTintRender,
      ]),
  ]);
  if (kIsWeb || !ui.ImageFilter.isShaderFilterSupported) return shaders;
  return Future.wait<void>([
    shaders,
    _guard(() async {
      await FlutterGpuGeometryRenderer.waitUntilGpuContextAvailable();
      final renderer = await FlutterGpuGeometryRenderer.fromAsset(
        ShaderKeys.gpuGeometryShaderBundle,
      );
      renderer.dispose();
    }),
  ]);
}

Future<void> _guard(Future<void> Function() load) async {
  try {
    await load();
  } on Object catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'flutter_sea_glass',
        context: ErrorDescription('while precaching liquid glass shaders'),
      ),
    );
  }
}
