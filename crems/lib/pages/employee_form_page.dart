import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../models/employee.dart';
import '../models/user.dart';
import '../services/employee_service.dart';

// --- VIOLET COLOR PALETTE (Consistent with other pages) ---
const Color primaryViolet = Color(0xFF673AB7);
const Color secondaryViolet = Color(0xFF9575CD);
const Color backgroundLight = Color(0xFFF5F5F5);
const Color accentRed = Color(0xFFFF6B6B);
const Color accentGreen = Color(0xFF4CAF50);
// --- END OF PALETTE ---

class EmployeeFormPage extends StatefulWidget {
  final Employee? employee;

  const EmployeeFormPage({Key? key, this.employee}) : super(key: key);

  @override
  State<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends State<EmployeeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nidController = TextEditingController();
  final _salaryController = TextEditingController();
  final _countryController = TextEditingController();
  final _addressController = TextEditingController();

  String _role = 'ADMIN';
  String _salaryType = 'Monthly';
  bool _status = true;
  XFile? _imageFile;
  Uint8List? _webImage;
  bool _isLoading = false;
  DateTime? _joiningDate;

  final ImagePicker _picker = ImagePicker();

  final List<String> _roles = ['ADMIN', 'PROJECT_MANAGER', 'SITE_MANAGER', 'LABOUR'];
  final List<String> _salaryTypes = ['Monthly', 'Weekly', 'Daily'];
  final Map<String, IconData> _roleIcons = {
    'ADMIN': Icons.admin_panel_settings_outlined,
    'PROJECT_MANAGER': Icons.engineering_outlined,
    'SITE_MANAGER': Icons.construction_outlined,
    'LABOUR': Icons.handyman_outlined,
  };

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) _populateForm();
  }

  void _populateForm() {
    final emp = widget.employee!;
    _nameController.text = emp.name ?? '';
    _emailController.text = emp.email ?? '';
    _phoneController.text = emp.phone ?? '';
    _nidController.text = emp.nid?.toString() ?? '';
    _role = emp.role ?? 'ADMIN';
    _salaryController.text = emp.salary?.toString() ?? '';
    _countryController.text = emp.country ?? '';
    _addressController.text = emp.address ?? '';
    _salaryType = emp.salaryType ?? 'Monthly';
    _status = emp.status ?? true;
    _joiningDate = emp.joiningDate;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() { _imageFile = image; _webImage = bytes; });
        } else {
          setState(() => _imageFile = image);
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundLight,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Choose Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryViolet)),
            const SizedBox(height: 20),
            if (!kIsWeb)
              ListTile(
                leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: secondaryViolet.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.camera_alt_outlined, color: secondaryViolet)),
                title: const Text('Camera'),
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
              ),
            ListTile(
              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: primaryViolet.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.photo_library_outlined, color: primaryViolet)),
              title: const Text('Gallery'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    ImageProvider? imageProvider;
    if (_imageFile != null) {
      if (kIsWeb && _webImage != null) imageProvider = MemoryImage(_webImage!);
      else if (!kIsWeb) imageProvider = FileImage(File(_imageFile!.path));
    } else if (widget.employee?.photo != null) {
      imageProvider = NetworkImage('http://localhost:8080/images/employees/${widget.employee!.photo}');
    }

    return CircleAvatar(
      radius: 65,
      backgroundColor: primaryViolet.withOpacity(0.1),
      backgroundImage: imageProvider,
      onBackgroundImageError: imageProvider != null ? (_, __) {} : null,
      child: imageProvider == null ? Center(child: Text(_nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'E', style: const TextStyle(color: primaryViolet, fontSize: 48, fontWeight: FontWeight.bold))) : null,
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: primaryViolet, onPrimary: Colors.white, onSurface: primaryViolet)), child: child!),
    );
    if (picked != null) setState(() => _joiningDate = picked);
  }

  Future<void> _saveEmployee() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final employee = Employee(
          id: widget.employee?.id,
          name: _nameController.text.trim(), email: _emailController.text.trim(),
          password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
          phone: _phoneController.text.trim(), nid: int.tryParse(_nidController.text),
          joiningDate: _joiningDate, role: _role, salaryType: _salaryType,
          salary: double.tryParse(_salaryController.text), status: _status,
          country: _countryController.text.trim(), address: _addressController.text.trim(),
        );

        bool success;
        if (widget.employee == null) {
          final user = User(
            name: _nameController.text.trim(), email: _emailController.text.trim(), phone: _phoneController.text.trim(),
            password: _passwordController.text, role: _role, active: true, isLock: false,
          );
          success = await EmployeeService.createEmployee(user, employee, _imageFile);
        } else {
          success = await EmployeeService.updateEmployee(employee, _imageFile);
        }

        if (mounted) {
          _showStatusSnackBar(success ? (widget.employee == null ? 'Employee created successfully' : 'Employee updated successfully') : 'Failed to save employee. Please try again.', success);
          if (success) Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) _showErrorSnackBar('Error: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(_buildStatusSnackBar(message, Icons.error_outline, accentRed));
  }

  void _showStatusSnackBar(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(_buildStatusSnackBar(message, success ? Icons.check_circle : Icons.error_outline, success ? accentGreen : accentRed));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(title: Text(widget.employee == null ? 'Add Employee' : 'Edit Employee'), backgroundColor: primaryViolet, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [primaryViolet, secondaryViolet])),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showImageSourceDialog,
            child: Stack(
              children: [
                _buildImagePreview(),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(gradient: LinearGradient(colors: [secondaryViolet, primaryViolet]), shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Tap to upload employee photo', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('Personal Information'),
            const SizedBox(height: 16),
            _buildTextField(_nameController, 'Full Name', Icons.person_outline, validator: (v) => v!.trim().isEmpty ? 'Please enter name' : null),
            const SizedBox(height: 16),
            _buildTextField(_emailController, 'Email Address', Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => v!.trim().isEmpty || !v.contains('@') ? 'Enter a valid email' : null),
            if (widget.employee == null) ...[
              const SizedBox(height: 16),
              _buildTextField(_passwordController, 'Password', Icons.lock_outline, obscureText: true, validator: (v) => v!.isEmpty ? 'Please enter password' : (v.length < 6 ? 'Password must be at least 6 characters' : null)),
            ],
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildTextField(_phoneController, 'Phone', Icons.phone_outlined, keyboardType: TextInputType.phone, validator: (v) => v!.trim().isEmpty ? 'Required' : null)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_nidController, 'NID', Icons.badge_outlined, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null)),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle('Employment Details'),
            const SizedBox(height: 16),
            _buildDateSelector(),
            const SizedBox(height: 16),
            _buildRoleDropdown(),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildSalaryTypeDropdown()),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_salaryController, 'Salary', Icons.attach_money_outlined, keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle('Address Information'),
            const SizedBox(height: 16),
            _buildTextField(_countryController, 'Country', Icons.public_outlined),
            const SizedBox(height: 16),
            _buildTextField(_addressController, 'Full Address', Icons.location_on_outlined, maxLines: 3),
            const SizedBox(height: 24),
            _buildStatusSwitch(),
            const SizedBox(height: 32),
            _buildSaveButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _saveEmployee,
        style: ElevatedButton.styleFrom(backgroundColor: primaryViolet, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        icon: _isLoading ? const SizedBox.shrink() : Icon(widget.employee == null ? Icons.add_circle_outline : Icons.check_circle_outline),
        label: _isLoading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : Text(widget.employee == null ? 'Create Employee' : 'Update Employee', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 24, decoration: BoxDecoration(gradient: const LinearGradient(colors: [primaryViolet, secondaryViolet]), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryViolet)),
      ],
    );
  }

  Widget _buildTextField(TextEditingController c, String label, IconData icon, {TextInputType? keyboardType, bool obscureText = false, int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: c, keyboardType: keyboardType, obscureText: obscureText, maxLines: maxLines,
      decoration: _inputDecoration(label, icon),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, {Color? color}) {
    final iconColor = color ?? primaryViolet;
    return InputDecoration(
        labelText: label,
        prefixIcon: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: iconColor)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryViolet, width: 2.0))
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: _inputDecoration('Joining Date', Icons.calendar_today_outlined),
        child: Text(_joiningDate != null ? DateFormat('MMMM dd, yyyy').format(_joiningDate!) : 'Select Date', style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _role,
      decoration: _inputDecoration('Role', _roleIcons[_role] ?? Icons.work_outline),
      items: _roles.map((role) => DropdownMenuItem(value: role, child: Row(children: [Icon(_roleIcons[role] ?? Icons.work_outline, size: 20, color: primaryViolet), const SizedBox(width: 12), Text(role.replaceAll('_', ' '))]))).toList(),
      onChanged: (value) => setState(() => _role = value!),
      validator: (v) => v == null || v.isEmpty ? 'Please select a role' : null,
    );
  }

  Widget _buildSalaryTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _salaryType,
      decoration: _inputDecoration('Salary Type', Icons.payment_outlined, color: secondaryViolet),
      items: _salaryTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
      onChanged: (value) => setState(() => _salaryType = value!),
    );
  }

  Widget _buildStatusSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: (_status ? accentGreen : accentRed).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(_status ? Icons.toggle_on_outlined : Icons.toggle_off_outlined, color: _status ? accentGreen : accentRed)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Active Status', style: TextStyle(fontWeight: FontWeight.bold, color: primaryViolet)),
                  Text(_status ? 'Employee is active' : 'Employee is inactive', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
          Switch(value: _status, onChanged: (value) => setState(() => _status = value), activeColor: accentGreen),
        ],
      ),
    );
  }

  SnackBar _buildStatusSnackBar(String message, IconData icon, Color color) {
    return SnackBar(
      content: Row(children: [Icon(icon, color: Colors.white), const SizedBox(width: 12), Text(message)]),
      backgroundColor: color, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _nidController.dispose();
    _salaryController.dispose();
    _countryController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}