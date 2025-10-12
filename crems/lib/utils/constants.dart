class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:8080/api';
  static const String imageBaseUrl = 'http://localhost:8080/images';
  static const String authEndpoint = '/auth';
  static const String employeeEndpoint = '/employees';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Common Roles (Used for both User and Employee)
  static const List<String> roles = [
    'ADMIN',
    'PROJECT_MANAGER',
    'SITE_MANAGER',
    'LABOUR',
  ];

  // Salary Types
  static const List<String> salaryTypes = [
    'Daily',
    'Monthly',
    'Contract',
  ];

  // Countries List
  static const List<String> countries = [
    'Afghanistan',
    'Albania',
    'Algeria',
    'Argentina',
    'Australia',
    'Austria',
    'Bangladesh',
    'Belgium',
    'Brazil',
    'Canada',
    'Chile',
    'China',
    'Colombia',
    'Denmark',
    'Egypt',
    'Finland',
    'France',
    'Germany',
    'Greece',
    'India',
    'Indonesia',
    'Iran',
    'Iraq',
    'Ireland',
    'Italy',
    'Japan',
    'Jordan',
    'Kenya',
    'Kuwait',
    'Lebanon',
    'Malaysia',
    'Mexico',
    'Morocco',
    'Netherlands',
    'New Zealand',
    'Nigeria',
    'Norway',
    'Oman',
    'Pakistan',
    'Palestine',
    'Philippines',
    'Poland',
    'Portugal',
    'Qatar',
    'Russia',
    'Saudi Arabia',
    'Singapore',
    'South Africa',
    'South Korea',
    'Spain',
    'Sri Lanka',
    'Sudan',
    'Sweden',
    'Switzerland',
    'Syria',
    'Thailand',
    'Turkey',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'Vietnam',
    'Yemen',
  ];

  // Helper method to format role for display
  static String formatRole(String role) {
    return role.replaceAll('_', ' ');
  }

  // Helper method to get role key from display name
  static String getRoleKey(String displayName) {
    return displayName.replaceAll(' ', '_').toUpperCase();
  }
}