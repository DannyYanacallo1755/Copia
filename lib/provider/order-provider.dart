import 'package:flutter/material.dart';

class OrderProvider with ChangeNotifier {
  List<String> _adressList = [];

  List<String> get dataList => _adressList;

  void addData(dynamic newData) {
    _adressList.add(newData);
    notifyListeners();
  }

  void removeData(String dataToRemove) {
    _adressList.remove(dataToRemove);
    notifyListeners();
  }

  void setDataList(List<String> newList) {
    _adressList = newList;
    notifyListeners();
  }
}
