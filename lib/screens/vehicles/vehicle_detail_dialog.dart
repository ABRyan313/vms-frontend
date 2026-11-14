import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/vehicle_model.dart';
import '../../widgets/status_badge.dart';

/// Clean detail modal presenting full technical specifications of a vehicle.
class VehicleDetailDialog extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailDialog({
    super.key,
    required this.vehicle,
  });

  static Future<void> show(BuildContext context, Vehicle vehicle) {
    return showDialog(
      context: context,
      builder: (ctx) => VehicleDetailDialog(vehicle: vehicle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      actionsPadding: const EdgeInsets.all(20),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_car, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.displayName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Plate: ${vehicle.plateNumber}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
          StatusBadge(status: vehicle.status),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              const SizedBox(height: 16),

              // Grid of specifications
              _buildSpecRow('VIN Number', vehicle.vin),
              _buildSpecRow('Category / Type', vehicle.type.label),
              _buildSpecRow('Fuel / Powertrain', vehicle.fuelType.label),
              _buildSpecRow('Current Odometer', '${vehicle.mileage.toString()} km'),
              _buildSpecRow('Assigned Driver', vehicle.assignedDriver ?? 'Unassigned'),
              _buildSpecRow('Current Location', vehicle.location ?? 'Depot Main Yard'),
              _buildSpecRow(
                'Last Service Date',
                vehicle.lastServiceDate != null
                    ? '${vehicle.lastServiceDate!.year}-${vehicle.lastServiceDate!.month.toString().padLeft(2, '0')}-${vehicle.lastServiceDate!.day.toString().padLeft(2, '0')}'
                    : 'No records recorded',
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          SelectableText(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
