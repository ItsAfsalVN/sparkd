class FileUploadEntity {
  final String fileName;
  final String fileUrl;
  final int fileSize;
  final DateTime uploadedAt;

  const FileUploadEntity({
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.uploadedAt,
  });
}