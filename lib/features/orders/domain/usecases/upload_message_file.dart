import 'package:file_picker/file_picker.dart';
import 'package:sparkd/features/orders/domain/repository/upload_file_repository.dart';

class UploadMessageFile {
  final UploadFileRepository _repository;
  UploadMessageFile({required UploadFileRepository repository})
    : _repository = repository;

  Future<String> call(String userId, PlatformFile file) async {
    try {
      final fileUrl = await _repository.uploadFile(userId: userId, file: file);
      return fileUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
}
