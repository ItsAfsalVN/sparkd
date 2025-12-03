import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparkd/core/utils/logger.dart';

class UserHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch user's full name from Firestore by user ID
  static Future<String?> getUserName(String userId) async {
    try {
      logger.d("UserHelper: Fetching user name for UID: $userId");

      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists || doc.data() == null) {
        logger.w("UserHelper: No user found for UID: $userId");
        return null;
      }

      final data = doc.data()!;
      final fullName = data['fullName'] as String?;

      logger.i("UserHelper: User name fetched successfully for UID: $userId");
      return fullName;
    } catch (e) {
      logger.e(
        "UserHelper: Failed to fetch user name for UID: $userId",
        error: e,
      );
      return null;
    }
  }

  /// Fetch user's email from Firestore by user ID
  static Future<String?> getUserEmail(String userId) async {
    try {
      logger.d("UserHelper: Fetching user email for UID: $userId");

      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists || doc.data() == null) {
        logger.w("UserHelper: No user found for UID: $userId");
        return null;
      }

      final data = doc.data()!;
      final email = data['email'] as String?;

      logger.i("UserHelper: User email fetched successfully for UID: $userId");
      return email;
    } catch (e) {
      logger.e(
        "UserHelper: Failed to fetch user email for UID: $userId",
        error: e,
      );
      return null;
    }
  }
}
