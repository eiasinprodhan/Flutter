import 'dart:io';
import 'package:code/page/loginpage.dart';
import 'package:code/service/authservice.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:radio_group_v2/radio_group_v2.dart';
import 'package:radio_group_v2/radio_group_v2.dart' as v2;

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  bool _obscurePassword = true;

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController cell = TextEditingController();
  final TextEditingController address = TextEditingController();

  final RadioGroupController genderController = RadioGroupController();

  final DateTimeFieldPickerPlatform dob = DateTimeFieldPickerPlatform.material;

  String? selectedGender;

  DateTime? selectedDOB;

  XFile? selectedImage;

  Uint8List? webImage;

  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                TextField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),

                SizedBox(height: 20.0),

                TextField(
                  controller: email,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                ),

                SizedBox(height: 20.0),

                TextField(
                  obscureText: _obscurePassword,
                  controller: password,
                  decoration: InputDecoration(
                    labelText: 'Password ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),

                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                SizedBox(height: 20),
                TextField(
                  controller: confirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),

                SizedBox(height: 20),
                TextField(
                  controller: cell,
                  decoration: InputDecoration(
                    labelText: 'Cell Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: address,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.maps_home_work_rounded),
                  ),
                ),
                SizedBox(height: 20),

                DateTimeFormField(
                  decoration: const InputDecoration(labelText: 'Date of Birth'),

                  mode: DateTimeFieldPickerMode.date,
                  pickerPlatform: dob,

                  onChanged: (DateTime? value) {
                    setState(() {
                      selectedDOB = value;
                    });
                  },
                ),

                SizedBox(height: 20),

                // Gender Selection
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Gender:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      v2.RadioGroup(
                        controller: genderController,
                        values: const ["Male", "Female", "Other"],
                        indexOfDefault: 2,
                        orientation: RadioGroupOrientation.horizontal,
                        onChanged: (newValue) {
                          setState(() {
                            selectedGender = newValue.toString();
                          });
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.0),


                TextButton.icon(
                  icon: Icon(Icons.image),
                  label: Text('Upload Image'),
                  onPressed: pickImage,
                ),
                // Display selected image preview
                if (kIsWeb && webImage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.memory(
                      webImage!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  if (!kIsWeb && selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(
                        File(selectedImage!.path),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),

                    ),



                SizedBox(height: 20.0),

                ElevatedButton(
                  onPressed: () {
                    _register();
                  },
                  child: Text(
                    "Registration",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: GoogleFonts.lato().fontFamily,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20.0),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
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




  Future<void> pickImage() async {
    if (kIsWeb) {
      // For Web: Use image_picker_web to pick image and store as bytes
      var pickedImage = await ImagePickerWeb.getImageAsBytes();
      if (pickedImage != null) {
        setState(() {
          webImage = pickedImage; // Store the picked image as Uint8List
        });
      }
    } else {
      // For Mobile: Use image_picker to pick image
      final XFile? pickedImage =
      await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          selectedImage = pickedImage;
        });
      }
    }
  }



  // void _register() async {
  //   if (_formKey.currentState!.validate()) {
  //     if (password.text != confirmPassword.text) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Passwords do not match!')),
  //       );
  //       return;
  //     }
  //
  //     // Validate image selection
  //     if (kIsWeb) {
  //       if (webImage == null) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Please select an image.')),
  //         );
  //         return;
  //       }
  //     } else {
  //       if (selectedImage == null) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Please select an image.')),
  //         );
  //         return;
  //       }
  //     }
  //
  //     final user = {
  //       "name": name.text,
  //       "email": email.text,
  //       "phone": cell.text,
  //       "password": password.text,
  //     };
  //
  //     final jobSeeker = {
  //       "name": name.text,
  //       "email": email.text,
  //       "phone": cell.text,
  //       "gender": selectedGender ?? "Other",
  //       "address": address.text,
  //       "dateOfBirth": selectedDOB?.toIso8601String() ?? "",
  //     };
  //
  //     final apiService = AuthService();
  //     bool success = false;
  //
  //     if (kIsWeb && webImage != null) {
  //       success = await apiService.registerJobSeekerWeb(
  //         user: user,
  //         jobSeeker: jobSeeker,
  //         photoBytes: webImage!, // safe because checked above
  //       );
  //     } else if (selectedImage != null) {
  //       success = await apiService.registerJobSeekerWeb(
  //         user: user,
  //         jobSeeker: jobSeeker,
  //         photoFile: File(selectedImage!.path), // safe because checked above
  //       );
  //     }
  //
  //     if (success) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Registration Successful')),
  //       );
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => LoginPage()),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Registration Failed')),
  //       );
  //     }
  //   }
  // }


  /// Method to handle Job Seeker registration
  void _register() async {
    // ✅ Check if the form (text fields) is valid
    if (_formKey.currentState!.validate()) {
      // ✅ Check if password and confirm password match
      if (password.text != confirmPassword.text) {
        // Show an error message if passwords don’t match
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Passwords do not match!')),
        );
        return; // stop further execution
      }

      // ✅ Validate that the user has selected an image
      if (kIsWeb) {
        // On Web → check if webImage (Uint8List) is selected
        if (webImage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please select an image.')),
          );
          return; // stop further execution
        }
      } else {
        // On Mobile/Desktop → check if image file is selected
        if (selectedImage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please select an image.')),
          );
          return; // stop further execution
        }
      }

      // ✅ Prepare User object (basic login info)
      final user = {
        "name": name.text,
        "email": email.text,
        "phone": cell.text,
        "password": password.text,
      };

      // ✅ Prepare JobSeeker object (extra personal info)
      final jobSeeker = {
        "name": name.text,
        "email": email.text,
        "phone": cell.text,
        "gender": selectedGender ?? "Other",
        // fallback if null
        "address": address.text,
        "dateOfBirth": selectedDOB?.toIso8601String() ?? "",
        // convert DateTime to ISO string
      };

      // ✅ Initialize your API Service
      final apiService = AuthService();

      // ✅ Track API call success or failure
      bool success = false;

      // ✅ Send registration request (different handling for Web vs Mobile)
      if (kIsWeb && webImage != null) {
        // For Web → send photo as bytes
        success = await apiService.registerJobSeekerWeb(
          user: user,
          jobSeeker: jobSeeker,
          photoBytes: webImage!, // safe to use ! because already checked above
        );
      } else if (selectedImage != null) {
        // For Mobile → send photo as file
        success = await apiService.registerJobSeekerWeb(
          user: user,
          jobSeeker: jobSeeker,
          photoFile: File(selectedImage!
              .path), // safe to use ! because already checked above
        );
      }

      // ✅ Handle the API response
      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Successful')),
        );

        // Redirect user to Login Page after successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        // Show error message if regi

      }
    }
  }



}
