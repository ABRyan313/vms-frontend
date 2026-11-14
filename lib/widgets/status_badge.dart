import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/vehicle_model.dart';

/// Semantic Material 3 status badge widget matching Stark Group specifications.
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

    switch (status) {
      case VehicleStatus.active:
        textColor = AppColors.statusActive;
        bgColor = AppColors.statusActiveBg;
        break;
      case VehicleStatus.inMaintenance:
        textColor = AppColors.statusMaintenance;
        bgColor = AppColors.statusMaintenanceBg;
        break;
      case VehicleStatus.outOfService:
        textColor = AppColors.statusOutOfService;
        bgColor = AppColors.statusOutOfServiceBg;
        break;
      case VehicleStatus.reserved:
        textColor = AppColors.statusReserved;
        bgColor = AppColors.statusReservedBg;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
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
              fontWeight: FontWeight.w600,
              fontSize: compact ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
