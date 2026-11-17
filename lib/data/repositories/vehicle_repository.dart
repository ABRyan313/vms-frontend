import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../models/vehicle_model.dart';
import '../services/api_client.dart';

class VehicleRepository extends ChangeNotifier {
  static final VehicleRepository _instance = VehicleRepository._internal();

  factory VehicleRepository() => _instance;

  VehicleRepository._internal();

  List<Vehicle> _vehicles = [];

  int _totalElements = 0;
  int _totalPages = 0;
  int _pageSize = 10;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);
  int get totalElements => _totalElements;
  int get totalPages => _totalPages;

  int get totalCount => _vehicles.length;

  int get activeCount =>
      _vehicles.where((v) => v.status == VehicleStatus.active).length;

  int get maintenanceCount =>
      _vehicles.where((v) => v.status == VehicleStatus.inMaintenance).length;

  int get outOfServiceCount =>
      _vehicles.where((v) => v.status == VehicleStatus.outOfService).length;

  int get reservedCount =>
      _vehicles.where((v) => v.status == VehicleStatus.reserved).length;

  Future<void> fetchVehicles({
    int page = 0,
    int size = 10,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.get(
        '/vehicles',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final content = data['content'] as List<dynamic>;

      _vehicles = content
          .map(
            (item) => Vehicle.fromApiJson(item as Map<String, dynamic>),
          )
          .toList();

      _totalElements = (data['totalElements'] as num).toInt();
      _totalPages = (data['totalPages'] as num).toInt();
      _pageSize = size;
    } on DioException catch (e) {
      _error = e.response?.data?.toString() ?? e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Vehicle? findById(String id) {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    await ApiClient.dio.post(
      '/vehicles',
      data: {
        'vehicleNumber': vehicle.plateNumber,
        'brand': vehicle.make,
        'model': vehicle.model,
      },
    );

    // A newly registered vehicle should appear on the first page.
    await fetchVehicles(page: 0, size: _pageSize);
  }

  Future<void> updateVehicle(Vehicle updated) async {
    await ApiClient.dio.put(
      '/vehicles/${updated.id}',
      data: {
        'vehicleNumber': updated.plateNumber,
        'brand': updated.make,
        'model': updated.model,
      },
    );

    // Update the local item after the backend confirms the PUT request.
    // Status and other extra fields remain UI-only because the backend
    // currently stores only vehicleNumber, brand, and model.
    final index = _vehicles.indexWhere((v) => v.id == updated.id);
    if (index != -1) {
      _vehicles[index] = updated;
      notifyListeners();
    }
  }

 Future<void> deleteVehicle(String id) async {
  // Delete from the backend first.
  await ApiClient.dio.delete('/vehicles/$id');

  // Update the local list only after successful backend deletion.
  final previousLength = _vehicles.length;
  _vehicles.removeWhere((vehicle) => vehicle.id == id);

  if (_vehicles.length != previousLength) {
    if (_totalElements > 0) {
      _totalElements--;
    }

    _totalPages = _totalElements == 0
        ? 0
        : (_totalElements / _pageSize).ceil();

    notifyListeners();
  }
}

  List<Vehicle> filter({
    String query = '',
    VehicleStatus? statusFilter,
    VehicleType? typeFilter,
  }) {
    final cleanQuery = query.trim().toLowerCase();

    return _vehicles.where((v) {
      final matchesQuery = cleanQuery.isEmpty ||
          v.plateNumber.toLowerCase().contains(cleanQuery) ||
          v.make.toLowerCase().contains(cleanQuery) ||
          v.model.toLowerCase().contains(cleanQuery) ||
          v.vin.toLowerCase().contains(cleanQuery) ||
          (v.assignedDriver?.toLowerCase().contains(cleanQuery) ?? false) ||
          (v.location?.toLowerCase().contains(cleanQuery) ?? false);

      final matchesStatus =
          statusFilter == null || v.status == statusFilter;

      final matchesType = typeFilter == null || v.type == typeFilter;

      return matchesQuery && matchesStatus && matchesType;
    }).toList();
  }
}