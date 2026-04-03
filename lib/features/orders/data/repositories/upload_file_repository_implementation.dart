import 'package:file_picker/file_picker.dart';
import 'package:sparkd/features/orders/data/datasources/upload_file_remote_repository.dart';
import 'package:sparkd/features/orders/domain/repository/upload_file_repository.dart';

class UploadFileRepositoryImplementation implements UploadFileRepository{
  final UploadFileRemoteRepository _remoteRepository;
  UploadFileRepositoryImplementation({required UploadFileRemoteRepository remoteRepository})
    : _remoteRepository = remoteRepository;

  @override
  Future<String> uploadFile({required String userId, required PlatformFile file}) {
    return _remoteRepository.uploadFile(userId: userId, file: file);
  }

}