import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sparkd/core/presentation/widgets/spark/gig_card.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/form_statuses.dart';
import 'package:sparkd/core/services/service_locator.dart';
import 'package:sparkd/features/spark/presentation/bloc/gig/gig_bloc.dart';
import 'package:sparkd/features/spark/presentation/screens/create_new_gig_provider.dart';

class SparkGigScreen extends StatefulWidget {
  const SparkGigScreen({super.key});

  @override
  State<SparkGigScreen> createState() => _SparkGigScreenState();
}

class _SparkGigScreenState extends State<SparkGigScreen> {
  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (context) {
        final bloc = sl<GigBloc>();
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          bloc.add(LoadUserGigs(currentUser.uid));
        }
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text("My Gigs", style: textStyles.heading2),
          scrolledUnderElevation: 0.0,
          surfaceTintColor: Colors.transparent,
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateNewGigProvider(),
              ),
            );

            // Refresh gigs list if a new gig was created
            if (result == true) {
              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser != null && context.mounted) {
                context.read<GigBloc>().add(LoadUserGigs(currentUser.uid));
              }
            }
          },
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          child: const Icon(Icons.add, size: 30),
        ),

        body: BlocBuilder<GigBloc, GigState>(
          builder: (context, state) {
            if (state.status == FormStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == FormStatus.failure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Failed to load gigs', style: textStyles.heading3),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        final currentUser = FirebaseAuth.instance.currentUser;
                        if (currentUser != null) {
                          context.read<GigBloc>().add(
                            LoadUserGigs(currentUser.uid),
                          );
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state.userGigs.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  final currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    context.read<GigBloc>().add(LoadUserGigs(currentUser.uid));
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No Gigs Yet',
                            style: textStyles.heading3.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CreateNewGigProvider(),
                                ),
                              );
                            },
                            child: Text(
                              'Create a gig now!',
                              style: textStyles.subtext.copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: colorScheme.primary.withValues(
                                  alpha: 0.7,
                                ),
                                color: colorScheme.primary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  context.read<GigBloc>().add(LoadUserGigs(currentUser.uid));
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      spacing: 12,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: state.userGigs.map((gig) {
                        return GigCard(
                          title: gig.title,
                          description: gig.description,
                          price: gig.price,
                          thumbnailImage: gig.thumbnailImage,
                          category: gig.categoryId,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
