part of 'business_details_bloc.dart';

 class BusinessDetailsEvent extends Equatable {
  const BusinessDetailsEvent();

  @override
  List<Object> get props => [];
}

class BusinessNameChanged extends BusinessDetailsEvent {
  final String businessName;

  const BusinessNameChanged(this.businessName);

  @override
  List<Object> get props => [businessName];
}

class CategoryChanged extends BusinessDetailsEvent {
  final String category;

  const CategoryChanged(this.category);

  @override
  List<Object> get props => [category];
}

class LocationChanged extends BusinessDetailsEvent {
  final String location;

  const LocationChanged(this.location);

  @override
  List<Object> get props => [location];
}

class SubmitBusinessDetails extends BusinessDetailsEvent {
  const SubmitBusinessDetails();

  @override
  List<Object> get props => [];
}