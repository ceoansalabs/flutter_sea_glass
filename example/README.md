# flutter_sea_glass examples

Five apps, each run from this directory with `flutter run -t <file>` on an
Impeller device with Flutter GPU (iOS, Android, macOS):

| Entry point | What it is |
| --- | --- |
| `lib/sea_glass_showcase_main.dart` | The showcase: six screens made of sea glass (quick settings, a tide pool of living pebbles, music, weather, a smart home, a wallet). Its style tray switches every screen between sea glass, slab, clear slab and mineral glass and tunes the wallpaper, finish, tone, shape, shine, shadows, transparency, frost and color, plus mineral glass's etch, caustic and tints. |
| `lib/guide_main.dart` | The README's "Build a UI with sea glass" guide as a small app: toggle tiles that merge like drops, a two-shape slider and a switch between three glasses. Start here to learn the API. |
| `lib/slab_sea_glass_main.dart` | Slab sea glass: a component sheet after the Sea Glass design concept, with daylight, dusk and a flashlight that follows the pointer. |
| `lib/mineral_sea_glass_main.dart` | Mineral sea glass beside pebble, slab and liquid glass: a draggable pill over large type, with Frost Etch and Caustic Glow sliders and mineral tint swatches. |
| `lib/main.dart` | The settings playground for the renderer, described below. |

```sh
cd example
flutter run -t lib/sea_glass_showcase_main.dart --enable-impeller --enable-flutter-gpu
```

## Settings playground

`lib/main.dart` is a settings playground. Use `flutter devices` to pick an
iOS, Android or macOS Impeller device.

The stage fills the window and shows glass over backdrops that page
horizontally and scroll vertically, so the glass moves over real content: a
photo feed, a night page, a long article and a grid. The settings button in
its top trailing corner opens a settings sheet
([`stupid_simple_sheet`](https://pub.dev/packages/stupid_simple_sheet)) that
floats beside the stage on wide windows and rises to half height on phones.
The stage stays interactive while the sheet is open, and scrolling the sheet
past its top drags it closed. The sheet controls:

- **Scene**: everyday controls, shapes that merge in a `LiquidGlassBlendGroup`,
  light, dark, clear and tinted glass blending in one layer, and
  `LiquidGlassLoupe`s magnifying the backdrop.
- **Material**: the Regular, Toolbar, Clear and Loupe presets in light or
  dark. The Liquid Glass slider sets
  `LiquidGlassSettings.tintAmount` and the preset's blur
  (`ios27RegularFrost`, `ios27ClearFrost`). The loupe ignores it, as on iOS.
- **FakeGlass** instead of the full renderer, plus **Refraction** and
  **Lighting** controls. **Copy as Dart** puts the current
  `LiquidGlassSettings` on the clipboard.

Interactive glass shows the package's `GlassGlow` under the pointer. All glass
on the stage, including the settings button, renders in a single
`LiquidGlassLayer`; each loupe brings its own. The sheet has no glass and only
exists while it is open.

For a deterministic grid backdrop and a fixed blur (useful for screenshots):

```sh
fvm flutter run -d macos \
  --dart-define=LIQUID_GLASS_EXAMPLE_TEST_BACKGROUND=true \
  --dart-define=LIQUID_GLASS_EXAMPLE_TEST_BLUR=0
```

Other entry points:

- `integration_test/benchmark_test.dart`: the benchmark harness, see
  [`tool/README.md`](tool/README.md).
- `--dart-define=LIQUID_GLASS_EXAMPLE_PERFORMANCE_PROBE=true` logs frame timing
  windows, and `--dart-define=LIQUID_GLASS_DEBUG_GEOMETRY=true` paints the
  geometry textures instead of glass.

The photographic backdrops in `assets/backdrops/` are AI-generated for this
example.
