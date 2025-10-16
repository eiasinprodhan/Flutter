import 'package:dreampainter/constants/app_colors.dart';
import 'package:dreampainter/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dream Painter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.cardBackground,
          foregroundColor: AppColors.primaryText,
          elevation: 1.0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          titleTextStyle: GoogleFonts.pacifico(
            fontSize: 28,
            color: AppColors.primary,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}