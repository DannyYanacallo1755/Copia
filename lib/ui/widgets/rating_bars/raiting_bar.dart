import '../../pages/pages.dart';

class RaitingBarWidget extends StatelessWidget {
  const RaitingBarWidget({
    super.key,
    required this.product,
    this.size,
  });

  final FilteredProduct product;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final Size s = MediaQuery.of(context).size;
    return RatingBar(
      initialRating: product.productReviewInfo!.ratingAvg,
      direction: Axis.horizontal,
      allowHalfRating: true,
      ignoreGestures: true,
      itemCount: 5,
      itemSize: size ?? s.width * 0.04,
      glowColor: Colors.amber,
      unratedColor: Colors.amber,
      ratingWidget: RatingWidget(                          
        full: const Icon(Icons.star, color: Colors.amber,),
        half: const Icon(Icons.star_half, color: Colors.amber,),
        empty: const Icon(Icons.star_border, color: Colors.amber,),
      ),
      tapOnlyMode: true,
      onRatingUpdate: (rating) {},
    );
  }
}
