import 'package:flutter/material.dart';
import '../patient/home/home.dart';
import '../caregiver/home.dart';
import '../doctor/home.dart';
import 'package:hackto/coolors.dart' as coolors;
import 'bottom_navbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedRole = 'Patient';

  final TextEditingController patientIdController = TextEditingController();
  final TextEditingController doctorIdController = TextEditingController();
  final TextEditingController caregiverCodeController = TextEditingController();

  String? patientIdError;
  String? doctorIdError;
  String? caregiverCodeError;

  @override
  void dispose() {
    patientIdController.dispose();
    doctorIdController.dispose();
    caregiverCodeController.dispose();
    super.dispose();
  }

  bool get _isLoginButtonEnabled {
    switch (selectedRole) {
      case 'Patient':
        return patientIdController.text.isNotEmpty &&
            doctorIdController.text.isNotEmpty;
      case 'Doctor':
        return doctorIdController.text.isNotEmpty;
      case 'Caregiver':
        return caregiverCodeController.text.isNotEmpty;
      default:
        return false;
    }
  }

  void _handleLogin(BuildContext context) {
    setState(() {
      patientIdError = null;
      doctorIdError = null;
      caregiverCodeError = null;
    });

    bool isValid = true;

    switch (selectedRole) {
      case 'Patient':
        if (patientIdController.text.isEmpty) {
          patientIdError = 'Patient ID is required.';
          isValid = false;
        }
        if (doctorIdController.text.isEmpty) {
          doctorIdError = 'Doctor ID is required.';
          isValid = false;
        }
        if (isValid) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PatientHomeScreen(
                patientId: patientIdController.text,
                doctorId: doctorIdController.text,
              ),
            ),
          );
        }
        break;
      case 'Doctor':
        if (doctorIdController.text.isEmpty) {
          doctorIdError = 'Doctor ID is required.';
          isValid = false;
        }
        if (isValid) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorHomeScreen(
                doctorId: doctorIdController.text,
              ),
            ),
          );
        }
        break;
      case 'Caregiver':
        if (caregiverCodeController.text.isEmpty) {
          caregiverCodeError = 'Caregiver Code is required.';
          isValid = false;
        }
        if (isValid) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CaregiverHomeScreen(
                caregiverId: caregiverCodeController.text,
              ),
            ),
          );
        }
        break;
    }
    setState(() {});
  }

  Widget _buildRoleButton(BuildContext context, String role) {
    final bool isSelected = selectedRole == role;
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            selectedRole = role;
            patientIdError = null;
            doctorIdError = null;
            caregiverCodeError = null;
          });
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isSelected
                ? coolors.customColorScheme.primary
                : coolors.customColorScheme.onSurface.withValues(alpha: 0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isSelected
              ? coolors.customColorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          role,
          style: TextStyle(
            color: isSelected
                ? coolors.customColorScheme.primary
                : coolors.customColorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginFields(BuildContext context) {
    InputDecoration dec(String label, String? error) => InputDecoration(
          labelText: label,
          errorText: error,
          filled: true,
          fillColor: coolors.customColorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        );

    return Column(
      children: [
        if (selectedRole == 'Patient' || selectedRole == 'Doctor')
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextField(
              controller: doctorIdController,
              onChanged: (_) => setState(() {}),
              decoration: dec('Doctor ID', doctorIdError),
            ),
          ),
        if (selectedRole == 'Patient')
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextField(
              controller: patientIdController,
              onChanged: (_) => setState(() {}),
              decoration: dec('Patient ID', patientIdError),
            ),
          ),
        if (selectedRole == 'Caregiver')
          TextField(
            controller: caregiverCodeController,
            onChanged: (_) => setState(() {}),
            decoration: dec('Special Caregiver Code', caregiverCodeError),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Apply your custom ColorScheme app-wide within this screen
    final themed =
        Theme.of(context).copyWith(colorScheme: coolors.customColorScheme);
    final cs = themed.colorScheme;
    final size = MediaQuery.of(context).size;

    // Height of the sticky bottom area (button + sign up). Used to pad the scroll view.
    const double stickyAreaApproxHeight = 120;

    return Theme(
      data: themed,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: coolors.customColorScheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              size.width * 0.08,
              size.height * 0.04,
              size.width * 0.08,
              // Extra bottom padding so last field isn't hidden behind the sticky bar
              size.height * 0.02 + stickyAreaApproxHeight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: size.height * 0.06),
                Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: coolors.customColorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: coolors.customColorScheme.onSurface,
                  ),
                ),
                SizedBox(height: size.height * 0.06),
                Text(
                  'Select your role',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: coolors.customColorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildRoleButton(context, 'Patient'),
                    const SizedBox(width: 10),
                    _buildRoleButton(context, 'Doctor'),
                    const SizedBox(width: 10),
                    _buildRoleButton(context, 'Caregiver'),
                  ],
                ),
                SizedBox(height: size.height * 0.04),
                _buildLoginFields(context),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: coolors.customColorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Sticky bottom bar (stays visible; lifts above keyboard)
        bottomNavigationBar: AuthBar(
          isEnabled: _isLoginButtonEnabled,
          onSignIn: () => _handleLogin(context),
          colorScheme: cs,
        ),
      ),
    );
  }
}
