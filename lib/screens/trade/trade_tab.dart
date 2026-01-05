import 'dart:async';
import 'package:dhukuti/models/transaction_model.dart';
import 'package:dhukuti/providers/market_provider.dart';
import 'package:dhukuti/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TradeTab extends StatefulWidget {
  const TradeTab({super.key});

  @override
  State<TradeTab> createState() => _TradeTabState();
}

class _TradeTabState extends State<TradeTab> {
  final _quantityController = TextEditingController();
  bool _isLoading = false;
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
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
    final isMarketOpen = marketProvider.isMarketOpen;
    final marketStatusMsg = marketProvider.marketStatusMessage;

    if (price == null) {
      return const Center(child: Text("Price currently unavailable"));
    }

    final formattedDate = DateFormat('EEEE, MMM d, yyyy').format(_currentTime);
    final formattedTime = DateFormat('h:mm:ss a').format(_currentTime);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Time and Date Display
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(formattedDate, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(formattedTime, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text("Trading Hours: 11:15 AM - 5:00 PM", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: isMarketOpen ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        marketStatusMsg,
                        style: TextStyle(
                          color: isMarketOpen ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),

          Center(child: Text("Today's Rate: Rs. $price / Tola", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 30),
          
          if (isMarketOpen) ...[
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
              const Center(child: CircularProgressIndicator())
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
          ] else ...[
             Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: Colors.red.shade50,
                 borderRadius: BorderRadius.circular(8),
                 border: Border.all(color: Colors.red.shade200),
               ),
               child: const Column(
                 children: [
                   Icon(Icons.lock_clock, size: 48, color: Colors.red),
                   SizedBox(height: 10),
                   Text(
                     "Trading is currently paused.",
                     textAlign: TextAlign.center,
                     style: TextStyle(fontSize: 16, color: Colors.red),
                   ),
                 ],
               ),
             )
          ]
        ],
      ),
    );
  }
}

