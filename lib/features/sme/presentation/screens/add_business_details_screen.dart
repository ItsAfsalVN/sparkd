import 'package:flutter/material.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/presentation/widgets/custom_dropdown.dart';
import 'package:sparkd/core/presentation/widgets/custom_text_field.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';

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

  final FocusNode _businessFocusNode = FocusNode();
  final FocusNode _categoryFocusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();

  String? _selectedCategory;

  @override
  void dispose() {
    _businessNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      final businessName = _businessNameController.text.trim();
      final category = _selectedCategory;
      final location = _locationController.text.trim();

      debugPrint('Business Name: $businessName');
      debugPrint('Category: $category');
      debugPrint('Location: $location');

      // Navigate to next screen or save data
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textStyles;
    final bool isLightMode = Theme.of(context).brightness == Brightness.light;
    final logo = isLightMode
        ? 'assets/images/logo_light.png'
        : 'assets/images/logo_dark.png';

    return Scaffold(
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
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 24,
                    children: [
                      // Header Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tell Us About Your Business",
                            style: textStyles.heading2.copyWith(height: 1.2),
                          ),
                          Text(
                            "We only need a few details to connect you with the right local talent.",
                            style: textStyles.paragraph.copyWith(
                              fontSize: 14,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Business Name Field
                      CustomTextField(
                        controller: _businessNameController,
                        hintText: "e.g., Lulu Cafe, Edappally",
                        labelText: "Business Name",
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your business name';
                          }
                          if (value.trim().length < 2) {
                            return 'Business name must be at least 2 characters';
                          }
                          return null;
                        },
                        focusNode: _businessFocusNode,
                        onFieldSubmitted: (value) {
                          _categoryFocusNode.requestFocus();
                        },
                        textInputAction: TextInputAction.next,
                        autoFocus: true,
                      ),

                      BusinessCategoryDropdown(
                        focusNode: _categoryFocusNode,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedCategory = value;
                            _locationFocusNode.requestFocus();
                          });
                        },
                      ),

                      // Location Field with Auto-Suggest hint
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            focusNode: _locationFocusNode,
                            controller: _locationController,
                            hintText: "e.g., Kochi, Aluva",
                            labelText: "Your Location",
                            prefixIcon: Icon(
                              Icons.location_on_outlined,
                              size: 20,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your location';
                              }
                              if (value.trim().length < 2) {
                                return 'Location must be at least 2 characters';
                              }
                              return null;
                            },
                            onFieldSubmitted: (value) {
                              _handleContinue();
                            },
                            textInputAction: TextInputAction.done,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4, top: 4),
                            child: Text(
                              'Enter your city or area for hyper-local matching',
                              style: textStyles.subtext.copyWith(
                                fontSize: 12,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Info Card explaining why we need this info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                            Expanded(
                              child: Text(
                                'This information helps us match you with talented local creators who understand your area and can provide professional services.',
                                style: textStyles.subtext.copyWith(
                                  fontSize: 13,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: CustomButton(
                onPressed: _handleContinue,
                title: "Continue",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
