import 'package:sparkd/features/gigs/domain/entities/gig_entity.dart';

abstract class GigRepository {
  Future<GigEntity> createGig(GigEntity gig);
  Future<List<GigEntity>> getGigs();
  Future<GigEntity> getGigById(String id);
  Future<GigEntity> updateGig(GigEntity gig);
  Future<void> deleteGig(String id);
  Future<List<GigEntity>> getGigsByCategory(String categoryId);
  Future<List<GigEntity>> getGigsByCreator(String creatorId);
}
