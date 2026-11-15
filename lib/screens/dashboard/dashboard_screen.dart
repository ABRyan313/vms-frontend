import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../routes/app_routes.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/status_badge.dart';
import '../vehicles/vehicle_detail_dialog.dart';

/// Admin Dashboard Screen showing fleet health KPIs, quick actions,
/// and recent vehicle records.
class DashboardScreen extends StatelessWidget {
  final VoidCallback onNavigateToVehicles;

  const DashboardScreen({
    super.key,
    required this.onNavigateToVehicles,
  });

  @override
  Widget build(BuildContext context) {
    final vehicleRepo = VehicleRepository();

    return ListenableBuilder(
      listenable: vehicleRepo,
      builder: (context, _) {
        final total = vehicleRepo.totalCount;
        final active = vehicleRepo.activeCount;
        final maintenance = vehicleRepo.maintenanceCount;
        final outOfService = vehicleRepo.outOfServiceCount;
        final vehicles = vehicleRepo.vehicles.take(5).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header with Clear Title & Primary Action
              _buildHeader(context),
              const SizedBox(height: 24),

              // KPI Metric Cards Grid
              _buildKpiGrid(context, total, active, maintenance, outOfService),
              const SizedBox(height: 28),

              // Recent Fleet Overview Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fleet Activity Overview',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Most recently registered and updated fleet vehicles',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: onNavigateToVehicles,
                            icon: const Icon(Icons.arrow_forward, size: 16),
                            label: const Text('View All Vehicles'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // Responsive preview table
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 800),
                          child: DataTable(
                            headingRowHeight: 46,
                            dataRowMinHeight: 56,
                            dataRowMaxHeight: 60,
                            columns: const [
                              DataColumn(label: Text('VEHICLE NUMBER')),
                              DataColumn(label: Text('VEHICLE')),
                              DataColumn(label: Text('CATEGORY')),
                              DataColumn(label: Text('STATUS')),
                              DataColumn(label: Text('ODOMETER')),
                              DataColumn(label: Text('DRIVER')),
                              DataColumn(label: Text('ACTION')),
                            ],
                            rows: vehicles.map((v) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      v.plateNumber,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      v.displayName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(v.type.label)),
                                  DataCell(StatusBadge(status: v.status, compact: true)),
                                  DataCell(Text('${v.mileage.toString()} km')),
                                  DataCell(Text(v.assignedDriver ?? 'Unassigned')),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.visibility_outlined, size: 18),
                                      tooltip: 'View Details',
                                      color: AppColors.textSecondary,
                                      onPressed: () {
                                        VehicleDetailDialog.show(context, v);
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fleet Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Monitor fleet status, availability, and vehicle operational health.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.vehicleRegister);
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Register Vehicle'),
        ),
      ],
    );
  }

  Widget _buildKpiGrid(
    BuildContext context,
    int total,
    int active,
    int maintenance,
    int outOfService,
  ) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    final cards = [
      MetricCard(
        title: 'TOTAL FLEET',
        value: total.toString(),
        icon: Icons.directions_car,
        iconColor: AppColors.primary,
        iconBgColor: AppColors.primaryLight,
        subtitle: 'All registered units',
        onTap: onNavigateToVehicles,
      ),
      MetricCard(
        title: 'ACTIVE ON ROAD',
        value: active.toString(),
        icon: Icons.check_circle_outline,
        iconColor: AppColors.statusActive,
        iconBgColor: AppColors.statusActiveBg,
        subtitle: '$total units total',
        onTap: onNavigateToVehicles,
      ),
      MetricCard(
        title: 'IN MAINTENANCE',
        value: maintenance.toString(),
        icon: Icons.build_outlined,
        iconColor: AppColors.statusMaintenance,
        iconBgColor: AppColors.statusMaintenanceBg,
        subtitle: 'Scheduled service',
        onTap: onNavigateToVehicles,
      ),
      MetricCard(
        title: 'OUT OF SERVICE',
        value: outOfService.toString(),
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.statusOutOfService,
        iconBgColor: AppColors.statusOutOfServiceBg,
        subtitle: 'Requires attention',
        onTap: onNavigateToVehicles,
      ),
    ];

    if (isDesktop) {
      return Row(
        children: cards
            .map((c) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: c,
                  ),
                ))
            .toList(),
      );
    } else if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 12),
              Expanded(child: cards[3]),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: cards
            .map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: c,
                ))
            .toList(),
      );
    }
  }
}
