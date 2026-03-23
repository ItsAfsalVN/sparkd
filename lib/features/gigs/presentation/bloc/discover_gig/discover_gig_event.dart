part of 'discover_gig_bloc.dart';

class DiscoverGigEvent extends Equatable {
  const DiscoverGigEvent();

  @override
  List<Object> get props => [];
}

class DiscoverGigsRequested extends DiscoverGigEvent {}

class DiscoverGigSearchRequested extends DiscoverGigEvent {
  final String query;

  const DiscoverGigSearchRequested({required this.query});

  @override
  List<Object> get props => [query];
}
