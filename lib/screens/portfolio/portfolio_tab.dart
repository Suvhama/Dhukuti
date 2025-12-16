import 'package:dhukuti/providers/market_provider.dart';
import 'package:dhukuti/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PortfolioTab extends StatefulWidget {
  const PortfolioTab({super.key});

  @override
  State<PortfolioTab> createState() => _PortfolioTabState();
}

class _PortfolioTabState extends State<PortfolioTab> {
  bool _initFetchDone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initFetchDone) {
      final user = context.read<UserProvider>().userModel;
      if (user != null) {
        context.read<MarketProvider>().fetchPortfolio(user.uid);
        _initFetchDone = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final marketProvider = context.watch<MarketProvider>();
    
    // Auto-fetch if user becomes available later and we haven't fetched
    if (!_initFetchDone && userProvider.userModel != null) {
       // use Future.microtask to avoid build-time state changes if necessary, 
       // but strictly speaking safe if we don't cause rebuild loop.
       // Safest to do in microtask.
       Future.microtask(() {
         if (mounted && !_initFetchDone) {
            context.read<MarketProvider>().fetchPortfolio(userProvider.userModel!.uid);
            setState(() => _initFetchDone = true);
         }
       });
    }

    if (userProvider.errorMessage != null) {
      return Center(child: Text("Error: ${userProvider.errorMessage}"));
    }

    final portfolio = marketProvider.portfolio;
    final currentPrice = marketProvider.currentPrice ?? 0;

    if (userProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (portfolio == null || marketProvider.isLoadingPortfolio) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentValue = portfolio.totalSilverTola * currentPrice;
    final profitLoss = currentValue - portfolio.totalInvestedAmount;
    final isProfit = profitLoss >= 0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("My Portfolio", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildSummaryCard("Current Holdings", "${portfolio.totalSilverTola.toStringAsFixed(2)} Tola"),
          const SizedBox(height: 10),
          _buildSummaryCard("Total Investment", "Rs. ${portfolio.totalInvestedAmount.toStringAsFixed(2)}"),
          const SizedBox(height: 10),
          _buildSummaryCard(
            "Profit / Loss",
            "Rs. ${profitLoss.abs().toStringAsFixed(2)}",
            valueColor: isProfit ? Colors.green : Colors.red,
            subtitle: isProfit ? "Profit" : "Loss",
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, {Color? valueColor, String? subtitle}) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: valueColor)) : null,
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ),
    );
  }
}
