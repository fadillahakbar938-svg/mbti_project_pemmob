import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;

  AuthResult({required this.success, this.errorMessage});
}

class SupabaseUser {
  final Map<String, dynamic>? userMetadata;
  final String? email;

  SupabaseUser({this.userMetadata, this.email});
}

class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();

  static const _supabaseUrl = 'https://ycskqtrbzmfsugyxpldm.supabase.co';
  static const _supabaseAnonKey =
      'sb_publishable_H9VoZAVO68VSgwWi_OX5hw_j6cumGpb';

  late final SupabaseClient _client;
  SupabaseUser? _currentUser;

  SupabaseUser? get currentUser => _currentUser;

  Future<void> initialize() async {
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
    _client = Supabase.instance.client;
    await _restoreSession();
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        await _loadUserProfile(email);
        return AuthResult(success: true);
      }
    } catch (error) {
      // Supabase Auth may not be configured or login may fail. Fall back to users table check.
    }

    final row = await _client
        .from('users')
        .select()
        .eq('email', email)
        .maybeSingle();
    if (row == null) {
      return AuthResult(
        success: false,
        errorMessage: 'Email tidak ditemukan di tabel users.',
      );
    }

    if (row is Map<String, dynamic> &&
        row.containsKey('password') &&
        row['password'] != null) {
      final stored = row['password'] as String;
      final ok = BCrypt.checkpw(password, stored);
      if (!ok) {
        return AuthResult(success: false, errorMessage: 'Kata sandi salah.');
      }
    } else {
      return AuthResult(
        success: false,
        errorMessage:
            'Pengguna ditemukan, tetapi tabel users belum memiliki kolom password.',
      );
    }

    _currentUser = SupabaseUser(userMetadata: row, email: email);
    return AuthResult(success: true);
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    String? fullName,
    String? nim,
    String? jurusan,
  }) async {
    final hashed = BCrypt.hashpw(password, BCrypt.gensalt());

    Future<AuthResult> insertFallback() async {
      try {
        final inserted = await _client
            .from('users')
            .insert({
              'username': fullName?.trim().isNotEmpty == true
                  ? fullName!.trim()
                  : email.split('@')[0],
              'email': email,
              'password': hashed,
              'created_at': DateTime.now().toIso8601String(),
            })
            .select()
            .maybeSingle();

        if (inserted == null) {
          return AuthResult(
            success: false,
            errorMessage: 'Gagal menyimpan pengguna ke tabel users.',
          );
        }

        if (inserted is Map<String, dynamic>) {
          if (!inserted.containsKey('password') ||
              inserted['password'] == null) {
            print('Warning: password column not saved for user: $email');
            return AuthResult(
              success: false,
              errorMessage:
                  'Registrasi berhasil, tetapi password tidak tersimpan di tabel users. Periksa RLS/policy di Supabase.',
            );
          }
        }

        return AuthResult(success: true);
      } catch (insertError) {
        return AuthResult(
          success: false,
          errorMessage:
              'Gagal menyimpan pengguna ke tabel users: ${insertError.toString()}',
        );
      }
    }

    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
        },
      );

      if (res.user != null) {
        final insertResult = await insertFallback();
        if (!insertResult.success) {
          return insertResult;
        }
        return AuthResult(success: true);
      }

      return await insertFallback();
    } catch (error) {
      final fallbackResult = await insertFallback();
      if (fallbackResult.success) {
        return AuthResult(success: true);
      }
      return AuthResult(
        success: false,
        errorMessage:
            'Registrasi gagal: ${error.toString()}. Fallback DB insert juga gagal: ${fallbackResult.errorMessage}',
      );
    }
  }

  Future<AuthResult> loginWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(Provider.google);
      await _restoreSession();
      if (_currentUser == null) {
        return AuthResult(
          success: false,
          errorMessage:
              'Login Google berhasil, tetapi profil pengguna tidak ditemukan.',
        );
      }
      return AuthResult(success: true);
    } catch (error) {
      return AuthResult(
        success: false,
        errorMessage: 'Login Google gagal: ${error.toString()}',
      );
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    _currentUser = null;
  }

  Future<void> _restoreSession() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      _currentUser = null;
      return;
    }

    final email = authUser.email;
    if (email == null) {
      _currentUser = SupabaseUser(
        userMetadata: authUser.userMetadata,
        email: null,
      );
      return;
    }

    final row = await _client
        .from('users')
        .select()
        .eq('email', email)
        .maybeSingle();

    if (row == null) {
      final username =
          authUser.userMetadata?['name'] ??
          authUser.userMetadata?['email']?.split('@')[0] ??
          email.split('@')[0];
      await _client.from('users').insert({
        'username': username,
        'email': email,
        'created_at': DateTime.now().toIso8601String(),
      });
      _currentUser = SupabaseUser(
        userMetadata: {
          'username': username,
          'email': email,
          'created_at': DateTime.now().toIso8601String(),
        },
        email: email,
      );
      return;
    }

    _currentUser = SupabaseUser(
      userMetadata: row as Map<String, dynamic>?,
      email: email,
    );
  }

  Future<void> _loadUserProfile(String email) async {
    final row = await _client
        .from('users')
        .select()
        .eq('email', email)
        .maybeSingle();
    _currentUser = SupabaseUser(
      userMetadata: row as Map<String, dynamic>?,
      email: email,
    );
  }
}
