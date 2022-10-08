import 'dart:math';
import 'dart:ui' as ui;
import 'package:drop_shadow_image/drop_shadow_image.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'info_fields.dart';

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
      title: 'Flutter Demo',
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

final logoIndexProvider = StateProvider((ref) => 0);
final logoProvider = StateProvider((ref) {
  final logoIndex = ref.watch(logoIndexProvider);
  return NetworkImage(
    [
      "https://nixos.org/logo/nixos-logo-only-hires.png",
      "https://gamepedia.cursecdn.com/gamia_gamepedia_en/1/19/Windows-8-logo-150x150.png?version=5e5c6e34894d5984836420e90842c5e8",
      "https://macpowerstore.com/wp-content/uploads/2021/02/Apple-logo-150x150.png",
      "https://i1.wp.com/passthroughpo.st/wp-content/uploads/2017/12/arch-logo.png?ssl=1"
          "https://www.gentoo.org/assets/img/logo/gentoo-g.png",
      "https://webstockreview.net/images/fedora-clipart-vector-19.png",
      "https://i2.wp.com/endeavouros.com/wp-content/uploads/2020/10/endeavour-logo-sans-logotype_plein.png?fit=500%2C500&ssl=1",
    ][logoIndex],
  );
});

final colorsProvider = FutureProvider(
  (ref) async {
    final logo = ref.watch(logoProvider);
    return PaletteGenerator.fromImageProvider(
      logo,
      maximumColorCount: 20,
    );
  },
);

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(context, ref) {
    final logo = ref.watch(logoProvider);
    final colors = ref.watch(colorsProvider);
    final scrollController = useScrollController();
    final scrollProgress = useValueNotifier<double>(0);
    final infoFields = ref.watch(infoFieldsProvider);

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
      floatingActionButton: TextButton(
          child: const Text("Switch!"),
          onPressed: () {
            ref.read(logoIndexProvider.state).state++;
          }),
      body: colors.when(
        error: (err, trace) => const Text("Error"),
        loading: () => const Center(child: CircularProgressIndicator()),
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

          return Container(
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
                              Center(
                                child: DropShadowImage(
                                  image: Image(
                                    image: logo,
                                    height: 150 * (1 - scrollProgress.value),
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
                                  minWidth: MediaQuery.of(context).size.width *
                                      scrollProgress.value,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("flafydev@nixos"),
                                    Opacity(
                                      opacity: scrollProgress.value,
                                      child: Image(
                                        image: logo,
                                        height: 20 * scrollProgress.value,
                                        filterQuality: ui.FilterQuality.medium,
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
                          child: infoFields.when(
                            data: (infoFields) => Column(
                              children: infoFields.map((info) => Field(info: info, titleColor: titleColor)).toList(),
                            ),
                            error: (err, trace) => Text(err.toString()),
                            loading: () => const Center(child: CircularProgressIndicator()),

                            // children: [
                            //   Entry(
                            //     title: "OS",
                            //     text: "NixOS",
                            //     titleColor: titleColor,
                            //   ),
                            //   Entry(
                            //     title: "Host",
                            //     text: "LENOVO Provence-5R1",
                            //     titleColor: titleColor,
                            //   ),
                            //   Entry(
                            //     title: "Kernel",
                            //     text: "5.9.11",
                            //     titleColor: titleColor,
                            //   ),
                            //   Entry(
                            //     title: "Uptime",
                            //     text: "9 mins",
                            //     titleColor: titleColor,
                            //   ),
                            //   Entry(
                            //     title: "Packages",
                            //     text: "816 (nix-system) 1069 (nix-user)",
                            //     titleColor: titleColor,
                            //   ),
                            //   Entry(
                            //     title: "Shell",
                            //     text: "zsh 5.9",
                            //     titleColor: titleColor,
                            //   ),
                            //   Entry(
                            //     title: "Resolution",
                            //     text: "1920x1080, 1920x1080",
                            //     titleColor: titleColor,
                            //   ),
                            //   Entry(
                            //     title: "Wayland Compositor",
                            //     text: "Hyprland",
                            //     titleColor: titleColor,
                            //   ),
                            //   Entry(
                            //     title: "Terminal",
                            //     text: "Foot",
                            //     titleColor: titleColor,
                            //   ),
                            //   Entry(
                            //     title: "CPU",
                            //     text: "Intel i5-7300HQ",
                            //     titleColor: titleColor,
                            //   ),
                            //   Entry(
                            //     title: "GPU",
                            //     text: "Intel HD Graphics 630",
                            //     titleColor: titleColor,
                            //   ),
                            //   Entry(
                            //     title: "GPU",
                            //     text: "NVIDIA GeForce GTX 1050 Mobile",
                            //     titleColor: titleColor,
                            //   ),
                            //   Entry(
                            //     title: "Memory",
                            //     text: "3285MiB / 7849MiB",
                            //     titleColor: titleColor,
                            //   ),
                            // ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
      children: [
        Text(info.title, style: TextStyle(color: titleColor ?? Colors.blue)),
        const Spacer(),
        Text(info.text, textAlign: TextAlign.end),
      ],
    );
  }
}
