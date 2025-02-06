import '../../../pages.dart';

class OrderDetailBuyer extends StatefulWidget {
  final String order;
  const OrderDetailBuyer({super.key, required this.order});

  @override
  State<OrderDetailBuyer> createState() => _OrderDetailBuyerState();
}

class _OrderDetailBuyerState extends State<OrderDetailBuyer> {
  @override
  Widget build(BuildContext context) {
    final List<String> status = [
      'Borrador',
      'Pendiente',
      'Pagado',
      'En proceso',
      'Empacando',
      'Enviado',
      'En tránsito',
      'En camino para entrega',
      'Entregado',
      'Cancelado',
      'Devuelto'
    ];
    final ThemeData theme = Theme.of(context);
    final Size size = MediaQuery.of(context).size;
    final TextStyle style =
        theme.textTheme.bodyLarge!.copyWith(color: Colors.black);
    final AppLocalizations translations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          translations.order_detail,
          style: const TextStyle(
              color: Color(0xff003049),
              fontSize: 18.0,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<Order>(
        future: context.read<OrdersBloc>().getOrderById(widget.order),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final order = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormField(
                    label: translations.shipping_address,
                    content: (order.addressLine1 != null &&
                            order.addressLine1!.isNotEmpty)
                        ? order.addressLine1
                        : translations.no_information,
                  ),
                  const SizedBox(height: 5),
                  _buildFormField(
                    label: translations.order_status,
                    content: (order.orderStatus?.isEmpty ?? true)
                        ? translations.no_information
                        : order.orderStatus!,
                  ),
                  const SizedBox(height: 5),
                  _buildFormField(
                    label: translations.order_date,
                    content: order.createdAt != null
                        ? order.createdAt!.toLocal().toString().substring(0, 10)
                        : translations.no_information,
                  ),
                  const SizedBox(height: 5),
                  _buildFormField(
                    label: translations.total_shipping,
                    content: order.total != null
                        ? "\$${order.total!.toStringAsFixed(2)}"
                        : translations.no_information,
                    contentStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15.0),
                  ),
                  const SizedBox(height: 12),
                  Text(translations.articles,
                      style: const TextStyle(
                          color: Color(0xff003049), fontSize: 16.0)),
                  const SizedBox(height: 12),
                  ListView.builder(
                    itemCount: snapshot.data!.orderItems?.length ?? 0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final OrderItem item = snapshot.data!.orderItems![index];
                      return _Article(
                        size: size,
                        item: item,
                        style: style,
                        translations: translations,
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text(translations.no_information));
          }
        },
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String content,
    TextStyle? contentStyle,
  }) {
    final AppLocalizations translations = AppLocalizations.of(context)!;

    var orderStatus = content;
    if (content == 'RETURNED') {
      orderStatus = translations.returned;
    } else if (content == 'DRAFT_ADMIN' || content == 'DRAFT_ECOMMERCE') {
      orderStatus = translations.draft;
    } else if (content == 'PENDING_ADMIN' || content == 'PENDING_ECOMMERCE') {
      orderStatus = translations.pending;
    } else if (content == 'PAID') {
      orderStatus = translations.paid;
    } else if (content == 'PROCESSING') {
      orderStatus = translations.processing;
    } else if (content == 'PACKING') {
      orderStatus = translations.packing;
    } else if (content == 'SHIPPED') {
      orderStatus = translations.shipped;
    } else if (content == 'IN_TRANSIT') {
      orderStatus = translations.in_transit;
    } else if (content == 'OUT_FOR_DELIVERY') {
      orderStatus = translations.out_for_delivery;
    } else if (content == 'CANCELLED') {
      orderStatus = translations.cancelled;
    } else if (content == 'DELIVERED') {
      orderStatus = translations.delivered;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            orderStatus,
            style: contentStyle ??
                const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
          ),
        ],
      ),
    );
  }
}

class _Article extends StatelessWidget {
  const _Article({
    required this.size,
    required this.item,
    required this.style,
    required this.translations,
  });

  final Size size;
  final OrderItem item;
  final TextStyle style;
  final AppLocalizations translations;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5.0,
            spreadRadius: 2.0,
            offset: const Offset(0, 0),
          )
        ],
      ),
      width: size.width,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    child: CachedNetworkImage(
                      imageUrl:
                          '${dotenv.env['PRODUCT_URL']}${item.productMainPhotoUrl}',
                      fit: BoxFit.contain,
                    ),
                  );
                },
              );
            },
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5.0),
                  bottomLeft: Radius.circular(5.0)),
              child: item.productMainPhotoUrl != null
                  ? CachedNetworkImage(
                      imageUrl:
                          '${dotenv.env['PRODUCT_URL']}${item.productMainPhotoUrl}',
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    )
                  : SizedBox(
                      width: size.width * 0.25,
                      child: Column(
                        children: [
                          const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                          FittedBox(
                            child: Text(
                              translations.no_image,
                              style: style.copyWith(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 5.0, top: 10.0),
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Helpers.truncateText(item.productName!, 25),
                    style: style,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Flexible(
                    child: Text(
                      translations.unit_price(item.price!),
                      style: style,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1, // Limitar a una sola línea
                    ),
                  ),
                  Flexible(
                    child: Text(
                      translations.discount(item.discount!),
                      style: style,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1, // Limitar a una sola línea
                    ),
                  ),
                  Flexible(
                    child: Text(
                      translations.sub_total(item.subTotal!),
                      style: style,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
