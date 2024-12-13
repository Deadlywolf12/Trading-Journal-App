import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchCryptoPrices(List<String> coinIds) async {
  final url =
      'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=${coinIds.join(",")}&order=market_cap_desc&per_page=100&page=1&sparkline=false';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body) as List<dynamic>;
    return {
      for (var coin in data)
        coin['id']: {
          'usd': coin['current_price'],
          'usd_24h_change': coin['price_change_percentage_24h'],
          'high_24h': coin['high_24h'], // Add 24h high
          'low_24h': coin['low_24h'], // Add 24h low
          'image': coin['image'],
        }
    };
  } else {
    throw Exception("Failed to fetch market data");
  }
}

Future<List<Map<String, String>>> fetchAllCoins() async {
  const String baseUrl =
      'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&sparkline=false';

  try {
    // Prepare URLs for 4 pages
    final List<String> urls = List.generate(4, (i) => '$baseUrl&page=${i + 1}');

    // Fetch data from all pages concurrently
    final responses =
        await Future.wait(urls.map((url) => http.get(Uri.parse(url))));

    // Combine results from all responses
    final List<Map<String, String>> allCoins = [];
    for (var response in responses) {
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        allCoins.addAll(data.map((coin) {
          return {
            'id': coin['id'] as String,
            'name': coin['name'] as String,
            // 'symbol': coin['symbol'], (optional)
          };
        }));
      } else {
        throw Exception("Failed to load coins: ${response.statusCode}");
      }
    }

    return allCoins;
  } catch (e) {
    throw Exception("Error fetching coins: $e");
  }
}
