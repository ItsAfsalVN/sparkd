import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkd/features/auth/presentation/screens/role_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final List<Widget> _pages = [
    const OnboardingPage(
      image: 'assets/images/onboarding/connection.png',
      title: 'Local Connection',
      description:
          'Connecting the bright digital talent of our neighbourhoods with the local businesses that are the heart of our community.',
    ),
    const OnboardingPage(
      image: 'assets/images/onboarding/local_shops.png',
      title: 'For Our Local Shops',
      description:
          "Find affordable, fixed-price 'Gig Packs' for social media, design, and more — offered by talented young creators from your community.",
    ),
    const OnboardingPage(
      image: 'assets/images/onboarding/creators.png',
      title: 'For Young Creators',
      description:
          'Offer your digital skills through flexible, value-based projects. Gain real-world experience, build a professional portfolio, and earn on your own schedule.',
    ),
    const OnboardingPage(
      image: 'assets/images/onboarding/marketplace.png',
      title: 'More Than a Market Place',
      description:
          "This is about launching careers for our youth and helping the local shops we love thrive in the digital world. It's growth, powered by our community.",
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    final bool isLightMode = Theme.of(context).brightness == Brightness.light;
    final logo = isLightMode
        ? 'assets/images/logo_light.png'
        : 'assets/images/logo_dark.png';

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const RoleSelectionScreen(),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        body: SafeArea(
          child: Column(
            spacing: 20,
            children: [
              SizedBox(
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        logo,
                        width: 105,
                        height: 35,
                        fit: BoxFit.contain,
                      ),
                      if (!isLastPage)
                        TextButton(
                          onPressed: () {
                            _controller.animateToPage(
                              _pages.length - 1,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            'Skip >>',
                            style: TextStyle(
                              height: .9,
                              color: Theme.of(context).colorScheme.primary,
                              fontFamily: 'Poppins',
                              fontSize: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 1. PageView
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: _pages,
                ),
              ),

              // 2. Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: WormEffect(
                      activeDotColor: Theme.of(context).colorScheme.primary,
                      dotColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: .5),
                      dotHeight: 10,
                      dotWidth: 10,
                    ),
                  ),
                ),
              ),

              // 3. Button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: CustomButton(
                  onPressed: () {
                    if (isLastPage) {
                      context.read<AuthBloc>().add(AuthOnboardingCompleted());
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  color: isLightMode ? Colors.white : Colors.black,
                  title: isLastPage ? 'Continue' : 'Next',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(image, width: double.infinity, fit: BoxFit.contain),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(
                title,
                style: Theme.of(context).textStyles.heading1.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  height: 1,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textStyles.subtext.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
