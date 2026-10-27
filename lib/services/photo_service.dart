import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';


class PhotoService {
  static const String bucket = 'pet-photos';
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pick(ImageSource source) {
    return _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
  }

  String _ext(String name) {
    final i = name.lastIndexOf('.');
    if (i == -1) return 'jpg';
    final e = name.substring(i + 1).toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp'].contains(e) ? e : 'jpg';
  }

  /// Uploads into a folder named after the logged-in user (required by the
  /// storage policy) and returns the public link.
  Future<String> upload(String petId, XFile file) async {
    final uid = supabase.auth.currentUser!.id;
    final bytes = await file.readAsBytes();

    var ext = _ext(file.name);
    final mt = file.mimeType;
    if (mt == 'image/png') ext = 'png';
    if (mt == 'image/webp') ext = 'webp';
    if (mt == 'image/jpeg') ext = 'jpg';

    final contentType = ext == 'png'
        ? 'image/png'
        : ext == 'webp'
            ? 'image/webp'
            : 'image/jpeg';

    final path = '$uid/${petId}_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await supabase.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType),
        );
    return supabase.storage.from(bucket).getPublicUrl(path);
  }

  /// Deletes an old photo file. Never throws (a leftover file is harmless).
  Future<void> deleteByUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final marker = '/$bucket/';
    final i = url.indexOf(marker);
    if (i == -1) return;
    final path = Uri.decodeComponent(url.substring(i + marker.length));
    try {
      await supabase.storage.from(bucket).remove([path]);
    } catch (_) {}
  }
}