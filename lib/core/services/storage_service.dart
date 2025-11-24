import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sparkd/core/utils/logger.dart';

abstract class StorageService {
  Future<String> uploadImage(File file, String path);
  Future<String> uploadVideo(File file, String path);
  Future<List<String>> uploadMultipleImages(List<File> files, String basePath);
  Future<void> deleteFile(String url);
}

class FirebaseStorageService implements StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<String> uploadImage(File file, String path) async {
    try {
      logger.i('Uploading image to: $path');

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final ref = _storage.ref().child('users/${user.uid}/$path');
      final uploadTask = ref.putFile(file);

      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();

      logger.i('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      logger.e('Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  @override
  Future<String> uploadVideo(File file, String path) async {
    try {
      logger.i('Uploading video to: $path');

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final ref = _storage.ref().child('users/${user.uid}/$path');
      final uploadTask = ref.putFile(file);

      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();

      logger.i('Video uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      logger.e('Error uploading video: $e');
      throw Exception('Failed to upload video: $e');
    }
  }

  @override
  Future<List<String>> uploadMultipleImages(
    List<File> files,
    String basePath,
  ) async {
    try {
      logger.i('Uploading ${files.length} images to: $basePath');

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final List<String> downloadUrls = [];

      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final ref = _storage.ref().child(
          'users/${user.uid}/$basePath/$fileName',
        );

        final uploadTask = ref.putFile(file);
        await uploadTask;
        final downloadUrl = await ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }

      logger.i('All images uploaded successfully');
      return downloadUrls;
    } catch (e) {
      logger.e('Error uploading multiple images: $e');
      throw Exception('Failed to upload images: $e');
    }
  }

  @override
  Future<void> deleteFile(String url) async {
    try {
      logger.i('Deleting file: $url');
      final ref = _storage.refFromURL(url);
      await ref.delete();
      logger.i('File deleted successfully');
    } catch (e) {
      logger.e('Error deleting file: $e');
      throw Exception('Failed to delete file: $e');
    }
  }
}
