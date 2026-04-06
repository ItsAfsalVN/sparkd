import 'package:sparkd/features/orders/domain/repository/workshop_repository.dart';

class DownloadWorkshopFileUseCase {
  final WorkshopRepository _repository;

  DownloadWorkshopFileUseCase({required WorkshopRepository repository})
    : _repository = repository;

  Future<String> call({
    required String fileUrl,
    required String fileName,
  }) async {
    return await _repository.downloadWorkshopFile(
      fileUrl: fileUrl,
      fileName: fileName,
    );
  }
}
