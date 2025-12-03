import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/utils/form_statuses.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/auth/domain/repositories/sign_up_data_repository.dart';
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';

part 'business_details_event.dart';
part 'business_details_state.dart';

class BusinessDetailsBloc
    extends Bloc<BusinessDetailsEvent, BusinessDetailsState> {
  final AuthBloc _authBloc;
  final SignUpDataRepository _signUpDataRepository;
  BusinessDetailsBloc({
    required SignUpDataRepository signUpDataRepository,
    required AuthBloc authBloc,
  }) : _signUpDataRepository = signUpDataRepository,
       _authBloc = authBloc,
       super(BusinessDetailsState()) {
    on<BusinessNameChanged>(_onBusinessNameChanged);
    on<CategoryChanged>(_onCategoryChanged);
    on<LocationChanged>(_onLocationChanged);
    on<SubmitBusinessDetails>(_onSubmitBusinessDetails);
  }

  void _onBusinessNameChanged(
    BusinessNameChanged event,
    Emitter<BusinessDetailsState> emit,
  ) {
    logger.d(
      'BusinessDetailsBloc: Business name changed to: ${event.businessName}',
    );
    emit(state.copyWith(businessName: event.businessName));
  }

  void _onCategoryChanged(
    CategoryChanged event,
    Emitter<BusinessDetailsState> emit,
  ) {
    logger.d('BusinessDetailsBloc: Category changed to: ${event.category}');
    emit(state.copyWith(category: event.category));
  }

  void _onLocationChanged(
    LocationChanged event,
    Emitter<BusinessDetailsState> emit,
  ) {
    logger.d('BusinessDetailsBloc: Location changed to: ${event.location}');
    emit(state.copyWith(location: event.location));
  }

  void _onSubmitBusinessDetails(
    SubmitBusinessDetails event,
    Emitter<BusinessDetailsState> emit,
  ) async {
    logger.i('BusinessDetailsBloc: Submitting business details...');
    emit(state.copyWith(formStatus: FormStatus.submitting));

    // Validate all fields
    if (state.businessName.trim().isEmpty ||
        state.category.isEmpty ||
        state.location.trim().isEmpty) {
      logger.w(
        'BusinessDetailsBloc: Validation failed - missing required fields',
      );
      emit(
        state.copyWith(
          formStatus: FormStatus.failure,
          errorMessage: "All fields are required.",
        ),
      );
      return;
    }

    try {
      logger.d('BusinessDetailsBloc: Fetching current sign-up data...');
      final currentData = _signUpDataRepository.getData();

      final businessData = {
        "businessName": state.businessName.trim(),
        "category": state.category,
        "location": state.location.trim(),
      };

      logger.d('BusinessDetailsBloc: Business data to save: $businessData');

      final updatedData = currentData.copyWith(businessData: businessData);

      logger.i('BusinessDetailsBloc: Saving business data to repository...');
      _signUpDataRepository.updateData(updatedData);

      logger.i('BusinessDetailsBloc: Business data saved successfully');
      logger.i('BusinessDetailsBloc: Triggering AuthFinalizeSignUp...');

      _authBloc.add(const AuthFinalizeSignUp());

      emit(state.copyWith(formStatus: FormStatus.success));
      logger.i('BusinessDetailsBloc: Business details submission complete');
    } catch (error, stackTrace) {
      logger.e(
        'BusinessDetailsBloc: Error submitting business details',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          formStatus: FormStatus.failure,
          errorMessage: "Failed to save business details. Please try again.",
        ),
      );
    }
  }
}
