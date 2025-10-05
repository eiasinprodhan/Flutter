import 'dart:io';
import 'dart:typed_data';

import 'package:crems/pages/SignIn.dart';
import 'package:crems/services/EmployeeService.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController salary = TextEditingController();
  final TextEditingController nid = TextEditingController();
  final TextEditingController address = TextEditingController();

  DateTime? selectedJoiningDate;
  final joiningDate = DateTimeFieldPickerPlatform.material;

  List<String> salaryTypes = ['Daily', 'Monthly', 'Contract'];
  String? selectedSalaryType;

  List<String> roles = ['ADMIN', 'PROJECT_MANAGER', 'SITE_MANAGER', 'LABOUR'];
  String? selectedRole;

  List<String> countries = ['India', 'United States of America', 'Canada', 'Australia', 'Bangladesh', 'United Kingdom', 'Nepal', 'Germany', 'France', 'Other'];
  String? selectedCountry;

  Uint8List? webImage;
  XFile? selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          "Sign Up",
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(name, "Name", Icons.person),
                SizedBox(height: 20.0),
                _buildTextField(email, "Email", Icons.email),
                SizedBox(height: 20.0),
                _buildTextField(phone, "Phone", Icons.phone),
                SizedBox(height: 20.0),

                _buildPasswordField(
                  controller: password,
                  label: "Password",
                  icon: Icons.lock,
                  obscure: _obscurePassword,
                  toggle: () => setState(() {
                    _obscurePassword = !_obscurePassword;
                  }),
                ),
                SizedBox(height: 20.0),

                _buildPasswordField(
                  controller: confirmPassword,
                  label: "Confirm Password",
                  icon: Icons.lock_outline,
                  obscure: _obscureConfirmPassword,
                  toggle: () => setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  }),
                ),
                SizedBox(height: 20.0),

                DateTimeFormField(
                  decoration: InputDecoration(
                    labelText: "Joining Date",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  mode: DateTimeFieldPickerMode.date,
                  pickerPlatform: joiningDate,
                  onChanged: (value) {
                    setState(() {
                      selectedJoiningDate = value;
                    });
                  },
                ),
                SizedBox(height: 20.0),

                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: "Role",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: roles.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRole = newValue;
                    });
                  },
                  validator: (value) =>
                  value == null ? 'Please select a role' : null,
                ),
                SizedBox(height: 20.0),

                DropdownButtonFormField<String>(
                  value: selectedSalaryType,
                  decoration: InputDecoration(
                    labelText: "Salary Type",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.monetization_on_outlined),
                  ),
                  items: salaryTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSalaryType = newValue;
                    });
                  },
                  validator: (value) =>
                  value == null ? 'Please select a salary type' : null,
                ),
                SizedBox(height: 20.0),

                TextField(
                  controller: salary,
                  decoration: InputDecoration(
                    labelText: 'Salary',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.monetization_on),
                    alignLabelWithHint: true,
                  ),
                ),
                SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: selectedCountry,
                  decoration: InputDecoration(
                    labelText: "Country",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.language),
                  ),
                  items: countries.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCountry = newValue;
                    });
                  },
                  validator: (value) =>
                  value == null ? 'Please select a country' : null,
                ),
                SizedBox(height: 20.0),

                TextField(
                  controller: nid,
                  decoration: InputDecoration(
                    labelText: 'NID',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.credit_card_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Profile Image",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: pickImage,
                  child: Card(
                    elevation: 3,
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: (kIsWeb && webImage != null)
                            ? Image.memory(webImage!, fit: BoxFit.cover)
                            : (!kIsWeb && selectedImage != null)
                            ? Image.file(
                          File(selectedImage!.path),
                          fit: BoxFit.cover,
                        )
                            : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Tap to upload",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                TextField(
                  controller: address,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.maps_home_work_rounded),
                    alignLabelWithHint: true,
                  ),
                ),
                SizedBox(height: 50),

                ElevatedButton(
                  onPressed: _registerEmployee,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                  ),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: GoogleFonts.lato().fontFamily,
                    ),
                  ),
                ),
                SizedBox(height: 25.0),

                Text("Do You Already Have An Account?"),
                SizedBox(height: 25.0),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignIn()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                  ),
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: GoogleFonts.lato().fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(
          onPressed: toggle,
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    if (kIsWeb) {
      var pickedImage = await ImagePickerWeb.getImageAsBytes();
      if (pickedImage != null) {
        setState(() {
          webImage = pickedImage;
        });
      }
    } else {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedImage != null) {
        setState(() {
          selectedImage = pickedImage;
        });
      }
    }
  }

  void _registerEmployee() async {
    if (_formKey.currentState!.validate()) {
      if (password.text != confirmPassword.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Passwords do not match.")),
        );
        return;
      }

      if ((kIsWeb && webImage == null) || (!kIsWeb && selectedImage == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select an image.")),
        );
        return;
      }

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

      bool success = false;

      if (kIsWeb && webImage != null) {
        success = await employeeService.registerEmployee(
          user: user,
          employee: employee,
          photoBytes: webImage!,
        );
      } else if (selectedImage != null) {
        success = await employeeService.registerEmployee(
          user: user,
          employee: employee,
          photoFile: File(selectedImage!.path),
        );
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Successful.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Failed.')),
        );
      }
    }
  }
}
