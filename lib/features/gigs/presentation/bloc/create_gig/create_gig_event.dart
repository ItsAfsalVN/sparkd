part of 'create_gig_bloc.dart';

sealed class CreateGigEvent extends Equatable {
  const CreateGigEvent();

  @override
  List<Object> get props => [];
}

class GigTitleChanged extends CreateGigEvent {
  final String title;
  const GigTitleChanged(this.title);
  @override
  List<Object> get props => [title];
}

class GigDescriptionChanged extends CreateGigEvent {
  final String description;
  const GigDescriptionChanged(this.description);
  @override
  List<Object> get props => [description];
}

class GigCategoryChanged extends CreateGigEvent {
  final SkillEntity category;
  const GigCategoryChanged(this.category);
  @override
  List<Object> get props => [category];
}

class GigDeliveryTypeChanged extends CreateGigEvent {
  final DeliveryTypes deliveryType;
  const GigDeliveryTypeChanged(this.deliveryType);
  @override
  List<Object> get props => [deliveryType];
}

class GigPriceChanged extends CreateGigEvent {
  final double price;
  const GigPriceChanged(this.price);
  @override
  List<Object> get props => [price];
}

class GigDeliveryTimeChanged extends CreateGigEvent {
  final int days;
  const GigDeliveryTimeChanged(this.days);
  @override
  List<Object> get props => [days];
}

class GigRevisionsChanged extends CreateGigEvent {
  final int revisions;
  const GigRevisionsChanged(this.revisions);
  @override
  List<Object> get props => [revisions];
}

class GigTagsChanged extends CreateGigEvent {
  final List<String> tags;
  const GigTagsChanged(this.tags);
  @override
  List<Object> get props => [tags];
}

class GigDeliverablesChanged extends CreateGigEvent {
  final List<String> deliverables;
  const GigDeliverablesChanged(this.deliverables);
  @override
  List<Object> get props => [deliverables];
}

class GigRequirementsChanged extends CreateGigEvent {
  final List<String> requirements;
  const GigRequirementsChanged(this.requirements);
  @override
  List<Object> get props => [requirements];
}

class GigPostInstructionsChanged extends CreateGigEvent {
  final List<String> instructions;
  const GigPostInstructionsChanged(this.instructions);
  @override
  List<Object> get props => [instructions];
}

class GigThumbnailChanged extends CreateGigEvent {
  final String path;
  const GigThumbnailChanged(this.path);
  @override
  List<Object> get props => [path];
}

class GigGalleryImagesChanged extends CreateGigEvent {
  final List<String> paths;
  const GigGalleryImagesChanged(this.paths);
  @override
  List<Object> get props => [paths];
}

class GigDemoVideoChanged extends CreateGigEvent {
  final String? videoPath;
  const GigDemoVideoChanged(this.videoPath);
  @override
  List<Object> get props => [videoPath ?? ''];
}

class CreateGigSubmitted extends CreateGigEvent {
  const CreateGigSubmitted();
}

class CreateGigStatusReset extends CreateGigEvent {
  const CreateGigStatusReset();
}

class LoadUserGigs extends CreateGigEvent {
  final String userId;
  const LoadUserGigs(this.userId);
  @override
  List<Object> get props => [userId];
}
