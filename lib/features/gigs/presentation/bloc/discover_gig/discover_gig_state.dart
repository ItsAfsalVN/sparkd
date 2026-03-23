part of 'discover_gig_bloc.dart';

class DiscoverGigState extends Equatable {
  final FormStatus status;
  final String? errorMessage;
  final List<GigEntity> allGigs;
  final List<GigEntity> gigs;
  final String? query;

  const DiscoverGigState({
    this.status = FormStatus.initial,
    this.errorMessage,
    this.allGigs = const [],
    this.gigs = const [],
    this.query,
  });

  DiscoverGigState copyWith({
    FormStatus? status,
    String? errorMessage,
    List<GigEntity>? allGigs,
    List<GigEntity>? gigs,
    String? query,
  }) {
    return DiscoverGigState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      allGigs: allGigs ?? this.allGigs,
      gigs: gigs ?? this.gigs,
      query: query ?? this.query,
    );
  }

  @override
  List<Object> get props => [status, allGigs, gigs, query ?? ''];
}
