import '../../pages/pages.dart';


class BottomOptions {
  final String text;
  final IconData icon;
  final Function() onTap;

  BottomOptions({required this.text, required this.icon, required this.onTap});
}

class FloatingBottomNavigationBar extends StatefulWidget {
  const FloatingBottomNavigationBar({
    super.key,
    required this.size,
    required this.options,
  });

  final Size size;
  final List<BottomOptions> options;

  @override
  State<FloatingBottomNavigationBar> createState() => _FloatingBottomNavigationBarState();
}

class _FloatingBottomNavigationBarState extends State<FloatingBottomNavigationBar> with TickerProviderStateMixin {

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;


  late AnimationController _translationController;
  late Animation<double> _translationAnimation;

  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;

  late AnimationController _notificationController;
  late Animation<double> _notificationAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _translationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _scaleController, curve: const Interval(0.10, 0.75, curve: Curves.easeIn)));
    _translationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_translationController);

    _zoomController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(CurvedAnimation(parent: _zoomController, curve: const Interval(0.10, 0.75, curve: Curves.easeIn)));

    _notificationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _notificationAnimation = Tween<double>(begin: -10.0, end: 1.0).animate(CurvedAnimation(parent: _notificationController, curve: Curves.easeIn));

    _scaleController.forward();
    _translationController.forward();
    _notificationController.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _scaleController.dispose();
    _translationController.dispose();
    _zoomController.dispose();
    _notificationController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Positioned(
      bottom: 20.0,
      left: 0.0,
      right: 0.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        height: widget.size.height * 0.10,
        width: widget.size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 1.0,
              spreadRadius: 1.0,
              offset: const Offset(0.0, 0.0)
            )
          ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widget.options.map((option) {
              final int id = widget.options.indexOf(option);
                return Stack(
                  children: [
                    BottomNavigationBarOption(
                      scaleController: _scaleController, 
                      translationController: _translationController, 
                      scaleAnimation: _scaleAnimation, 
                      translationAnimation: _translationAnimation, 
                      widget: widget, 
                      zoomController: _zoomController, 
                      zoomAnimation: _zoomAnimation,
                      id: id,
                      text: option.text, 
                      icon: option.icon, 
                      iconColor: id == context.watch<GeneralBloc>().state.selectedBottomNavTab ? AppTheme.palette[500] : Colors.grey.shade400,
                      textStyle: id == context.watch<GeneralBloc>().state.selectedBottomNavTab ? theme.textTheme.labelSmall?.copyWith(color: AppTheme.palette[500]) : theme.textTheme.labelSmall?.copyWith(color: Colors.grey.shade400),
                      onTap: option.onTap,
                      selectedOption: (id) {
                        context.read<GeneralBloc>().add(ChangeBottomNavTab(id));
                      },
                    ),
                    // 
                    if (id == 2 && context.watch<ProductsBloc>().state.cartProducts.isNotEmpty)
                      Positioned(
                        right: 0.0,
                        top: 1.0,
                        child: AnimatedBuilder(
                          animation: _notificationController,
                          builder: (BuildContext context, Widget? child) {
                            return Transform.translate(
                              offset: Offset(0.0, _notificationAnimation.value),
                              child: child,
                            );
                          },
                          child: CircleAvatar(
                            radius: 7.0,
                            backgroundColor: AppTheme.palette[600],
                            child: Text(
                              context.watch<ProductsBloc>().state.cartProducts.length.toString(),
                              style: theme.textTheme.labelSmall?.copyWith(color: Colors.white, fontSize: 8.0),
                            ),
                          ),
                        ),
                      )
                    else const SizedBox.shrink()
                  ],
                );
            } 
          ).toList()
        ),
      ),
    );
  }
}