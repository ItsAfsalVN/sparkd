import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/features/sme/presentation/widgets/custom_search_box.dart';
import 'package:sparkd/features/sme/presentation/widgets/sme_gig_card.dart';
import 'package:sparkd/core/services/service_locator.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/form_statuses.dart';
import 'package:sparkd/features/gigs/presentation/bloc/discover_gig/discover_gig_bloc.dart';

class SmeDiscoverScreen extends StatefulWidget {
  const SmeDiscoverScreen({super.key});

  @override
  State<SmeDiscoverScreen> createState() => _SmeDiscoverScreenState();
}

class _SmeDiscoverScreenState extends State<SmeDiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final DiscoverGigBloc _discoverGigBloc;

  @override
  void initState() {
    super.initState();
    _discoverGigBloc = sl<DiscoverGigBloc>()..add(DiscoverGigsRequested());
  }

  void _triggerSearch() {
    _discoverGigBloc.add(
      DiscoverGigSearchRequested(query: _searchController.text),
    );
  }

  @override
  void dispose() {
    _discoverGigBloc.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    return BlocProvider.value(
      value: _discoverGigBloc,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: kToolbarHeight + 68,
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
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: CustomSearchBox(
                        hintText: "Search for gigs",
                        controller: _searchController,
                        onFieldSubmitted: (_) => _triggerSearch(),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _triggerSearch,
                      child: const Text("Search"),
                    ),
                  ],
                ),
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
                      spacing: 16,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Failed to load gigs"),
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
