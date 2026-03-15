import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/gigs/domain/entities/gig_entity.dart';
import 'package:sparkd/features/gigs/domain/repositories/gig_repository.dart';

class UpdateGigUseCase {
  final GigRepository repository;

  UpdateGigUseCase({required this.repository});

  Future<GigEntity> call(GigEntity gig) async {
    try {
      logger.i('UseCase: Updating gig - ${gig.title} (ID: ${gig.id})');

      // Validate gig data
      _validateGig(gig);

      // Update the gig
      final updatedGig = await repository.updateGig(gig);

      logger.i('UseCase: Gig updated successfully with ID: ${updatedGig.id}');
      return updatedGig;
    } catch (e) {
      logger.e('UseCase: Error updating gig - $e');
      rethrow;
    }
  }

  void _validateGig(GigEntity gig) {

    if (gig.id == null || gig.id!.trim().isEmpty) {
      throw Exception('Gig ID is required for update');
    }

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

    if (gig.maxRevisions < 0 && gig.maxRevisions != -1) {
      throw Exception('Invalid revisions value');
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
