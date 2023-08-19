import 'dart:math';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter/material.dart';
import 'package:guifetch/config.dart';
import 'package:guifetch/info/host.dart';
import 'package:guifetch/info/user.dart';
import 'package:guifetch/widgets/fields.dart';
import 'package:guifetch/widgets/logo.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'info/logo.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guifetch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(),
        ).apply(bodyColor: Colors.white),
      ),
      home: const MyHomePage(),
    );
  }
}

final logoColorsProvider = FutureProvider<PaletteGenerator>(
  (ref) async {
    final logo = ref.watch(logoProvider);

    if (logo.value == null) {
      return PaletteGenerator.fromColors([PaletteColor(Colors.blue, 1)]);
    }
    return PaletteGenerator.fromImage(logo.value!, maximumColorCount: 20);
  },
);

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(context, ref) {
    final colors = ref.watch(logoColorsProvider);
    final config = ref.watch(configProvider);
    final logo = ref.watch(logoProvider);
    final scrollController = useScrollController();
    final scrollProgress = useValueNotifier<double>(0);

    void onScroll() {
      scrollProgress.value = (scrollController.offset / 140).clamp(0, 1);
    }

    useEffect(
      () {
        scrollController.addListener(onScroll);
        return () => scrollController.removeListener(onScroll);
      },
      [scrollController],
    );

    Color titleColor = (colors.value?.lightVibrantColor ??
                colors.value?.lightMutedColor ??
                colors.value?.paletteColors.first)
            ?.color ??
        Colors.white;
    final titleHSLColor = HSLColor.fromColor(titleColor);
    titleColor = titleHSLColor
        .withSaturation(min(titleHSLColor.saturation * 2, 1))
        .toColor();
    final containerColor =
        ((colors.value?.vibrantColor ?? colors.value?.paletteColors.first)
                    ?.color ??
                Colors.black)
            .withOpacity(0.1);

    return Scaffold(
      body: Container(
        color: config.value?.backgroundColor ?? Colors.black,
        child: Stack(
          children: [
            AnimatedBuilder(
                animation: scrollProgress,
                builder: (context, snapshot) {
                  return Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          logo.whenOrNull(
                                data: (logo) => Positioned(
                                  top: -35 - 64 * (scrollProgress.value),
                                  width: 256,
                                  height: 256,
                                  child: Transform.scale(
                                    scale: 1 - scrollProgress.value,
                                    child: Logo(
                                      logo: logo,
                                    ),
                                  ),
                                ),
                              ) ??
                              Container(),
                          Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  color: containerColor,
                                  borderRadius: BorderRadius.only(
                                    bottomRight: const Radius.circular(20),
                                    bottomLeft: Radius.circular(
                                      20 * scrollProgress.value,
                                    ),
                                  ),
                                ),
                                height: 40,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                constraints: BoxConstraints(
                                  minWidth: MediaQuery.of(context).size.width *
                                      scrollProgress.value,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Consumer(builder: (context, ref, child) {
                                      final host = ref.watch(infoHostProvider);
                                      final user = ref.watch(infoUserProvider);
                                      return Text("$user@${host.value}");
                                    }),
                                    if (logo.value != null)
                                      Opacity(
                                        opacity:
                                            max(scrollProgress.value - 0.5, 0) *
                                                2,
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            return Logo(
                                              size: Size(
                                                20,
                                                constraints.maxHeight,
                                              ),
                                              logo: logo.value!,
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                }),
            Padding(
              padding: const EdgeInsets.only(top: 45),
              child: ImprovedScrolling(
                scrollController: scrollController,
                enableMMBScrolling: true,
                enableKeyboardScrolling: true,
                enableCustomMouseWheelScrolling: true,
                keyboardScrollConfig: KeyboardScrollConfig(
                  arrowsScrollAmount: 250.0,
                  homeScrollDurationBuilder:
                      (currentScrollOffset, minScrollOffset) {
                    return const Duration(milliseconds: 100);
                  },
                  endScrollDurationBuilder:
                      (currentScrollOffset, maxScrollOffset) {
                    return const Duration(milliseconds: 2000);
                  },
                ),
                // customMouseWheelScrollConfig:
                //     const CustomMouseWheelScrollConfig(
                //   scrollAmountMultiplier: 2.0,
                // ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 8 + 150 - 20,
                      left: 8,
                      right: 8,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: containerColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: InfoFields(titleColor: titleColor),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
