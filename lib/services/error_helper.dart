import 'package:supabase_flutter/supabase_flutter.dart';

String friendlyError(Object e) {
  if (e is PostgrestException) {
    if (e.code == '23514') {
      return 'Some values are not allowed. Check the phone number (10-13 digits) and the dates.';
    }
    if (e.code == '42501') return 'You do not have permission to do that.';
    return e.message;
  }
  if (e is StorageException) {
    return 'Photo problem: ${e.message}. Photos must be JPG, PNG or WEBP under 5 MB.';
  }
  if (e is AuthException) return e.message;
  return 'Something went wrong. Check your internet and try again.';
}