import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';

class AddressProvider with ChangeNotifier {
  final AddressService _addressService = AddressService();

  List<AddressModel> _addresses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AddressModel? get defaultAddress {
    try {
      return _addresses.firstWhere((address) => address.isDefault);
    } catch (e) {
      return null;
    }
  }

  void listenToAddresses() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _addressService.watchAddresses().listen(
      (addresses) {
        _addresses = addresses;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Failed to load addresses';
        notifyListeners();
      },
    );
  }

  Future<void> addAddress(AddressModel address) async {
    try {
      await _addressService.addAddress(address);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to add address';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateAddress(AddressModel address) async {
    try {
      await _addressService.updateAddress(address);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to update address';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      await _addressService.deleteAddress(addressId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to delete address';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    try {
      await _addressService.setDefaultAddress(addressId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to set default address';
      notifyListeners();
      rethrow;
    }
  }
}
