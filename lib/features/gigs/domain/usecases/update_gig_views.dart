import 'package:sparkd/features/gigs/domain/repositories/gig_repository.dart';

class UpdateGigViews {
  final GigRepository _repository;

  UpdateGigViews({required GigRepository repository})
    : _repository = repository;

  Future<void> call(String gigId) async {
    await _repository.incrementGigViews(gigId);
  }
}
