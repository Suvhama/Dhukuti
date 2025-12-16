import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dhukuti/models/portfolio_model.dart';
import 'package:dhukuti/models/transaction_model.dart';
import 'package:dhukuti/services/price_service.dart';
import 'package:flutter/foundation.dart';

class MarketProvider extends ChangeNotifier {
  final PriceService _priceService = PriceService();
  
  double? _currentPrice;
  double? get currentPrice => _currentPrice;
  bool _isLoadingPrice = false;
  bool get isLoadingPrice => _isLoadingPrice;

  bool _isLoadingPortfolio = false;
  bool get isLoadingPortfolio => _isLoadingPortfolio;

  PortfolioModel? _portfolio;
  PortfolioModel? get portfolio => _portfolio;

  MarketProvider() {
    fetchPrice();
  }

  Future<void> fetchPrice() async {
    _isLoadingPrice = true;
    notifyListeners();
    try {
      _currentPrice = await _priceService.getSilverPrice();
    } catch (e) {
      debugPrint("Error fetching price: $e");
    } finally {
      _isLoadingPrice = false;
      notifyListeners();
    }
  }

  Future<void> fetchPortfolio(String userId) async {
    _isLoadingPortfolio = true;
    notifyListeners();
    try {
      final doc = await FirebaseFirestore.instance
          .collection('portfolios')
          .doc(userId)
          .get();

      if (doc.exists) {
        _portfolio = PortfolioModel.fromMap(doc.data()!, userId);
      } else {
        _portfolio = PortfolioModel(
            userId: userId, totalSilverTola: 0, totalInvestedAmount: 0);
      }
    } catch (e) {
      debugPrint("Error fetching portfolio: $e");
    } finally {
      _isLoadingPortfolio = false;
      notifyListeners();
    }
  }

  Future<void> executeTrade({
    required String userId,
    required TransactionType type,
    required double quantityTola,
  }) async {
    if (_currentPrice == null) throw Exception("Price not available");
    
    final totalAmount = quantityTola * _currentPrice!;
    final transactionId = FirebaseFirestore.instance.collection('transactions').doc().id;

    final transaction = TransactionModel(
      id: transactionId,
      userId: userId,
      type: type,
      quantityTola: quantityTola,
      ratePerTola: _currentPrice!,
      totalAmount: totalAmount,
      timestamp: DateTime.now(),
    );

    // Run transaction
    await FirebaseFirestore.instance.runTransaction((tx) async {
      // 1. Read Portfolio First (CRITICAL: All reads must happen before writes)
      final portRef = FirebaseFirestore.instance.collection('portfolios').doc(userId);
      final portDoc = await tx.get(portRef);
      
      double currentSilver = 0;
      double currentInvested = 0;

      if (portDoc.exists) {
        final data = portDoc.data()!;
        currentSilver = (data['totalSilverTola'] ?? 0).toDouble();
        currentInvested = (data['totalInvestedAmount'] ?? 0).toDouble();
      }

      if (type == TransactionType.buy) {
        currentSilver += quantityTola;
        currentInvested += totalAmount;
      } else {
        if (currentSilver < quantityTola) {
          throw Exception("Insufficient holdings to sell");
        }
        currentSilver -= quantityTola;
         if (currentSilver > 0) {
           double ratio = quantityTola / (currentSilver + quantityTola);
           currentInvested = currentInvested * (1 - ratio);
         } else {
           currentInvested = 0;
         }
      }

      final newPortfolio = PortfolioModel(
        userId: userId,
        totalSilverTola: currentSilver,
        totalInvestedAmount: currentInvested,
      );
      
      // 2. Perform Writes
      final txRef = FirebaseFirestore.instance.collection('transactions').doc(transactionId);
      tx.set(txRef, transaction.toMap()); // Write Log
      tx.set(portRef, newPortfolio.toMap()); // Write Portfolio
    });

    // Refresh local state
    await fetchPortfolio(userId);
  }
}
