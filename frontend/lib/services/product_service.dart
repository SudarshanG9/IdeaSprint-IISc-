// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class ProductResult {
  final Product? product;
  final String?  error;
  final bool     fromCache;

  ProductResult._({this.product, this.error, required this.fromCache});
  factory ProductResult.success(Product p, {required bool fromCache}) =>
      ProductResult._(product: p, fromCache: fromCache);
  factory ProductResult.error(String msg) =>
      ProductResult._(error: msg, fromCache: false);

  bool get isSuccess => product != null;
}

class ProductService {
  static final ProductService _i = ProductService._();
  factory ProductService() => _i;
  ProductService._();

  // ── Point this to your teammate's backend ──────────────────────────────────
  // Use locatunnel reverse proxy for universal access bypassing Wi-Fi blocks
  static const String _baseUrl = 'https://dafae26c90b022.lhr.life';
  // ──────────────────────────────────────────────────────────────────────────

  /// Real API call
  Future<ProductResult> fetchProduct(String productId) async {
    try {
      final tts = TtsService();
      final fullCode = await tts.getSavedLanguage();
      final lang = fullCode.split('-').first; // e.g., 'ta' from 'ta-IN'

      final res = await http
          .get(
            Uri.parse('$_baseUrl/p/$productId?lang=$lang'),
            headers: {
              'X-App-Client': 'blind-app',
              'Bypass-Tunnel-Reminder': 'true'
            },
          )
          .timeout(const Duration(seconds: 15));
          
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final product = Product.fromJson(json);
        await _cache(productId, json);
        return ProductResult.success(product, fromCache: false);
      }
    } catch (_) {}

    // Fallback to cache
    final cached = await _fromCache(productId);
    if (cached != null) return ProductResult.success(cached, fromCache: true);
    return ProductResult.error('Product not available offline.');
  }

  /// Mock — no network needed, works on Chrome too
  Future<ProductResult> fetchMock(String productId) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final mock = {
      'DEMO001': Product(
        id: 'DEMO001', name: 'Maggi 2-Minute Noodles',
        category: 'Instant Food',
        description: 'Maggi 2-Minute Noodles. Instant food. Preparation required. Net weight 70 grams.',
        ingredients: ['Wheat flour', 'Palm oil', 'Salt', 'Spices', 'Tastemaker'],
        warnings: ['Contains wheat gluten', 'May contain traces of soy'],
      ),
      'DEMO002': Product(
        id: 'DEMO002', name: 'Paracetamol 500mg',
        category: 'Medicine',
        description: 'Paracetamol 500 milligram tablets. Pain reliever and fever reducer. 10 tablets per strip.',
        ingredients: ['Paracetamol 500mg', 'Microcrystalline cellulose', 'Starch'],
        warnings: ['Do not exceed 4 doses in 24 hours', 'Keep out of reach of children'],
      ),
      'DEMO003': Product(
        id: 'DEMO003', name: 'Tata Salt',
        category: 'Groceries',
        description: 'Tata Salt. Iodised salt. 1 kilogram pack. Vacuum evaporated for purity.',
        ingredients: ['Salt', 'Potassium iodate'],
        warnings: ['Store in a cool dry place'],
      ),
    };

    final product = mock[productId] ?? Product(
      id: productId, name: 'Sample Product',
      category: 'General',
      description: 'Sample product. ID scanned: $productId.',
      ingredients: ['Ingredient A', 'Ingredient B'],
      warnings: ['Store in cool dry place'],
    );
    return ProductResult.success(product, fromCache: false);
  }

  Future<void> _cache(String id, Map<String, dynamic> json) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('product_$id', jsonEncode(json));
    } catch (_) {}
  }

  Future<Product?> _fromCache(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('product_$id');
      if (raw != null) return Product.fromJson(jsonDecode(raw));
    } catch (_) {}
    return null;
  }
}