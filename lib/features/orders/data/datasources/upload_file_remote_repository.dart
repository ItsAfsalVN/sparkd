import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class UploadFileRemoteRepository {
  Future<String> uploadFile({
    required String userId,
    required PlatformFile file,
  });
}

class UploadFileRemoteRepositoryImplementation
    implements UploadFileRemoteRepository {
  @override
  Future<String> uploadFile({
    required String userId,
    required PlatformFile file,
  }) async {
    if (file.size > 10 * 1024 * 1024) {
      throw Exception('File size exceeds the maximum limit of 10MB');
    }
    try {
      final timeStamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${timeStamp}_${file.name}';
      // Upload to Firebase Storage
      final reference = FirebaseStorage.instance.ref().child(
        'orders/$userId/$fileName',
      );

      // Handle both in-memory bytes and file path
      late UploadTask uploadTask;
      if (file.bytes != null) {
        // If bytes are available, upload directly
        uploadTask = reference.putData(file.bytes!);
      } else if (file.path != null) {
        // If bytes are not available, read from file path
        final fileToUpload = File(file.path!);
        uploadTask = reference.putFile(fileToUpload);
      } else {
        throw Exception('File has no bytes or path available');
      }

      await uploadTask;

      final downloadUrl = await reference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
}
