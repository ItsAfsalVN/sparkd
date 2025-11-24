import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/spark/data/models/gig_model.dart';

abstract class GigRemoteDataSource {
  Future<GigModel> createGig(GigModel gig);
  Future<List<GigModel>> getGigs();
  Future<GigModel> getGigById(String id);
  Future<GigModel> updateGig(GigModel gig);
  Future<void> deleteGig(String id);
  Future<List<GigModel>> getGigsByCategory(String categoryId);
  Future<List<GigModel>> getGigsByCreator(String creatorId);
}

class GigRemoteDataSourceImpl implements GigRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  GigRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  @override
  Future<GigModel> createGig(GigModel gig) async {
    try {
      logger.i('Creating gig: ${gig.title}');

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final gigWithCreator = gig.copyWith(
        creatorId: currentUser.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('gigs')
          .add(gigWithCreator.toJson());

      final createdGig = gigWithCreator.copyWith(id: docRef.id);

      // Update the document with the generated ID
      await docRef.update({'id': docRef.id});

      logger.i('Gig created successfully with ID: ${docRef.id}');
      return createdGig;
    } catch (e) {
      logger.e('Error creating gig: $e');
      throw Exception('Failed to create gig: $e');
    }
  }

  @override
  Future<List<GigModel>> getGigs() async {
    try {
      logger.i('Fetching all gigs');

      final querySnapshot = await _firestore
          .collection('gigs')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final gigs = querySnapshot.docs
          .map((doc) => GigModel.fromJson(doc.data()))
          .toList();

      logger.i('Fetched ${gigs.length} gigs');
      return gigs;
    } catch (e) {
      logger.e('Error fetching gigs: $e');
      throw Exception('Failed to fetch gigs: $e');
    }
  }

  @override
  Future<GigModel> getGigById(String id) async {
    try {
      logger.i('Fetching gig by ID: $id');

      final docSnapshot = await _firestore.collection('gigs').doc(id).get();

      if (!docSnapshot.exists) {
        throw Exception('Gig not found');
      }

      final gig = GigModel.fromJson(docSnapshot.data()!);
      logger.i('Fetched gig: ${gig.title}');
      return gig;
    } catch (e) {
      logger.e('Error fetching gig by ID: $e');
      throw Exception('Failed to fetch gig: $e');
    }
  }

  @override
  Future<GigModel> updateGig(GigModel gig) async {
    try {
      logger.i('Updating gig: ${gig.id}');

      if (gig.id == null) {
        throw Exception('Gig ID cannot be null for update');
      }

      final updatedGig = gig.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection('gigs')
          .doc(gig.id)
          .update(updatedGig.toJson());

      logger.i('Gig updated successfully');
      return updatedGig;
    } catch (e) {
      logger.e('Error updating gig: $e');
      throw Exception('Failed to update gig: $e');
    }
  }

  @override
  Future<void> deleteGig(String id) async {
    try {
      logger.i('Deleting gig: $id');

      // Soft delete by setting isActive to false
      await _firestore.collection('gigs').doc(id).update({
        'isActive': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      logger.i('Gig deleted successfully');
    } catch (e) {
      logger.e('Error deleting gig: $e');
      throw Exception('Failed to delete gig: $e');
    }
  }

  @override
  Future<List<GigModel>> getGigsByCategory(String categoryId) async {
    try {
      logger.i('Fetching gigs by category: $categoryId');

      final querySnapshot = await _firestore
          .collection('gigs')
          .where('categoryId', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final gigs = querySnapshot.docs
          .map((doc) => GigModel.fromJson(doc.data()))
          .toList();

      logger.i('Fetched ${gigs.length} gigs for category: $categoryId');
      return gigs;
    } catch (e) {
      logger.e('Error fetching gigs by category: $e');
      throw Exception('Failed to fetch gigs by category: $e');
    }
  }

  @override
  Future<List<GigModel>> getGigsByCreator(String creatorId) async {
    try {
      logger.i('Fetching gigs by creator: $creatorId');

      final querySnapshot = await _firestore
          .collection('gigs')
          .where('creatorId', isEqualTo: creatorId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final gigs = querySnapshot.docs
          .map((doc) => GigModel.fromJson(doc.data()))
          .toList();

      logger.i('Fetched ${gigs.length} gigs for creator: $creatorId');
      return gigs;
    } catch (e) {
      logger.e('Error fetching gigs by creator: $e');
      throw Exception('Failed to fetch gigs by creator: $e');
    }
  }
}
