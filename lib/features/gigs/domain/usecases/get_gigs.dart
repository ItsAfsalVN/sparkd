import 'package:sparkd/features/gigs/domain/entities/gig_entity.dart';
import 'package:sparkd/features/gigs/domain/repositories/gig_repository.dart';

class GetGigsUseCase {
  final GigRepository _gigRepository;
  GetGigsUseCase({required GigRepository gigRepository})
    : _gigRepository = gigRepository;

  Future<List<GigEntity>> call() async {
    return await _gigRepository.getGigs();
  }
}
