import 'package:file_picker/file_picker.dart';

abstract class UploadFileRepository {
  Future<String> uploadFile({
    required String userId,
    required PlatformFile file,
  });
}
