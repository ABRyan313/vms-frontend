import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/vehicle_model.dart';
import '../../widgets/status_badge.dart';

/// Clean detail modal presenting full technical specifications of a vehicle.
/// Consistent corporate blue styling and clean typography.
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.directions_car, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.displayName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Vehicle Plate: ${vehicle.plateNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatusBadge(status: vehicle.status),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Specifications list
              _buildSpecRow('Vehicle Number', vehicle.plateNumber),
              _buildSpecRow('VIN Number', vehicle.vin),
              _buildSpecRow('Brand / Manufacturer', vehicle.make),
              _buildSpecRow('Model Variant', vehicle.model),
              _buildSpecRow('Category', vehicle.type.label),
              _buildSpecRow('Fuel / Powertrain', vehicle.fuelType.label),
              _buildSpecRow('Odometer Reading', '${vehicle.mileage.toString()} km'),
              _buildSpecRow('Assigned Driver', vehicle.assignedDriver ?? 'Unassigned'),
              _buildSpecRow('Current Location', vehicle.location ?? 'Central Depot'),
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
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          SelectableText(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
