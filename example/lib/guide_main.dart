import 'package:flutter/material.dart';
import 'package:flutter_sea_glass/flutter_sea_glass.dart';

/// The README's "Build a UI with sea glass" guide as a runnable app: a
/// quick settings panel with toggle tiles that merge like drops, a slider
/// made of two shapes, and a switch between our sea glass, slab glass and
/// clear slab glass.
///
/// Run with `flutter run -t lib/guide_main.dart`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlass.precache();
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: GuidePage()),
  );
}

/// Which glass the panel is made of.
enum Glass { sea, slab, clearSlab }

/// The settings of each glass.
LiquidGlassSettings settingsFor(Glass glass) => switch (glass) {
  // Tumbled, frosted sea glass with a flat lens; colored glass made half
  // clear. The preset's default 100 pt dome suits pebbles more than tiles.
  Glass.sea => LiquidGlassSettings.seaGlass(
    finish: const SeaGlassFinish(gloss: 0, colorClarity: .5),
    refractionHeight: 36,
    refractionAmount: 16,
  ),
  // Milky pastel slabs, lit from above, casting soft shadows.
  Glass.slab => LiquidGlassSettings.slabSeaGlass(),
  // The same slabs made translucent, with a wider lens and some frost.
  Glass.clearSlab =>
    LiquidGlassSettings.slabSeaGlass(
      finish: const SeaGlassFinish.slab().copyWith(
        scatter: .24,
        colorClarity: .6,
      ),
      frost: 6,
    ).copyWith(
      refractionHeight: 32,
      refractionAmount: 26,
      refractionFitsShape: true,
    ),
};

class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  var _glass = Glass.sea;
  final _on = <String>{'Wi-Fi'};
  var _level = .6;

  /// Colored glass of switched-on tiles; frosted white glass otherwise.
  LiquidGlassAppearance _tile(bool on) => LiquidGlassAppearance.seaGlass(
    color: on
        ? (_glass == Glass.sea
              ? SeaGlassColors.teal
              : SlabSeaGlass.original.tertiary)
        : (_glass == Glass.sea
              ? SeaGlassColors.white.withValues(alpha: .35)
              : SlabSeaGlass.original.clear.withValues(
                  alpha: _glass == Glass.slab ? 1 : .4,
                )),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Content behind the glass: glass samples what is below it.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8ED3B6), Color(0xFF2FB8DA)],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SizedBox(
                width: 360,
                // 2. One layer for the whole panel: it samples the
                // backdrop once for every shape inside it.
                child: LiquidGlassLayer(
                  settings: settingsFor(_glass),
                  defaultAppearance: _tile(false),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _GlassSlider(
                        value: _level,
                        onChanged: (value) => setState(() => _level = value),
                        color: _tile(true).tint,
                      ),
                      const SizedBox(height: 16),
                      // 3. A blend group: tiles dragged toward each other
                      // merge like drops and pinch apart.
                      LiquidGlassBlendGroup(
                        blend: 10,
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (final label in const [
                              'Wi-Fi',
                              'Bluetooth',
                              'Torch',
                              'Location',
                            ])
                              _Tile(
                                label: label,
                                // Deep sea glass needs light ink.
                                ink: _on.contains(label) && _glass == Glass.sea
                                    ? const Color(0xFFFFFFFF)
                                    : const Color(0xFF173A40),
                                appearance: _tile(_on.contains(label)),
                                onTap: () => setState(() {
                                  if (!_on.remove(label)) _on.add(label);
                                }),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SegmentedButton<Glass>(
                        segments: const [
                          ButtonSegment(value: Glass.sea, label: Text('Sea')),
                          ButtonSegment(value: Glass.slab, label: Text('Slab')),
                          ButtonSegment(
                            value: Glass.clearSlab,
                            label: Text('Clear slab'),
                          ),
                        ],
                        selected: {_glass},
                        onSelectionChanged: (glass) =>
                            setState(() => _glass = glass.single),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 4. A tile: a glass shape that stretches like a drop while pressed.
class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.ink,
    required this.appearance,
    required this.onTap,
  });

  final String label;
  final Color ink;
  final LiquidGlassAppearance appearance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LiquidStretch.seaGlass(
        child: LiquidGlass.grouped(
          shape: const LiquidRoundedSuperellipse(borderRadius: 32),
          appearance: appearance,
          child: SizedBox(
            width: 168,
            height: 64,
            child: Center(
              child: Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w600, color: ink),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 5. A slider made of two shapes: colored glass for the level, frosted
/// glass for the rest.
class _GlassSlider extends StatelessWidget {
  const _GlassSlider({
    required this.value,
    required this.onChanged,
    required this.color,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        void update(Offset local) =>
            onChanged((local.dx / width).clamp(0.0, 1.0));
        return GestureDetector(
          onHorizontalDragDown: (details) => update(details.localPosition),
          onHorizontalDragUpdate: (details) => update(details.localPosition),
          child: SizedBox(
            height: 56,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 56 + (width - 66) * value,
                  child: LiquidGlass(
                    shape: const LiquidRoundedSuperellipse(borderRadius: 28),
                    appearance: LiquidGlassAppearance.seaGlass(color: color),
                    child: const SizedBox.expand(),
                  ),
                ),
                Positioned(
                  left: 66 + (width - 66) * value,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: const LiquidGlass(
                    shape: LiquidRoundedSuperellipse(borderRadius: 28),
                    child: SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
