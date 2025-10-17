import 'dart:typed_data';

import 'package:crems/pages/SignIn.dart';
import 'package:crems/services/EmployeeService.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController salary = TextEditingController();
  final TextEditingController nid = TextEditingController();
  final TextEditingController address = TextEditingController();

  DateTime? selectedJoiningDate;
  String? selectedSalaryType;
  String? selectedRole;
  String? selectedCountry;

  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  final List<String> salaryTypes = ['Daily', 'Monthly', 'Contract'];
  final List<String> roles = [
    'ADMIN',
    'PROJECT_MANAGER',
    'SITE_MANAGER',
    'LABOUR',
  ];
  final List<String> countries = [
    'India',
    'United States',
    'Canada',
    'Australia',
    'Bangladesh',
    'United Kingdom',
    'Nepal',
    'Germany',
    'France',
    'Other',
  ];

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    confirmPassword.dispose();
    salary.dispose();
    nid.dispose();
    address.dispose();
    super.dispose();
  }

  Future<void> _registerEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a profile image."),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = {
        "name": name.text,
        "email": email.text,
        "phone": phone.text,
        "password": password.text,
        "role": selectedRole,
      };

      final employee = {
        "name": name.text,
        "email": email.text,
        "password": password.text,
        "phone": phone.text,
        "nid": nid.text,
        "joiningDate": selectedJoiningDate?.toIso8601String() ?? "",
        "role": selectedRole,
        "salaryType": selectedSalaryType,
        "salary": salary.text,
        "country": selectedCountry,
        "address": address.text,
      };

      final employeeService = EmployeeService();

      bool success = await employeeService.registerEmployee(
        user: user,
        employee: employee,
        photoBytes: _imageBytes!,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration Successful! Please Sign In.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SignIn()),
          (route) => false,
        );
      } else if (mounted) {
        throw Exception('Server returned a failure response.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration Failed: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                children: [
                  const Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 80,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Create an Account",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Fill in the details below to get started",
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader("Account Information"),
                  _buildAccountFields(),
                  _buildSectionHeader("Job & Salary Details"),
                  _buildJobDetailsFields(),
                  _buildSectionHeader("Personal Information"),
                  _buildImagePicker(),
                  const SizedBox(height: 16),
                  _buildPersonalInfoFields(),
                  const SizedBox(height: 32),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildSignUpButton(),
                  const SizedBox(height: 20),

                  _buildSignInLink(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 16.0, top: 24.0),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    ),
  );

  Widget _buildAccountFields() => Column(
    children: [
      TextFormField(
        controller: name,
        decoration: _buildInputDecoration(
          labelText: "Full Name",
          prefixIcon: Icons.person_outline,
        ),
        validator: (v) => v!.isEmpty ? "Name is required" : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: email,
        keyboardType: TextInputType.emailAddress,
        decoration: _buildInputDecoration(
          labelText: "Email",
          prefixIcon: Icons.email_outlined,
        ),
        validator: (v) =>
            v!.isEmpty || !v.contains('@') ? "Enter a valid email" : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: password,
        obscureText: _obscurePassword,
        decoration: _buildInputDecoration(
          labelText: "Password",
          prefixIcon: Icons.lock_outline,
          suffixIcon: _buildTogglePasswordVisibility(
            isObscure: _obscurePassword,
            toggle: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        validator: (v) =>
            v!.length < 6 ? "Password must be at least 6 characters" : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: confirmPassword,
        obscureText: _obscureConfirmPassword,
        decoration: _buildInputDecoration(
          labelText: "Confirm Password",
          prefixIcon: Icons.lock_outline,
          suffixIcon: _buildTogglePasswordVisibility(
            isObscure: _obscureConfirmPassword,
            toggle: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword,
            ),
          ),
        ),
        validator: (v) => v != password.text ? "Passwords do not match" : null,
      ),
    ],
  );

  Widget _buildJobDetailsFields() => Column(
    children: [
      DropdownButtonFormField<String>(
        value: selectedRole,
        items: roles
            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
            .toList(),
        onChanged: (v) => setState(() => selectedRole = v),
        decoration: _buildInputDecoration(
          labelText: "Role",
          prefixIcon: Icons.work_outline,
        ),
        validator: (v) => v == null ? 'Please select a role' : null,
      ),
      const SizedBox(height: 16),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: selectedSalaryType,
              items: salaryTypes
                  .map((st) => DropdownMenuItem(value: st, child: Text(st)))
                  .toList(),
              onChanged: (v) => setState(() => selectedSalaryType = v),
              decoration: _buildInputDecoration(labelText: "Pay Type"),
              validator: (v) => v == null ? 'Required' : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: salary,
              keyboardType: TextInputType.number,
              decoration: _buildInputDecoration(labelText: 'Salary Amount'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      DateTimeFormField(
        decoration: _buildInputDecoration(
          labelText: "Joining Date",
          prefixIcon: Icons.calendar_today_outlined,
        ),
        mode: DateTimeFieldPickerMode.date,
        onChanged: (value) => setState(() => selectedJoiningDate = value),
        validator: (v) => v == null ? 'Please select a date' : null,
      ),
    ],
  );

  Widget _buildPersonalInfoFields() => Column(
    children: [
      TextFormField(
        controller: phone,
        keyboardType: TextInputType.phone,
        decoration: _buildInputDecoration(
          labelText: "Phone Number",
          prefixIcon: Icons.phone_outlined,
        ),
        validator: (v) => v!.isEmpty ? "Phone is required" : null,
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: selectedCountry,
        items: countries
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: (v) => setState(() => selectedCountry = v),
        decoration: _buildInputDecoration(
          labelText: "Country",
          prefixIcon: Icons.public_outlined,
        ),
        validator: (v) => v == null ? 'Please select a country' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: nid,
        decoration: _buildInputDecoration(
          labelText: "National ID / Aadhar",
          prefixIcon: Icons.badge_outlined,
        ),
        validator: (v) => v!.isEmpty ? "ID is required" : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: address,
        maxLines: 2,
        decoration: _buildInputDecoration(
          labelText: 'Full Address',
          prefixIcon: Icons.location_on_outlined,
        ),
        validator: (v) => v!.isEmpty ? "Address is required" : null,
      ),
    ],
  );

  Widget _buildImagePicker() => GestureDetector(
    onTap: _pickImage,
    child: Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: _imageBytes != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                _imageBytes!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 40,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Upload Profile Image",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
    ),
  );

  IconButton _buildTogglePasswordVisibility({
    required bool isObscure,
    required VoidCallback toggle,
  }) => IconButton(
    onPressed: toggle,
    icon: Icon(
      isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
    ),
  );

  InputDecoration _buildInputDecoration({
    required String labelText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) => InputDecoration(
    labelText: labelText,
    prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
    ),
    filled: true,
    fillColor: Colors.grey[50],
  );

  Widget _buildSignUpButton() => ElevatedButton(
    onPressed: _registerEmployee,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    ),
    child: const Text(
      "Create Account",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  );

  Widget _buildSignInLink(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Already have an account?"),
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        // Use pop for better navigation flow
        child: const Text(
          "Sign In",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ),
    ],
  );
}
