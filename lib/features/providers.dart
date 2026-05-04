import 'package:flutter_riverpod/flutter_riverpod.dart';
final userIdProvider = StateProvider<int?>((ref) => null);
final userRoleProvider = StateProvider<String?>((ref) => null);
final baseUrlProvider = Provider<String>((ref) {
  return "http://192.168.1.4:3000"; // change here only
});
