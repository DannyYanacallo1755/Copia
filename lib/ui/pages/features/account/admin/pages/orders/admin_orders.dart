import 'package:intl/intl.dart';

import '../../../../../pages.dart';

class AdminOrders extends StatefulWidget {
  const AdminOrders({super.key});

  @override
  State<AdminOrders> createState() => _AdminOrdersState();
}

class _AdminOrdersState extends State<AdminOrders> {
  late ScrollController _scrollController;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchAdminOrders();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> fetchAdminOrders() async {
    await context.read<OrdersBloc>().getFilteredAdminOrders(1);
  }

  void _scrollListener() async {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        context.read<OrdersBloc>().state.hasMore &&
        context.read<OrdersBloc>().state.ordersStatus !=
            OrdersStatus.loadingMore) {
      if (context.read<OrdersBloc>().state.ordersStatus !=
          OrdersStatus.loadingMore) {
        await context.read<OrdersBloc>().getFilteredAdminOrders(
            context.read<OrdersBloc>().state.currentPage + 1);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();

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
          final filteredOrders = state.adminOrders.where((order) {
            return order.customerName.toLowerCase().contains(_searchQuery) ||
                order.orderNumber.toLowerCase().contains(_searchQuery) ||
                order.createdAt.toLowerCase().contains(_searchQuery);
          }).toList();

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            height: size.height,
            width: size.width,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 5.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8.0,
                          spreadRadius: 1.0,
                        ),
                      ],
                    ),
                    child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 20.0),
                          hintText: '${translations.search}...',
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[600],
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        ),
                        cursorColor: const Color(0xff003049)),
                  ),
                ),
                const SizedBox(height: 10.0),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: state.hasMore
                        ? filteredOrders.length + 1
                        : filteredOrders.length,
                    itemBuilder: (context, index) {
                      if (index >= filteredOrders.length && state.hasMore) {
                        return const Center(
                            child: CircularProgressIndicator.adaptive());
                      }

                      final FilteredOrders order = filteredOrders[index];
                      String orderStatus =
                          translateOrderStatus(order.orderStatus, translations);
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: 5.0, left: 4.0, right: 5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
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
                                                color: const Color(0xff032030)),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '${translations.order_date}: ${order.orderStatuses.isNotEmpty && order.orderStatuses[0].createdAt != null ? formatDateTime(order.orderStatuses[0].createdAt) : translations.no_information}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: Colors.black54),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '${translations.client_name}: ${order.customerName}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: Colors.black54),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '${translations.order_status}: ${orderStatus.toUpperCase()}',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: orderStatus ==
                                                      translations.paid ||
                                                  orderStatus ==
                                                      translations.delivered
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ),
                                      SizedBox(height: 5),
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
                            onTap: () => context.push(
                              '/admin/option/orders/detail',
                              extra: order,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
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
