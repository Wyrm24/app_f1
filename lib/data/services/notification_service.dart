import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final _messaging = FirebaseMessaging.instance;
  final _supabase = Supabase.instance.client;

  // Initialisation + permissions
  Future<void> init() async {
    // Demande permission
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) return;

    // Récupère token
    final token = await _messaging.getToken();
    if (token != null) await _saveToken(token);

    // Refresh token si changé
    _messaging.onTokenRefresh.listen(_saveToken);
  }

  // Sauvegarde token dans profiles
  Future<void> _saveToken(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('profiles')
        .update({'fcm_token': token})
        .eq('id', userId);
  }
}
