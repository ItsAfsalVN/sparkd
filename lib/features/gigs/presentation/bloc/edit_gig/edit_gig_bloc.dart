import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/utils/delivery_types.dart';
import 'package:sparkd/core/utils/form_statuses.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/gigs/domain/entities/gig_entity.dart';
import 'package:sparkd/features/gigs/domain/entities/requirement_entity.dart';
import 'package:sparkd/features/spark/domain/entities/skill_entity.dart';
import 'package:sparkd/features/gigs/domain/usecases/update_gig.dart';

part 'edit_gig_event.dart';
part 'edit_gig_state.dart';

class EditGigBloc extends Bloc<EditGigEvent, EditGigState> {
  final UpdateGigUseCase updateGigUseCase;

  EditGigBloc({required this.updateGigUseCase}) : super(const EditGigState()) {
    on<EditGigInitialized>(_onInitialized);
    on<EditGigTitleChanged>(_onTitleChanged);
    on<EditGigDescriptionChanged>(_onDescriptionChanged);
    on<EditGigCategoryChanged>(_onCategoryChanged);
    on<EditGigDeliveryTypeChanged>(_onDeliveryTypeChanged);
    on<EditGigPriceChanged>(_onPriceChanged);
    on<EditGigDeliveryTimeChanged>(_onDeliveryTimeChanged);
    on<EditGigRevisionsChanged>(_onRevisionsChanged);
    on<EditGigTagsChanged>(_onTagsChanged);
    on<EditGigDeliverablesChanged>(_onDeliverablesChanged);
    on<EditGigRequirementsChanged>(_onRequirementsChanged);
    on<EditGigThumbnailChanged>(_onThumbnailChanged);
    on<EditGigGalleryImagesChanged>(_onGalleryImagesChanged);
    on<EditGigDemoVideoChanged>(_onDemoVideoChanged);
    on<EditGigSubmitted>(_onSubmitted);
    on<EditGigStatusReset>(_onStatusReset);
  }

  void _onInitialized(EditGigInitialized event, Emitter<EditGigState> emit) {
    logger.i('EditGigBloc: Initializing with gig ID: ${event.gig.id}');
    emit(
      EditGigState(
        gigId: event.gig.id,
        creatorId: event.gig.creatorId,
        createdAt: event.gig.createdAt,
        title: event.gig.title,
        description: event.gig.description,
        price: event.gig.price,
        deliveryTimeInDays: event.gig.deliveryTimeInDays,
        revisions: event.gig.maxRevisions,
        tags: event.gig.tags,
        deliverables: event.gig.deliverables,
        requirements: event.gig.requirements,
        deliveryType: event.gig.deliveryType,
        thumbnailImage: event.gig.thumbnailImage,
        galleryImages: event.gig.portfolioImages,
        demoVideo: event.gig.demoVideo,
        category: event.gig.categoryId.isNotEmpty
            ? SkillEntity(
                categoryID: event.gig.categoryId,
                categoryName: '',
                tools: [],
              )
            : null,
        status: FormStatus.initial,
      ),
    );
  }

  void _onTitleChanged(EditGigTitleChanged event, Emitter<EditGigState> emit) {
    emit(state.copyWith(title: event.title));
  }

  void _onDescriptionChanged(
    EditGigDescriptionChanged event,
    Emitter<EditGigState> emit,
  ) {
    emit(state.copyWith(description: event.description));
  }

  void _onCategoryChanged(
    EditGigCategoryChanged event,
    Emitter<EditGigState> emit,
  ) {
    emit(state.copyWith(category: event.category));
  }

  void _onDeliveryTypeChanged(
    EditGigDeliveryTypeChanged event,
    Emitter<EditGigState> emit,
  ) {
    emit(state.copyWith(deliveryType: event.deliveryType));
  }

  void _onPriceChanged(EditGigPriceChanged event, Emitter<EditGigState> emit) {
    emit(state.copyWith(price: event.price));
  }

  void _onDeliveryTimeChanged(
    EditGigDeliveryTimeChanged event,
    Emitter<EditGigState> emit,
  ) {
    emit(state.copyWith(deliveryTimeInDays: event.days));
  }

  void _onRevisionsChanged(
    EditGigRevisionsChanged event,
    Emitter<EditGigState> emit,
  ) {
    emit(state.copyWith(revisions: event.revisions));
  }

  void _onTagsChanged(EditGigTagsChanged event, Emitter<EditGigState> emit) {
    emit(state.copyWith(tags: event.tags));
  }

  void _onDeliverablesChanged(
    EditGigDeliverablesChanged event,
    Emitter<EditGigState> emit,
  ) {
    emit(state.copyWith(deliverables: event.deliverables));
  }

  void _onRequirementsChanged(
    EditGigRequirementsChanged event,
    Emitter<EditGigState> emit,
  ) {
    emit(state.copyWith(requirements: event.requirements));
  }

  void _onThumbnailChanged(
    EditGigThumbnailChanged event,
    Emitter<EditGigState> emit,
  ) {
    emit(state.copyWith(thumbnailImage: event.path));
  }

  void _onGalleryImagesChanged(
    EditGigGalleryImagesChanged event,
    Emitter<EditGigState> emit,
  ) {
    emit(state.copyWith(galleryImages: event.paths));
  }

  void _onDemoVideoChanged(
    EditGigDemoVideoChanged event,
    Emitter<EditGigState> emit,
  ) {
    emit(state.copyWith(demoVideo: event.videoPath));
  }

  Future<void> _onSubmitted(
    EditGigSubmitted event,
    Emitter<EditGigState> emit,
  ) async {
    try {
      logger.i('EditGigBloc: Starting gig update submission');
      emit(state.copyWith(status: FormStatus.loading));

      // Create gig entity from state
      final gigEntity = GigEntity(
        id: state.gigId,
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
        creatorId: state.creatorId,
        createdAt: state.createdAt,
      );

      // Update the gig using use case
      final updatedGig = await updateGigUseCase(gigEntity);

      logger.i(
        'EditGigBloc: Gig updated successfully with ID: ${updatedGig.id}, Creator: ${updatedGig.creatorId}',
      );
      emit(state.copyWith(status: FormStatus.success));
    } catch (e) {
      logger.e('EditGigBloc: Error updating gig - $e');
      emit(state.copyWith(status: FormStatus.failure));
    }
  }

  void _onStatusReset(EditGigStatusReset event, Emitter<EditGigState> emit) {
    emit(state.copyWith(status: FormStatus.initial));
  }
}
