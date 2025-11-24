import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/utils/delivery_types.dart';
import 'package:sparkd/core/utils/form_statuses.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/spark/domain/entities/gig_entity.dart';
import 'package:sparkd/features/spark/domain/entities/skill_entity.dart';
import 'package:sparkd/features/spark/domain/usecases/create_new_gig.dart';

part 'gig_event.dart';
part 'gig_state.dart';

class GigBloc extends Bloc<GigEvent, GigState> {
  final CreateNewGigUseCase createNewGigUseCase;

  GigBloc({required this.createNewGigUseCase}) : super(const GigState()) {
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
  }

  // --- Text Handlers ---

  void _onTitleChanged(GigTitleChanged event, Emitter<GigState> emit) {
    emit(state.copyWith(title: event.title));
  }

  void _onDescriptionChanged(
    GigDescriptionChanged event,
    Emitter<GigState> emit,
  ) {
    emit(state.copyWith(description: event.description));
  }

  void _onCategoryChanged(GigCategoryChanged event, Emitter<GigState> emit) {
    emit(state.copyWith(category: event.category));
  }

  void _onDeliveryTypeChanged(
    GigDeliveryTypeChanged event,
    Emitter<GigState> emit,
  ) {
    emit(state.copyWith(deliveryType: event.deliveryType));
  }

  void _onPriceChanged(GigPriceChanged event, Emitter<GigState> emit) {
    emit(state.copyWith(price: event.price));
  }

  void _onDeliveryTimeChanged(
    GigDeliveryTimeChanged event,
    Emitter<GigState> emit,
  ) {
    emit(state.copyWith(deliveryTimeInDays: event.days));
  }

  void _onRevisionsChanged(GigRevisionsChanged event, Emitter<GigState> emit) {
    emit(state.copyWith(revisions: event.revisions));
  }

  void _onTagsChanged(GigTagsChanged event, Emitter<GigState> emit) {
    emit(state.copyWith(tags: event.tags));
  }

  void _onDeliverablesChanged(
    GigDeliverablesChanged event,
    Emitter<GigState> emit,
  ) {
    emit(state.copyWith(deliverables: event.deliverables));
  }

  void _onRequirementsChanged(
    GigRequirementsChanged event,
    Emitter<GigState> emit,
  ) {
    emit(state.copyWith(requirements: event.requirements));
  }

  void _onPostInstructionsChanged(
    GigPostInstructionsChanged event,
    Emitter<GigState> emit,
  ) {
    emit(state.copyWith(postGigInstructions: event.instructions));
  }

  void _onThumbnailChanged(GigThumbnailChanged event, Emitter<GigState> emit) {
    emit(state.copyWith(thumbnailImage: event.path));
  }

  void _onGalleryImagesChanged(
    GigGalleryImagesChanged event,
    Emitter<GigState> emit,
  ) {
    emit(state.copyWith(galleryImages: event.paths));
  }

  void _onDemoVideoChanged(GigDemoVideoChanged event, Emitter<GigState> emit) {
    emit(state.copyWith(demoVideo: event.videoPath));
  }

  Future<void> _onSubmitted(
    CreateGigSubmitted event,
    Emitter<GigState> emit,
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

  void _onStatusReset(CreateGigStatusReset event, Emitter<GigState> emit) {
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
}
