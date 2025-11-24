part of 'create_new_gig_bloc.dart';

sealed class CreateNewGigEvent extends Equatable {
  const CreateNewGigEvent();

  @override
  List<Object> get props => [];
}

class GigTitleChanged extends CreateNewGigEvent {
  final String title;
  const GigTitleChanged(this.title);
  @override
  List<Object> get props => [title];
}

class GigDescriptionChanged extends CreateNewGigEvent {
  final String description;
  const GigDescriptionChanged(this.description);
  @override
  List<Object> get props => [description];
}

class GigCategoryChanged extends CreateNewGigEvent {
  final SkillEntity category;
  const GigCategoryChanged(this.category);
  @override
  List<Object> get props => [category];
}

class GigDeliveryTypeChanged extends CreateNewGigEvent {
  final DeliveryTypes deliveryType;
  const GigDeliveryTypeChanged(this.deliveryType);
  @override
  List<Object> get props => [deliveryType];
}

class GigPriceChanged extends CreateNewGigEvent {
  final double price;
  const GigPriceChanged(this.price);
  @override
  List<Object> get props => [price];
}

class GigDeliveryTimeChanged extends CreateNewGigEvent {
  final int days;
  const GigDeliveryTimeChanged(this.days);
  @override
  List<Object> get props => [days];
}

class GigRevisionsChanged extends CreateNewGigEvent {
  final int revisions;
  const GigRevisionsChanged(this.revisions);
  @override
  List<Object> get props => [revisions];
}

class GigTagsChanged extends CreateNewGigEvent {
  final List<String> tags;
  const GigTagsChanged(this.tags);
  @override
  List<Object> get props => [tags];
}

class GigDeliverablesChanged extends CreateNewGigEvent {
  final List<String> deliverables;
  const GigDeliverablesChanged(this.deliverables);
  @override
  List<Object> get props => [deliverables];
}

class GigRequirementsChanged extends CreateNewGigEvent {
  final List<String> requirements;
  const GigRequirementsChanged(this.requirements);
  @override
  List<Object> get props => [requirements];
}

class GigPostInstructionsChanged extends CreateNewGigEvent {
  final List<String> instructions;
  const GigPostInstructionsChanged(this.instructions);
  @override
  List<Object> get props => [instructions];
}

class GigThumbnailChanged extends CreateNewGigEvent {
  final String path;
  const GigThumbnailChanged(this.path);
  @override
  List<Object> get props => [path];
}

class GigGalleryImagesChanged extends CreateNewGigEvent {
  final List<String> paths;
  const GigGalleryImagesChanged(this.paths);
  @override
  List<Object> get props => [paths];
}

class CreateGigSubmitted extends CreateNewGigEvent {
  const CreateGigSubmitted();
}

class CreateGigStatusReset extends CreateNewGigEvent {
  const CreateGigStatusReset();
}
