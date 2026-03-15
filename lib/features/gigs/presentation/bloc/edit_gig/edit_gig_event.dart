part of 'edit_gig_bloc.dart';

sealed class EditGigEvent extends Equatable {
  const EditGigEvent();

  @override
  List<Object> get props => [];
}

class EditGigInitialized extends EditGigEvent {
  final GigEntity gig;
  const EditGigInitialized(this.gig);
  @override
  List<Object> get props => [gig];
}

class EditGigTitleChanged extends EditGigEvent {
  final String title;
  const EditGigTitleChanged(this.title);
  @override
  List<Object> get props => [title];
}

class EditGigDescriptionChanged extends EditGigEvent {
  final String description;
  const EditGigDescriptionChanged(this.description);
  @override
  List<Object> get props => [description];
}

class EditGigCategoryChanged extends EditGigEvent {
  final SkillEntity category;
  const EditGigCategoryChanged(this.category);
  @override
  List<Object> get props => [category];
}

class EditGigDeliveryTypeChanged extends EditGigEvent {
  final DeliveryTypes deliveryType;
  const EditGigDeliveryTypeChanged(this.deliveryType);
  @override
  List<Object> get props => [deliveryType];
}

class EditGigPriceChanged extends EditGigEvent {
  final double price;
  const EditGigPriceChanged(this.price);
  @override
  List<Object> get props => [price];
}

class EditGigDeliveryTimeChanged extends EditGigEvent {
  final int days;
  const EditGigDeliveryTimeChanged(this.days);
  @override
  List<Object> get props => [days];
}

class EditGigRevisionsChanged extends EditGigEvent {
  final int revisions;
  const EditGigRevisionsChanged(this.revisions);
  @override
  List<Object> get props => [revisions];
}

class EditGigTagsChanged extends EditGigEvent {
  final List<String> tags;
  const EditGigTagsChanged(this.tags);
  @override
  List<Object> get props => [tags];
}

class EditGigDeliverablesChanged extends EditGigEvent {
  final List<String> deliverables;
  const EditGigDeliverablesChanged(this.deliverables);
  @override
  List<Object> get props => [deliverables];
}

class EditGigRequirementsChanged extends EditGigEvent {
  final List<RequirementEntity> requirements;
  const EditGigRequirementsChanged(this.requirements);
  @override
  List<Object> get props => [requirements];
}

class EditGigThumbnailChanged extends EditGigEvent {
  final String path;
  const EditGigThumbnailChanged(this.path);
  @override
  List<Object> get props => [path];
}

class EditGigGalleryImagesChanged extends EditGigEvent {
  final List<String> paths;
  const EditGigGalleryImagesChanged(this.paths);
  @override
  List<Object> get props => [paths];
}

class EditGigDemoVideoChanged extends EditGigEvent {
  final String videoPath;
  const EditGigDemoVideoChanged(this.videoPath);
  @override
  List<Object> get props => [videoPath];
}

class EditGigSubmitted extends EditGigEvent {
  const EditGigSubmitted();
}

class EditGigStatusReset extends EditGigEvent {
  const EditGigStatusReset();
}
