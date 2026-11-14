import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../models/vehicle_model.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/status_badge.dart';

/// Clean, responsive form screen for Registering or Editing a Fleet Vehicle.
/// Focused on 4 core fields: Vehicle Number, Brand, Model, and Status.
class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicleToEdit;

  const VehicleFormScreen({
    super.key,
    this.vehicleToEdit,
  });

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _vehicleNumberController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late VehicleStatus _selectedStatus;

  bool _isDirty = false;

  bool get isEditMode => widget.vehicleToEdit != null;

  // Common Stark Group fleet brands for quick selection
  static const List<String> _quickBrands = [
    'Volvo',
    'Scania',
    'Mercedes-Benz',
    'MAN',
    'DAF',
    'Ford',
  ];

  @override
  void initState() {
    super.initState();
    final v = widget.vehicleToEdit;

    _vehicleNumberController = TextEditingController(text: v?.plateNumber ?? '');
    _brandController = TextEditingController(text: v?.make ?? '');
    _modelController = TextEditingController(text: v?.model ?? '');
    _selectedStatus = v?.status ?? VehicleStatus.active;

    _vehicleNumberController.addListener(_markDirty);
    _brandController.addListener(_markDirty);
    _modelController.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_isDirty) {
      setState(() => _isDirty = true);
    }
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _handleCancel() async {
    if (_isDirty) {
      final discard = await ConfirmDialog.show(
        context,
        title: 'Discard Changes?',
        message: 'You have unsaved changes in this form. Are you sure you want to discard them?',
        confirmLabel: 'Discard Changes',
        cancelLabel: 'Keep Editing',
        isDestructive: true,
      );
      if (discard != true) return;
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final repo = VehicleRepository();
    final vehicleNumber = _vehicleNumberController.text.trim();
    final brand = _brandController.text.trim();
    final model = _modelController.text.trim();

    if (isEditMode) {
      final updatedVehicle = widget.vehicleToEdit!.copyWith(
        plateNumber: vehicleNumber,
        make: brand,
        model: model,
        status: _selectedStatus,
      );
      repo.updateVehicle(updatedVehicle);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text('Vehicle "$vehicleNumber" ($brand $model) updated successfully.'),
            ],
          ),
          backgroundColor: AppColors.statusActive,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final newVehicle = Vehicle(
        id: 'veh-${DateTime.now().millisecondsSinceEpoch % 10000}',
        plateNumber: vehicleNumber,
        vin: 'VIN-${vehicleNumber.replaceAll(RegExp(r'[^A-Za-z0-9]'), '')}',
        make: brand,
        model: model,
        year: DateTime.now().year,
        type: VehicleType.truck,
        status: _selectedStatus,
        fuelType: FuelType.diesel,
        mileage: 0,
        assignedDriver: null,
        location: 'Stark Central Depot',
        lastServiceDate: DateTime.now(),
      );
      repo.addVehicle(newVehicle);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text('New vehicle "$vehicleNumber" ($brand $model) registered.'),
            ],
          ),
          backgroundColor: AppColors.statusActive,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Vehicle Fleet',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              isEditMode ? 'Edit Vehicle' : 'Register Vehicle',
              style: TextStyle(
                fontSize: isMobile ? 15 : 18,
                fontWeight: FontWeight.bold,
                color: AppColors.starkDark,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _handleCancel,
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _handleSave,
              icon: const Icon(Icons.check, size: 18),
              label: Text(isEditMode ? 'Save Changes' : 'Register Vehicle'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Edit mode vehicle summary banner
                  if (isEditMode) ...[
                    _buildEditContextBanner(),
                    const SizedBox(height: 16),
                  ],

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section 1: Identification & Status
                          _buildSectionHeader(
                            icon: Icons.badge_outlined,
                            title: 'Vehicle Registration & Status',
                            subtitle:
                                'Set the unique fleet vehicle registration tag and current operational status.',
                          ),
                          const SizedBox(height: 20),

                          _buildResponsiveRow(
                            isDesktop: !isMobile,
                            child1: _buildTextField(
                              controller: _vehicleNumberController,
                              label: 'Vehicle Number *',
                              hintText: 'e.g. SG-1042-TK',
                              helperText: 'Unique fleet license plate or registration tag',
                              prefixIcon: Icons.confirmation_number_outlined,
                              textCapitalization: TextCapitalization.characters,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter the vehicle number';
                                }
                                if (val.trim().length < 3) {
                                  return 'Vehicle number must be at least 3 characters';
                                }
                                return null;
                              },
                            ),
                            child2: _buildStatusDropdown(),
                          ),

                          const SizedBox(height: 28),
                          const Divider(),
                          const SizedBox(height: 24),

                          // Section 2: Manufacturer & Model
                          _buildSectionHeader(
                            icon: Icons.directions_car_outlined,
                            title: 'Vehicle Specification',
                            subtitle:
                                'Specify the vehicle manufacturer brand and specific model designation.',
                          ),
                          const SizedBox(height: 20),

                          _buildResponsiveRow(
                            isDesktop: !isMobile,
                            child1: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextField(
                                  controller: _brandController,
                                  label: 'Brand *',
                                  hintText: 'e.g. Volvo, Scania, Mercedes-Benz',
                                  helperText: 'Vehicle manufacturer brand name',
                                  prefixIcon: Icons.business_outlined,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Please enter the vehicle brand';
                                    }
                                    if (val.trim().length < 2) {
                                      return 'Brand name must be at least 2 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                _buildQuickBrandSuggestions(),
                              ],
                            ),
                            child2: _buildTextField(
                              controller: _modelController,
                              label: 'Model *',
                              hintText: 'e.g. FH16 750 Globetrotter',
                              helperText: 'Specific model series or variant name',
                              prefixIcon: Icons.commute_outlined,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter the vehicle model';
                                }
                                if (val.trim().length < 2) {
                                  return 'Model must be at least 2 characters';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 36),
                          const Divider(),
                          const SizedBox(height: 24),

                          // Action Buttons
                          _buildActionButtons(isMobile),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Banner displayed in Edit Mode summarizing current vehicle details
  Widget _buildEditContextBanner() {
    final v = widget.vehicleToEdit!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderMedium),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_note, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Editing: ${v.plateNumber}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.starkDark,
                    ),
                  ),
                  Text(
                    '${v.make} ${v.model}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatusBadge(status: v.status),
        ],
      ),
    );
  }

  /// Form Section Header
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.starkDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Responsive row layout (2-column on desktop/tablet, 1-column on mobile)
  Widget _buildResponsiveRow({
    required bool isDesktop,
    required Widget child1,
    required Widget child2,
  }) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: child1),
          const SizedBox(width: 20),
          Expanded(child: child2),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child1,
          const SizedBox(height: 20),
          child2,
        ],
      );
    }
  }

  /// Consistent reusable text field with floating label, clear helper & error text
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    String? helperText,
    IconData? prefixIcon,
    TextCapitalization textCapitalization = TextCapitalization.words,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.starkDark,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          textCapitalization: textCapitalization,
          validator: validator,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            helperMaxLines: 2,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: AppColors.textSecondary)
                : null,
          ),
        ),
      ],
    );
  }

  /// Quick-select brand chips to speed up data entry
  Widget _buildQuickBrandSuggestions() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Quick select:',
          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        ..._quickBrands.map((brand) {
          final isSelected = _brandController.text.trim().toLowerCase() == brand.toLowerCase();
          return InkWell(
            onTap: () {
              setState(() {
                _brandController.text = brand;
                _markDirty();
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryContainer : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                ),
              ),
              child: Text(
                brand,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.starkSteel,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  /// Operational Status Dropdown with semantic color indicators
  Widget _buildStatusDropdown() {
    Color getStatusDotColor(VehicleStatus status) {
      switch (status) {
        case VehicleStatus.active:
          return AppColors.statusActive;
        case VehicleStatus.inMaintenance:
          return AppColors.statusMaintenance;
        case VehicleStatus.outOfService:
          return AppColors.statusOutOfService;
        case VehicleStatus.reserved:
          return AppColors.statusReserved;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status *',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.starkDark,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<VehicleStatus>(
          initialValue: _selectedStatus,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.tune_outlined, size: 20, color: AppColors.textSecondary),
            helperText: 'Current operational deployment status',
          ),
          items: VehicleStatus.values.map((status) {
            final color = getStatusDotColor(status);
            return DropdownMenuItem<VehicleStatus>(
              value: status,
              child: Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.starkDark,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (newStatus) {
            if (newStatus != null) {
              setState(() {
                _selectedStatus = newStatus;
                _markDirty();
              });
            }
          },
        ),
      ],
    );
  }

  /// Bottom action buttons (Cancel & Save)
  Widget _buildActionButtons(bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: _handleSave,
            icon: const Icon(Icons.check, size: 18),
            label: Text(isEditMode ? 'Save Changes' : 'Register Vehicle'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _handleCancel,
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: _handleCancel,
          icon: const Icon(Icons.close, size: 18),
          label: const Text('Cancel'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          ),
        ),
        const SizedBox(width: 14),
        ElevatedButton.icon(
          onPressed: _handleSave,
          icon: const Icon(Icons.check, size: 18),
          label: Text(isEditMode ? 'Save Changes' : 'Register Vehicle'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ],
    );
  }
}
