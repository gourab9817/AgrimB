import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../widgets/dashboard/dashboard_appbar.dart';
import '../../widgets/dashboard/weather_card.dart'; // This now imports the new weather card
import '../../widgets/dashboard/feature_card.dart';
import '../../widgets/dashboard/mandi_bhav_card.dart';
import '../../widgets/dashboard/best_deals_card.dart';
import '../../widgets/dashboard/section_title.dart';
import '../../../core/constants/app_assets.dart';
import '../../widgets/appbar/navbar.dart';
import 'buy_card.dart';
// Remove the old weather_data.dart import - it's no longer needed
import 'package:provider/provider.dart';
import '../../../view_model/profile/profile_view_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PageController _buyCropController = PageController(viewportFraction: 0.7);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileViewModel>(context, listen: false).fetchUserData();
    });
  }

  @override
  void dispose() {
    _buyCropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dummy data for demonstration
    final mandiData = [
      {'name': 'Mustard', 'price': '₹71,000/MT', 'change': '+₹12,496 since last month'},
      {'name': 'Wheat', 'price': '₹28,500/MT', 'change': '+₹638 since last month'},
    ];

    // Best deals data 
    final bestDealsList = [
      {'image': AppAssets.wheat, 'title': 'Premium Wheat Deal'},
      {'image': AppAssets.vagetables, 'title': 'Fresh Vegetables'},
      {'image': AppAssets.tomato, 'title': 'Organic Tomatoes'},
    ];

    return Scaffold(
      appBar: const DashboardAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // New dynamic weather card - no parameters needed
              const Center(
                child: WeatherCard(), // This will now show real-time weather
              ),
              
              const SizedBox(height: 16),
              
              const SectionTitle(title: 'Buy Crop'),
              Center(
                child: FeatureCard(
                  onTap: () {
                    Navigator.pushNamed(context, '/buy');
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              MandiBhavCard(mandiData: mandiData),
              
              const SectionTitle(title: 'Best Deals'),
              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: bestDealsList.map((deal) => Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: BestDealsCard(
                      image: deal['image']!,
                      title: deal['title']!,
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}