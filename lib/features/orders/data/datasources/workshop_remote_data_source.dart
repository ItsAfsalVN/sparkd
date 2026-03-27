import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparkd/features/orders/data/models/workshop_message_model.dart';
import 'package:sparkd/core/utils/logger.dart';

abstract class WorkshopRemoteDataSource {
  Stream<List<WorkshopMessageModel>> getWorkshopMessages(String orderId);
  Future<void> sendMessage(WorkshopMessageModel message);
  Future<void> deleteMessage(String messageId);
}

class WorkshopRemoteDataSourceImpl implements WorkshopRemoteDataSource {
  final FirebaseFirestore _firestore;

  WorkshopRemoteDataSourceImpl(this._firestore);

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
}
