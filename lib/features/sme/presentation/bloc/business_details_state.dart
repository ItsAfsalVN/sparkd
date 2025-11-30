part of 'business_details_bloc.dart';

class BusinessDetailsState extends Equatable {
  final String businessName;
  final String category;
  final String location;
  final FormStatus formStatus;
  final String? errorMessage;

  const BusinessDetailsState({
    this.businessName = "",
    this.category = "",
    this.location = "",
    this.formStatus = FormStatus.initial,
    this.errorMessage,
  });

  BusinessDetailsState copyWith({
    String? businessName,
    String? category,
    String? location,
    FormStatus? formStatus,
    String? errorMessage,
  }){
    return BusinessDetailsState(
      businessName: businessName ?? this.businessName,
      category: category ?? this.category,
      location: location ?? this.location,
      formStatus: formStatus ?? this.formStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [businessName, category, location, formStatus];
}