import 'package:flutter/material.dart';
import 'package:sparkd/core/presentation/widgets/sme/custom_search_box.dart';
import 'package:sparkd/core/presentation/widgets/sme/gig_card.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';

class SmeDiscoverScreen extends StatelessWidget {
  const SmeDiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 120,
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0.0,
        flexibleSpace: Padding(
          padding: EdgeInsets.only(top: 40, bottom: 10, left: 20, right: 20),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Discover", style: textStyles.heading2),
              CustomSearchBox(hintText: "Search for gigs"),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              spacing: 10,
              children: [
                SmeGigCard(),
                SmeGigCard(),
                SmeGigCard(),
                SmeGigCard(),
                SmeGigCard(),
                SmeGigCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
