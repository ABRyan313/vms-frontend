import 'package:flutter/foundation.dart';
import '../../models/vehicle_model.dart';
import '../mock/mock_vehicles.dart';

/// In-memory reactive repository managing Fleet Vehicle data.
/// Uses ChangeNotifier so UI components automatically update when records change.
class VehicleRepository extends ChangeNotifier {
  static final VehicleRepository _instance = VehicleRepository._internal();
  factory VehicleRepository() => _instance;
  VehicleRepository._internal() {
    _vehicles = List<Vehicle>.from(initialMockVehicles);
  }

  late List<Vehicle> _vehicles;

  /// Returns an unmodifiable list of all vehicles.
  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);

  // Fleet Statistics
  int get totalCount => _vehicles.length;

  int get activeCount =>
      _vehicles.where((v) => v.status == VehicleStatus.active).length;

  int get maintenanceCount =>
      _vehicles.where((v) => v.status == VehicleStatus.inMaintenance).length;

  int get outOfServiceCount =>
      _vehicles.where((v) => v.status == VehicleStatus.outOfService).length;

  int get reservedCount =>
      _vehicles.where((v) => v.status == VehicleStatus.reserved).length;

  /// Find a vehicle by ID
  Vehicle? findById(String id) {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Add a new vehicle to the fleet
  void addVehicle(Vehicle vehicle) {
    _vehicles.insert(0, vehicle);
    notifyListeners();
  }

  /// Update an existing vehicle's data
  bool updateVehicle(Vehicle updated) {
    final index = _vehicles.indexWhere((v) => v.id == updated.id);
    if (index != -1) {
      _vehicles[index] = updated;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Remove a vehicle from the fleet
  bool deleteVehicle(String id) {
    final index = _vehicles.indexWhere((v) => v.id == id);
    if (index != -1) {
      _vehicles.removeAt(index);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Search and filter vehicles by text query, status, or type
  List<Vehicle> filter({
    String query = '',
    VehicleStatus? statusFilter,
    VehicleType? typeFilter,
  }) {
    final cleanQuery = query.trim().toLowerCase();

    return _vehicles.where((v) {
      // 1. Text search across plate, make, model, VIN, driver, location
      final matchesQuery = cleanQuery.isEmpty ||
          v.plateNumber.toLowerCase().contains(cleanQuery) ||
          v.make.toLowerCase().contains(cleanQuery) ||
          v.model.toLowerCase().contains(cleanQuery) ||
          v.vin.toLowerCase().contains(cleanQuery) ||
          (v.assignedDriver?.toLowerCase().contains(cleanQuery) ?? false) ||
          (v.location?.toLowerCase().contains(cleanQuery) ?? false);

      // 2. Status filter
      final matchesStatus = statusFilter == null || v.status == statusFilter;

      // 3. Type filter
      final matchesType = typeFilter == null || v.type == typeFilter;

      return matchesQuery && matchesStatus && matchesType;
    }).toList();
  }
}
