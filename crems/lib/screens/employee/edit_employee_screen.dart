import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/employee_model.dart';
import '../../providers/employee_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/image_picker_helper.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditEmployeeScreen extends StatefulWidget {
  final Employee employee;

  const EditEmployeeScreen({Key? key, required this.employee}) : super(key: key);

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _nidController;
  late TextEditingController _salaryController;
  late TextEditingController _addressController;

  late String selectedRole;
  late String selectedSalaryType;
  late String selectedCountry;
  late DateTime? joiningDate;
  PickedImageData? selectedImage;
  late bool isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employee.name);
    _emailController = TextEditingController(text: widget.employee.email);
    _phoneController = TextEditingController(text: widget.employee.phone);
    _nidController = TextEditingController(text: widget.employee.nid.toString());
    _salaryController = TextEditingController(text: widget.employee.salary.toString());
    _addressController = TextEditingController(text: widget.employee.address);

    selectedRole = widget.employee.role;
    selectedSalaryType = widget.employee.salaryType;
    selectedCountry = widget.employee.country;
    joiningDate = widget.employee.joiningDate;
    isActive = widget.employee.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nidController.dispose();
    _salaryController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImageSource? source = await ImagePickerHelper.showImageSourceDialog(context);

      if (source != null) {
        final imageData = await ImagePickerHelper.pickImage(source);

        if (imageData != null) {
          setState(() {
            selectedImage = imageData;
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      _showSnackBar('Error selecting image: $e', isError: true);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: joiningDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        joiningDate = picked;
      });
    }
  }

  Future<void> _updateEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedImage == null && widget.employee.photo == null) {
      _showSnackBar('Please select a photo', isError: true);
      return;
    }

    try {
      final updatedEmployee = Employee(
        id: widget.employee.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        nid: int.parse(_nidController.text.trim()),
        joiningDate: joiningDate,
        role: selectedRole,
        salaryType: selectedSalaryType,
        salary: double.parse(_salaryController.text.trim()),
        status: isActive,
        country: selectedCountry,
        address: _addressController.text.trim(),
        photo: widget.employee.photo,
        totalSalary: widget.employee.totalSalary,
        lastSalary: widget.employee.lastSalary,
        user: widget.employee.user,
      );

      final provider = Provider.of<EmployeeProvider>(context, listen: false);
      final success = await provider.updateEmployee(updatedEmployee, selectedImage);

      if (mounted) {
        if (success) {
          _showSnackBar('Employee updated successfully', isError: false);
          Navigator.pop(context, true);
        } else {
          _showSnackBar(provider.errorMessage ?? 'Failed to update employee', isError: true);
        }
      }
    } catch (e) {
      print('Exception in _updateEmployee: $e');
      if (mounted) {
        _showSnackBar('Error: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: ResponsiveBuilder(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: _buildForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _buildForm(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  margin: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient.scale(0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              bottomLeft: Radius.circular(30),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildImagePicker(),
                              const SizedBox(height: 30),
                              const Text(
                                'Edit Employee',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Update employee information',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: _buildForm(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Edit Employee',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: ResponsiveHelper.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            if (!isDesktop) ...[
              _buildImagePicker(),
              const SizedBox(height: 30),
            ],

            _buildSectionTitle('Personal Information', Icons.person_outline),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter full name',
              prefixIcon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter email address',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              enabled: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            if (isDesktop)
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _phoneController,
                      label: 'Phone',
                      hint: 'Enter phone number',
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _nidController,
                      label: 'NID',
                      hint: 'Enter NID number',
                      prefixIcon: Icons.badge,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter NID';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              )
            else ...[
              CustomTextField(
                controller: _phoneController,
                label: 'Phone',
                hint: 'Enter phone number',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nidController,
                label: 'NID',
                hint: 'Enter NID number',
                prefixIcon: Icons.badge,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter NID';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 30),

            _buildSectionTitle('Address Information', Icons.location_on_outlined),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _addressController,
              label: 'Address',
              hint: 'Enter full address',
              prefixIcon: Icons.home,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              'Country',
              selectedCountry,
              AppConstants.countries,
                  (value) => setState(() => selectedCountry = value!),
              icon: Icons.flag,
            ),
            const SizedBox(height: 30),

            _buildSectionTitle('Employment Details', Icons.work_outline),
            const SizedBox(height: 16),

            if (isDesktop)
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      'Role',
                      selectedRole,
                      AppConstants.roles,
                          (value) => setState(() => selectedRole = value!),
                      icon: Icons.admin_panel_settings,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePicker(),
                  ),
                ],
              )
            else ...[
              _buildDropdown(
                'Role',
                selectedRole,
                AppConstants.roles,
                    (value) => setState(() => selectedRole = value!),
                icon: Icons.admin_panel_settings,
              ),
              const SizedBox(height: 16),
              _buildDatePicker(),
            ],
            const SizedBox(height: 30),

            _buildSectionTitle('Salary Information', Icons.payments_outlined),
            const SizedBox(height: 16),

            if (isDesktop)
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      'Salary Type',
                      selectedSalaryType,
                      AppConstants.salaryTypes,
                          (value) => setState(() => selectedSalaryType = value!),
                      icon: Icons.payment,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _salaryController,
                      label: 'Salary Amount',
                      hint: 'Enter salary amount',
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter salary';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter valid amount';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              )
            else ...[
              _buildDropdown(
                'Salary Type',
                selectedSalaryType,
                AppConstants.salaryTypes,
                    (value) => setState(() => selectedSalaryType = value!),
                icon: Icons.payment,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _salaryController,
                label: 'Salary Amount',
                hint: 'Enter salary amount',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter salary';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid amount';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),
            _buildStatusSwitch(),
            const SizedBox(height: 30),

            Consumer<EmployeeProvider>(
              builder: (context, provider, child) {
                return CustomButton(
                  text: 'Update Employee',
                  onPressed: _updateEmployee,
                  isLoading: provider.isLoading,
                  icon: Icons.save,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: selectedImage != null
                  ? ClipOval(
                child: kIsWeb && selectedImage!.bytes != null
                    ? Image.memory(
                  selectedImage!.bytes!,
                  fit: BoxFit.cover,
                )
                    : selectedImage!.file != null
                    ? Image.file(
                  selectedImage!.file!,
                  fit: BoxFit.cover,
                )
                    : const Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.white,
                ),
              )
                  : widget.employee.photo != null
                  ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: '${AppConstants.imageBaseUrl}/employees/${widget.employee.photo}',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    );
                  },
                ),
              )
                  : const Icon(
                Icons.add_a_photo,
                size: 40,
                color: Colors.white,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
      String label,
      String value,
      List<String> items,
      void Function(String?) onChanged, {
        IconData? icon,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              prefixIcon: icon != null
                  ? Icon(icon, color: AppColors.primary)
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
            dropdownColor: Colors.white,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  AppConstants.formatRole(item),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Joining Date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  joiningDate != null
                      ? '${joiningDate!.day}/${joiningDate!.month}/${joiningDate!.year}'
                      : 'Select joining date',
                  style: TextStyle(
                    color: joiningDate != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.primary.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.check_circle_outline, color: AppColors.primary),
              SizedBox(width: 12),
              Text(
                'Active Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Switch(
            value: isActive,
            onChanged: (value) => setState(() => isActive = value),
            activeColor: AppColors.success,
            activeTrackColor: AppColors.success.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}