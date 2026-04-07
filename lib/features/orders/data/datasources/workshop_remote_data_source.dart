import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sparkd/features/orders/data/models/workshop_message_model.dart';
import 'package:sparkd/features/orders/domain/repository/upload_file_repository.dart';
import 'package:sparkd/core/utils/logger.dart';

abstract class WorkshopRemoteDataSource {
  Stream<List<WorkshopMessageModel>> getWorkshopMessages(String orderId);
  Future<void> sendMessage(WorkshopMessageModel message);
  Future<void> deleteMessage(String messageId);
  Future<void> uploadAttachment(
    String userId,
    String senderId,
    String senderName,
    String senderRole,
    String orderId,
    String messageText,
    PlatformFile file,
  );
  Future<String> downloadWorkshopFile({
    required String fileUrl,
    required String fileName,
  });
}

class WorkshopRemoteDataSourceImpl implements WorkshopRemoteDataSource {
  final FirebaseFirestore _firestore;
  final UploadFileRepository _uploadFileRepository;

  WorkshopRemoteDataSourceImpl(this._firestore, this._uploadFileRepository);

  @override
  Stream<List<WorkshopMessageModel>> getWorkshopMessages(String orderId) {
    try {
      return _firestore
          .collection('workshops')
          .doc(orderId)
          .collection('messages')
          .orderBy('sentAt', descending: true)
          .snapshots()
          .map((querySnapshot) {
            return querySnapshot.docs
                .map(
                  (doc) => WorkshopMessageModel.fromMap({
                    ...doc.data(),
                    'id': doc.id,
                  }),
                )
                .toList();
          });
    } catch (e) {
      logger.e('Error getting workshop messages: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendMessage(WorkshopMessageModel message) async {
    try {
      await _firestore
          .collection('workshops')
          .doc(message.orderId)
          .collection('messages')
          .doc(message.id)
          .set(message.toMap(), SetOptions(merge: true));
    } catch (e) {
      logger.e('Error sending message: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      // Delete logic would need the orderId, so this is a placeholder
      logger.i('Delete message: $messageId');
    } catch (e) {
      logger.e('Error deleting message: $e');
      rethrow;
    }
  }

  @override
  Future<void> uploadAttachment(
    String userId,
    String senderId,
    String senderName,
    String senderRole,
    String orderId,
    String messageText,
    PlatformFile file,
  ) async {
    try {
      // Step 1: Upload file to storage and get URL
      final fileUrl = await _uploadFileRepository.uploadFile(
        userId: userId,
        file: file,
      );

      // Step 2: Create message with attachment URL
      final message = WorkshopMessageModel(
        id: DateTime.now().toString(),
        orderId: orderId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        message: messageText,
        sentAt: DateTime.now(),
        attachmentUrls: [fileUrl],
      );

      // Step 3: Save message with attachment to Firestore
      await sendMessage(message);
    } catch (e) {
      logger.e('Error uploading attachment: $e');
      rethrow;
    }
  }

  @override
  Future<String> downloadWorkshopFile({
    required String fileUrl,
    required String fileName,
  }) async {
    final dio = Dio();
    try {
      // Get the Downloads directory
      Directory downloadDir;

      if (Platform.isAndroid) {
        // For Android, save to public Downloads folder
        // This is accessible via file manager on all Android versions
        final externalStoragePath = '/storage/emulated/0/Download';
        downloadDir = Directory(externalStoragePath);

        // If that doesn't work, try alternative paths
        if (!await downloadDir.exists()) {
          try {
            // Try using environment variable
            final homeDir = Platform.environment['HOME'];
            if (homeDir != null) {
              downloadDir = Directory('$homeDir/Download');
            }
          } catch (e) {
            // Fallback to app cache if all else fails
            downloadDir = await getApplicationCacheDirectory();
            logger.w('Using cache directory as fallback: ${downloadDir.path}');
          }
        }
      } else if (Platform.isIOS) {
        // For iOS, use the app's Documents folder which is accessible
        downloadDir = await getApplicationDocumentsDirectory();
      } else {
        // For other platforms
        downloadDir = await getApplicationDocumentsDirectory();
      }

      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // Create Sparkd subfolder
      final sparkdDir = Directory('${downloadDir.path}/Sparkd');
      if (!await sparkdDir.exists()) {
        await sparkdDir.create(recursive: true);
      }

      String savePath = '${sparkdDir.path}/$fileName';

      // FIX: URL-decode the filename and extract just the actual filename (not folder paths)
      // The fileName often comes with URL-encoded paths like "orders%2FuserId%2Ffilename.jpg"
      // We need to decode it and get just the actual filename
      final decodedFileName = Uri.decodeComponent(fileName);
      final actualFileName = decodedFileName
          .split('/')
          .last; // Get just the filename after any slashes

      savePath = '${sparkdDir.path}/$actualFileName';

      logger.i(
        '🔍 downloadWorkshopFile: original fileName=$fileName, decoded=$decodedFileName, actual=$actualFileName, savePath=$savePath',
      );

      // Check if file already exists
      if (File(savePath).existsSync()) {
        logger.i('File already exists: $fileName at $savePath');
        return savePath;
      }

      await dio.download(
        fileUrl,
        savePath,
        onReceiveProgress: (count, total) {
          if (total != -1) {
            logger.i(
              'Downloading: ${(count / total * 100).toStringAsFixed(0)}%',
            );
          }
        },
      );

      logger.i('File downloaded successfully: $fileName at $savePath');
      return savePath;
    } catch (e) {
      logger.e('Error downloading file: $e');
      rethrow;
    }
  }
}
