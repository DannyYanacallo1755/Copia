part of 'orders_bloc.dart';

enum OrdersStatus {
  initial,
  loading,
  loaded,
  error,
  loadingMore,
  submittingOrder,
  orderSubmitted,
  updatingOrder,
  orderUpdated
}

class OrdersState extends Equatable {
  final List<FilteredOrders> adminOrders;
  final OrdersStatus ordersStatus;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final List<FilteredOrders> filteredAdminOrders;
  final bool isFiltering;
  final List<FilteredProduct> orderProducts;
  final List<FilteredOrders> ordersByUse;

  const OrdersState({
    this.adminOrders = const [],
    this.ordersStatus = OrdersStatus.initial,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = true,
    this.filteredAdminOrders = const [],
    this.isFiltering = false,
    this.orderProducts = const [],
    this.ordersByUse = const [],
  });

  OrdersState copyWith({
    List<FilteredOrders>? adminOrders,
    OrdersStatus? ordersStatus,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    List<FilteredOrders>? filteredAdminOrders,
    bool? isFiltering,
    List<FilteredProduct>? orderProducts,
    List<FilteredOrders>? ordersByUse,
  }) {
    return OrdersState(
      adminOrders: adminOrders ?? this.adminOrders,
      ordersStatus: ordersStatus ?? this.ordersStatus,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      filteredAdminOrders: filteredAdminOrders ?? this.filteredAdminOrders,
      isFiltering: isFiltering ?? this.isFiltering,
      orderProducts: orderProducts ?? this.orderProducts,
      ordersByUse: ordersByUse ?? this.ordersByUse,
    );
  }

  @override
  List<Object> get props => [
        adminOrders,
        ordersStatus,
        currentPage,
        totalPages,
        hasMore,
        filteredAdminOrders,
        isFiltering,
        orderProducts,
        ordersByUse,
      ];
}
