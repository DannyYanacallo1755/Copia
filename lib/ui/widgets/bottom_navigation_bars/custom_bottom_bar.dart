import '../../pages/pages.dart';
import 'floating_navigation_bar.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({
    super.key, 
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:  BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 3,
            spreadRadius: 3,
            offset: const Offset(0, -1),
          )
        ]
      ),
      height: MediaQuery.of(context).size.height * 0.1,
      width: double.maxFinite,
      child: Center(
        child: child
      )
    );
  }
}



class BottomNavigationBarOption extends StatelessWidget {
  const BottomNavigationBarOption({
    super.key,
    required AnimationController scaleController,
    required AnimationController translationController,
    required Animation<double> scaleAnimation,
    required Animation<double> translationAnimation,
    required this.widget,
    required AnimationController zoomController,
    required Animation<double> zoomAnimation, 
    required this.id, 
    required this.text, 
    required this.icon, 
    required this.onTap, 
    this.selectedOption, 
    this.iconColor, 
    this.iconSize, 
    this.textStyle,
  }) : _scaleController = scaleController, _translationController = translationController, _scaleAnimation = scaleAnimation, _translationAnimation = translationAnimation, _zoomController = zoomController, _zoomAnimation = zoomAnimation;

  final int id;
  final String text;
  final IconData icon;
  final Function() onTap;
  final Function(int id)? selectedOption;
  final Color? iconColor;
  final double? iconSize;
  final TextStyle? textStyle;

  final AnimationController _scaleController;
  final AnimationController _translationController;
  final Animation<double> _scaleAnimation;
  final Animation<double> _translationAnimation;
  final FloatingBottomNavigationBar widget;
  final AnimationController _zoomController;
  final Animation<double> _zoomAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleController,
        _translationController
      ]
      ),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.translate(
            offset: Offset(0.0, _translationAnimation.value),
            child: child
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          onTap();
          selectedOption!(id);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _zoomController,
              builder: (BuildContext context,  Widget? child) {
                return Transform.scale(
                  scale: _zoomAnimation.value,
                  child: Icon(icon, color: iconColor, size: iconSize,)
                );
              },
              child: Icon(icon, color: iconColor, size: iconSize,)
            ),
            Text(text, style: textStyle,),
          ],
        ),
      ),
    );
  }
}