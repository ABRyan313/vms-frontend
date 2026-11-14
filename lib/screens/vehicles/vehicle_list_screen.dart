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
/// Includes live search, multi-attribute filtering, and CRUD operations.
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

  Future<void> _handleDelete(Vehicle vehicle) async {
    final confirm = await ConfirmDialog.show(
      context,
      title: 'Delete Vehicle',
      message: 'Are you sure you want to remove "${vehicle.displayName}" (${vehicle.plateNumber}) from the fleet? This action cannot be undone.',
      confirmLabel: 'Delete Record',
      isDestructive: true,
    );

    if (confirm == true && mounted) {
      VehicleRepository().deleteVehicle(vehicle.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vehicle "${vehicle.displayName}" removed.'),
          backgroundColor: AppColors.statusOutOfService,
        ),
      );
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header
              _buildHeader(context, vehicleRepo.totalCount),
              const SizedBox(height: 20),

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
                              child: _buildStatusFilterDropdown(),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: _buildTypeFilterDropdown(),
                            ),
                            if (hasActiveFilters) ...[
                              const SizedBox(width: 12),
                              TextButton.icon(
                                onPressed: _clearFilters,
                                icon: const Icon(Icons.clear_all, size: 18),
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
                        Row(
                          children: [
                            Expanded(child: _buildStatusFilterDropdown()),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTypeFilterDropdown()),
                          ],
                        ),
                        if (hasActiveFilters) ...[
                          const SizedBox(height: 8),
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

              // Vehicles Data Card / Table
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing ${filteredVehicles.length} of ${vehicleRepo.totalCount} Vehicles',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    if (filteredVehicles.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: EmptyStateWidget(
                          title: 'No vehicles match criteria',
                          description: hasActiveFilters
                              ? 'Try adjusting your search keywords or clear filters to see all fleet vehicles.'
                              : 'No vehicles registered yet. Add your first vehicle above!',
                          actionLabel: hasActiveFilters ? 'Clear Filters' : 'Register Vehicle',
                          onAction: hasActiveFilters
                              ? _clearFilters
                              : () => Navigator.of(context).pushNamed(AppRoutes.vehicleRegister),
                        ),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 1000),
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('PLATE #')),
                              DataColumn(label: Text('MAKE & MODEL')),
                              DataColumn(label: Text('VIN')),
                              DataColumn(label: Text('CATEGORY')),
                              DataColumn(label: Text('POWERTRAIN')),
                              DataColumn(label: Text('STATUS')),
                              DataColumn(label: Text('ODOMETER')),
                              DataColumn(label: Text('DRIVER')),
                              DataColumn(label: Text('ACTIONS')),
                            ],
                            rows: filteredVehicles.map((vehicle) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      vehicle.plateNumber,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(vehicle.displayName)),
                                  DataCell(
                                    Text(
                                      vehicle.vin,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(vehicle.type.label)),
                                  DataCell(Text(vehicle.fuelType.label)),
                                  DataCell(StatusBadge(status: vehicle.status, compact: true)),
                                  DataCell(Text('${vehicle.mileage.toString()} km')),
                                  DataCell(Text(vehicle.assignedDriver ?? 'Unassigned')),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.visibility_outlined, size: 18),
                                          tooltip: 'View Details',
                                          color: const Color(0xFF475569),
                                          onPressed: () {
                                            VehicleDetailDialog.show(context, vehicle);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18),
                                          tooltip: 'Edit Vehicle',
                                          color: AppColors.primary,
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => VehicleFormScreen(
                                                  vehicleToEdit: vehicle,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18),
                                          tooltip: 'Delete Vehicle',
                                          color: AppColors.statusOutOfService,
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
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
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
                  fontWeight: FontWeight.w600,
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

  Widget _buildStatusFilterDropdown() {
    return SizedBox(
      height: 44,
      child: DropdownButtonFormField<VehicleStatus?>(
        initialValue: _statusFilter,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
          hintText: 'Filter by Status',
        ),
        items: [
          const DropdownMenuItem(
            value: null,
            child: Text('All Statuses', style: TextStyle(fontSize: 13)),
          ),
          ...VehicleStatus.values.map(
            (status) => DropdownMenuItem(
              value: status,
              child: Text(status.label, style: const TextStyle(fontSize: 13)),
            ),
          ),
        ],
        onChanged: (val) {
          setState(() {
            _statusFilter = val;
          });
        },
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
          hintText: 'Filter by Type',
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
