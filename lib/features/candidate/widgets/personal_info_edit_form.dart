import 'package:flutter/material.dart';

/// Personal Information Edit Form - Matches Web Layout
///
/// This replaces the current _buildEditablePersonalInfo() in profile_screen.dart

class PersonalInfoEditForm {
  static const Color primaryColor = Color(0xFF257180);

  /// Build edit form with all fields in grid layout
  static Widget build({
    required TextEditingController firstNameController,
    required TextEditingController middleNameController,
    required TextEditingController lastNameController,
    required TextEditingController suffixController,
    required TextEditingController emailController,
    required TextEditingController phoneController,
    required TextEditingController cityController,
    required TextEditingController provinceController,
    required String selectedDisabilityType,
    required List<String> disabilityTypes,
    required Function(String?) onDisabilityChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Row 1: First Name | Middle Name
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: firstNameController,
                  label: 'First Name',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: middleNameController,
                  label: 'Middle Name',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row 2: Last Name | Suffix
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: lastNameController,
                  label: 'Last Name',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: suffixController,
                  label: 'Suffix',
                  hint: 'Jr., Sr., III, etc.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row 3: Contact Number | City
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: phoneController,
                  label: 'Contact Number',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: cityController,
                  label: 'City',
                  prefixIcon: Icons.location_city,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row 4: Province | Type of Disability
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: provinceController,
                  label: 'Province',
                  prefixIcon: Icons.location_on,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  label: 'Type of Disability',
                  value: selectedDisabilityType,
                  items: disabilityTypes,
                  onChanged: onDisabilityChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build text field with label
  static Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Text field
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint ?? label,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '$label is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  /// Build dropdown field with label
  static Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        // Dropdown
        DropdownButtonFormField<String>(
          value: value.isEmpty ? null : value,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
