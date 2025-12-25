import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool isHebrew = false; // ✅ language toggle

  final TextEditingController patientIdController = TextEditingController();
  final TextEditingController doctorIdController = TextEditingController();
  final TextEditingController caregiverCodeController = TextEditingController();

  String? patientIdError;
  String? doctorIdError;
  String? caregiverCodeError;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<bool> _patientExists(String pid, String did) async {
    final doc = await _firestore.collection('patients').doc(pid).get();
    if (!doc.exists) return false;
    final data = doc.data();
    if (data == null) return false;
    return (data['doctorId'] ?? '') == did;
  }

  Future<bool> _doctorExists(String did) async {
    final doc = await _firestore.collection('doctors').doc(did).get();
    return doc.exists;
  }

  Future<void> _handleLogin(BuildContext context) async {
    setState(() {
      patientIdError = null;
      doctorIdError = null;
      caregiverCodeError = null;
    });

    bool isValid = true;

    switch (selectedRole) {
      case 'Patient':
        if (patientIdController.text.isEmpty) {
          patientIdError =
              isHebrew ? 'נדרש מזהה מטופל' : 'Patient ID is required.';
          isValid = false;
        }
        if (doctorIdController.text.isEmpty) {
          doctorIdError =
              isHebrew ? 'נדרש מזהה רופא' : 'Doctor ID is required.';
          isValid = false;
        }
        if (isValid) {
          final pid = patientIdController.text.trim();
          final did = doctorIdController.text.trim();
          final exists = await _patientExists(pid, did);
          if (exists) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PatientHomeScreen(
                  patientId: pid,
                  doctorId: did,
                ),
              ),
            );
          } else {
            setState(() {
              patientIdError = isHebrew
                  ? 'מזהה מטופל או רופא לא חוקי'
                  : 'Invalid PID or DID combination.';
              doctorIdError = isHebrew
                  ? 'מזהה מטופל או רופא לא חוקי'
                  : 'Invalid PID or DID combination.';
            });
          }
        }
        break;

      case 'Doctor':
        if (doctorIdController.text.isEmpty) {
          doctorIdError =
              isHebrew ? 'נדרש מזהה רופא' : 'Doctor ID is required.';
          isValid = false;
        }
        if (isValid) {
          final did = doctorIdController.text.trim();
          final exists = await _doctorExists(did);
          if (exists) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorHomeScreen(
                  doctorId: did,
                ),
              ),
            );
          } else {
            setState(() {
              doctorIdError =
                  isHebrew ? 'מזהה רופא לא נמצא' : 'Doctor ID not found.';
            });
          }
        }
        break;

      case 'Caregiver':
        if (caregiverCodeController.text.isEmpty) {
          caregiverCodeError =
              isHebrew ? 'נדרש קוד מטפל' : 'Caregiver Code is required.';
          isValid = false;
        }
        if (isValid) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CaregiverHomeScreen(
                caregiverId: caregiverCodeController.text.trim(),
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
    final translatedRole = {
      'Patient': isHebrew ? 'מטופל' : 'Patient',
      'Doctor': isHebrew ? 'רופא' : 'Doctor',
      'Caregiver': isHebrew ? 'מטפל' : 'Caregiver',
    }[role]!;

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
                : coolors.customColorScheme.onSurface.withOpacity(0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isSelected
              ? coolors.customColorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          translatedRole,
          style: TextStyle(
            color: isSelected
                ? coolors.customColorScheme.primary
                : coolors.customColorScheme.onSurface.withOpacity(0.7),
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
              decoration:
                  dec(isHebrew ? 'מזהה רופא' : 'Doctor ID', doctorIdError),
            ),
          ),
        if (selectedRole == 'Patient')
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextField(
              controller: patientIdController,
              onChanged: (_) => setState(() {}),
              decoration:
                  dec(isHebrew ? 'מזהה מטופל' : 'Patient ID', patientIdError),
            ),
          ),
        if (selectedRole == 'Caregiver')
          TextField(
            controller: caregiverCodeController,
            onChanged: (_) => setState(() {}),
            decoration: dec(
                isHebrew ? 'קוד מטפל מיוחד' : 'Special Caregiver Code',
                caregiverCodeError),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themed =
        Theme.of(context).copyWith(colorScheme: coolors.customColorScheme);
    final cs = themed.colorScheme;
    final size = MediaQuery.of(context).size;

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
              size.height * 0.02 + stickyAreaApproxHeight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ✅ Language toggle row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(isHebrew ? "עברית" : "English"),
                    Switch(
                      value: isHebrew,
                      onChanged: (val) {
                        setState(() => isHebrew = val);
                      },
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  isHebrew ? 'ברוך שובך' : 'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: coolors.customColorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isHebrew ? 'התחבר לחשבון שלך' : 'Sign in to your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: coolors.customColorScheme.onSurface,
                  ),
                ),
                SizedBox(height: size.height * 0.06),
                Text(
                  isHebrew ? 'בחר את התפקיד שלך' : 'Select your role',
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
                    isHebrew ? 'שכחת סיסמה?' : 'Forgot Password?',
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
        bottomNavigationBar: AuthBar(
          isEnabled: _isLoginButtonEnabled,
          onSignIn: () => _handleLogin(context),
          colorScheme: cs,
        ),
      ),
    );
  }
}
