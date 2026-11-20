import 'package:attendance_app/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serialisasi dan deserialisasi UserProfile', () {
    final profile = UserProfile(
      id: 'uid',
      email: 'user@example.com',
      fullName: 'Pengguna',
      createdAt: DateTime(2026, 11, 12),
    );
    final json = profile.toJson();
    expect(json['full_name'], 'Pengguna');
    expect(json['role'], 'Pengguna');
    final copy = UserProfile.fromJson(json);
    expect(copy.id, 'uid');
    expect(copy.email, 'user@example.com');
  });
}
