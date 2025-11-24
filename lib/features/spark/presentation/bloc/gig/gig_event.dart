part of 'gig_bloc.dart';

sealed class GigEvent extends Equatable {
  const GigEvent();

  @override
  List<Object> get props => [];
}

class GigTitleChanged extends GigEvent {
  final String title;
  const GigTitleChanged(this.title);
  @override
  List<Object> get props => [title];
}

class GigDescriptionChanged extends GigEvent {
  final String description;
  const GigDescriptionChanged(this.description);
  @override
  List<Object> get props => [description];
}

class GigCategoryChanged extends GigEvent {
  final SkillEntity category;
  const GigCategoryChanged(this.category);
  @override
  List<Object> get props => [category];
}

class GigDeliveryTypeChanged extends GigEvent {
  final DeliveryTypes deliveryType;
  const GigDeliveryTypeChanged(this.deliveryType);
  @override
  List<Object> get props => [deliveryType];
}

class GigPriceChanged extends GigEvent {
  final double price;
  const GigPriceChanged(this.price);
  @override
  List<Object> get props => [price];
}

class GigDeliveryTimeChanged extends GigEvent {
  final int days;
  const GigDeliveryTimeChanged(this.days);
  @override
  List<Object> get props => [days];
}

class GigRevisionsChanged extends GigEvent {
  final int revisions;
  const GigRevisionsChanged(this.revisions);
  @override
  List<Object> get props => [revisions];
}

class GigTagsChanged extends GigEvent {
  final List<String> tags;
  const GigTagsChanged(this.tags);
  @override
  List<Object> get props => [tags];
}

class GigDeliverablesChanged extends GigEvent {
  final List<String> deliverables;
  const GigDeliverablesChanged(this.deliverables);
  @override
  List<Object> get props => [deliverables];
}

class GigRequirementsChanged extends GigEvent {
  final List<String> requirements;
  const GigRequirementsChanged(this.requirements);
  @override
  List<Object> get props => [requirements];
}

class GigPostInstructionsChanged extends GigEvent {
  final List<String> instructions;
  const GigPostInstructionsChanged(this.instructions);
  @override
  List<Object> get props => [instructions];
}

class GigThumbnailChanged extends GigEvent {
  final String path;
  const GigThumbnailChanged(this.path);
  @override
  List<Object> get props => [path];
}

class GigGalleryImagesChanged extends GigEvent {
  final List<String> paths;
  const GigGalleryImagesChanged(this.paths);
  @override
  List<Object> get props => [paths];
}

class GigDemoVideoChanged extends GigEvent {
  final String? videoPath;
  const GigDemoVideoChanged(this.videoPath);
  @override
  List<Object> get props => [videoPath ?? ''];
}

class CreateGigSubmitted extends GigEvent {
  const CreateGigSubmitted();
}

class CreateGigStatusReset extends GigEvent {
  const CreateGigStatusReset();
}
