part of 'discover_gig_bloc.dart';

class DiscoverGigState extends Equatable {
  final FormStatus status;
  final String? errorMessage;
  final List<GigEntity> gigs;

  const DiscoverGigState({
    this.status = FormStatus.initial,
    this.errorMessage,
    this.gigs = const [],
  });

  DiscoverGigState copyWith({
    FormStatus? status,
    String? errorMessage,
    List<GigEntity>? gigs,
  }) {
    return DiscoverGigState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      gigs: gigs ?? this.gigs,
    );
  }

  @override
  List<Object> get props => [
        status,
        gigs,
  ];
}

