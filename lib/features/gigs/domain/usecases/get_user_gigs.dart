import 'package:sparkd/features/gigs/domain/entities/gig_entity.dart';
import 'package:sparkd/features/gigs/domain/repositories/gig_repository.dart';

class GetUserGigsUseCase {
  final GigRepository repository;

  GetUserGigsUseCase({required this.repository});

  Future<List<GigEntity>> call(String userId) async {
    return await repository.getGigsByCreator(userId);
  }
}
