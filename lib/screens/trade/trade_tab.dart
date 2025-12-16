import 'package:dhukuti/models/transaction_model.dart';
import 'package:dhukuti/providers/market_provider.dart';
import 'package:dhukuti/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TradeTab extends StatefulWidget {
  const TradeTab({super.key});

  @override
  State<TradeTab> createState() => _TradeTabState();
}

class _TradeTabState extends State<TradeTab> {
  final _quantityController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _handleTrade(TransactionType type) async {
    final qtyText = _quantityController.text;
    final qty = double.tryParse(qtyText);

    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter valid quantity")));
      return;
    }

    final user = context.read<UserProvider>().userModel;
    if (user == null) return;

    setState(() => _isLoading = true);
    
    try {
      await context.read<MarketProvider>().executeTrade(
        userId: user.uid,
        type: type,
        quantityTola: qty,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${type.name.toUpperCase()} Success!")));
        _quantityController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final marketProvider = context.watch<MarketProvider>();
    final price = marketProvider.currentPrice;

    if (price == null) {
      return const Center(child: Text("Price currently unavailable"));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text("Today's Rate: Rs. $price / Tola", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          TextField(
            controller: _quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "Quantity (Tola)",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    onPressed: () => _handleTrade(TransactionType.buy),
                    child: const Text("BUY SILVER"),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    onPressed: () => _handleTrade(TransactionType.sell),
                    child: const Text("SELL SILVER"),
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }
}
