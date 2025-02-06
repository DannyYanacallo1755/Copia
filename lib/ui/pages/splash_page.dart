

import 'dart:async';
import 'package:ourshop_ecommerce/ui/pages/pages.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _downAnimation;
  late Animation<double> _downOpacity;

  final ValueNotifier<int> percent = ValueNotifier(0);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _downAnimation = Tween<double>(begin: -500.0, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    _downOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _startIncrementing();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _startIncrementing() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (percent.value < 100) {
        percent.value += 1;
      } else {
        _timer?.cancel();
        _navigateToChooseLanguagePage();
      }
    });
  }
  void _navigateToChooseLanguagePage() {
    locator<Preferences>().saveLastVisitedPage('splash_page');
    context.go('/choose-language');
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([_controller]),
              builder: (BuildContext context, Widget? child) {
                return Transform.translate(
                  offset: Offset(0, _downAnimation.value),
                  child: Opacity(
                    opacity: _downOpacity.value,
                    child: child
                  ),
                );
              },
              child: Image.asset('assets/logos/logo_ourshop_1.png', width: 200, height: 200,)
            ),
            ValueListenableBuilder(
              valueListenable: percent,
              builder: (BuildContext context, value, _) {
                return CircularProgressIndicator.adaptive(
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff263959)),
                  backgroundColor: const Color(0xff3fe7b6),
                  value: value / 100,
                );
              },
            ),
            const SizedBox(height: 10.0,),
            ValueListenableBuilder(
              valueListenable: percent,
              builder: (BuildContext context, value, _) {
                if (_controller.isCompleted) {
                  return Text('$value%', style: theme.textTheme.titleMedium,);
                }
                return const SizedBox();
              },
            )
          ],
        ),
      ),
    );
  }
}