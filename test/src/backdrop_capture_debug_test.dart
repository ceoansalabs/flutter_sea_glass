import 'package:flutter/material.dart';
import 'package:flutter_sea_glass/flutter_sea_glass.dart';
import 'package:flutter_sea_glass/src/internal/backdrop_capture_debug.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(BackdropCaptureDebug.reset);
  tearDown(BackdropCaptureDebug.reset);

  testWidgets(
    'warns when two own-layer glasses capture independently',
    (tester) async {
      final messages = <String>[];
      final previousDebugPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) {
        if (message != null) messages.add(message);
      };

      try {
        await tester.pumpWidget(
          const MaterialApp(
            home: Stack(
              children: [
                LiquidGlass.withOwnLayer(
                  fake: true,
                  shape: LiquidOval(),
                  child: SizedBox.square(dimension: 80),
                ),
                LiquidGlass.withOwnLayer(
                  fake: true,
                  shape: LiquidOval(),
                  child: SizedBox.square(dimension: 80),
                ),
              ],
            ),
          ),
        );
        await tester.pump();

        expect(
          messages,
          contains(contains('independent backdrop captures')),
        );
        expect(
          messages.where((message) => message.contains('independent backdrop')),
          hasLength(1),
        );
      } finally {
        debugPrint = previousDebugPrint;
      }
    },
  );

  testWidgets(
    'does not warn when own-layer glasses share a BackdropGroup',
    (tester) async {
      final messages = <String>[];
      final previousDebugPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) {
        if (message != null) messages.add(message);
      };

      try {
        await tester.pumpWidget(
          MaterialApp(
            home: BackdropGroup(
              child: const Stack(
                children: [
                  LiquidGlass.withOwnLayer(
                    fake: true,
                    useBackdropGroup: true,
                    shape: LiquidOval(),
                    child: SizedBox.square(dimension: 80),
                  ),
                  LiquidGlass.withOwnLayer(
                    fake: true,
                    useBackdropGroup: true,
                    shape: LiquidOval(),
                    child: SizedBox.square(dimension: 80),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pump();

        expect(
          messages.where((message) => message.contains('independent backdrop')),
          isEmpty,
        );
      } finally {
        debugPrint = previousDebugPrint;
      }
    },
  );
}
