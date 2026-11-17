/// Operational status of a fleet vehicle.
enum VehicleStatus {
  active,
  inMaintenance,
  outOfService,
  reserved;

  String get label {
    switch (this) {
      case VehicleStatus.active:
        return 'Active';
      case VehicleStatus.inMaintenance:
        return 'In Maintenance';
      case VehicleStatus.outOfService:
        return 'Out of Service';
      case VehicleStatus.reserved:
        return 'Reserved';
    }
  }

  static VehicleStatus fromString(String val) {
    return VehicleStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase() ||
             e.label.toLowerCase() == val.toLowerCase(),
      orElse: () => VehicleStatus.active,
    );
  }
}

/// Category/Type of vehicle.
enum VehicleType {
  sedan,
  suv,
  truck,
  van,
  electric;

  String get label {
    switch (this) {
      case VehicleType.sedan:
        return 'Sedan';
      case VehicleType.suv:
        return 'SUV';
      case VehicleType.truck:
        return 'Truck';
      case VehicleType.van:
        return 'Van / Cargo';
      case VehicleType.electric:
        return 'Electric EV';
    }
  }

  static VehicleType fromString(String val) {
    return VehicleType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase() ||
             e.label.toLowerCase() == val.toLowerCase(),
      orElse: () => VehicleType.sedan,
    );
  }
}

/// Energy/fuel source.
enum FuelType {
  petrol,
  diesel,
  electric,
  hybrid;

  String get label {
    switch (this) {
      case FuelType.petrol:
        return 'Petrol';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.electric:
        return 'Electric';
      case FuelType.hybrid:
        return 'Hybrid';
    }
  }

  static FuelType fromString(String val) {
    return FuelType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase() ||
             e.label.toLowerCase() == val.toLowerCase(),
      orElse: () => FuelType.petrol,
    );
  }
}

/// Core domain entity for a Fleet Vehicle.
class Vehicle {
  final String id;
  final String vin;
  final String plateNumber;
  final String make;
  final String model;
  final int year;
  final VehicleType type;
  final VehicleStatus status;
  final FuelType fuelType;
  final int mileage;
  final String? assignedDriver;
  final String? location;
  final DateTime? lastServiceDate;

  const Vehicle({
    required this.id,
    required this.vin,
    required this.plateNumber,
    required this.make,
    required this.model,
    required this.year,
    required this.type,
    required this.status,
    required this.fuelType,
    required this.mileage,
    this.assignedDriver,
    this.location,
    this.lastServiceDate,
  });

  /// Convenient display title combining Make, Model & Year
  String get displayName => '$year $make $model';

  /// Aliases for flexibility across domain naming conventions
  String get vehicleNumber => plateNumber;
  String get brand => make;
  String get company => location ?? 'Stark Group Fleet';

  Vehicle copyWith({
    String? id,
    String? vin,
    String? plateNumber,
    String? make,
    String? model,
    int? year,
    VehicleType? type,
    VehicleStatus? status,
    FuelType? fuelType,
    int? mileage,
    String? assignedDriver,
    String? location,
    DateTime? lastServiceDate,
  }) {
    return Vehicle(
      id: id ?? this.id,
      vin: vin ?? this.vin,
      plateNumber: plateNumber ?? this.plateNumber,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      type: type ?? this.type,
      status: status ?? this.status,
      fuelType: fuelType ?? this.fuelType,
      mileage: mileage ?? this.mileage,
      assignedDriver: assignedDriver ?? this.assignedDriver,
      location: location ?? this.location,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
    );
  }

  /// Serialization for API and state persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vin': vin,
      'plateNumber': plateNumber,
      'make': make,
      'model': model,
      'year': year,
      'type': type.name,
      'status': status.name,
      'fuelType': fuelType.name,
      'mileage': mileage,
      'assignedDriver': assignedDriver,
      'location': location,
      'lastServiceDate': lastServiceDate?.toIso8601String(),
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      vin: json['vin'] as String,
      plateNumber: json['plateNumber'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      year: (json['year'] as num).toInt(),
      type: VehicleType.fromString(json['type'] as String? ?? 'sedan'),
      status: VehicleStatus.fromString(json['status'] as String? ?? 'active'),
      fuelType: FuelType.fromString(json['fuelType'] as String? ?? 'petrol'),
      mileage: (json['mileage'] as num).toInt(),
      assignedDriver: json['assignedDriver'] as String?,
      location: json['location'] as String?,
      lastServiceDate: json['lastServiceDate'] != null
          ? DateTime.tryParse(json['lastServiceDate'] as String)
          : null,
    );
  }

  factory Vehicle.fromApiJson(Map<String, dynamic> json) {
  return Vehicle(
    id: json['id'].toString(),
    vin: '',
    plateNumber: json['vehicleNumber'] as String,
    make: json['brand'] as String,
    model: json['model'] as String,
    year: DateTime.now().year,
    type: VehicleType.sedan,
    status: VehicleStatus.active,
    fuelType: FuelType.petrol,
    mileage: 0,
  );
}
}
