import '../../../pages.dart';

class SubCategoryChip extends StatelessWidget {
  const SubCategoryChip({
    super.key,
    required this.onTap,
    required this.c,
    required this.theme,
  });

  final void Function(Category)? onTap;
  final Category c;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      onTap: () {
        if(onTap != null){
          onTap!(c);
        }
      } ,
      child: Chip(
        avatar: 
        c.iconSvg != null && c.iconSvg!.isNotEmpty ? SvgPicture.string(
          c.iconSvg!,
          placeholderBuilder: (context) => const Center(child: CircularProgressIndicator.adaptive()),
          fit: BoxFit.cover,
          width: 20,
          height: 20,
        ): null,
        label: Text(c.name, style: theme.textTheme.labelSmall,),
      ),
    );
  }
}

class SubcategoryCard extends StatelessWidget {
  const SubcategoryCard({
    super.key, 
    required this.height, 
    required this.width, 
    required this.theme, 
    required this.translations, 
    required this.onTap, 
    this.urlImage, 
    this.children,
    this.child
  });


  final double height;
  final double width;
  final ThemeData theme;
  final AppLocalizations translations;
  final void Function() onTap;
  final String? urlImage;
  final List<Widget>? children;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            if (urlImage == null || urlImage!.isEmpty) 
              const SizedBox.shrink() 
            else Expanded(
              child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
              child: SvgPicture.string(
                  urlImage!,
                  placeholderBuilder: (context) => const Center(child: CircularProgressIndicator.adaptive()),
                  fit: BoxFit.cover,
                )
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children ?? []
              ),
            ),
          ],
        ),
      ),
    );
  }
}