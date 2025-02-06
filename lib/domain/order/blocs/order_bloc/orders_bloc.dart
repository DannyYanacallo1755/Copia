import 'dart:developer';

import '../../../../ui/pages/pages.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrderService _orderService;
  OrdersBloc(OrderService service)
      : _orderService = service,
        super(const OrdersState()) {
    on<AddAdminOrdersEvent>((event, emit) => emit(state.copyWith(
        adminOrders: event.adminOrders,
        currentPage: event.page,
        totalPages: event.totalPages)));
    on<AddOrdersStatusEvent>((event, emit) => emit(state.copyWith(
        ordersStatus: event.ordersStatus, hasMore: event.hasMore)));
    on<AddFilteredAdminOrdersEvent>((event, emit) =>
        emit(state.copyWith(filteredAdminOrders: event.filteredAdminOrders)));
    on<FilterAdminOrdersEvent>((event, emit) {
      final List<FilteredOrders> filteredAdminOrders = state.filteredAdminOrders
          .where((element) => element.customerName
              .toLowerCase()
              .contains(event.searchString.toLowerCase()))
          .toList();
      log('filteredAdminOrders: $filteredAdminOrders');
      if (filteredAdminOrders.isNotEmpty) {
        emit(state.copyWith(
            filteredAdminOrders: filteredAdminOrders, isFiltering: false));
      } else {
        emit(state.copyWith(
            filteredAdminOrders: state.adminOrders, isFiltering: false));
      }
    });

    on<AddOrdersByUserEvent>((event, emit) async {
      try {
        emit(state.copyWith(ordersStatus: OrdersStatus.loading));
        //
        emit(state.copyWith(ordersStatus: OrdersStatus.loaded));
      } catch (e) {
        log('e: $e');
      }
    });

    on<NewOrderEvent>((event, emit) async {
      try {
        emit(state.copyWith(ordersStatus: OrdersStatus.submittingOrder));
        final dynamic response = await _orderService.addNewOrder(event.data);
        if (response is OrderResponse) {
          emit(state.copyWith(ordersStatus: OrdersStatus.orderSubmitted));
        }
        emit(state.copyWith(ordersStatus: OrdersStatus.initial));
      } catch (e) {
        log('e: $e');
      }
    });

    on<UpdateOrderEvent>((event, emit) async {
      try {
        emit(state.copyWith(ordersStatus: OrdersStatus.updatingOrder));

        final dynamic response =
            await _orderService.updateOrder(event.updatedData, event.orderId);

        if (response is OrderResponse) {
          final updatedOrders = state.adminOrders.map((order) {
            if (order.id == event.orderId) {
              return order.copyWith(
                orderNumber: event.updatedData['orderNumber'] as String?,
                customerId: event.updatedData['customerId'] as String?,
                customerName: event.updatedData['customerName'] as String?,
                orderStatus: event.updatedData['orderStatus'] as String?,
                subTotal: event.updatedData['subTotal'] as double?,
                discount: event.updatedData['discount'] as double?,
                total: event.updatedData['total'] as double?,
              );
            }
            return order;
          }).toList();

          emit(state.copyWith(
            adminOrders: updatedOrders,
            ordersStatus: OrdersStatus.orderUpdated,
          ));
        } else {
          emit(state.copyWith(ordersStatus: OrdersStatus.error));
        }
      } catch (e) {
        log('Update Order Error: $e');
        emit(state.copyWith(ordersStatus: OrdersStatus.error));
      }
    });
  }

  Future<void> getFilteredAdminOrders(int page) async {
    if (page == 1) {
      add(const AddOrdersStatusEvent(ordersStatus: OrdersStatus.loading));
    } else {
      add(const AddOrdersStatusEvent(ordersStatus: OrdersStatus.loadingMore));
    }

    log('company id: ${locator<UsersBloc>().state.loggedUser.companyId}');

    final filteredParameters = {
      "uuids": [
        {
          "fieldName": "orderItems.product.company.id",
          "value": locator<UsersBloc>().state.loggedUser.companyId
        }
      ],
      "searchFields": [],
      "sortOrders": [
        {"fieldName": "createdAt", "direction": -1}
      ],
      "page": page,
      "pageSize": 10,
      "searchString": ""
    };

    try {
      final response =
          await _orderService.getFilteredAdminOrders(filteredParameters);
      if (response is FilteredData) {
        final List<FilteredOrders> updatedOrders =
            List<FilteredOrders>.from(state.adminOrders);
        updatedOrders.addAll(response.content as List<FilteredOrders>);

        add(AddFilteredAdminOrdersEvent(filteredAdminOrders: updatedOrders));

        add(AddAdminOrdersEvent(
          adminOrders: updatedOrders,
          page: response.page,
          totalPages: response.totalPages,
        ));
        final hasMore = response.page < response.totalPages;
        add(AddOrdersStatusEvent(
          ordersStatus: OrdersStatus.loaded,
          hasMore: hasMore,
        ));
      }
    } catch (e) {
      log('e: $e');
      add(const AddOrdersStatusEvent(ordersStatus: OrdersStatus.error));
    }
  }

  Future<Order> getOrderById(String orderId) async {
    try {
      final response = await _orderService.getOrderbyId(orderId);
      return response;
    } catch (e) {
      log('e: $e');
      throw Exception('Error getting order by id :$e');
    }
  }

  void restartState() {
    add(const AddAdminOrdersEvent(adminOrders: [], page: 1, totalPages: 1));
    add(const AddOrdersStatusEvent(
      ordersStatus: OrdersStatus.initial,
      hasMore: true,
    ));
  }

  Future<void> getFilteredBuyerOrders(int page) async {
    if (page == 1) {
      add(const AddOrdersStatusEvent(ordersStatus: OrdersStatus.loading));
    } else {
      add(const AddOrdersStatusEvent(ordersStatus: OrdersStatus.loadingMore));
    }

    log('company id: ${locator<UsersBloc>().state.loggedUser.userId}');

    final filteredParameters = {
      "uuids": [
        {
          "fieldName": "customer.id",
          "value": locator<UsersBloc>().state.loggedUser.userId
        }
      ],
      "searchFields": [],
      "sortOrders": [
        {"fieldName": "createdAt", "direction": -1}
      ],
      "page": page,
      "pageSize": 10,
      "searchString": ""
    };

    try {
      final response =
          await _orderService.getFilteredAdminOrders(filteredParameters);
      if (response is FilteredData) {
        final List<FilteredOrders> updatedOrders =
            List<FilteredOrders>.from(state.adminOrders);
        updatedOrders.addAll(response.content as List<FilteredOrders>);

        add(AddFilteredAdminOrdersEvent(filteredAdminOrders: updatedOrders));

        add(AddAdminOrdersEvent(
          adminOrders: updatedOrders,
          page: response.page,
          totalPages: response.totalPages,
        ));
        final hasMore = response.page < response.totalPages;
        add(AddOrdersStatusEvent(
          ordersStatus: OrdersStatus.loaded,
          hasMore: hasMore,
        ));
      }
    } catch (e) {
      log('e: $e');
      add(const AddOrdersStatusEvent(ordersStatus: OrdersStatus.error));
    }
  }
}
