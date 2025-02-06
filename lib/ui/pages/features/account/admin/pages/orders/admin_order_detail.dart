import 'package:ourshop_ecommerce/ui/pages/pages.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.order});
  final FilteredOrders order;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage>
    with TickerProviderStateMixin {
  final ValueNotifier<bool> _editMode = ValueNotifier<bool>(false);

  final List<String> tabs = ['Articulos', 'Estados y comentarios'];
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

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  late TabController _tabController;
  final OrderService _orderService = locator<OrderService>();
  late String orderStatus;

  var _isLoading = false;

  @override
  void initState() {
    orderStatus = widget.order.orderStatus;
    _tabController = TabController(
      length: orderStatus == 'CANCELLED' ||
              orderStatus == 'DELIVERED' ||
              orderStatus == 'PENDING_ADMIN' ||
              orderStatus == 'PENDING_ECOMMERCE'
          ? 1
          : 2,
      vsync: this,
    );
    _editMode.value = true;
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _editMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translations = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final TextStyle style =
        theme.textTheme.bodyLarge!.copyWith(color: Colors.black);
    final Size size = MediaQuery.of(context).size;
    const Widget spacer = SizedBox(height: 10);

    return Scaffold(
      appBar: AppBar(
          title: Text('${translations.order} #${widget.order.orderNumber}'),
          elevation: 0.0,
          actions: [
            IconButton(
                onPressed: () {},
                icon: Icon(!_editMode.value ? Icons.edit : null))
          ],
          bottom: const PreferredSize(
              preferredSize: Size.fromHeight(5.0),
              child: Divider(
                indent: 30,
                endIndent: 30,
              ))),
      body: Container(
        color: Colors.white,
        height: size.height,
        width: size.width,
        child: ValueListenableBuilder(
          valueListenable: _editMode,
          builder: (BuildContext context, value, Widget? child) {
            if (value) {
              final TextStyle style =
                  theme.textTheme.bodyMedium!.copyWith(color: Colors.black);
              return FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: FormBuilderTextField(
                          name: "client-name",
                          style: style,
                          initialValue: widget.order.customerName,
                          decoration: InputDecoration(
                            labelText: translations.client_name,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: FormBuilderTextField(
                          name: "status",
                          style: style,
                          initialValue: translateOrderStatus(
                              widget.order.orderStatus, translations),
                          decoration: InputDecoration(
                            labelText: translations.status(''),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: FormBuilderTextField(
                          name: "total",
                          style: style,
                          initialValue: widget.order.total.toString(),
                          decoration: InputDecoration(
                            labelText: translations.total,
                          ),
                        ),
                      ),
                      DefaultTabController(
                          length: tabs.length,
                          child: Column(
                            children: [
                              TabBar(
                                isScrollable: true,
                                controller: _tabController,
                                tabAlignment: TabAlignment.center,
                                tabs: [
                                  Tab(text: translations.articles),
                                  if (widget.order.orderStatus != 'CANCELLED' &&
                                      widget.order.orderStatus != 'DELIVERED' &&
                                      widget.order.orderStatus !=
                                          'PENDING_ADMIN' &&
                                      widget.order.orderStatus !=
                                          'PENDING_ECOMMERCE')
                                    Tab(text: translations.state_comments),
                                ],
                              ),
                            ],
                          )),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            Container(
                              width: size.width,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: FutureBuilder<Order>(
                                future: context
                                    .read<OrdersBloc>()
                                    .getOrderById(widget.order.id),
                                builder: (BuildContext context,
                                    AsyncSnapshot<Order> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator
                                            .adaptive());
                                  }
                                  if (snapshot.hasError) {
                                    return const Center(child: Text('Error'));
                                  }
                                  return ListView.builder(
                                    itemCount:
                                        snapshot.data!.orderItems?.length,
                                    itemBuilder: (context, index) {
                                      final OrderItem item =
                                          snapshot.data!.orderItems![index];
                                      return _Article(
                                          size: size,
                                          item: item,
                                          style: style,
                                          translations: translations);
                                    },
                                  );
                                },
                              ),
                            ),
                            if (orderStatus != 'CANCELLED' &&
                                orderStatus != 'DELIVERED' &&
                                orderStatus != 'PENDING_ADMIN' &&
                                orderStatus != 'PENDING_ECOMMERCE')
                              Container(
                                height: size.height,
                                width: size.width,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: FormBuilderDropdown(
                                          name: "order-status",
                                          decoration: InputDecoration(
                                            labelText:
                                                translations.order_status,
                                            hintText: translations.order_status,
                                          ),
                                          items: status
                                              .map((e) => DropdownMenuItem(
                                                  value: e, child: Text(e)))
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: FormBuilderTextField(
                                          name: "comentario",
                                          decoration: InputDecoration(
                                            labelText: translations.comments,
                                            hintText: translations.comments,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0),
                                        child: Text(
                                          translations.order_status_history,
                                          style: style.copyWith(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: FutureBuilder<Order>(
                                        future: context
                                            .read<OrdersBloc>()
                                            .getOrderById(widget.order.id),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<Order> snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                                child: CircularProgressIndicator
                                                    .adaptive());
                                          }
                                          if (snapshot.hasError) {
                                            return Center(
                                                child: Text(
                                              'Error',
                                              style: style,
                                            ));
                                          }
                                          return ListView.builder(
                                            itemCount: snapshot
                                                .data!.orderItems?.length,
                                            itemBuilder: (context, index) {
                                              final OrderItem item = snapshot
                                                  .data!.orderItems![index];
                                              return _Article(
                                                  size: size,
                                                  item: item,
                                                  style: style,
                                                  translations: translations);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (widget.order.orderStatus != 'CANCELLED' &&
                          widget.order.orderStatus != 'DELIVERED' &&
                          widget.order.orderStatus != 'PENDING_ADMIN' &&
                          widget.order.orderStatus != 'PENDING_ECOMMERCE')
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: _isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xff003049)),
                                      strokeWidth: 3.0,
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.save,
                                        color: Colors.black),
                                    onPressed: () {
                                      _onSubmit(context, widget.order);
                                    },
                                  ),
                          ),
                        )
                    ],
                  ));
            }
            return child!;
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                translations.client(widget.order.customerName),
                style: style,
              ),
              spacer,
              Text(translateOrderStatus(widget.order.orderStatus, translations),
                  style: style),
              spacer,
              Text(translations.total_order('\$${widget.order.total}'),
                  style: style.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
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

  void _onSubmit(BuildContext context, FilteredOrders order) async {
    var orderStatus = '';
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState?.value;
      double total = double.tryParse(formData?['total'] ?? '0') ?? 0.0;

      var items =
          await context.read<OrdersBloc>().getOrderById(widget.order.id);

      if (formData?['order-status'] == 'Pendiente') {
        orderStatus = 'PENDING_ECOMMERCE';
      } else if (formData?['order-status'] == 'Enviado') {
        orderStatus = 'SHIPPED';
      } else if (formData?['order-status'] == 'Entregado') {
        orderStatus = 'DELIVERED';
      } else if (formData?['order-status'] == 'Cancelado') {
        orderStatus = 'CANCELLED';
      } else if (formData?['order-status'] == 'Pagado') {
        orderStatus = 'PAID';
      } else if (formData?['order-status'] == 'Borrador') {
        orderStatus = 'DRAFT_ADMIN';
      } else if (formData?['order-status'] == 'Pendiente') {
        orderStatus = 'PENDING_ADMIN';
      } else if (formData?['order-status'] == 'En proceso') {
        orderStatus = 'PROCESSING';
      } else if (formData?['order-status'] == 'Empacando') {
        orderStatus = 'PACKING';
      } else if (formData?['order-status'] == 'En tránsito') {
        orderStatus = 'IN_TRANSIT';
      } else if (formData?['order-status'] == 'En camino para entrega') {
        orderStatus = 'OUT_FOR_DELIVERY';
      } else if (formData?['order-status'] == 'Devuelto') {
        orderStatus = 'RETURNED';
      }

      final Map<String, dynamic> updatedData = {
        "customerId": order.customerId,
        "orderStatus": orderStatus,
        "total": total,
        "orderItems": items.orderItems!.map((e) {
          return {
            "id": e.id,
            "orderId": e.orderId,
            "productId": e.id,
            "productName": e.productName,
            "productCategoryName": e.productCategoryName ?? "",
            "productUnitMeasurementName": e.productUnitMeasurementName,
            "productMainPhotoUrl": e.productMainPhotoUrl ?? '',
            "productCompanyId": e.productCompanyId ?? 0,
            "description": e.description,
            "shippingRangeCalculationId": order.orderPackages[0].id,
            "packageDetails": {
              "id": order.orderPackages[0].packageDetails[0].id,
              "orderItemId":
                  order.orderPackages[0].packageDetails[0].orderItemId,
              "orderPackageId":
                  order.orderPackages[0].packageDetails[0].orderPackageId,
              "orderItemProductId":
                  order.orderPackages[0].packageDetails[0].orderItemProductId,
              "orderItemProductName":
                  order.orderPackages[0].packageDetails[0].orderItemProductName,
              "quantity": order.orderPackages[0].packageDetails[0].quantity,
              "price": order.orderPackages[0].packageDetails[0].price,
              "total": order.orderPackages[0].packageDetails[0].total
            },
            "qty": e.qty ?? 0,
            "price": e.price ?? 0.0,
            "discount": e.discount ?? 0,
            "total": e.total ?? 0,
            "subTotal": e.subTotal ?? 0,
            "companyName": e.companyName ?? '',
          };
        }).toList(),
        "comments": formData?['comentario'],
        "shippingAddressId": order.shippingAddressId,
        "shippingRangeCalculation": order.orderPackages.map((i) {
          return {
            "id": null,
            "cost": 4.4,
            "trackingNumber": null,
            "packageStatus": "PROCESSING",
            "quantity": 1,
            "weight": 2,
            "subTotal": 4,
            "discount": 0,
            "total": 4,
            "trackingStatus": null,
            "trackingEvents": null,
            "shippingServiceRateId": null,
            "shippingServiceRateCourierId": null,
            "shippingServiceRateCourierCode": null,
            "shippingServiceRateCourierName": null,
            "estimatedDeliveryDate": null,
            "actualDeliveryDate": null,
            "packageDetails": [
              {
                "id": null,
                "orderItemId": null,
                "orderPackageId": null,
                "orderItemProductId": i.packageDetails[0].orderItemProductId,
                "orderItemProductName":
                    i.packageDetails[0].orderItemProductName,
                "quantity": i.packageDetails[0].quantity,
                "price": i.packageDetails[0].price,
                "total": i.packageDetails[0].total
              }
            ],
            "orderId": null,
            "companyId": order.orderPackages[0].companyId,
            "companyName": order.orderPackages[0].companyName
          };
        }).toList()
      };

      var response = await _orderService.updateOrder(updatedData, order.id);
      if (response.data == null) {
        setState(() {
          _isLoading = false;
        });
        ErrorToast(
          title: AppLocalizations.of(context)!.error,
          description: AppLocalizations.of(context)!.error_updated_status,
          style: ToastificationStyle.flatColored,
          foregroundColor: Colors.white,
          backgroundColor: Colors.red.shade500,
          icon: const Icon(
            Icons.error,
            color: Colors.white,
          ),
        ).showToast(context);
      } else {
        setState(() {
          _isLoading = false;
        });
        SuccessToast(
          title: AppLocalizations.of(context)!.suceess,
          description: AppLocalizations.of(context)!.updated_status,
          style: ToastificationStyle.flatColored,
          foregroundColor: Colors.white,
          backgroundColor: Colors.green.shade500,
          icon: const Icon(
            Icons.check,
            color: Colors.white,
          ),
        ).showToast(context);
        Navigator.pop(context);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, completa los campos requeridos.')),
      );
    }
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
          ]),
      width: size.width,
      child: Row(
        children: [
          ClipRRect(
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
                        )
                      ],
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
                  ),
                  Text(translations.unit_price(item.price!), style: style),
                  Text(translations.discount(item.discount!), style: style),
                  Text(translations.sub_total(item.subTotal!), style: style),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
