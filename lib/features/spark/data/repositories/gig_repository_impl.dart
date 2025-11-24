import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/spark/data/datasources/gig_remote_data_source.dart';
import 'package:sparkd/features/spark/data/models/gig_model.dart';
import 'package:sparkd/features/spark/domain/entities/gig_entity.dart';
import 'package:sparkd/features/spark/domain/repositories/gig_repository.dart';

class GigRepositoryImpl implements GigRepository {
  final GigRemoteDataSource remoteDataSource;

  GigRepositoryImpl({required this.remoteDataSource});

  @override
  Future<GigEntity> createGig(GigEntity gig) async {
    try {
      logger.i('Repository: Creating gig ${gig.title}');

      final gigModel = GigModel.fromEntity(gig);
      final createdGigModel = await remoteDataSource.createGig(gigModel);

      logger.i('Repository: Gig created successfully');
      return createdGigModel.toEntity();
    } catch (e) {
      logger.e('Repository: Error creating gig - $e');
      rethrow;
    }
  }

  @override
  Future<List<GigEntity>> getGigs() async {
    try {
      logger.i('Repository: Fetching all gigs');

      final gigModels = await remoteDataSource.getGigs();
      final gigs = gigModels.map((model) => model.toEntity()).toList();

      logger.i('Repository: Fetched ${gigs.length} gigs');
      return gigs;
    } catch (e) {
      logger.e('Repository: Error fetching gigs - $e');
      rethrow;
    }
  }

  @override
  Future<GigEntity> getGigById(String id) async {
    try {
      logger.i('Repository: Fetching gig by ID: $id');

      final gigModel = await remoteDataSource.getGigById(id);

      logger.i('Repository: Fetched gig successfully');
      return gigModel.toEntity();
    } catch (e) {
      logger.e('Repository: Error fetching gig by ID - $e');
      rethrow;
    }
  }

  @override
  Future<GigEntity> updateGig(GigEntity gig) async {
    try {
      logger.i('Repository: Updating gig ${gig.id}');

      final gigModel = GigModel.fromEntity(gig);
      final updatedGigModel = await remoteDataSource.updateGig(gigModel);

      logger.i('Repository: Gig updated successfully');
      return updatedGigModel.toEntity();
    } catch (e) {
      logger.e('Repository: Error updating gig - $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteGig(String id) async {
    try {
      logger.i('Repository: Deleting gig $id');

      await remoteDataSource.deleteGig(id);

      logger.i('Repository: Gig deleted successfully');
    } catch (e) {
      logger.e('Repository: Error deleting gig - $e');
      rethrow;
    }
  }

  @override
  Future<List<GigEntity>> getGigsByCategory(String categoryId) async {
    try {
      logger.i('Repository: Fetching gigs by category: $categoryId');

      final gigModels = await remoteDataSource.getGigsByCategory(categoryId);
      final gigs = gigModels.map((model) => model.toEntity()).toList();

      logger.i('Repository: Fetched ${gigs.length} gigs for category');
      return gigs;
    } catch (e) {
      logger.e('Repository: Error fetching gigs by category - $e');
      rethrow;
    }
  }

  @override
  Future<List<GigEntity>> getGigsByCreator(String creatorId) async {
    try {
      logger.i('Repository: Fetching gigs by creator: $creatorId');

      final gigModels = await remoteDataSource.getGigsByCreator(creatorId);
      final gigs = gigModels.map((model) => model.toEntity()).toList();

      logger.i('Repository: Fetched ${gigs.length} gigs for creator');
      return gigs;
    } catch (e) {
      logger.e('Repository: Error fetching gigs by creator - $e');
      rethrow;
    }
  }
}
