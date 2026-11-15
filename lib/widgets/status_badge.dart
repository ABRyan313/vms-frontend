import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/vehicle_model.dart';

/// Semantic Material 3 status badge widget matching corporate design specifications.
/// High contrast, easy scanning in tables and cards.
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
        borderColor = AppColors.statusActiveBorder;
        break;
      case VehicleStatus.inMaintenance:
        textColor = AppColors.statusMaintenance;
        bgColor = AppColors.statusMaintenanceBg;
        borderColor = AppColors.statusMaintenanceBorder;
        break;
      case VehicleStatus.outOfService:
        textColor = AppColors.statusOutOfService;
        bgColor = AppColors.statusOutOfServiceBg;
        borderColor = AppColors.statusOutOfServiceBorder;
        break;
      case VehicleStatus.reserved:
        textColor = AppColors.statusReserved;
        bgColor = AppColors.statusReservedBg;
        borderColor = AppColors.statusReservedBorder;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 12,
        vertical: compact ? 4 : 5,
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
              fontWeight: FontWeight.w600,
              fontSize: compact ? 11 : 12,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
