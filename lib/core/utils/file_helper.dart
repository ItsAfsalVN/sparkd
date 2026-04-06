// Helper methods
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

String _getFileExtension(String fileName) {
  return fileName.split('.').last.toLowerCase();
}

IconData _getFileIcon(String fileName) {
  final ext = _getFileExtension(fileName);
  switch (ext) {
    case 'pdf':
      return Icons.picture_as_pdf;
    case 'doc':
    case 'docx':
      return Icons.description;
    case 'xls':
    case 'xlsx':
      return Icons.table_chart;
    case 'ppt':
    case 'pptx':
      return Icons.slideshow;
    case 'zip':
    case 'rar':
      return Icons.folder_zip;
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
    case 'webp':
      return Icons.image;
    case 'mp4':
    case 'avi':
    case 'mov':
      return Icons.video_file;
    case 'mp3':
    case 'wav':
    case 'flac':
      return Icons.audio_file;
    case 'txt':
      return Icons.text_fields;
    default:
      return Icons.insert_drive_file;
  }
}

bool _isImage(String fileName) {
  final ext = _getFileExtension(fileName);
  return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
}

String _formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

Future<String> _getCacheFilePath(String fileName) async {
  final directory = await getApplicationCacheDirectory();
  final cacheDir = Directory('${directory.path}/workshop_files');

  if (!await cacheDir.exists()) {
    await cacheDir.create(recursive: true);
  }

  return '${cacheDir.path}/$fileName';
}

Future<bool> _fileExistsInCache(String fileName) async {
  final path = await _getCacheFilePath(fileName);
  return File(path).exists();
}

String _getFileNameFromUrl(String url) {
  return url.split('/').last.split('?').first;
}

class FileHelper {
  static IconData getFileIcon(String fileName) => _getFileIcon(fileName);
  static bool isImage(String fileName) => _isImage(fileName);
  static String formatFileSize(int bytes) => _formatFileSize(bytes);
  static String getFileName(String fileUrl) {
    return fileUrl.split('/').last.split('?').first;
  }

  static String getFileExtension(String fileName) =>
      _getFileExtension(fileName);
  static Future<String> getCacheFilePath(String fileName) =>
      _getCacheFilePath(fileName);
  static Future<bool> fileExistsInCache(String fileName) =>
      _fileExistsInCache(fileName);
  static String getFileNameFromUrl(String url) => _getFileNameFromUrl(url);
}
