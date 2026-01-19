import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../models/quote_model.dart';
import '../models/collection_model.dart';

class FavoritesViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<Quote> _favoriteQuotes = [];
  List<Collection> _collections = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Quote> get favoriteQuotes => _favoriteQuotes;
  List<Collection> get collections => _collections;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadFavorites() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _favoriteQuotes = await _supabaseService.getFavoriteQuotes();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCollections() async {
    try {
      _collections = await _supabaseService.getCollections();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> createCollection(String name) async {
    try {
      await _supabaseService.createCollection(name);
      await loadCollections();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeFromFavorites(int quoteId) async {
    try {
      await _supabaseService.removeFromFavorites(quoteId);
      _favoriteQuotes.removeWhere((quote) => quote.id == quoteId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
