# CLAUDE.md

Guidance for Claude Code (claude.ai/code) working in this repository.

## Project

`flutter_sea_glass` is a Flutter package (pub.dev) for sea glass and liquid
glass effects. It is a fork of `liquid_glass_renderer` by whynotmake.it under
the Apache License 2.0: keep `LICENSE`, `NOTICE` and the original copyright
headers, and keep the widget API names (`LiquidGlass`, `LiquidGlassLayer`,
...) so code moves over by changing the import.

It needs Impeller and Flutter GPU (macOS, iOS, Android). Skia is not
supported; web compiles and renders `FakeGlass`.

## Layout

- `lib/flutter_sea_glass.dart`: the public library.
- `lib/src/`: widgets, settings (`liquid_glass_settings.dart`), sea glass
  (`sea_glass.dart`, `slab_sea_glass.dart`, `glass_light.dart`), shapes
  (`liquid_shape.dart`), rendering (`rendering/`) and internals (`internal/`).
- `lib/assets/shaders/`: `*.frag` entry points and shared `*.glsl`
  (`liquid_glass_final_render_core.glsl`, `sea_glass.glsl`,
  `fake_glass_shape.glsl`; Flutter GPU shaders in `gpu/`, listed in
  `flutter_sea_glass.shaderbundle.json` and built by `hook/build.dart`).
- `example/`: the playground (`lib/main.dart`), the sea glass showcase
  (`lib/sea_glass_showcase_main.dart`) and the slab sea glass demo
  (`lib/slab_sea_glass_main.dart`).

## Commands

```bash
flutter pub get
flutter analyze
flutter test --enable-impeller --enable-flutter-gpu --exclude-tags golden
cd example && flutter run -t lib/sea_glass_showcase_main.dart
```

Golden tests are tagged `golden`; regenerate them on macOS with
`--update-goldens`.

## Gotchas

- Asset builds only notice changes to `.frag` entry points: after editing an
  included `.glsl`, run `flutter clean` (or touch the `.frag` files).
- On Windows, build from a short path; long paths break the shader compiler.
- `SeaGlassFinish.none()` (the default) must render exactly as before: new
  finish controls default to `0`.
