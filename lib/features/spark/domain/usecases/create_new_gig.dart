import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/spark/domain/entities/gig_entity.dart';
import 'package:sparkd/features/spark/domain/repositories/gig_repository.dart';

class CreateNewGigUseCase {
  final GigRepository repository;

  CreateNewGigUseCase({required this.repository});

  Future<GigEntity> call(GigEntity gig) async {
    try {
      logger.i('UseCase: Creating new gig - ${gig.title}');

      // Validate gig data
      _validateGig(gig);

      // Create the gig
      final createdGig = await repository.createGig(gig);

      logger.i('UseCase: Gig created successfully with ID: ${createdGig.id}');
      return createdGig;
    } catch (e) {
      logger.e('UseCase: Error creating gig - $e');
      rethrow;
    }
  }

  void _validateGig(GigEntity gig) {
    if (gig.title.trim().isEmpty) {
      throw Exception('Gig title cannot be empty');
    }

    if (gig.title.trim().length < 5) {
      throw Exception('Gig title must be at least 5 characters long');
    }

    if (gig.description.trim().isEmpty) {
      throw Exception('Gig description cannot be empty');
    }

    if (gig.description.trim().length < 20) {
      throw Exception('Gig description must be at least 20 characters long');
    }

    if (gig.categoryId.trim().isEmpty) {
      throw Exception('Please select a category');
    }

    if (gig.price <= 0) {
      throw Exception('Price must be greater than 0');
    }

    if (gig.deliveryTimeInDays <= 0) {
      throw Exception('Delivery time must be at least 1 day');
    }

    if (gig.maxRevisions < 0) {
      throw Exception('Revisions cannot be negative');
    }

    if (gig.deliverables.isEmpty) {
      throw Exception('At least one deliverable must be selected');
    }

    if (gig.requirements.isEmpty) {
      throw Exception('At least one requirement must be specified');
    }

    if (gig.thumbnailImage == null || gig.thumbnailImage!.trim().isEmpty) {
      throw Exception('Thumbnail image is required');
    }

    logger.i('UseCase: Gig validation passed');
  }
}
