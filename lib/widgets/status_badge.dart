import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/vehicle_model.dart';

/// Semantic Material 3 status badge widget matching Stark Group specifications.
/// High-contrast, easily scannable in fleet data tables.
class StatusBadge extends StatelessWidget {
  final VehicleStatus status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color bgColor;
    Color borderColor;

    switch (status) {
      case VehicleStatus.active:
        textColor = AppColors.statusActive;
        bgColor = AppColors.statusActiveBg;
        borderColor = const Color(0xFF86EFAC); // Soft emerald green border
        break;
      case VehicleStatus.inMaintenance:
        textColor = AppColors.statusMaintenance;
        bgColor = AppColors.statusMaintenanceBg;
        borderColor = const Color(0xFFFDE68A); // Soft amber border
        break;
      case VehicleStatus.outOfService:
        textColor = AppColors.statusOutOfService;
        bgColor = AppColors.statusOutOfServiceBg;
        borderColor = const Color(0xFFFECACA); // Soft red border
        break;
      case VehicleStatus.reserved:
        textColor = AppColors.statusReserved;
        bgColor = AppColors.statusReservedBg;
        borderColor = const Color(0xFFDDD6FE); // Soft purple border
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 11 : 12,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
