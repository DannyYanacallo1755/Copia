import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/address.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddressService {
  final List<Address> _addresses = [];

  List<Address> get addresses => _addresses;

  Future<void> fetchAddresses(String userId, String token) async {
    try {
      var data = {
        "uuids": [
          {"fieldName": "user.id", "value": userId}
        ],
        "searchFields": [],
        "sortOrders": [],
        "page": 1,
        "pageSize": 50,
        "searchString": ""
      };

      final response = await http.post(
        Uri.parse(
            '${dotenv.env['ADMIN_API_URL']}/shipping-addresses/filtered-page'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final decodedResponse =
            json.decode(response.body) as Map<String, dynamic>;
        final content = decodedResponse['data']['content'] as List<dynamic>;
        _addresses.clear();
        _addresses.addAll(content.map((item) {
          return Address(
            id: item['id'],
            name: item['name'] ?? '',
            countryId: item['countryId'] ?? '',
            stateId: item['stateId'] ?? '',
            cityId: item['cityId'] ?? '',
            postalCode: item['zipCode'] ?? '',
            phoneNumber: item['phoneNumber'] ?? '',
            addressLine1: item['addressLine1'] ?? '',
            addressLine2: item['addressLine2'] ?? '',
            addressLine3: item['addressLine3'] ?? '',
            userId: item['userId'] ?? '',
          );
        }).toList());
      } else {
        throw Exception('Failed to fetch addresses');
      }
    } catch (e) {
      print('Error fetching addresses: $e');
      throw e;
    }
  }

  Future<String> addAddress(address, token) async {
    try {
      final response = await http.post(
          Uri.parse('${dotenv.env['ADMIN_API_URL']}/shipping-addresses'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(address));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return 'error';
      }
    } catch (e) {
      return 'Error fetching countries: $e';
    }
  }

  void updateAddress(int index, Address address) {
    _addresses[index] = address;
  }

  void deleteAddress(int index) {
    _addresses.removeAt(index);
  }
  
}
