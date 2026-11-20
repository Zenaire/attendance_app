import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_services.dart';
import 'widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.authServices});
  final AuthServices authServices;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_email.text.trim().isEmpty) {
      _snack('Email wajib diisi');
      return;
    }
    if (_password.text.length < 6) {
      _snack('Kata sandi minimal 6 karakter');
      return;
    }
    if (_confirmation.text != _password.text) {
      _snack('Konfirmasi kata sandi tidak sama');
      return;
    }
    setState(() => _loading = true);
    try {
      await widget.authServices.registerWithEmailAndPassword(
        _email.text.trim(),
        _password.text,
      );
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _snack('Gagal mendaftar: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      _snack('Gagal mendaftar: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar akun')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            AuthTextField(label: 'Email', controller: _email),
            const SizedBox(height: 16),
            AuthTextField(
              label: 'Kata sandi',
              controller: _password,
              obscureText: _obscure,
              onToggle: () => setState(() => _obscure = !_obscure),
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: 'Konfirmasi kata sandi',
              controller: _confirmation,
              obscureText: _obscure,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Daftar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
