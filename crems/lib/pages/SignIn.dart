import 'package:crems/pages/SignUp.dart';
import 'package:crems/pages/UserProfile.dart';
import 'package:crems/services/AuthService.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
const SignIn({super.key});

@override
State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
final _formKey = GlobalKey<FormState>();
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

bool _obscurePassword = true;
bool _isLoading = false;

final AuthService authService = AuthService();

@override
void dispose() {
emailController.dispose();
passwordController.dispose();
super.dispose();
}

Future<void> _signIn() async {
if (!_formKey.currentState!.validate()) return;

setState(() => _isLoading = true);

try {
await authService.login(emailController.text, passwordController.text);
if (mounted) {
Navigator.pushReplacement(
context,
MaterialPageRoute(builder: (context) => const UserProfile()),
);
}
} catch (error) {
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Login Failed: ${error.toString()}'),
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

@override
Widget build(BuildContext context) {
// Get screen dimensions for responsive sizing
final screenHeight = MediaQuery.of(context).size.height;
final screenWidth = MediaQuery.of(context).size.width;

return Scaffold(
backgroundColor: Colors.white,
body: SafeArea(
child: Center(
child: ConstrainedBox(
// **RESPONSIVE**: Constrain the width for larger screens (tablets, web)
constraints: const BoxConstraints(maxWidth: 500),
child: SingleChildScrollView(
// **RESPONSIVE**: Use dynamic horizontal padding
padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
// Give some space from the top, especially in landscape
SizedBox(height: screenHeight * 0.05),

// --- Header Section ---
Icon(
Icons.lock_open_rounded,
// **RESPONSIVE**: Icon size scales with screen height
size: screenHeight * 0.1,
color: Colors.deepPurple,
),
SizedBox(height: screenHeight * 0.02),
Text(
"Welcome Back!",
textAlign: TextAlign.center,
// **RESPONSIVE**: Use theme for adaptive text scaling
style: Theme.of(context).textTheme.headlineMedium?.copyWith(
fontWeight: FontWeight.bold,
color: Colors.black87,
),
),
SizedBox(height: screenHeight * 0.01),
Text(
"Sign in to continue to CREMS",
textAlign: TextAlign.center,
style: Theme.of(context).textTheme.titleMedium?.copyWith(
color: Colors.grey[600],
),
),
SizedBox(height: screenHeight * 0.05),

// --- Form Section ---
_buildForm(screenHeight),
SizedBox(height: screenHeight * 0.03),

// --- Sign In Button ---
_isLoading
? const Center(child: CircularProgressIndicator())
    : _buildSignInButton(),
SizedBox(height: screenHeight * 0.03),

// --- Divider and Social Logins ---
_buildDivider(),
SizedBox(height: screenHeight * 0.02),
_buildSocialLoginRow(),
SizedBox(height: screenHeight * 0.03),

// --- Sign Up Navigation ---
_buildSignUpLink(context),
SizedBox(height: screenHeight * 0.02),
],
),
),
),
),
),
);
}

// --- Helper Widgets for Cleaner Build Method ---

Widget _buildForm(double screenHeight) {
return Form(
key: _formKey,
child: Column(
children: [
TextFormField(
controller: emailController,
keyboardType: TextInputType.emailAddress,
decoration: _buildInputDecoration(
labelText: "Email",
prefixIcon: Icons.email_outlined,
),
validator: (value) {
if (value == null || value.isEmpty) return 'Please enter your email';
if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
return 'Please enter a valid email address';
}
return null;
},
),
// **RESPONSIVE**: Dynamic spacing
SizedBox(height: screenHeight * 0.025),
TextFormField(
controller: passwordController,
obscureText: _obscurePassword,
decoration: _buildInputDecoration(
labelText: "Password",
prefixIcon: Icons.lock_outline_rounded,
suffixIcon: IconButton(
onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
icon: Icon(
_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
),
),
),
validator: (value) {
if (value == null || value.isEmpty) return 'Please enter your password';
return null;
},
),
],
),
);
}

Widget _buildSignInButton() {
return ElevatedButton(
onPressed: _signIn,
style: ElevatedButton.styleFrom(
backgroundColor: Colors.deepPurple,
padding: const EdgeInsets.symmetric(vertical: 16.0),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
),
child: const Text(
"Sign In",
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
color: Colors.white,
),
),
);
}

InputDecoration _buildInputDecoration({
required String labelText,
required IconData prefixIcon,
Widget? suffixIcon,
}) {
return InputDecoration(
labelText: labelText,
prefixIcon: Icon(prefixIcon),
suffixIcon: suffixIcon,
border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(12.0),
borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
),
filled: true,
fillColor: Colors.grey[50],
);
}

Widget _buildDivider() {
return const Row(
children: [
Expanded(child: Divider(thickness: 1)),
Padding(
padding: EdgeInsets.symmetric(horizontal: 10.0),
child: Text("OR", style: TextStyle(color: Colors.grey)),
),
Expanded(child: Divider(thickness: 1)),
],
);
}

Widget _buildSocialLoginRow() {
return Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
_buildSocialLoginButton(
imageUrl: 'https://cdn-icons-png.flaticon.com/512/281/281764.png',
onPressed: () { /* TODO: Implement Google Sign In */ },
),
const SizedBox(width: 20),
_buildSocialLoginButton(
imageUrl: 'https://cdn-icons-png.flaticon.com/512/731/731985.png',
onPressed: () { /* TODO: Implement Apple Sign In */ },
),
const SizedBox(width: 20),
_buildSocialLoginButton(
imageUrl: 'https://cdn-icons-png.flaticon.com/512/145/145802.png',
onPressed: () { /* TODO: Implement Facebook Sign In */ },
),
],
);
}

Widget _buildSocialLoginButton({required String imageUrl, required VoidCallback onPressed}) {
return InkWell(
onTap: onPressed,
borderRadius: BorderRadius.circular(12),
child: Container(
padding: const EdgeInsets.all(12.0),
decoration: BoxDecoration(
border: Border.all(color: Colors.grey.shade300),
borderRadius: BorderRadius.circular(12.0),
),
child: Image.network(
imageUrl,
height: 40,
width: 40,
errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
loadingBuilder: (context, child, loadingProgress) {
if (loadingProgress == null) return child;
return const SizedBox(
height: 40, width: 40,
child: CircularProgressIndicator(),
);
},
),
),
);
}

Widget _buildSignUpLink(BuildContext context) {
return Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Text("Don't have an account?"),
TextButton(
onPressed: () => Navigator.push(
context,
MaterialPageRoute(builder: (context) => const SignUp()),
),
child: const Text(
"Sign Up",
style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
),
),
],
);
}
}