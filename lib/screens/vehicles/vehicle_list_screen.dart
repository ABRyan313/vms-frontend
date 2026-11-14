import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../models/vehicle_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/status_badge.dart';
import 'vehicle_detail_dialog.dart';
import 'vehicle_form_screen.dart';

/// Full-featured, desktop-first Vehicle Management List Screen.
/// Optimized for rapid scanning, with highlighted Vehicle Number plates,
/// prominent Status badges, explicit Edit/Delete actions, and polished empty states.
class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final TextEditingController _searchController = TextEditingController();
  VehicleStatus? _statusFilter;
  VehicleType? _typeFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _statusFilter = null;
      _typeFilter = null;
    });
  }

  void _handleEdit(Vehicle vehicle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VehicleFormScreen(
          vehicleToEdit: vehicle,
        ),
      ),
    );
  }

  Future<void> _handleDelete(Vehicle vehicle) async {
    final confirm = await ConfirmDialog.show(
      context,
      title: 'Delete Vehicle',
      message:
          'Are you sure you want to remove "${vehicle.displayName}" (${vehicle.plateNumber}) from the fleet? This action cannot be undone.',
      confirmLabel: 'Delete Vehicle',
      isDestructive: true,
    );

    if (confirm == true && mounted) {
      VehicleRepository().deleteVehicle(vehicle.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text('Vehicle "${vehicle.displayName}" (${vehicle.plateNumber}) removed.'),
            ],
          ),
          backgroundColor: AppColors.statusOutOfService,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  IconData _getTypeIcon(VehicleType type) {
    switch (type) {
      case VehicleType.truck:
        return Icons.local_shipping_outlined;
      case VehicleType.van:
        return Icons.airport_shuttle_outlined;
      case VehicleType.electric:
        return Icons.electric_car_outlined;
      case VehicleType.suv:
        return Icons.directions_car_filled_outlined;
      case VehicleType.sedan:
        return Icons.directions_car_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleRepo = VehicleRepository();
    final isDesktop = Responsive.isDesktop(context);

    return ListenableBuilder(
      listenable: vehicleRepo,
      builder: (context, _) {
        final filteredVehicles = vehicleRepo.filter(
          query: _searchController.text,
          statusFilter: _statusFilter,
          typeFilter: _typeFilter,
        );

        final hasActiveFilters = _searchController.text.isNotEmpty ||
            _statusFilter != null ||
            _typeFilter != null;

        // Build active filter tags for the empty state
        final activeFilterTags = <String>[];
        if (_searchController.text.trim().isNotEmpty) {
          activeFilterTags.add('Search: "${_searchController.text.trim()}"');
        }
        if (_statusFilter != null) {
          activeFilterTags.add('Status: ${_statusFilter!.label}');
        }
        if (_typeFilter != null) {
          activeFilterTags.add('Category: ${_typeFilter!.label}');
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header
              _buildHeader(context, vehicleRepo.totalCount),
              const SizedBox(height: 20),

              // Quick Status Filter Pills (one-click filter tabs)
              _buildStatusTabs(vehicleRepo),
              const SizedBox(height: 16),

              // Filter & Search Toolbar
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (isDesktop)
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: SearchBarWidget(
                                controller: _searchController,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: _buildTypeFilterDropdown(),
                            ),
                            if (hasActiveFilters) ...[
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: _clearFilters,
                                icon: const Icon(Icons.clear_all, size: 16),
                                label: const Text('Reset'),
                              ),
                            ],
                          ],
                        )
                      else ...[
                        SearchBarWidget(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        _buildTypeFilterDropdown(),
                        if (hasActiveFilters) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _clearFilters,
                              icon: const Icon(Icons.clear_all, size: 16),
                              label: const Text('Reset Filters'),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Vehicles Data Card / Table / List
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Summary sub-header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Showing ${filteredVehicles.length} of ${vehicleRepo.totalCount} Vehicles',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.starkDark,
                                ),
                              ),
                              if (hasActiveFilters) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Filtered',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Content: Empty State vs Data Table
                    if (filteredVehicles.isEmpty)
                      EmptyStateWidget(
                        icon: hasActiveFilters
                            ? Icons.search_off_outlined
                            : Icons.directions_car_outlined,
                        title: hasActiveFilters
                            ? 'No Matching Vehicles Found'
                            : 'No Vehicles in Fleet',
                        description: hasActiveFilters
                            ? 'No vehicles match your search keywords or filter criteria. Try resetting the filters to view the full fleet.'
                            : 'Your fleet inventory is currently empty. Register your first vehicle to get started.',
                        activeFilters: hasActiveFilters ? activeFilterTags : null,
                        actionLabel: hasActiveFilters ? 'Reset Filters' : 'Register Vehicle',
                        onAction: hasActiveFilters
                            ? _clearFilters
                            : () => Navigator.of(context).pushNamed(AppRoutes.vehicleRegister),
                        secondaryActionLabel: hasActiveFilters ? 'Register New Vehicle' : null,
                        onSecondaryAction: hasActiveFilters
                            ? () => Navigator.of(context).pushNamed(AppRoutes.vehicleRegister)
                            : null,
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 1080),
                          child: DataTable(
                            headingRowHeight: 46,
                            dataRowMinHeight: 64,
                            dataRowMaxHeight: 68,
                            columns: const [
                              DataColumn(label: Text('VEHICLE NUMBER')),
                              DataColumn(label: Text('STATUS')),
                              DataColumn(label: Text('MAKE & MODEL')),
                              DataColumn(label: Text('CATEGORY / FUEL')),
                              DataColumn(label: Text('ODOMETER')),
                              DataColumn(label: Text('ASSIGNED DRIVER')),
                              DataColumn(label: Text('ACTIONS')),
                            ],
                            rows: filteredVehicles.map((vehicle) {
                              return DataRow(
                                cells: [
                                  // 1. Highlighted Vehicle Number plate
                                  DataCell(
                                    InkWell(
                                      onTap: () => VehicleDetailDialog.show(context, vehicle),
                                      borderRadius: BorderRadius.circular(6),
                                      child: _buildVehicleNumberBadge(vehicle.plateNumber, vehicle.vin),
                                    ),
                                  ),

                                  // 2. Highlighted Status Badge
                                  DataCell(
                                    StatusBadge(status: vehicle.status),
                                  ),

                                  // 3. Make & Model
                                  DataCell(
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          vehicle.displayName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.starkDark,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          vehicle.location ?? 'Stark Fleet Terminal',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 4. Category & Fuel with visual icon
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Icon(
                                            _getTypeIcon(vehicle.type),
                                            size: 16,
                                            color: AppColors.starkSteel,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              vehicle.type.label,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.starkDark,
                                              ),
                                            ),
                                            Text(
                                              vehicle.fuelType.label,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 5. Odometer
                                  DataCell(
                                    Text(
                                      '${vehicle.mileage.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} km',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.starkDark,
                                      ),
                                    ),
                                  ),

                                  // 6. Driver
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.person_outline,
                                          size: 16,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          vehicle.assignedDriver ?? 'Unassigned',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: vehicle.assignedDriver != null
                                                ? FontWeight.w500
                                                : FontWeight.normal,
                                            color: vehicle.assignedDriver != null
                                                ? AppColors.starkDark
                                                : AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 7. Clear Edit and Delete Actions
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Quick View Details
                                        IconButton(
                                          icon: const Icon(Icons.visibility_outlined, size: 18),
                                          tooltip: 'View Details',
                                          color: AppColors.textSecondary,
                                          onPressed: () {
                                            VehicleDetailDialog.show(context, vehicle);
                                          },
                                        ),
                                        const SizedBox(width: 4),

                                        // Explicit Edit Action Button
                                        OutlinedButton.icon(
                                          icon: const Icon(Icons.edit_outlined, size: 14),
                                          label: const Text('Edit'),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            visualDensity: VisualDensity.compact,
                                            side: const BorderSide(color: AppColors.borderMedium),
                                            foregroundColor: AppColors.starkDark,
                                          ),
                                          onPressed: () => _handleEdit(vehicle),
                                        ),
                                        const SizedBox(width: 8),

                                        // Explicit Delete Action Button
                                        OutlinedButton.icon(
                                          icon: const Icon(Icons.delete_outline, size: 14),
                                          label: const Text('Delete'),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            visualDensity: VisualDensity.compact,
                                            side: BorderSide(
                                              color: AppColors.statusOutOfService
                                                  .withValues(alpha: 0.35),
                                            ),
                                            foregroundColor: AppColors.statusOutOfService,
                                            backgroundColor: AppColors.statusOutOfServiceBg
                                                .withValues(alpha: 0.4),
                                          ),
                                          onPressed: () => _handleDelete(vehicle),
                                        ),
                                      ],
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
            ],
          ),
        );
      },
    );
  }

  /// Highlighted Vehicle Number tag with Stark safety orange accent and VIN preview
  Widget _buildVehicleNumberBadge(String plateNumber, String vin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderMedium, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                plateNumber,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.6,
                  color: AppColors.starkDark,
                ),
              ),
              Text(
                'VIN: ${vin.length > 8 ? vin.substring(0, 8) : vin}...',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Screen Header with fleet title and Register Vehicle primary CTA
  Widget _buildHeader(BuildContext context, int totalCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'Vehicle Fleet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.starkDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$totalCount total',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
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

  /// Status quick-filter segmented pills for one-click filtering
  Widget _buildStatusTabs(VehicleRepository repo) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: 'All Vehicles',
            count: repo.totalCount,
            isSelected: _statusFilter == null,
            onTap: () => setState(() => _statusFilter = null),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Active',
            count: repo.activeCount,
            isSelected: _statusFilter == VehicleStatus.active,
            activeColor: AppColors.statusActive,
            onTap: () => setState(() => _statusFilter = VehicleStatus.active),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'In Maintenance',
            count: repo.maintenanceCount,
            isSelected: _statusFilter == VehicleStatus.inMaintenance,
            activeColor: AppColors.statusMaintenance,
            onTap: () => setState(() => _statusFilter = VehicleStatus.inMaintenance),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Out of Service',
            count: repo.outOfServiceCount,
            isSelected: _statusFilter == VehicleStatus.outOfService,
            activeColor: AppColors.statusOutOfService,
            onTap: () => setState(() => _statusFilter = VehicleStatus.outOfService),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Reserved',
            count: repo.reservedCount,
            isSelected: _statusFilter == VehicleStatus.reserved,
            activeColor: AppColors.statusReserved,
            onTap: () => setState(() => _statusFilter = VehicleStatus.reserved),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    Color? activeColor,
    required VoidCallback onTap,
  }) {
    final effectiveColor = activeColor ?? AppColors.primary;

    return Material(
      color: isSelected
          ? effectiveColor.withValues(alpha: 0.12)
          : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? effectiveColor : AppColors.borderLight,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? effectiveColor : AppColors.starkSteel,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? effectiveColor
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilterDropdown() {
    return SizedBox(
      height: 44,
      child: DropdownButtonFormField<VehicleType?>(
        initialValue: _typeFilter,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
          hintText: 'Filter by Category',
        ),
        items: [
          const DropdownMenuItem(
            value: null,
            child: Text('All Categories', style: TextStyle(fontSize: 13)),
          ),
          ...VehicleType.values.map(
            (t) => DropdownMenuItem(
              value: t,
              child: Text(t.label, style: const TextStyle(fontSize: 13)),
            ),
          ),
        ],
        onChanged: (val) {
          setState(() {
            _typeFilter = val;
          });
        },
      ),
    );
  }
}
