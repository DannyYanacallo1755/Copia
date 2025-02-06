import '../../ui/pages/pages.dart';

class OrderResponse extends Equatable {
    final bool success;
    final String message;
    final Order? data;

    const OrderResponse({
        required this.success,
        required this.message,
        this.data,
    });

    OrderResponse copyWith({
        bool? success,
        String? message,
        Order? data,
    }) => 
        OrderResponse(
            success: success ?? this.success,
            message: message ?? this.message,
            data: data ?? this.data,
        );

    factory OrderResponse.fromJson(Map<String, dynamic> json) => OrderResponse(
        success: json["success"],
        message: json["message"],
        data: json['data'] != null ? Order.fromJson(json["data"]) : null,
    );
    
    @override
    List<Object?> get props => [
        success,
        message,
        data,
    ];
}


class Order {
    final String? id;
    final String? orderNumber;
    final String? customerId;
    final String? customerName;
    final String? orderStatus;
    final List<OrderItem>? orderItems;
    final dynamic orderStatuses;
    final double? subTotal;
    final double? discount;
    final double? total;
    final DateTime? createdAt;
    final dynamic addressLine1;
    final dynamic addressLine2;
    final dynamic addressLine3;
    final dynamic phoneNumber;
    final dynamic city;
    final dynamic state;
    final dynamic country;
    final dynamic zipCode;

    Order({
        this.id,
        this.orderNumber,
        this.customerId,
        this.customerName,
        this.orderStatus,
        this.orderItems,
        this.orderStatuses,
        this.subTotal,
        this.discount,
        this.total,
        this.createdAt,
        this.addressLine1,
        this.addressLine2,
        this.addressLine3,
        this.phoneNumber,
        this.city,
        this.state,
        this.country,
        this.zipCode,
    });

    Order copyWith({
        String? id,
        String? orderNumber,
        String? customerId,
        String? customerName,
        String? orderStatus,
        List<OrderItem>? orderItems,
        dynamic orderStatuses,
        double? subTotal,
        double? discount,
        double? total,
        DateTime? createdAt,
        dynamic addressLine1,
        dynamic addressLine2,
        dynamic addressLine3,
        dynamic phoneNumber,
        dynamic city,
        dynamic state,
        dynamic country,
        dynamic zipCode,
    }) => 
        Order(
            id: id ?? this.id,
            orderNumber: orderNumber ?? this.orderNumber,
            customerId: customerId ?? this.customerId,
            customerName: customerName ?? this.customerName,
            orderStatus: orderStatus ?? this.orderStatus,
            orderItems: orderItems ?? this.orderItems,
            orderStatuses: orderStatuses ?? this.orderStatuses,
            subTotal: subTotal ?? this.subTotal,
            discount: discount ?? this.discount,
            total: total ?? this.total,
            createdAt: createdAt ?? this.createdAt,
            addressLine1: addressLine1 ?? this.addressLine1,
            addressLine2: addressLine2 ?? this.addressLine2,
            addressLine3: addressLine3 ?? this.addressLine3,
            phoneNumber: phoneNumber ?? this.phoneNumber,
            city: city ?? this.city,
            state: state ?? this.state,
            country: country ?? this.country,
            zipCode: zipCode ?? this.zipCode,
        );

    factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        orderNumber: json["orderNumber"],
        customerId: json["customerId"],
        customerName: json["customerName"],
        orderStatus: json["orderStatus"],
        orderItems: json["orderItems"] == null ? [] : List<OrderItem>.from(json["orderItems"]!.map((x) => OrderItem.fromJson(x))),
        orderStatuses: json["orderStatuses"],
        subTotal: json["subTotal"]?.toDouble(),
        discount: json["discount"]?.toDouble(),
        total: json["total"]?.toDouble(),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        addressLine1: json["addressLine1"],
        addressLine2: json["addressLine2"],
        addressLine3: json["addressLine3"],
        phoneNumber: json["phoneNumber"],
        city: json["city"],
        state: json["state"],
        country: json["country"],
        zipCode: json["zipCode"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "orderNumber": orderNumber,
        "customerId": customerId,
        "customerName": customerName,
        "orderStatus": orderStatus,
        "orderItems": orderItems == null ? [] : List<dynamic>.from(orderItems!.map((x) => x.toJson())),
        "orderStatuses": orderStatuses,
        "subTotal": subTotal,
        "discount": discount,
        "total": total,
        "createdAt": createdAt?.toIso8601String(),
        "addressLine1": addressLine1,
        "addressLine2": addressLine2,
        "addressLine3": addressLine3,
        "phoneNumber": phoneNumber,
        "city": city,
        "state": state,
        "country": country,
        "zipCode": zipCode,
    };
}

class OrderItem {
    final String? id;
    final String? orderId;
    final String? productId;
    final String? productName;
    final String? productCategoryName;
    final String? productUnitMeasurementName;
    final String? productMainPhotoUrl;
    final String? productCompanyId;
    final dynamic description;
    final dynamic shippingRangeCalculationId;
    final int? qty;
    final double? price;
    final double? discount;
    final double? total;
    final double? subTotal;
    final String? companyName;

    OrderItem({
        this.id,
        this.orderId,
        this.productId,
        this.productName,
        this.productCategoryName,
        this.productUnitMeasurementName,
        this.productMainPhotoUrl,
        this.productCompanyId,
        this.description,
        this.shippingRangeCalculationId,
        this.qty,
        this.price,
        this.discount,
        this.total,
        this.subTotal,
        this.companyName,
    });

    OrderItem copyWith({
        String? id,
        String? orderId,
        String? productId,
        String? productName,
        String? productCategoryName,
        String? productUnitMeasurementName,
        String? productMainPhotoUrl,
        String? productCompanyId,
        dynamic description,
        dynamic shippingRangeCalculationId,
        int? qty,
        double? price,
        double? discount,
        double? total,
        double? subTotal,
        String? companyName,
    }) => 
        OrderItem(
            id: id ?? this.id,
            orderId: orderId ?? this.orderId,
            productId: productId ?? this.productId,
            productName: productName ?? this.productName,
            productCategoryName: productCategoryName ?? this.productCategoryName,
            productUnitMeasurementName: productUnitMeasurementName ?? this.productUnitMeasurementName,
            productMainPhotoUrl: productMainPhotoUrl ?? this.productMainPhotoUrl,
            productCompanyId: productCompanyId ?? this.productCompanyId,
            description: description ?? this.description,
            shippingRangeCalculationId: shippingRangeCalculationId ?? this.shippingRangeCalculationId,
            qty: qty ?? this.qty,
            price: price ?? this.price,
            discount: discount ?? this.discount,
            total: total ?? this.total,
            subTotal: subTotal ?? this.subTotal,
            companyName: companyName ?? this.companyName,
        );

    factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json["id"],
        orderId: json["orderId"],
        productId: json["productId"],
        productName: json["productName"],
        productCategoryName: json["productCategoryName"],
        productUnitMeasurementName: json["productUnitMeasurementName"],
        productMainPhotoUrl: json["productMainPhotoUrl"],
        productCompanyId: json["productCompanyId"],
        description: json["description"],
        shippingRangeCalculationId: json["shippingRangeCalculationId"],
        qty: json["qty"],
        price: json["price"]?.toDouble(),
        discount: json["discount"]?.toDouble(),
        total: json["total"]?.toDouble(),
        subTotal: json["subTotal"]?.toDouble(),
        companyName: json["companyName"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "orderId": orderId,
        "productId": productId,
        "productName": productName,
        "productCategoryName": productCategoryName,
        "productUnitMeasurementName": productUnitMeasurementName,
        "productMainPhotoUrl": productMainPhotoUrl,
        "productCompanyId": productCompanyId,
        "description": description,
        "shippingRangeCalculationId": shippingRangeCalculationId,
        "qty": qty,
        "price": price,
        "discount": discount,
        "total": total,
        "subTotal": subTotal,
        "companyName": companyName,
    };
}


class ShippingRangeCalculation {
    final int? quantity;
    final int? quantityProducts;
    final double? price;
    final ShippingRange? shippingRange;
    final String? shippingRangeId;

    ShippingRangeCalculation({
        this.quantity,
        this.quantityProducts,
        this.price,
        this.shippingRange,
        this.shippingRangeId,
    });

    ShippingRangeCalculation copyWith({
        int? quantity,
        int? quantityProducts,
        double? price,
        ShippingRange? shippingRange,
        String? shippingRangeId,
    }) => 
        ShippingRangeCalculation(
            quantity: quantity ?? this.quantity,
            quantityProducts: quantityProducts ?? this.quantityProducts,
            price: price ?? this.price,
            shippingRange: shippingRange ?? this.shippingRange,
            shippingRangeId: shippingRangeId ?? this.shippingRangeId,
        );

    factory ShippingRangeCalculation.fromJson(Map<String, dynamic> json) => ShippingRangeCalculation(
        quantity: json["quantity"],
        quantityProducts: json["quantityProducts"],
        price: json["price"],
        shippingRange: json["shippingRange"] == null ? null : ShippingRange.fromJson(json["shippingRange"]),
        shippingRangeId: json["shippingRangeId"],
    );
}

