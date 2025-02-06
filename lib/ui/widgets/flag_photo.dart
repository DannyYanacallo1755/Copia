
import 'dart:developer';

import '../pages/pages.dart';

class FlagPhoto extends StatelessWidget {
  const FlagPhoto({
    super.key, 
    required this.country,
  });

  final Country country;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      key: ValueKey('${dotenv.env['FLAG_URL']}${country.flagUrl}'),
      cacheKey: '${dotenv.env['FLAG_URL']}${country.flagUrl}',
      imageUrl: '${dotenv.env['FLAG_URL']}${country.flagUrl}', 
      width: 30, 
      height: 30,
      fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorWidget: (context, url, error) {
          return  const Icon(Icons.error);
        },
        imageBuilder: (context, imageProvider) {
          return Image(image: imageProvider, fit: BoxFit.cover);
        },
        errorListener: (value) {
          log('value: $value');
        },
        placeholderFadeInDuration: const Duration(milliseconds: 500),
        fadeInDuration: const Duration(milliseconds: 500),
        fadeOutDuration: const Duration(milliseconds: 500),
        fadeInCurve: Curves.easeIn,
        fadeOutCurve: Curves.easeOut,
        progressIndicatorBuilder: (context, url, progress) {
          return Center(
            child: CircularProgressIndicator.adaptive(
              value: progress.progress,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.palette[1000]!),
            )
          );
        },
    );
  }
}