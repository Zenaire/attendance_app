import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/attendance_record.dart';
import '../../services/attendance_service.dart';
import '../../services/auth_services.dart';
import '../../services/storage_services.dart';
import '../history/history_screen.dart';
import 'widgets/attendance_card.dart';
import 'widgets/camera_button.dart';
import 'widgets/profile_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.authServices,
    this.attendanceService,
    this.photoStorage,
  });

  final AuthServices authServices;
  final AttendanceService? attendanceService;
  final PhotoStorage? photoStorage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final AttendanceService _attendance;
  late final PhotoStorage _photos;
  StreamSubscription<AttendanceRecord?>? _subscription;
  AttendanceRecord? _today;
  bool _loading = false;
  String? _streamError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _attendance = widget.attendanceService ?? AttendanceService();
    _photos = widget.photoStorage ?? StorageServices();
    _listen();
  }

  void _listen() {
    _subscription?.cancel();
    final uid = widget.authServices.currentUser?.uid;
    if (uid == null) {
      setState(
        () => _streamError = 'Sesi akun tidak ditemukan. Masuk kembali.',
      );
      return;
    }
    _subscription = _attendance
        .getTodayRecordStream(uid)
        .listen(
          (record) {
            if (!mounted) return;
            setState(() {
              _today = record;
              _streamError = null;
            });
          },
          onError: (Object error) {
            if (!mounted) return;
            setState(() => _streamError = 'Gagal memuat presensi: $error');
          },
        );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _listen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _checkIn(String sourcePath) async {
    final uid = widget.authServices.currentUser?.uid;
    if (uid == null) {
      _snack('Sesi akun tidak ditemukan. Masuk kembali.');
      await widget.authServices.signOut();
      return;
    }
    setState(() => _loading = true);
    try {
      final photoPath = await _photos.savePhoto(sourcePath, 'checkin');
      final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day);
      final record = AttendanceRecord(
        id: now.microsecondsSinceEpoch.toString(),
        userId: uid,
        checkInTime: now,
        date: date,
        checkInPhotoPath: photoPath,
      );
      await _attendance.createAttendanceRecord(record);
      _snack('Presensi masuk berhasil disimpan');
    } catch (error) {
      _snack('Gagal menyimpan presensi masuk: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checkOut(String sourcePath) async {
    final uid = widget.authServices.currentUser?.uid;
    if (uid == null) {
      _snack('Sesi akun tidak ditemukan. Masuk kembali.');
      await widget.authServices.signOut();
      return;
    }
    if (_today == null || _today!.checkOutTime != null) return;
    setState(() => _loading = true);
    try {
      final photoPath = await _photos.savePhoto(sourcePath, 'checkout');
      final updated = _today!.copyWith(
        checkOutTime: DateTime.now(),
        checkOutPhotoPath: photoPath,
      );
      await _attendance.updateAttendanceRecord(updated);
      _snack('Presensi pulang berhasil disimpan');
    } catch (error) {
      _snack('Gagal menyimpan presensi pulang: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirm == true) await widget.authServices.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.authServices.currentUser?.email ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presensi Digital'),
        actions: [
          IconButton(
            onPressed: _logout,
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ProfileCard(email: email),
            const SizedBox(height: 12),
            if (_streamError != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_streamError!),
                ),
              ),
            AttendanceCard(record: _today),
            const SizedBox(height: 12),
            if (_today == null)
              CameraButton(
                label: 'Masuk',
                loading: _loading,
                onCaptured: _checkIn,
              )
            else if (_today!.checkOutTime == null)
              CameraButton(
                label: 'Pulang',
                loading: _loading,
                onCaptured: _checkOut,
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(
                    authServices: widget.authServices,
                    attendanceService: _attendance,
                  ),
                ),
              ),
              icon: const Icon(Icons.history),
              label: const Text('Riwayat'),
            ),
          ],
        ),
      ),
    );
  }
}
