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

/// Vehicle Management List Screen.
/// Columns: Vehicle Number | Brand | Model | Status | Action (edit & delete icons).
/// Includes status filter pills, category dropdown + Filter List button, and pagination.
class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final TextEditingController _searchController = TextEditingController();
  VehicleStatus? _statusFilter;
  VehicleType? _typeFilter;

  // Pagination state
  int _currentPage = 1;
  static const int _rowsPerPage = 10;

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
      _currentPage = 1;
    });
  }

  void _applyFilter() {
    // Triggers rebuild with current dropdown state — same as onChanged but
    // wired to the explicit "Filter List" button.
    setState(() {
      _currentPage = 1;
    });
  }

  void _handleEdit(Vehicle vehicle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VehicleFormScreen(vehicleToEdit: vehicle),
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

        // Pagination calculations
        final totalItems = filteredVehicles.length;
        final totalPages = (totalItems / _rowsPerPage).ceil().clamp(1, 999);
        final safePage = _currentPage.clamp(1, totalPages);
        final startIndex = (safePage - 1) * _rowsPerPage;
        final endIndex = (startIndex + _rowsPerPage).clamp(0, totalItems);
        final pageItems = totalItems == 0
            ? <Vehicle>[]
            : filteredVehicles.sublist(startIndex, endIndex);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Page Header ──────────────────────────────────────────────
              _buildHeader(context),
              const SizedBox(height: 20),

              // ── Status Filter Pills ──────────────────────────────────────
              _buildStatusTabs(vehicleRepo),
              const SizedBox(height: 16),

              // ── Search & Category Filter Toolbar ─────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: isDesktop
                      ? Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: SearchBarWidget(
                                controller: _searchController,
                                onChanged: (_) => setState(() => _currentPage = 1),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: _buildTypeFilterDropdown(),
                            ),
                            const SizedBox(width: 12),
                            // Filter List action button
                            OutlinedButton.icon(
                              onPressed: _applyFilter,
                              icon: const Icon(Icons.filter_list, size: 16),
                              label: const Text('Filter List'),
                            ),
                            if (hasActiveFilters) ...[
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: _clearFilters,
                                icon: const Icon(Icons.clear_all, size: 16),
                                label: const Text('Reset'),
                              ),
                            ],
                          ],
                        )
                      : Column(
                          children: [
                            SearchBarWidget(
                              controller: _searchController,
                              onChanged: (_) => setState(() => _currentPage = 1),
                            ),
                            const SizedBox(height: 12),
                            _buildTypeFilterDropdown(),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _applyFilter,
                                  icon: const Icon(Icons.filter_list, size: 16),
                                  label: const Text('Filter List'),
                                ),
                                if (hasActiveFilters) ...[
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: _clearFilters,
                                    icon: const Icon(Icons.clear_all, size: 16),
                                    label: const Text('Reset'),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Data Table Card ──────────────────────────────────────────
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sub-header: record count
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Row(
                        children: [
                          Text(
                            'Showing ${totalItems == 0 ? 0 : startIndex + 1}–$endIndex of $totalItems Vehicles',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (hasActiveFilters) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: AppColors.primaryContainer),
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
                    ),
                    const Divider(height: 1),

                    // Content: empty state or table
                    if (filteredVehicles.isEmpty)
                      EmptyStateWidget(
                        icon: hasActiveFilters
                            ? Icons.search_off_outlined
                            : Icons.directions_car_outlined,
                        title: hasActiveFilters
                            ? 'No Matching Vehicles Found'
                            : 'No Vehicles in Fleet',
                        description: hasActiveFilters
                            ? 'No vehicles match your search or filter criteria. Try resetting the filters.'
                            : 'Your fleet inventory is currently empty. Add your first vehicle to get started.',
                        activeFilters:
                            hasActiveFilters ? activeFilterTags : null,
                        actionLabel:
                            hasActiveFilters ? 'Reset Filters' : 'New Vehicle',
                        onAction: hasActiveFilters
                            ? _clearFilters
                            : () => Navigator.of(context)
                                .pushNamed(AppRoutes.vehicleRegister),
                        secondaryActionLabel:
                            hasActiveFilters ? 'New Vehicle' : null,
                        onSecondaryAction: hasActiveFilters
                            ? () => Navigator.of(context)
                                .pushNamed(AppRoutes.vehicleRegister)
                            : null,
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 760),
                          child: DataTable(
                            headingRowHeight: 44,
                            dataRowMinHeight: 60,
                            dataRowMaxHeight: 64,
                            // Columns: Vehicle Number | Brand | Model | Status | Action
                            columns: const [
                              DataColumn(label: Text('VEHICLE NUMBER')),
                              DataColumn(label: Text('BRAND')),
                              DataColumn(label: Text('MODEL')),
                              DataColumn(label: Text('STATUS')),
                              DataColumn(label: Text('ACTION')),
                            ],
                            rows: pageItems.map((vehicle) {
                              return DataRow(
                                cells: [
                                  // 1. Vehicle Number
                                  DataCell(
                                    InkWell(
                                      onTap: () => VehicleDetailDialog.show(
                                          context, vehicle),
                                      borderRadius: BorderRadius.circular(6),
                                      child: _buildPlateTag(vehicle.plateNumber),
                                    ),
                                  ),

                                  // 2. Brand
                                  DataCell(
                                    Text(
                                      vehicle.make,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),

                                  // 3. Model
                                  DataCell(
                                    Text(
                                      vehicle.model,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),

                                  // 4. Status
                                  DataCell(StatusBadge(status: vehicle.status)),

                                  // 5. Action — edit & delete icons only
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 18),
                                          tooltip: 'Edit',
                                          color: AppColors.primary,
                                          onPressed: () =>
                                              _handleEdit(vehicle),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.delete_outline,
                                              size: 18),
                                          tooltip: 'Delete',
                                          color: AppColors.statusOutOfService,
                                          onPressed: () =>
                                              _handleDelete(vehicle),
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

                    // ── Pagination ───────────────────────────────────────
                    if (filteredVehicles.isNotEmpty)
                      _buildPagination(totalItems, totalPages, safePage),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Plate tag ────────────────────────────────────────────────────────────
  Widget _buildPlateTag(String plateNumber) {
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
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            plateNumber,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 0.6,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Page Header ──────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Vehicle List',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.vehicleRegister),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('New Vehicle'),
        ),
      ],
    );
  }

  // ── Status filter pills ──────────────────────────────────────────────────
  Widget _buildStatusTabs(VehicleRepository repo) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: 'All',
            count: repo.totalCount,
            isSelected: _statusFilter == null,
            onTap: () => setState(() {
              _statusFilter = null;
              _currentPage = 1;
            }),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Active',
            count: repo.activeCount,
            isSelected: _statusFilter == VehicleStatus.active,
            activeColor: AppColors.statusActive,
            onTap: () => setState(() {
              _statusFilter = VehicleStatus.active;
              _currentPage = 1;
            }),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'In Maintenance',
            count: repo.maintenanceCount,
            isSelected: _statusFilter == VehicleStatus.inMaintenance,
            activeColor: AppColors.statusMaintenance,
            onTap: () => setState(() {
              _statusFilter = VehicleStatus.inMaintenance;
              _currentPage = 1;
            }),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Out of Service',
            count: repo.outOfServiceCount,
            isSelected: _statusFilter == VehicleStatus.outOfService,
            activeColor: AppColors.statusOutOfService,
            onTap: () => setState(() {
              _statusFilter = VehicleStatus.outOfService;
              _currentPage = 1;
            }),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Reserved',
            count: repo.reservedCount,
            isSelected: _statusFilter == VehicleStatus.reserved,
            activeColor: AppColors.statusReserved,
            onTap: () => setState(() {
              _statusFilter = VehicleStatus.reserved;
              _currentPage = 1;
            }),
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
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? effectiveColor : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
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
                    color:
                        isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Category dropdown ────────────────────────────────────────────────────
  Widget _buildTypeFilterDropdown() {
    return SizedBox(
      height: 44,
      child: DropdownButtonFormField<VehicleType?>(
        value: _typeFilter,
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
            _currentPage = 1;
          });
        },
      ),
    );
  }

  // ── Pagination bar ───────────────────────────────────────────────────────
  Widget _buildPagination(int totalItems, int totalPages, int currentPage) {
    final canPrev = currentPage > 1;
    final canNext = currentPage < totalPages;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Record info
          Text(
            '$totalItems record${totalItems != 1 ? 's' : ''}  •  Page $currentPage of $totalPages',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),

          // Page controls
          Row(
            children: [
              // First page
              _pageButton(
                icon: Icons.first_page,
                tooltip: 'First page',
                enabled: canPrev,
                onTap: () => setState(() => _currentPage = 1),
              ),
              // Previous page
              _pageButton(
                icon: Icons.chevron_left,
                tooltip: 'Previous page',
                enabled: canPrev,
                onTap: () => setState(() => _currentPage = currentPage - 1),
              ),

              // Page number pills
              ...List.generate(totalPages.clamp(0, 5), (i) {
                // Show at most 5 page buttons centred around current page
                int page;
                if (totalPages <= 5) {
                  page = i + 1;
                } else if (currentPage <= 3) {
                  page = i + 1;
                } else if (currentPage >= totalPages - 2) {
                  page = totalPages - 4 + i;
                } else {
                  page = currentPage - 2 + i;
                }

                final isActive = page == currentPage;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    onTap: () => setState(() => _currentPage = page),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.borderMedium,
                        ),
                      ),
                      child: Text(
                        '$page',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // Next page
              _pageButton(
                icon: Icons.chevron_right,
                tooltip: 'Next page',
                enabled: canNext,
                onTap: () => setState(() => _currentPage = currentPage + 1),
              ),
              // Last page
              _pageButton(
                icon: Icons.last_page,
                tooltip: 'Last page',
                enabled: canNext,
                onTap: () => setState(() => _currentPage = totalPages),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pageButton({
    required IconData icon,
    required String tooltip,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 34,
          height: 34,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.borderMedium),
            color: enabled ? Colors.white : const Color(0xFFF8FAFC),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? AppColors.textSecondary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
