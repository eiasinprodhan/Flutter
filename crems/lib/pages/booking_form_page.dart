import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/booking.dart';
import '../models/building.dart';
import '../models/customer.dart'; // Fixed import
import '../models/floor.dart';
import '../models/unit.dart';
import '../services/booking_service.dart';
import '../services/building_service.dart';
import '../services/customer_service.dart'; // Fixed for consistency
import '../services/floor_service.dart';
import '../services/unit_service.dart';

// --- VIOLET COLOR PALETTE ---
const Color primaryViolet = Color(0xFF673AB7);
const Color secondaryViolet = Color(0xFF9575CD);
const Color backgroundLight = Color(0xFFF5F5F5);
const Color accentRed = Color(0xFFFF6B6B);
const Color accentGreen = Color(0xFF4CAF50);
// --- END OF PALETTE ---

class BookingFormPage extends StatefulWidget {
final Booking? booking;
const BookingFormPage({Key? key, this.booking}) : super(key: key);

@override
State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
final _formKey = GlobalKey<FormState>();

// Controllers
final _amountController = TextEditingController();
final _discountController = TextEditingController();
final _downPaymentController = TextEditingController();
final _interestRateController = TextEditingController();
final _yearController = TextEditingController();

// State
DateTime? _bookingDate;
bool _isLoan = false;
bool _isLoading = false;
bool _isLoadingData = true;

// Dropdown Lists
List<Building> _buildings = [];
List<Floor> _floors = [];
List<Unit> _units = [];
List<Customer> _customers = [];

// Selected IDs for dropdowns
int? _selectedBuildingId;
int? _selectedFloorId;
int? _selectedUnitId;
int? _selectedCustomerId;

@override
void initState() {
super.initState();
_loadInitialData();
}

Future<void> _loadInitialData() async {
setState(() => _isLoadingData = true);
try {
final results = await Future.wait([BuildingService.getAllBuildings(), CustomerService.getAllCustomers()]);
if (mounted) {
setState(() {
_buildings = results[0] as List<Building>;
_customers = results[1] as List<Customer>;
});
if (widget.booking != null) await _populateForm();
}
} catch (e) {
if(mounted) _showErrorSnackBar('Failed to load initial data: $e');
} finally {
if(mounted) setState(() => _isLoadingData = false);
}
}

Future<void> _populateForm() async {
final b = widget.booking!;
_amountController.text = b.amount?.toString() ?? '';
_discountController.text = b.discount?.toString() ?? '';
_downPaymentController.text = b.downPayment?.toString() ?? '';
_interestRateController.text = b.interestRate?.toString() ?? '';
_yearController.text = b.year?.toString() ?? '';
_bookingDate = b.date;
_isLoan = b.isLoan;
_selectedCustomerId = b.customer?.id;

if (b.building?.id != null) {
await _onBuildingChanged(b.building!.id);
_selectedBuildingId = b.building!.id;
}
if (b.floor?.id != null) {
await _onFloorChanged(b.floor!.id);
_selectedFloorId = b.floor!.id;
}
_selectedUnitId = b.unit?.id;
}

Future<void> _onBuildingChanged(int? buildingId) async {
setState(() {
_selectedBuildingId = buildingId;
_selectedFloorId = null;
_selectedUnitId = null;
_floors = [];
_units = [];
});
if (buildingId != null) {
final floors = await FloorService.getFloorsByBuilding(buildingId);
if (mounted) setState(() => _floors = floors);
}
}

Future<void> _onFloorChanged(int? floorId) async {
setState(() {
_selectedFloorId = floorId;
_selectedUnitId = null;
_units = [];
});
if (floorId != null) {
final units = await UnitService.getAllUnits();
if (mounted) setState(() => _units = units);
}
}

Future<void> _saveBooking() async {
if (!_formKey.currentState!.validate()) return;
setState(() => _isLoading = true);
try {
final booking = Booking(
id: widget.booking?.id,
date: _bookingDate,
isLoan: _isLoan,
amount: double.tryParse(_amountController.text),
discount: double.tryParse(_discountController.text),
downPayment: double.tryParse(_downPaymentController.text),
interestRate: double.tryParse(_interestRateController.text),
year: int.tryParse(_yearController.text),
building: Building(id: _selectedBuildingId),
floor: Floor(id: _selectedFloorId),
unit: Unit(id: _selectedUnitId),
customer: Customer(id: _selectedCustomerId),
);

final success = widget.booking == null ? await BookingService.createBooking(booking) : await BookingService.updateBooking(booking);
if (mounted) {
_showStatusSnackBar(success ? 'Booking saved successfully' : 'Failed to save booking', success);
if (success) Navigator.pop(context, true);
}
} catch (e) {
if(mounted) _showErrorSnackBar('Error: $e');
} finally {
if(mounted) setState(() => _isLoading = false);
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
appBar: AppBar(
title: Text(widget.booking == null ? 'New Booking' : 'Edit Booking'),
backgroundColor: primaryViolet,
foregroundColor: Colors.white,
),
body: _isLoadingData
? const Center(child: CircularProgressIndicator(color: primaryViolet))
    : Form(
key: _formKey,
child: ListView(
padding: const EdgeInsets.all(24),
children: [
_buildSectionTitle('Unit Selection'),
const SizedBox(height: 16),
_buildDropdown<Building>(_buildings, _selectedBuildingId, 'Building', (val) => _onBuildingChanged(val), icon: Icons.business_rounded, validator: (v) => v == null ? 'Required' : null),
const SizedBox(height: 16),
_buildDropdown<Floor>(_floors, _selectedFloorId, 'Floor', (val) => _onFloorChanged(val), icon: Icons.layers_outlined, validator: (v) => v == null ? 'Required' : null),
const SizedBox(height: 16),
_buildDropdown<Unit>(_units, _selectedUnitId, 'Unit', (val) => setState(() => _selectedUnitId = val), icon: Icons.meeting_room_outlined, validator: (v) => v == null ? 'Required' : null),
const SizedBox(height: 24),
_buildSectionTitle('Customer & Date'),
const SizedBox(height: 16),
_buildDropdown<Customer>(_customers, _selectedCustomerId, 'Customer', (val) => setState(() => _selectedCustomerId = val), icon: Icons.person_outline, validator: (v) => v == null ? 'Required' : null),
const SizedBox(height: 16),
_buildDateSelector(),
const SizedBox(height: 24),
_buildSectionTitle('Payment Details'),
const SizedBox(height: 16),
_buildTextField(_amountController, 'Total Amount (\$)', Icons.attach_money_outlined, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
const SizedBox(height: 16),
_buildTextField(_discountController, 'Discount (\$)', Icons.local_offer_outlined, keyboardType: TextInputType.number),
const SizedBox(height: 16),
SwitchListTile(
title: const Text('Is this a Loan?'),
value: _isLoan,
onChanged: (val) => setState(() => _isLoan = val),
tileColor: Colors.white,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
activeColor: primaryViolet,
),
const SizedBox(height: 16),
Visibility(
visible: _isLoan,
child: Column(
children: [
_buildTextField(_downPaymentController, 'Down Payment (\$)', Icons.payment_outlined, keyboardType: TextInputType.number, validator: (v) => _isLoan && v!.isEmpty ? 'Required' : null),
const SizedBox(height: 16),
Row(children: [
Expanded(child: _buildTextField(_interestRateController, 'Interest Rate (%)', Icons.percent_outlined, keyboardType: TextInputType.number, validator: (v) => _isLoan && v!.isEmpty ? 'Required' : null)),
const SizedBox(width: 16),
Expanded(child: _buildTextField(_yearController, 'Years', Icons.hourglass_top_outlined, keyboardType: TextInputType.number, validator: (v) => _isLoan && v!.isEmpty ? 'Required' : null)),
]),
],
),
),
const SizedBox(height: 32),
SizedBox(
height: 56,
child: ElevatedButton.icon(
onPressed: _isLoading ? null : _saveBooking,
icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.save_outlined),
label: _isLoading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('Save Booking'),
style: ElevatedButton.styleFrom(backgroundColor: primaryViolet, foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
),
),
],
),
),
);
}

Widget _buildTextField(TextEditingController c, String label, IconData icon, {TextInputType? keyboardType, String? Function(String?)? validator}) {
return TextFormField(
controller: c,
decoration: _inputDecoration(label, icon),
keyboardType: keyboardType,
validator: validator,
);
}

Widget _buildDropdown<T>(List<dynamic> items, int? value, String hint, Function(int?) onChanged, {IconData? icon, String? Function(int?)? validator}) {
return DropdownButtonFormField<int>(
value: value,
decoration: _inputDecoration(hint, icon ?? Icons.arrow_drop_down),
items: items.map((item) => DropdownMenuItem<int>(value: item.id, child: Text(item.name ?? 'N/A'))).toList(),
onChanged: onChanged,
validator: validator,
isExpanded: true,
);
}

Widget _buildDateSelector() {
return InkWell(
onTap: () async {
final picked = await showDatePicker(context: context, initialDate: _bookingDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
if (picked != null) setState(() => _bookingDate = picked);
},
child: InputDecorator(
decoration: _inputDecoration('Booking Date', Icons.calendar_today_outlined),
child: Text(_bookingDate != null ? DateFormat.yMMMd().format(_bookingDate!) : 'Select Date', style: const TextStyle(fontSize: 16)),
),
);
}

InputDecoration _inputDecoration(String label, IconData icon) {
return InputDecoration(
labelText: label,
prefixIcon: Icon(icon, color: primaryViolet),
border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryViolet, width: 2.0)),
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

SnackBar _buildStatusSnackBar(String message, IconData icon, Color color) {
return SnackBar(content: Row(children: [Icon(icon, color: Colors.white), const SizedBox(width: 12), Text(message)]), backgroundColor: color, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)));
}
}