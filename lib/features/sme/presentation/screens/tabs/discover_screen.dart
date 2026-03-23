import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/features/sme/presentation/widgets/custom_search_box.dart';
import 'package:sparkd/features/sme/presentation/widgets/sme_gig_card.dart';
import 'package:sparkd/core/services/service_locator.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/form_statuses.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/gigs/presentation/bloc/discover_gig/discover_gig_bloc.dart';

class SmeDiscoverScreen extends StatefulWidget {
  const SmeDiscoverScreen({super.key});

  @override
  State<SmeDiscoverScreen> createState() => _SmeDiscoverScreenState();
}

class _SmeDiscoverScreenState extends State<SmeDiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final DiscoverGigBloc _discoverGigBloc;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _discoverGigBloc = sl<DiscoverGigBloc>();
    _searchFocusNode = FocusNode();
    logger.i('SmeDiscoverScreen: Initialized, fetching all gigs...');
    _discoverGigBloc.add(DiscoverGigsRequested());
  }

  void _triggerSearch() {
    final query = _searchController.text;
    logger.i('SmeDiscoverScreen: Searching for gigs with query: "$query"');
    FocusScope.of(context).unfocus();
    _discoverGigBloc.add(DiscoverGigSearchRequested(query: query));
  }

  @override
  void dispose() {
    _discoverGigBloc.close();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    final colorTheme = Theme.of(context).colorScheme;
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
                IntrinsicHeight(
                  child: Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: CustomSearchBox(
                          hintText: "Search for gigs",
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onFieldSubmitted: (_) => _triggerSearch(),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: colorTheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          minimumSize: const Size(0, 56),
                        ),
                        onPressed: _triggerSearch,
                        child: Icon(
                          Icons.search,
                          color: colorTheme.onPrimary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
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
                  logger.i('SmeDiscoverScreen: Loading gigs...');
                  return const Center(child: CircularProgressIndicator());
                } else if (state.status == FormStatus.failure) {
                  logger.e(
                    'SmeDiscoverScreen: Error loading gigs: ${state.errorMessage}',
                  );
                  return Center(
                    child: Column(
                      spacing: 16,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.errorMessage ?? 'Failed to load gigs',
                          textAlign: TextAlign.center,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            logger.i('SmeDiscoverScreen: Retry loading gigs');
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
                  logger.i(
                    'SmeDiscoverScreen: No gigs found for query: "${state.query ?? ''}"',
                  );
                  return Center(
                    child: Column(
                      spacing: 12,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: colorTheme.onSurface.withValues(alpha: 0.5),
                        ),
                        Text(
                          state.query != null && state.query!.isNotEmpty
                              ? 'No gigs found for "${state.query}"'
                              : 'No gigs available',
                        ),
                      ],
                    ),
                  );
                } else if (state.status == FormStatus.success) {
                  logger.i(
                    'SmeDiscoverScreen: Displaying ${state.gigs.length} gigs',
                  );
                  return ListView.separated(
                    itemCount: state.gigs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final gig = state.gigs[index];
                      return SmeGigCard(gig: gig);
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
