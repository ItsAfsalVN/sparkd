import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/utils/form_statuses.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/gigs/domain/entities/gig_entity.dart';
import 'package:sparkd/features/gigs/domain/usecases/get_gigs.dart';

part 'discover_gig_event.dart';
part 'discover_gig_state.dart';

class DiscoverGigBloc extends Bloc<DiscoverGigEvent, DiscoverGigState> {
  final GetGigsUseCase _getGigsUseCase;

  DiscoverGigBloc({required GetGigsUseCase getGigsUseCase})
    : _getGigsUseCase = getGigsUseCase,
      super(const DiscoverGigState()) {
    on<DiscoverGigsRequested>(_onDiscoverGigsRequested);
    on<DiscoverGigSearchRequested>(_onDiscoverGigSearchRequested);
  }

  Future<void> _onDiscoverGigsRequested(
    DiscoverGigsRequested event,
    Emitter<DiscoverGigState> emit,
  ) async {
    try {
      emit(state.copyWith(status: FormStatus.loading));
      logger.i('DiscoverGigBloc: Fetching gigs...');

      final gigs = await _getGigsUseCase();
      final filteredGigs = _filterGigs(gigs, state.query);

      emit(
        state.copyWith(
          status: FormStatus.success,
          allGigs: gigs,
          gigs: filteredGigs,
          errorMessage: null,
        ),
      );
      logger.i('DiscoverGigBloc: Successfully fetched ${gigs.length} gigs');
    } catch (e, stackTrace) {
      logger.e(
        'DiscoverGigBloc: Error fetching gigs',
        error: e,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(status: FormStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  void _onDiscoverGigSearchRequested(
    DiscoverGigSearchRequested event,
    Emitter<DiscoverGigState> emit,
  ) {
    final query = event.query.trim();
    final filteredGigs = _filterGigs(state.allGigs, query);

    emit(state.copyWith(query: query, gigs: filteredGigs));
    logger.i(
      'DiscoverGigBloc: Applied search "$query" and found ${filteredGigs.length} gigs',
    );
  }

  List<GigEntity> _filterGigs(List<GigEntity> gigs, String? query) {
    final normalizedQuery = query?.trim().toLowerCase() ?? '';
    if (normalizedQuery.isEmpty) {
      return gigs;
    }

    return gigs.where((gig) {
      final titleMatch = gig.title.toLowerCase().contains(normalizedQuery);
      final tagsMatch = gig.tags.any(
        (tag) => tag.toLowerCase().contains(normalizedQuery),
      );

      return titleMatch || tagsMatch;
    }).toList();
  }
}
