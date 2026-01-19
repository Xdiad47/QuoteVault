import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quote_model.dart';
import '../models/user_model.dart';
import '../models/collection_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // AUTH METHODS
  Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // QUOTE METHODS
  Future<List<Quote>> getQuotes({int limit = 20, int offset = 0}) async {
    final response = await _client
        .from('quotes')
        .select()
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => Quote.fromJson(json)).toList();
  }

  Future<List<Quote>> getQuotesByCategory(String category) async {
    final response = await _client
        .from('quotes')
        .select()
        .eq('category', category);

    return (response as List).map((json) => Quote.fromJson(json)).toList();
  }

  Future<List<Quote>> searchQuotes(String query) async {
    final response = await _client
        .from('quotes')
        .select()
        .or('text.ilike.%$query%,author.ilike.%$query%');

    return (response as List).map((json) => Quote.fromJson(json)).toList();
  }

  Future<Quote?> getQuoteOfTheDay() async {
    // Get a random quote - in production, you'd use a better algorithm
    final response = await _client
        .from('quotes')
        .select()
        .limit(1)
        .single();

    return Quote.fromJson(response);
  }

  // FAVORITES METHODS
  Future<void> addToFavorites(int quoteId) async {
    final userId = getCurrentUser()?.id;
    if (userId == null) throw Exception('User not logged in');

    await _client.from('user_favorites').insert({
      'user_id': userId,
      'quote_id': quoteId,
    });
  }

  Future<void> removeFromFavorites(int quoteId) async {
    final userId = getCurrentUser()?.id;
    if (userId == null) throw Exception('User not logged in');

    await _client
        .from('user_favorites')
        .delete()
        .eq('user_id', userId)
        .eq('quote_id', quoteId);
  }

  Future<List<Quote>> getFavoriteQuotes() async {
    final userId = getCurrentUser()?.id;
    if (userId == null) return [];

    final response = await _client
        .from('user_favorites')
        .select('quote_id, quotes(*)')
        .eq('user_id', userId);

    return (response as List)
        .map((item) => Quote.fromJson(item['quotes']))
        .toList();
  }

  Future<List<int>> getFavoriteQuoteIds() async {
    final userId = getCurrentUser()?.id;
    if (userId == null) return [];

    final response = await _client
        .from('user_favorites')
        .select('quote_id')
        .eq('user_id', userId);

    return (response as List).map((item) => item['quote_id'] as int).toList();
  }

  // COLLECTIONS METHODS
  Future<List<Collection>> getCollections() async {
    final userId = getCurrentUser()?.id;
    if (userId == null) return [];

    final response = await _client
        .from('collections')
        .select()
        .eq('user_id', userId);

    return (response as List).map((json) => Collection.fromJson(json)).toList();
  }

  Future<void> createCollection(String name) async {
    final userId = getCurrentUser()?.id;
    if (userId == null) throw Exception('User not logged in');

    await _client.from('collections').insert({
      'user_id': userId,
      'name': name,
    });
  }
}
