import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../models/quote_model.dart';

class QuoteViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<Quote> _quotes = [];
  List<int> _favoriteIds = [];
  Quote? _quoteOfTheDay;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<Quote> get quotes => _quotes;
  Quote? get quoteOfTheDay => _quoteOfTheDay;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  List<String> get categories => [
    'All',
    'Motivation',
    'Love',
    'Success',
    'Wisdom',
    'Humor'
  ];

  QuoteViewModel() {
    loadQuotes();
    loadQuoteOfTheDay();
    loadFavoriteIds();
  }

  Future<void> loadQuotes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _quotes = await _supabaseService.getQuotes(limit: 100);
      _updateFavoriteStatus();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadQuotesByCategory(String category) async {
    _selectedCategory = category;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (category == 'All') {
        _quotes = await _supabaseService.getQuotes(limit: 100);
      } else {
        _quotes = await _supabaseService.getQuotesByCategory(category);
      }
      _updateFavoriteStatus();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchQuotes(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      loadQuotes();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _quotes = await _supabaseService.searchQuotes(query);
      _updateFavoriteStatus();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadQuoteOfTheDay() async {
    try {
      _quoteOfTheDay = await _supabaseService.getQuoteOfTheDay();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadFavoriteIds() async {
    try {
      _favoriteIds = await _supabaseService.getFavoriteQuoteIds();
      _updateFavoriteStatus();
      notifyListeners();
    } catch (e) {
      // User might not be logged in
      _favoriteIds = [];
    }
  }

  Future<void> toggleFavorite(Quote quote) async {
    try {
      if (_favoriteIds.contains(quote.id)) {
        await _supabaseService.removeFromFavorites(quote.id);
        _favoriteIds.remove(quote.id);
      } else {
        await _supabaseService.addToFavorites(quote.id);
        _favoriteIds.add(quote.id);
      }
      _updateFavoriteStatus();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _updateFavoriteStatus() {
    for (var quote in _quotes) {
      quote.isFavorite = _favoriteIds.contains(quote.id);
    }
    if (_quoteOfTheDay != null) {
      _quoteOfTheDay!.isFavorite = _favoriteIds.contains(_quoteOfTheDay!.id);
    }
  }

  Future<void> refresh() async {
    await loadQuotes();
    await loadQuoteOfTheDay();
    await loadFavoriteIds();
  }
}
