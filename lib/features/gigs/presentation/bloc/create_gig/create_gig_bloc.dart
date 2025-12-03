import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/utils/delivery_types.dart';
import 'package:sparkd/core/utils/form_statuses.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/gigs/domain/entities/gig_entity.dart';
import 'package:sparkd/features/spark/domain/entities/skill_entity.dart';
import 'package:sparkd/features/gigs/domain/usecases/create_new_gig.dart';
import 'package:sparkd/features/gigs/domain/usecases/get_user_gigs.dart';

part 'create_gig_event.dart';
part 'create_gig_state.dart';

class CreateGigBloc extends Bloc<CreateGigEvent, CreateGigState> {
  final CreateNewGigUseCase createNewGigUseCase;
  final GetUserGigsUseCase getUserGigsUseCase;

  CreateGigBloc({required this.createNewGigUseCase, required this.getUserGigsUseCase})
    : super(const CreateGigState()) {
    on<GigTitleChanged>(_onTitleChanged);
    on<GigDescriptionChanged>(_onDescriptionChanged);
    on<GigCategoryChanged>(_onCategoryChanged);
    on<GigDeliveryTypeChanged>(_onDeliveryTypeChanged);
    on<GigPriceChanged>(_onPriceChanged);
    on<GigDeliveryTimeChanged>(_onDeliveryTimeChanged);
    on<GigRevisionsChanged>(_onRevisionsChanged);
    on<GigTagsChanged>(_onTagsChanged);
    on<GigDeliverablesChanged>(_onDeliverablesChanged);
    on<GigRequirementsChanged>(_onRequirementsChanged);
    on<GigPostInstructionsChanged>(_onPostInstructionsChanged);
    on<GigThumbnailChanged>(_onThumbnailChanged);
    on<GigGalleryImagesChanged>(_onGalleryImagesChanged);
    on<GigDemoVideoChanged>(_onDemoVideoChanged);
    on<CreateGigSubmitted>(_onSubmitted);
    on<CreateGigStatusReset>(_onStatusReset);
    on<LoadUserGigs>(_onLoadUserGigs);
  }

  // --- Text Handlers ---

  void _onTitleChanged(GigTitleChanged event, Emitter<CreateGigState> emit) {
    emit(state.copyWith(title: event.title));
  }

  void _onDescriptionChanged(
    GigDescriptionChanged event,
    Emitter<CreateGigState> emit,
  ) {
    emit(state.copyWith(description: event.description));
  }

  void _onCategoryChanged(GigCategoryChanged event, Emitter<CreateGigState> emit) {
    emit(state.copyWith(category: event.category));
  }

  void _onDeliveryTypeChanged(
    GigDeliveryTypeChanged event,
    Emitter<CreateGigState> emit,
  ) {
    emit(state.copyWith(deliveryType: event.deliveryType));
  }

  void _onPriceChanged(GigPriceChanged event, Emitter<CreateGigState> emit) {
    emit(state.copyWith(price: event.price));
  }

  void _onDeliveryTimeChanged(
    GigDeliveryTimeChanged event,
    Emitter<CreateGigState> emit,
  ) {
    emit(state.copyWith(deliveryTimeInDays: event.days));
  }

  void _onRevisionsChanged(GigRevisionsChanged event, Emitter<CreateGigState> emit) {
    emit(state.copyWith(revisions: event.revisions));
  }

  void _onTagsChanged(GigTagsChanged event, Emitter<CreateGigState> emit) {
    emit(state.copyWith(tags: event.tags));
  }

  void _onDeliverablesChanged(
    GigDeliverablesChanged event,
    Emitter<CreateGigState> emit,
  ) {
    emit(state.copyWith(deliverables: event.deliverables));
  }

  void _onRequirementsChanged(
    GigRequirementsChanged event,
    Emitter<CreateGigState> emit,
  ) {
    emit(state.copyWith(requirements: event.requirements));
  }

  void _onPostInstructionsChanged(
    GigPostInstructionsChanged event,
    Emitter<CreateGigState> emit,
  ) {
    emit(state.copyWith(postGigInstructions: event.instructions));
  }

  void _onThumbnailChanged(GigThumbnailChanged event, Emitter<CreateGigState> emit) {
    emit(state.copyWith(thumbnailImage: event.path));
  }

  void _onGalleryImagesChanged(
    GigGalleryImagesChanged event,
    Emitter<CreateGigState> emit,
  ) {
    emit(state.copyWith(galleryImages: event.paths));
  }

  void _onDemoVideoChanged(GigDemoVideoChanged event, Emitter<CreateGigState> emit) {
    emit(state.copyWith(demoVideo: event.videoPath));
  }

  Future<void> _onSubmitted(
    CreateGigSubmitted event,
    Emitter<CreateGigState> emit,
  ) async {
    try {
      logger.i('Bloc: Starting gig submission');
      emit(state.copyWith(status: FormStatus.loading));

      // Create gig entity from state
      final gigEntity = GigEntity(
        title: state.title,
        description: state.description,
        categoryId: state.category?.categoryID ?? '',
        tags: state.tags,
        price: state.price,
        deliveryTimeInDays: state.deliveryTimeInDays,
        maxRevisions: state.revisions,
        deliverables: state.deliverables,
        requirements: state.requirements,
        deliveryType: state.deliveryType ?? DeliveryTypes.file,
        thumbnailImage: state.thumbnailImage,
        portfolioImages: state.galleryImages,
        demoVideo: state.demoVideo,
      );

      // Create the gig using use case
      final createdGig = await createNewGigUseCase(gigEntity);

      logger.i('Bloc: Gig created successfully with ID: ${createdGig.id}');
      emit(state.copyWith(status: FormStatus.success));
    } catch (e) {
      logger.e('Bloc: Error creating gig - $e');
      emit(state.copyWith(status: FormStatus.failure));
    }
  }

  void _onStatusReset(CreateGigStatusReset event, Emitter<CreateGigState> emit) {
    emit(
      state.copyWith(
        title: '',
        description: '',
        price: 0.0,
        deliveryTimeInDays: 0,
        revisions: 0,
        tags: [],
        deliverables: [],
        requirements: [],
        postGigInstructions: [],
        status: FormStatus.initial,
        category: null,
        deliveryType: null,
        thumbnailImage: null,
        galleryImages: [],
        demoVideo: null,
      ),
    );
  }

  Future<void> _onLoadUserGigs(
    LoadUserGigs event,
    Emitter<CreateGigState> emit,
  ) async {
    emit(state.copyWith(status: FormStatus.loading));

    try {
      final gigs = await getUserGigsUseCase(event.userId);
      emit(state.copyWith(userGigs: gigs, status: FormStatus.success));
    } catch (error) {
      logger.e('Error loading user gigs: $error');
      emit(state.copyWith(status: FormStatus.failure));
    }
  }
}
