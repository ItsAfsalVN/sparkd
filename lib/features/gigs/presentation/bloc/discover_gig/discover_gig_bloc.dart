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
  }

  Future<void> _onDiscoverGigsRequested(
    DiscoverGigsRequested event,
    Emitter<DiscoverGigState> emit,
  ) async {
    try {
      emit(state.copyWith(status: FormStatus.loading));
      logger.i('DiscoverGigBloc: Fetching gigs...');

      final gigs = await _getGigsUseCase();

      emit(state.copyWith(status: FormStatus.success, gigs: gigs));
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
}
