import 'dart:convert';

import '../../ui/pages/pages.dart';

class CalculateShippingRangeresponse extends Equatable {
  final bool? success;
  final String? message;
  final List<ShippingPackage>? data;

  const CalculateShippingRangeresponse({
    this.success,
    this.message,
    this.data,
  });

  CalculateShippingRangeresponse copyWith({
    bool? success,
    String? message,
    List<ShippingPackage>? data,
  }) =>
      CalculateShippingRangeresponse(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory CalculateShippingRangeresponse.fromJson(Map<String, dynamic> json) {
    final dataList = json["data"] == null
        ? <ShippingPackage>[]
        : (json["data"] as List)
            .map((x) => ShippingPackage.fromJson(x as Map<String, dynamic>))
            .toList();
    _saveDataToSharedPreferences(dataList);

    return CalculateShippingRangeresponse(
      success: json["success"],
      message: json["message"],
      data: json["data"] == null
          ? []
          : List<ShippingPackage>.from(
              json["data"]!.map((x) => ShippingPackage.fromJson(x))),
    );
  }

  static Future<void> _saveDataToSharedPreferences(
      List<ShippingPackage> data) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(data.map((e) => e.toJson()).toList());
    await prefs.setString('shippingRangeCalculation', encodedData);
  }

  @override
  List<Object?> get props => [
        success,
        message,
        data,
      ];
}

class ShippingPackage extends Equatable {
  final String? id;
  final double? cost;
  final String? trackingNumber;
  final String? packageStatus;
  final int? quantity;
  final double? weight;
  final double? subTotal;
  final double? discount;
  final double? total;
  final List<PackageDetail>? packageDetails;
  final String? companyId;
  final String? companyName;

  const ShippingPackage({
    this.id,
    this.cost,
    this.trackingNumber,
    this.packageStatus,
    this.quantity,
    this.weight,
    this.subTotal,
    this.discount,
    this.total,
    this.packageDetails,
    this.companyId,
    this.companyName,
  });

  ShippingPackage copyWith({
    String? id,
    double? cost,
    String? trackingNumber,
    String? packageStatus,
    int? quantity,
    double? weight,
    double? subTotal,
    double? discount,
    double? total,
    List<PackageDetail>? packageDetails,
    String? companyId,
    String? companyName,
  }) =>
      ShippingPackage(
        id: id ?? this.id,
        cost: cost ?? this.cost,
        trackingNumber: trackingNumber ?? this.trackingNumber,
        packageStatus: packageStatus ?? this.packageStatus,
        quantity: quantity ?? this.quantity,
        weight: weight ?? this.weight,
        subTotal: subTotal ?? this.subTotal,
        discount: discount ?? this.discount,
        total: total ?? this.total,
        packageDetails: packageDetails ?? this.packageDetails,
        companyId: companyId ?? this.companyId,
        companyName: companyName ?? this.companyName,
      );
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "cost": cost,
      "quantity": quantity,
      "weight": weight,
      "subTotal": subTotal,
      "discount": discount,
      "total": total,
    };
  }

  factory ShippingPackage.fromJson(Map<String, dynamic> json) =>
      ShippingPackage(
        id: json["id"],
        cost: json["cost"] != null ? (json["cost"] as num).toDouble() : null,
        trackingNumber: json["trackingNumber"],
        packageStatus: json["packageStatus"],
        quantity: json["quantity"],
        weight: json["weight"],
        subTotal: json["subTotal"],
        discount: json["discount"] != null
            ? (json["discount"] as num).toDouble()
            : null,
        total: json["total"],
        packageDetails: json["packageDetails"] == null
            ? []
            : List<PackageDetail>.from(
                json["packageDetails"].map((x) => PackageDetail.fromJson(x))),
        companyId: json["companyId"],
        companyName: json["companyName"],
      );

  @override
  List<Object?> get props => [
        id,
        cost,
        trackingNumber,
        packageStatus,
        quantity,
        weight,
        subTotal,
        discount,
        total,
        packageDetails,
        companyId,
        companyName,
      ];
}

class PackageDetail extends Equatable {
  final String? id;
  final String? orderItemId;
  final String? orderPackageId;
  final String? orderItemProductId;
  final String? orderItemProductName;
  final int? quantity;
  final double? price;
  final double? total;

  const PackageDetail({
    this.id,
    this.orderItemId,
    this.orderPackageId,
    this.orderItemProductId,
    this.orderItemProductName,
    this.quantity,
    this.price,
    this.total,
  });

  PackageDetail copyWith({
    String? id,
    String? orderItemId,
    String? orderPackageId,
    String? orderItemProductId,
    String? orderItemProductName,
    int? quantity,
    double? price,
    double? total,
  }) =>
      PackageDetail(
        id: id ?? this.id,
        orderItemId: orderItemId ?? this.orderItemId,
        orderPackageId: orderPackageId ?? this.orderPackageId,
        orderItemProductId: orderItemProductId ?? this.orderItemProductId,
        orderItemProductName: orderItemProductName ?? this.orderItemProductName,
        quantity: quantity ?? this.quantity,
        price: price ?? this.price,
        total: total ?? this.total,
      );

  factory PackageDetail.fromJson(Map<String, dynamic> json) => PackageDetail(
        id: json["id"],
        orderItemId: json["orderItemId"],
        orderPackageId: json["orderPackageId"],
        orderItemProductId: json["orderItemProductId"],
        orderItemProductName: json["orderItemProductName"],
        quantity: json["quantity"],
        price: json["price"],
        total: json["total"],
      );

  @override
  List<Object?> get props => [
        id,
        orderItemId,
        orderPackageId,
        orderItemProductId,
        orderItemProductName,
        quantity,
        price,
        total,
      ];
}
