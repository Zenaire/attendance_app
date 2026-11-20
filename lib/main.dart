import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'screens/config_error/config_error_screen.dart';
import 'wrapper/auth_wrapper.dart';

const kSeedColor = Color(0xFF2563EB);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const AttendanceApp());
  } catch (error) {
    runApp(ConfigErrorApp(error: error));
  }
}

class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key, required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: kSeedColor, useMaterial3: true),
      home: ConfigErrorScreen(error: error),
    );
  }
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Presensi Digital',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: kSeedColor, useMaterial3: true),
      home: const AuthWrapper(),
    );
  }
}
