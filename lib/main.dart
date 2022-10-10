import 'dart:math';
import 'dart:ui' as ui;
import 'package:drop_shadow_image/drop_shadow_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter/material.dart';
import 'package:guifetch/config.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'info.dart';
import 'input_popup.dart';

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
          bodyText2: TextStyle(),
        ).apply(bodyColor: Colors.white),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(context, ref) {
    final logo = ref.watch(logoProvider);
    final colors = ref.watch(logoColorsProvider);
    final scrollController = useScrollController();
    final scrollProgress = useValueNotifier<double>(0);
    final infoFields = ref.watch(infoFieldsProvider);
    final infoTitle = ref.watch(infoTitleProvider);
    final config = ref.watch(configProvider);

    void _onScroll() {
      scrollProgress.value = (scrollController.offset / 140).clamp(0, 1);
    }

    useEffect(
      () {
        scrollController.addListener(_onScroll);
        Window.setEffect(effect: WindowEffect.transparent);
        return () => scrollController.removeListener(_onScroll);
      },
      [scrollController],
    );

    return Scaffold(
      body: GestureDetector(
        onTap: () async {
          if (kDebugMode) {
            ref.read(forcedOSIDProvider.state).state =
                await inputPopup(context, "Enter os id", "");
          }
        },
        child: colors.when(
          error: (err, trace) => const Text("Error"),
          loading: () => const Center(),
          data: (colors) {
            Color titleColor = (colors.lightVibrantColor ??
                    colors.lightMutedColor ??
                    colors.paletteColors.first)
                .color;
            final titleHSLColor = HSLColor.fromColor(titleColor);
            titleColor = titleHSLColor
                .withSaturation(min(titleHSLColor.saturation * 2, 1))
                .toColor();
            final containerColor =
                (colors.vibrantColor ?? colors.paletteColors.first)
                    .color
                    .withOpacity(0.1);

            return logo.when(
              error: (err, trace) => const Text("Error"),
              loading: () => const Center(),
              data: (logo) => config.when(
                error: (err, trace) => const Text("Error"),
                loading: () => const Center(),
                data: (config) {
                  return Container(
                    color: config.backgroundColor,
                    // decoration: BoxDecoration(
                    //   gradient: LinearGradient(
                    //     begin: Alignment.topCenter,
                    //     end: Alignment.bottomCenter,
                    //     colors: [
                    //       colors.vibrantColor?.color.withOpacity(0.1) ??
                    //           colors.paletteColors.first.color.withOpacity(0.1),
                    //       Colors.transparent,
                    //     ],
                    //   ),
                    // ),
                    child: Stack(
                      children: [
                        AnimatedBuilder(
                            animation: scrollProgress,
                            builder: (context, snapshot) {
                              return Stack(
                                children: [
                                  Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      if (logo != null)
                                        Center(
                                          child: DropShadowImage(
                                            image: Image(
                                              image: logo,
                                              height:
                                                  150 * (1 - scrollProgress.value),
                                              filterQuality: ui.FilterQuality.high,
                                            ),
                                            blurRadius: 40,
                                            offset: const Offset(0, 0),
                                          ),
                                        ),
                                    ],
                                  ),
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
                                          minWidth:
                                              MediaQuery.of(context).size.width *
                                                  scrollProgress.value,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(infoTitle),
                                            if (logo != null)
                                              Opacity(
                                                opacity: scrollProgress.value,
                                                child: Image(
                                                  image: logo,
                                                  height: 20 * scrollProgress.value,
                                                  filterQuality:
                                                      ui.FilterQuality.medium,
                                                ),
                                              ),
                                          ],
                                        ),
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
                                  child: Column(
                                    children: infoFields
                                        .map((info) => Field(
                                            info: info, titleColor: titleColor))
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              ),
            );
          },
        ),
      ),
    );
  }
}

class Field extends HookConsumerWidget {
  const Field({
    Key? key,
    required this.info,
    this.titleColor,
  }) : super(key: key);

  final InfoField info;
  final Color? titleColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(info.title, style: TextStyle(color: titleColor ?? Colors.blue)),
        const Spacer(),
        Text(info.text, textAlign: TextAlign.end),
      ],
    );
  }
}
