import 'package:dhukuti/providers/market_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final marketProvider = context.watch<MarketProvider>();
    final silverPrice = marketProvider.currentSilverPrice;
    final goldPrice = marketProvider.currentGoldPrice;
    final isLoading = marketProvider.isLoadingPrice;

    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Live Metal Rates (Today)",
            style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          _buildPriceCard("Silver", silverPrice, isLoading, screenWidth, Colors.blueGrey),
          const SizedBox(height: 10),
          _buildPriceCard("Gold (Hallmark)", goldPrice, isLoading, screenWidth, Colors.orange),

          const SizedBox(height: 32),

          Text(
            "Quick Actions",
            style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // Quick actions could navigate to the Trade tab programmatically
          // For now just showing them as visual elements or shortcuts
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.show_chart),
                  label: const Text("View Portfolio"),
                  onPressed: () {
                     // Tab switching handled by parent usually, or we can use keys/provider to switch
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(String title, double? price, bool isLoading, double screenWidth, Color iconColor) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.diamond, color: iconColor, size: 20),
                const SizedBox(width: 10),
                Text(title, style: TextStyle(fontSize: screenWidth * 0.04)),
              ],
            ),
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (price == null)
              const Text("Error", style: TextStyle(color: Colors.red))
            else
              Text(
                "Rs. ${price.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
