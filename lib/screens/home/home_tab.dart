import 'package:dhukuti/providers/market_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final marketProvider = context.watch<MarketProvider>();
    final price = marketProvider.currentPrice;
    final isLoading = marketProvider.isLoadingPrice;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Silver Price",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("NPR / Tola", style: TextStyle(fontSize: 16)),
                  if (isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (price == null)
                     const Text(
                      "Error",
                      style: TextStyle(color: Colors.red),
                    )
                  else
                    Text(
                      "Rs. ${price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            "Quick Actions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
}
