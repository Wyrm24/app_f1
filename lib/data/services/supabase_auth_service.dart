import 'package:supabase_flutter/supabase_flutter.dart';

// Auth service
class SupabaseAuthService {
  SupabaseAuthService._();
  static final SupabaseAuthService instance = SupabaseAuthService._();

  final SupabaseClient _client = Supabase.instance.client;

  // getters
  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // signup
  // create auth only (profile in setup page)

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  // signin
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // signout
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // reset pwd
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // profile done?
  // true if pseudo set
  Future<bool> hasCompletedProfile() async {
    final user = currentUser;
    if (user == null) return false;
    try {
      final data = await _client
          .from('profiles')
          .select('pseudo')
          .eq('id', user.id)
          .maybeSingle();
      return data != null && (data['pseudo'] as String?)?.isNotEmpty == true;
    } catch (_) {
      return false;
    }
  }

  // get profile
  Future<Map<String, dynamic>?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;
    return await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
  }

  // update profile
  Future<void> updateProfile({
    String? pseudo,
    String? avatarUrl,
    String? flagCode,
  }) async {
    final user = currentUser;
    if (user == null) return;
    await _client
        .from('profiles')
        .update({
          if (pseudo != null) 'pseudo': pseudo,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
          if (flagCode != null) 'flag_code': flagCode,
        })
        .eq('id', user.id);
  }
}
