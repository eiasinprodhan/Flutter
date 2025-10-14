import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/customer.dart';
import '../services/customer_service.dart';

// --- VIOLET COLOR PALETTE ---
const Color primaryViolet = Color(0xFF673AB7);
const Color secondaryViolet = Color(0xFF9575CD);
const Color backgroundLight = Color(0xFFF5F5F5);
const Color accentRed = Color(0xFFFF6B6B);
const Color accentGreen = Color(0xFF4CAF50);
// --- END OF PALETTE ---

// Define the base URL for your server to avoid hardcoding it multiple times
const String serverBaseUrl = 'http://localhost:8080';

class CustomerFormPage extends StatefulWidget {
  final Customer? customer;

  const CustomerFormPage({Key? key, this.customer}) : super(key: key);

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  XFile? _imageFile;
  Uint8List? _webImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) _populateForm();
    // FIX 3: Add a listener to update the UI (avatar initial) as the user types
    _nameController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // It's crucial to dispose of controllers to prevent memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _populateForm() {
    final c = widget.customer!;
    _nameController.text = c.name ?? '';
    _emailController.text = c.email ?? '';
    _phoneController.text = c.phone ?? '';
    _addressController.text = c.address ?? '';
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
    } else if (widget.customer?.photo != null && widget.customer!.photo!.isNotEmpty) {
      // FIX 1: Construct the full, correct URL for the network image
      // Assumes the backend saves a relative path like /uploads/customers/image.jpg
      imageProvider = NetworkImage('$serverBaseUrl${widget.customer!.photo!}');
    }
    return CircleAvatar(
      radius: 65,
      backgroundColor: primaryViolet.withOpacity(0.1),
      backgroundImage: imageProvider,
      onBackgroundImageError: imageProvider != null ? (_, __) {} : null,
      child: imageProvider == null ? Center(child: Text(_nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'C', style: const TextStyle(color: primaryViolet, fontSize: 48, fontWeight: FontWeight.bold))) : null,
    );
  }

  Future<void> _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final customer = Customer(
          id: widget.customer?.id,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          // FIX 2: Preserve the existing photo URL when updating if no new image is chosen
          photo: widget.customer?.photo,
        );

        bool success;
        if (widget.customer == null) {
          success = await CustomerService.createCustomer(customer, _imageFile);
        } else {
          success = await CustomerService.updateCustomer(customer, _imageFile);
        }

        if (mounted) {
          _showStatusSnackBar(success ? (widget.customer == null ? 'Customer created successfully' : 'Customer updated successfully') : 'Failed to save customer.', success);
          if (success) Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) _showErrorSnackBar('Error: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // ... (No changes to the rest of the file: _showErrorSnackBar, _showStatusSnackBar, build, _buildHeader, _buildForm, etc.) ...
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
      appBar: AppBar(title: Text(widget.customer == null ? 'Add Customer' : 'Edit Customer'), backgroundColor: primaryViolet, foregroundColor: Colors.white),
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
          const Text('Tap to upload photo', style: TextStyle(color: Colors.white70, fontSize: 14)),
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
            _buildSectionTitle('Customer Information'),
            const SizedBox(height: 16),
            _buildTextField(_nameController, 'Full Name', Icons.person_outline, validator: (v) => v!.trim().isEmpty ? 'Please enter a name' : null),
            const SizedBox(height: 16),
            _buildTextField(_emailController, 'Email Address', Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => v!.trim().isEmpty || !v.contains('@') ? 'Enter a valid email' : null),
            const SizedBox(height: 16),
            _buildTextField(_phoneController, 'Phone Number', Icons.phone_outlined, keyboardType: TextInputType.phone, validator: (v) => v!.trim().isEmpty ? 'Please enter a phone number' : null),
            const SizedBox(height: 16),
            _buildTextField(_addressController, 'Full Address', Icons.location_on_outlined, maxLines: 3, validator: (v) => v!.trim().isEmpty ? 'Please enter an address' : null),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveCustomer,
                icon: _isLoading ? const SizedBox.shrink() : Icon(widget.customer == null ? Icons.add_circle_outline : Icons.save_outlined),
                label: _isLoading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : Text(widget.customer == null ? 'Create Customer' : 'Update Customer'),
                style: ElevatedButton.styleFrom(backgroundColor: primaryViolet, foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: primaryViolet.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: primaryViolet)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryViolet, width: 2.0)),
    );
  }

  SnackBar _buildStatusSnackBar(String message, IconData icon, Color color) {
    return SnackBar(content: Row(children: [Icon(icon, color: Colors.white), const SizedBox(width: 12), Text(message)]), backgroundColor: color, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)));
  }
}