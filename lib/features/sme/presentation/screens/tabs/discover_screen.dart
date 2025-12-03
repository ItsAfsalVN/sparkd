import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/features/sme/presentation/widgets/custom_search_box.dart';
import 'package:sparkd/features/sme/presentation/widgets/sme_gig_card.dart';
import 'package:sparkd/core/services/service_locator.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/form_statuses.dart';
import 'package:sparkd/features/gigs/presentation/bloc/discover_gig/discover_gig_bloc.dart';

class SmeDiscoverScreen extends StatelessWidget {
  const SmeDiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    return BlocProvider(
      create: (context) => sl<DiscoverGigBloc>()..add(DiscoverGigsRequested()),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: kToolbarHeight + 54,
          automaticallyImplyLeading: false,
          elevation: 0,
          scrolledUnderElevation: 0.0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 40, left: 10, right: 10),
            child: Column(
              spacing: 6,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Discover", style: textStyles.heading2),
                const CustomSearchBox(hintText: "Search for gigs"),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: BlocBuilder<DiscoverGigBloc, DiscoverGigState>(
              builder: (context, state) {
                if (state.status == FormStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.status == FormStatus.failure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Failed to load gigs"),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<DiscoverGigBloc>().add(
                              DiscoverGigsRequested(),
                            );
                          },
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  );
                } else if (state.status == FormStatus.success &&
                    state.gigs.isEmpty) {
                  return const Center(child: Text("No gigs found"));
                } else if (state.status == FormStatus.success) {
                  return ListView.builder(
                    itemCount: state.gigs.length,
                    itemBuilder: (context, index) {
                      final gig = state.gigs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: SmeGigCard(gig: gig),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}
