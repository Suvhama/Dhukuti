import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PriceService {
  static const String _url = 'https://www.hamropatro.com/gold';
  static const String _cacheKeyPrice = 'daily_silver_price';
  static const String _cacheKeyTime = 'last_fetch_timestamp';

  Future<double> getSilverPrice() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // Target update time: Today at 11:05 AM
    final targetTime = DateTime(now.year, now.month, now.day, 11, 5);

    final lastFetchMs = prefs.getInt(_cacheKeyTime);
    final lastFetch = lastFetchMs != null
        ? DateTime.fromMillisecondsSinceEpoch(lastFetchMs)
        : null;

    if (lastFetch != null) {
      
      bool needsUpdate = false;
      if (now.isAfter(targetTime)) {
        if (lastFetch.isBefore(targetTime)) {
          needsUpdate = true;
        }
      } else {
      }

      if (!needsUpdate) {
        final cachedPrice = prefs.getDouble(_cacheKeyPrice);
        if (cachedPrice != null) {
          return cachedPrice;
        }
      }
    }

    try {
      final price = await _fetchFromHamroPatro();
      await prefs.setDouble(_cacheKeyPrice, price);
      await prefs.setInt(_cacheKeyTime, now.millisecondsSinceEpoch);
      return price;
    } catch (e) {
      final cachedPrice = prefs.getDouble(_cacheKeyPrice);
      if (cachedPrice != null) return cachedPrice;
      rethrow;
    }
  }

  Future<double> _fetchFromHamroPatro() async {
    final response = await http.get(Uri.parse(_url));
    if (response.statusCode == 200) {
      final RegExp regExp = RegExp(r'<li[^>]*>Silver - tola.*?</li>\s*<li[^>]*>\s*Nrs\.\s*([\d,.]+)', dotAll: true);
      final match = regExp.firstMatch(response.body);

      if (match != null) {
        final priceString = match.group(1)?.replaceAll(',', '') ?? '';
        final price = double.tryParse(priceString);
        if (price != null) return price;
      }
    }
    throw Exception('Failed to scrape price from Hamro Patro');
  }
}
