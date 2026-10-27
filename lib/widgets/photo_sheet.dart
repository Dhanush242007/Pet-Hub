import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/photo_service.dart';

class PhotoAction {
  final XFile? file;
  final bool remove;
  const PhotoAction.pick(this.file) : remove = false;
  const PhotoAction.remove()
      : file = null,
        remove = true;
}

/// Bottom sheet: gallery / camera / remove. Returns null if cancelled.
Future<PhotoAction?> showPhotoSheet(
  BuildContext context, {
  required bool hasPhoto,
}) async {
  final choice = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(ctx, 'gallery'),
          ),
          if (!kIsWeb)
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
          if (hasPhoto)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Remove photo'),
              onTap: () => Navigator.pop(ctx, 'remove'),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  if (choice == null) return null;
  if (choice == 'remove') return const PhotoAction.remove();

  final file = await PhotoService().pick(
    choice == 'camera' ? ImageSource.camera : ImageSource.gallery,
  );
  if (file == null) return null;
  return PhotoAction.pick(file);
}