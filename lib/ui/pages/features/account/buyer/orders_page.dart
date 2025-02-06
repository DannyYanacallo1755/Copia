import 'package:intl/intl.dart';
import 'package:ourshop_ecommerce/ui/pages/features/account/buyer/order_detail.dart';
import 'package:ourshop_ecommerce/ui/pages/pages.dart';

class BuyerOrdes extends StatefulWidget {
  const BuyerOrdes({super.key});

  @override
  State<BuyerOrdes> createState() => _BuyerOrdesState();
}

class _BuyerOrdesState extends State<BuyerOrdes> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    fetchBuyerOrdes();
    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  Future<void> fetchBuyerOrdes() async {
    await context.read<OrdersBloc>().getFilteredBuyerOrders(1);
  }

  void _scrollListener() async {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        context.read<OrdersBloc>().state.hasMore &&
        context.read<OrdersBloc>().state.ordersStatus !=
            OrdersStatus.loadingMore) {
      if (context.read<OrdersBloc>().state.ordersStatus !=
          OrdersStatus.loadingMore) {
        await context.read<OrdersBloc>().getFilteredBuyerOrders(
            context.read<OrdersBloc>().state.currentPage + 1);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
    context.read<OrdersBloc>().restartState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Size size = MediaQuery.of(context).size;
    final AppLocalizations translations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          translations.orders,
          style: const TextStyle(
              color: Color(0xff003049),
              fontSize: 18.0,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          if (state.ordersStatus == OrdersStatus.loading &&
              state.adminOrders.isEmpty) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state.ordersStatus == OrdersStatus.error &&
              state.adminOrders.isEmpty) {
            return Center(
                child: Text('Error',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.black)));
          }
          if (state.filteredAdminOrders.isEmpty) {
            return Center(
              child: Text(
                translations.no_orders_found,
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              height: size.height,
              width: size.width,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: state.hasMore
                          ? state.filteredAdminOrders.length + 1
                          : state.filteredAdminOrders.length,
                      itemBuilder: (context, index) {
                        if (index >= state.adminOrders.length &&
                            state.hasMore) {
                          return const Center(
                              child: CircularProgressIndicator.adaptive());
                        }

                        final FilteredOrders order = state.adminOrders[index];
                        String orderStatus = translateOrderStatus(
                            order.orderStatus, translations);
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: 5.0, left: 4.0, right: 5.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xff003049).withOpacity(0.15),
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 15.0),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${translations.order}: ${order.orderNumber}',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                    color: const Color(
                                                        0xff032030)),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            '${translations.order_date}: ${order.orderStatuses.isNotEmpty && order.orderStatuses[0].createdAt != null ? formatDateTime(order.orderStatuses[0].createdAt) : translations.no_information}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                    color: Colors.black54),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            '${translations.shipping_address}: ${order.shippingName.isEmpty ? translations.no_information : order.shippingName}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                    color: Colors.black54),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            '${translations.order_status}: ${orderStatus.toString().toUpperCase()}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: orderStatus ==
                                                          translations.paid ||
                                                      orderStatus ==
                                                          translations.delivered
                                                  ? Colors.green
                                                  : Colors.orange,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            '${translations.total}: \$${order.total.toStringAsFixed(2)}',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: const Color(0xff003049),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          OrderDetailBuyer(order: order.id),
                                    ),
                                  );
                                }),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String translateOrderStatus(String content, translations) {
    switch (content) {
      case 'RETURNED':
        return translations.returned;
      case 'DRAFT_ADMIN':
      case 'DRAFT_ECOMMERCE':
        return translations.draft;
      case 'PENDING_ADMIN':
      case 'PENDING_ECOMMERCE':
        return translations.pending;
      case 'PAID':
        return translations.paid;
      case 'PROCESSING':
        return translations.processing;
      case 'PACKING':
        return translations.packing;
      case 'SHIPPED':
        return translations.shipped;
      case 'IN_TRANSIT':
        return translations.in_transit;
      case 'OUT_FOR_DELIVERY':
        return translations.out_for_delivery;
      case 'CANCELLED':
        return translations.cancelled;
      case 'DELIVERED':
        return translations.delivered;
      default:
        return content; 
    }
  }

  String formatDateTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
      String formattedTime = DateFormat('HH:mm:ss').format(dateTime);

      return '$formattedDate $formattedTime';
    } catch (e) {
      return '';
    }
  }
}
