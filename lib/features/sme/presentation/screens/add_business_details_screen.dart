import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/presentation/widgets/custom_dropdown.dart';
import 'package:sparkd/core/presentation/widgets/custom_text_field.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/form_statuses.dart';
import 'package:sparkd/features/sme/presentation/bloc/business_details_bloc.dart';

class AddBusinessDetailsScreen extends StatefulWidget {
  const AddBusinessDetailsScreen({super.key});

  @override
  State<AddBusinessDetailsScreen> createState() =>
      _AddBusinessDetailsScreenState();
}

class _AddBusinessDetailsScreenState extends State<AddBusinessDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _businessFocusNode = FocusNode();
  final _categoryFocusNode = FocusNode();
  final _locationFocusNode = FocusNode();

  @override
  void dispose() {
    _businessNameController.dispose();
    _locationController.dispose();
    _businessFocusNode.dispose();
    _categoryFocusNode.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }

  void _handleContinue() {
    context.read<BusinessDetailsBloc>().add(const SubmitBusinessDetails());
  }

  bool _isFormValid(BusinessDetailsState state) {
    return state.businessName.trim().length >= 2 &&
        state.category.isNotEmpty &&
        state.location.trim().length >= 2;
  }

  String? _validateBusinessName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your business name';
    }
    if (value.trim().length < 2) {
      return 'Business name must be at least 2 characters';
    }
    return null;
  }

  String? _validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your location';
    }
    if (value.trim().length < 2) {
      return 'Location must be at least 2 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final logo = isLightMode
        ? 'assets/images/logo_light.png'
        : 'assets/images/logo_dark.png';

    return BlocListener<BusinessDetailsBloc, BusinessDetailsState>(
      listener: (context, state) {
        if (state.formStatus == FormStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        // Success handling will be done by AuthBloc navigation
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          scrolledUnderElevation: 0.0,
          title: Image.asset(logo, width: 105, height: 35, fit: BoxFit.contain),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 24,
                      children: [
                        _buildHeader(colorScheme),
                        _buildBusinessNameField(),
                        _buildCategoryDropdown(),
                        _buildLocationField(colorScheme),
                        _buildInfoCard(colorScheme),
                      ],
                    ),
                  ),
                ),
              ),
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    final textStyles = Theme.of(context).textStyles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          "Tell Us About Your Business",
          style: textStyles.heading2.copyWith(height: 1.2),
        ),
        Text(
          "We only need a few details to connect you with the right local talent.",
          style: textStyles.paragraph.copyWith(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessNameField() {
    return BlocBuilder<BusinessDetailsBloc, BusinessDetailsState>(
      buildWhen: (previous, current) =>
          previous.businessName != current.businessName,
      builder: (context, state) {
        return CustomTextField(
          autoFocus: true,
          controller: _businessNameController,
          focusNode: _businessFocusNode,
          hintText: "e.g., Lulu Cafe, Edappally",
          labelText: "Business Name",
          textInputAction: TextInputAction.next,
          validator: _validateBusinessName,
          onChanged: (value) {
            context.read<BusinessDetailsBloc>().add(BusinessNameChanged(value));
          },
          onFieldSubmitted: (_) => _categoryFocusNode.requestFocus(),
        );
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return BusinessCategoryDropdown(
      focusNode: _categoryFocusNode,
      onChanged: (value) {
        if (value != null) {
          context.read<BusinessDetailsBloc>().add(CategoryChanged(value));
          _locationFocusNode.requestFocus();
        }
      },
    );
  }

  Widget _buildLocationField(ColorScheme colorScheme) {
    return BlocBuilder<BusinessDetailsBloc, BusinessDetailsState>(
      buildWhen: (previous, current) => previous.location != current.location,
      builder: (context, state) {
        return CustomTextField(
          controller: _locationController,
          focusNode: _locationFocusNode,
          hintText: "e.g., Kochi, Aluva",
          labelText: "Your Location",
          textInputAction: TextInputAction.done,
          prefixIcon: Icon(
            Icons.location_on_outlined,
            size: 20,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          validator: _validateLocation,
          onChanged: (value) {
            context.read<BusinessDetailsBloc>().add(LocationChanged(value));
          },
          onFieldSubmitted: (_) {
            if (_isFormValid(state)) {
              _handleContinue();
            }
          },
        );
      },
    );
  }

  Widget _buildInfoCard(ColorScheme colorScheme) {
    final textStyles = Theme.of(context).textStyles;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
          Expanded(
            child: Text(
              'This information helps us match you with talented local creators who understand your area and can provide professional services.',
              style: textStyles.subtext.copyWith(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return BlocBuilder<BusinessDetailsBloc, BusinessDetailsState>(
      buildWhen: (previous, current) =>
          previous.formStatus != current.formStatus ||
          previous.businessName != current.businessName ||
          previous.category != current.category ||
          previous.location != current.location,
      builder: (context, state) {
        final isLoading = state.formStatus == FormStatus.submitting;
        final isValid = _isFormValid(state);

        return Padding(
          padding: const EdgeInsets.all(20),
          child: CustomButton(
            onPressed: isValid ? _handleContinue : null,
            title: isLoading ? "Submitting..." : "Continue",
            isLoading: isLoading,
          ),
        );
      },
    );
  }
}
