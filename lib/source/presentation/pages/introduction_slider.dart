library introduction_slider;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/widgets.dart';

// ignore: must_be_immutable
class IntroductionSlider extends StatefulWidget {
  /// Defines the appearance of the introduction slider items that are arrayed
  /// within the introduction slider.
  final List<dynamic> items;

  /// Determines the physics of a [Scrollable] widget.
  final ScrollPhysics? physics;

  /// The [Back] that is used to navigate to the previous page.
  final Back? back;

  /// The [Next] that is used to navigate to the next page.
  final Next? next;

  /// The [Done] that is used to navigate to the target page.
  final Done done;

  final bool showDots;

  /// The [DotIndicator] that is used to indicate dots.
  final DotIndicator? dotIndicator;

  /// The two cardinal directions in two dimensions.
  final Axis scrollDirection;

  /// Show and hide app status/navigation bar on the introduction slider.
  final bool showStatusBar;

  final Widget? customFullNextButton;

  final Widget? customLastItemButton;

  final dynamic? topBackButton;

  /// The initial page index of the introduction slider.
  int initialPage;

  IntroductionSlider({
    Key? key,
    required this.items,
    this.showStatusBar = false,
    this.initialPage = 0,
    this.physics,
    this.scrollDirection = Axis.horizontal,
    this.back,
    required this.done,
    this.next,
    this.showDots = true,
    this.dotIndicator,
    this.customFullNextButton,
    this.customLastItemButton,
    this.topBackButton,
  })  : assert((initialPage <= items.length - 1) && (initialPage >= 0),
            "initialPage can't be less than 0 or greater than items length."),
        super(key: key);

  @override
  State<IntroductionSlider> createState() => _IntroductionSliderState();
}

class _IntroductionSliderState extends State<IntroductionSlider> {
  /// The [PageController] of the introduction slider.
  late PageController pageController;

  /// [hideStatusBar] is used to hide status bar on the introduction slider.
  hideStatusBar(bool value) {
    if (value == false) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [],
      );
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [
          SystemUiOverlay.bottom,
          SystemUiOverlay.top,
        ],
      );
    }
  }

  @override
  void initState() {
    pageController = PageController(initialPage: widget.initialPage);
    hideStatusBar(widget.showStatusBar);
    super.initState();
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lastIndex = widget.initialPage == widget.items.length - 1;
    return Scaffold(
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          if (widget.topBackButton != null)
            Positioned(
              top: 80,
              left: 35,
              child: widget.topBackButton,
            ),
          PageView.builder(
            controller: pageController,
            itemCount: widget.items.length,
            physics: widget.physics,
            scrollDirection: widget.scrollDirection,
            onPageChanged: (index) =>
                setState(() => widget.initialPage = index),
            itemBuilder: (context, index) {
              if (widget.items[index].runtimeType == IntroductionSliderItem) {
                return Container(
                  decoration: BoxDecoration(
                    color: widget.items[index].backgroundColor,
                    gradient: widget.items[index].gradient,
                    image: widget.items[index].backgroundImageDecoration,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      widget.items[index].logo ?? const SizedBox(),
                      widget.items[index].title ?? const SizedBox(),
                      widget.items[index].subtitle ?? const SizedBox(),
                      const Spacer(),
                    ],
                  ),
                );
              } else {
                return widget.items[index];
              }
            },
          ),
          widget.dotIndicator == null || !widget.showDots
              ? const SizedBox()
              : Positioned(
                  bottom: 80,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 5,
                      runSpacing: 5,
                      children: List.generate(
                        widget.items.length,
                        (index) => AnimatedContainer(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: index == widget.initialPage
                                ? widget.dotIndicator?.selectedColor
                                : widget.dotIndicator?.unselectedColor ??
                                    widget.dotIndicator?.selectedColor
                                        ?.withOpacity(0.5),
                          ),
                          height: widget.dotIndicator?.size,
                          width: index == widget.initialPage
                              ? widget.dotIndicator!.size! * 2.5
                              : widget.dotIndicator!.size,
                          duration: const Duration(milliseconds: 350),
                        ),
                      ),
                    ),
                  ),
                ),
          if (widget.customFullNextButton == null)
            Positioned(
              bottom: 35,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    (widget.initialPage == 0 || widget.back == null)
                        ? const SizedBox()
                        : TextButton(
                            onPressed: () => pageController.previousPage(
                              duration: widget.back!.animationDuration!,
                              curve: widget.back!.curve!,
                            ),
                            style: widget.back!.style,
                            child: widget.back!.child,
                          ),
                    lastIndex
                        ? TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                PageRouteBuilder(
                                  transitionDuration:
                                      widget.done.animationDuration!,
                                  transitionsBuilder: (context, animation,
                                      secondAnimation, child) {
                                    animation = CurvedAnimation(
                                      parent: animation,
                                      curve: widget.done.curve!,
                                    );
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: widget.scrollDirection ==
                                                Axis.vertical
                                            ? const Offset(0, 1.0)
                                            : const Offset(1.0, 0.0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    );
                                  },
                                  pageBuilder:
                                      (context, animation, secondaryAnimation) {
                                    return widget.done.home!;
                                  },
                                ),
                              );
                            },
                            style: widget.done.style,
                            child: widget.done.child,
                          )
                        : widget.next == null
                            ? const SizedBox()
                            : TextButton(
                                onPressed: () => pageController.nextPage(
                                  duration: widget.next!.animationDuration!,
                                  curve: widget.next!.curve!,
                                ),
                                style: widget.next!.style,
                                child: widget.next!.child,
                              ),
                  ],
                ),
              ),
            ),
          if (widget.customFullNextButton != null)
            Positioned(
              bottom: 35,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: GestureDetector(
                  onTap: () {
                    if (!lastIndex) {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: !lastIndex
                      ? widget.customFullNextButton
                      : widget.customLastItemButton,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
