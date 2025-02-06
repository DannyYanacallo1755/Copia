import '../../../pages.dart';

enum SectionType {
  videos,
  text,
  custom,
}

class Section extends StatelessWidget {
  final String title;
  final String content;
  final ThemeData theme;
  final AppLocalizations translations;
  final SectionType type;
  final FilteredProduct? product;

  const Section({
    super.key,
    required this.title,
    required this.content,
    required this.theme,
    required this.translations, 
    required this.type, 
    this.product,
  }) : assert(type != SectionType.videos || product != null, 'Product must be provided for video sections');

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10.0),
        const Divider(indent: 12, endIndent: 20),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: const Color(0xff5d5f61),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        if (type == SectionType.text) 
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              content,
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xff5d5f61),
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        else if (type == SectionType.custom)
          Container(
            color: Colors.grey.shade50,
            height: size.height * 0.30,
            width: double.infinity,
            child: FutureBuilder<List<Review>?>(
              future: context.read<ProductsBloc>().getProductReviews(product!.id),
              builder: (BuildContext context, AsyncSnapshot<List<Review>?> snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator.adaptive());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(translations.error, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black),));
                }

                if(!snapshot.hasData) {
                  return const Center(child: Text('No reviews', style: TextStyle(color: Colors.black),));
                }

                if(snapshot.data!.isEmpty) {
                  return const Center(child: Text('No reviews', style: TextStyle(color: Colors.black),));
                }

                return ListView.separated(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final Review review = snapshot.data![index];
                    return ListTile(
                      titleTextStyle: theme.textTheme.labelMedium?.copyWith(color: Colors.black, fontWeight: FontWeight.w600),
                      shape: theme.listTileTheme.copyWith(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0))
                      ).shape,
                      title: Row(
                        children: [
                          const Icon(Icons.person, color: Colors.black, size: 18),
                          Text(
                            review.fullName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: const Color(0xff5d5f61),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          RaitingBarWidget(product: product!,)
                        ],
                      ),
                      subtitle: Text(
                        review.content,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: const Color(0xff5d5f61),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    );
                  }, 
                  separatorBuilder: (context ,index) =>  const Divider(indent: 10, endIndent: 20,), 
                );
              },
            ),
          )
       
        else if (type == SectionType.videos && product!.productVideos.isNotEmpty)
      
          VideoProductSection(product: product!, theme: theme)
        else const SizedBox.shrink(),
        const SizedBox(height: 10.0),
      ],
    );
  }
}

class VideoProductSection extends StatelessWidget {
  VideoProductSection({
    super.key,
    required this.product,
    required this.theme,
  });

  final FilteredProduct product;
  final ThemeData theme;

  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);
  final CarouselSliderController _controller = CarouselSliderController();

  String getMainUrl (dynamic link) {

    if(link is String && link.isNotEmpty) {
      return '${dotenv.env['PRODUCT_URL']}$link';
    }
    return product.productVideos.isNotEmpty ? '${dotenv.env['PRODUCT_URL']}${product.productVideos.first.video!.url}' :  'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Video(url: getMainUrl(product.mainVideoUrl), height: 250, width: size.width),
          const SizedBox(height: 10.0),
          ListVideos(
            videos: product.productVideos,
            controller: _controller,
            currentPage: _currentPage,
          ),
          ValueListenableBuilder(
            valueListenable: _currentPage, 
            builder: (context, value, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: product.productVideos.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _controller.animateToPage(entry.key),
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: value == entry.key ? AppTheme.palette[1000] : AppTheme.palette[700]
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}

class ListVideos extends StatelessWidget {
  const ListVideos({
    super.key,
    required this.videos, 
    required this.controller, 
    required this.currentPage,
  });

  final List<FilteredProductMedia> videos;
  final CarouselSliderController controller;
  final ValueNotifier<int> currentPage;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: 150,
      width: size.width,
      // child: ListView.builder(
      //   scrollDirection: Axis.horizontal,
      //   itemCount: widget.videos.length,
      //   itemBuilder: (BuildContext context, int index) {
      //     final FilteredProductMedia video = widget.videos[index];
      //     return Video(url: '${dotenv.env['PRODUCT_URL']}${video.video?.url}', height: 150, width: size.width * 0.60);
      //   },
      // ),
      child: CarouselSlider(
        options: CarouselOptions(
          height: size.height * 0.4,
          viewportFraction: 1.0,
          enableInfiniteScroll: false,
          onPageChanged: (index, reason) {
            currentPage.value = index;
          },
        ),
        items: videos.map((video) => Video(url: '${dotenv.env['PRODUCT_URL']}${video.video?.url}', height: 150, width: size.width * 0.60)).toList(),
      )
    );
  }
}

class Video extends StatefulWidget {
  const Video({
    super.key,
    required this.url, required this.height, required this.width,
  });

  final double height;
  final double width;
  final String url;

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> {

  late FlickManager flickManager;

  @override
  void initState() {
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true,),
      ),
      autoPlay: false
    );
    super.initState();
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(5.0),
          child: FlickVideoPlayer(
          flickManager: flickManager,
          flickVideoWithControls: const FlickVideoWithControls(
            controls: FlickPortraitControls(),
          ),
        ),
      ),
    );
  }
}