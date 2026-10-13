import 'package:flutter/widgets.dart';
import 'package:flutter_sea_glass/flutter_sea_glass.dart';
import 'package:flutter_sea_glass_example/app.dart';

void main() {
  debugPaintLiquidGlassGeometry = const bool.fromEnvironment(
    'LIQUID_GLASS_DEBUG_GEOMETRY',
  );
  runApp(const PlaygroundApp());
}
