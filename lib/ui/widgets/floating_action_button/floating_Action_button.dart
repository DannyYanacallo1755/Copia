import '../../pages/pages.dart';

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({
    super.key, 
    this.onClick, 
    required this.child,
    this.type = FloatingActionButtonType.UNKNOWN
  });

  final void Function()? onClick;
  final Widget child;
  final FloatingActionButtonType type;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case FloatingActionButtonType.ADD:
        return FloatingActionButton(
          onPressed: onClick,
          child: child,
        );
      case FloatingActionButtonType.EDIT:
        return FloatingActionButton(
          onPressed: onClick,
          child: child,
        );
      case FloatingActionButtonType.DELETE:
        return FloatingActionButton(
          onPressed: onClick,
          child: child,
        );
      case FloatingActionButtonType.UNKNOWN:
        return FloatingActionButton(
          onPressed: onClick,
          child: child,
        );
      case FloatingActionButtonType.CART:
        return FloatingActionButton(
          onPressed: onClick,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              child,
              BlocBuilder<ProductsBloc, ProductsState>(
                buildWhen: (previous, current) => previous.cartProducts.length != current.cartProducts.length,
                builder: (context, state) {
                  if (state.cartProducts.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Text('${state.cartProducts.length}', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),);
                },
              )
            ]
          ),
        );
    }
  }
}

