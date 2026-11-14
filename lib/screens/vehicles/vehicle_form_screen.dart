import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../models/vehicle_model.dart';

/// Form screen for Registering a New Vehicle or Editing an Existing Vehicle.
/// Desktop-first 2-column layout with comprehensive field validations.
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

  late TextEditingController _plateController;
  late TextEditingController _vinController;
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _mileageController;
  late TextEditingController _driverController;
  late TextEditingController _locationController;

  late VehicleType _selectedType;
  late VehicleStatus _selectedStatus;
  late FuelType _selectedFuelType;

  bool get isEditMode => widget.vehicleToEdit != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicleToEdit;

    _plateController = TextEditingController(text: v?.plateNumber ?? '');
    _vinController = TextEditingController(text: v?.vin ?? '');
    _makeController = TextEditingController(text: v?.make ?? '');
    _modelController = TextEditingController(text: v?.model ?? '');
    _yearController = TextEditingController(text: v?.year.toString() ?? DateTime.now().year.toString());
    _mileageController = TextEditingController(text: v?.mileage.toString() ?? '0');
    _driverController = TextEditingController(text: v?.assignedDriver ?? '');
    _locationController = TextEditingController(text: v?.location ?? '');

    _selectedType = v?.type ?? VehicleType.sedan;
    _selectedStatus = v?.status ?? VehicleStatus.active;
    _selectedFuelType = v?.fuelType ?? FuelType.petrol;
  }

  @override
  void dispose() {
    _plateController.dispose();
    _vinController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _driverController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final repo = VehicleRepository();
    final year = int.tryParse(_yearController.text.trim()) ?? DateTime.now().year;
    final mileage = int.tryParse(_mileageController.text.trim()) ?? 0;

    if (isEditMode) {
      final updatedVehicle = widget.vehicleToEdit!.copyWith(
        plateNumber: _plateController.text.trim(),
        vin: _vinController.text.trim(),
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: year,
        type: _selectedType,
        status: _selectedStatus,
        fuelType: _selectedFuelType,
        mileage: mileage,
        assignedDriver: _driverController.text.trim().isEmpty ? null : _driverController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      );
      repo.updateVehicle(updatedVehicle);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vehicle "${updatedVehicle.displayName}" updated successfully.'),
          backgroundColor: AppColors.statusActive,
        ),
      );
    } else {
      final newVehicle = Vehicle(
        id: 'veh-${DateTime.now().millisecondsSinceEpoch % 10000}',
        plateNumber: _plateController.text.trim(),
        vin: _vinController.text.trim(),
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: year,
        type: _selectedType,
        status: _selectedStatus,
        fuelType: _selectedFuelType,
        mileage: mileage,
        assignedDriver: _driverController.text.trim().isEmpty ? null : _driverController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        lastServiceDate: DateTime.now(),
      );
      repo.addVehicle(newVehicle);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New vehicle "${newVehicle.displayName}" registered in fleet.'),
          backgroundColor: AppColors.statusActive,
        ),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Vehicle Details' : 'Register New Vehicle'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
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
            constraints: const BoxConstraints(maxWidth: 900),
            child: Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Identification & General Info
                      _buildSectionHeader(
                        icon: Icons.directions_car,
                        title: 'Vehicle Identification',
                        subtitle: 'Primary registration numbers and manufacturer details.',
                      ),
                      const SizedBox(height: 20),

                      _buildResponsiveRow(
                        isDesktop: isDesktop,
                        child1: _buildTextField(
                          controller: _plateController,
                          label: 'License Plate *',
                          hintText: 'e.g. ABC-1234',
                          validator: (v) => v == null || v.trim().isEmpty ? 'Plate is required' : null,
                        ),
                        child2: _buildTextField(
                          controller: _vinController,
                          label: 'VIN (Vehicle Identification Number) *',
                          hintText: '17-character VIN',
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'VIN is required';
                            if (v.trim().length < 6) return 'VIN must be at least 6 characters';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildResponsiveRow(
                        isDesktop: isDesktop,
                        child1: _buildTextField(
                          controller: _makeController,
                          label: 'Make / Manufacturer *',
                          hintText: 'e.g. Toyota, Ford, Tesla',
                          validator: (v) => v == null || v.trim().isEmpty ? 'Make is required' : null,
                        ),
                        child2: _buildTextField(
                          controller: _modelController,
                          label: 'Model *',
                          hintText: 'e.g. Camry, F-150, Model 3',
                          validator: (v) => v == null || v.trim().isEmpty ? 'Model is required' : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildResponsiveRow(
                        isDesktop: isDesktop,
                        child1: _buildTextField(
                          controller: _yearController,
                          label: 'Manufacturing Year *',
                          hintText: 'e.g. 2024',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Year is required';
                            final y = int.tryParse(v.trim());
                            if (y == null || y < 1980 || y > DateTime.now().year + 1) {
                              return 'Enter a valid year';
                            }
                            return null;
                          },
                        ),
                        child2: _buildDropdownField<VehicleType>(
                          label: 'Vehicle Category / Type *',
                          value: _selectedType,
                          items: VehicleType.values.map((t) {
                            return DropdownMenuItem(value: t, child: Text(t.label));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedType = val);
                          },
                        ),
                      ),

                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 24),

                      // Section 2: Fleet Status & Operational Info
                      _buildSectionHeader(
                        icon: Icons.tune,
                        title: 'Operations & Fueling',
                        subtitle: 'Current deployment status, odometer, and driver allocation.',
                      ),
                      const SizedBox(height: 20),

                      _buildResponsiveRow(
                        isDesktop: isDesktop,
                        child1: _buildDropdownField<VehicleStatus>(
                          label: 'Operational Status *',
                          value: _selectedStatus,
                          items: VehicleStatus.values.map((s) {
                            return DropdownMenuItem(value: s, child: Text(s.label));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedStatus = val);
                          },
                        ),
                        child2: _buildDropdownField<FuelType>(
                          label: 'Fuel / Powertrain *',
                          value: _selectedFuelType,
                          items: FuelType.values.map((f) {
                            return DropdownMenuItem(value: f, child: Text(f.label));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedFuelType = val);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildResponsiveRow(
                        isDesktop: isDesktop,
                        child1: _buildTextField(
                          controller: _mileageController,
                          label: 'Current Odometer (km) *',
                          hintText: 'e.g. 24000',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Mileage is required';
                            final m = int.tryParse(v.trim());
                            if (m == null || m < 0) return 'Enter a positive mileage';
                            return null;
                          },
                        ),
                        child2: _buildTextField(
                          controller: _driverController,
                          label: 'Assigned Driver',
                          hintText: 'e.g. John Doe (optional)',
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _locationController,
                        label: 'Depot / Current Location',
                        hintText: 'e.g. North Terminal - Bay 4',
                      ),

                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _handleSave,
                            icon: const Icon(Icons.check, size: 18),
                            label: Text(isEditMode ? 'Save Changes' : 'Register Vehicle'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ],
    );
  }

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
        children: [
          child1,
          const SizedBox(height: 16),
          child2,
        ],
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          decoration: const InputDecoration(),
        ),
      ],
    );
  }
}
