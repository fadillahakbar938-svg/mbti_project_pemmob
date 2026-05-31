import 'package:supabase_flutter/supabase_flutter.dart';
class AuthResult {
  final bool success;
  final String? errorMessage;

  AuthResult({required this.success, this.errorMessage});
}

class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance =   SupabaseService._();

  final client = Supabase.instance.client;

  User? get currentUser => client.auth.currentUser;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return AuthResult(
        success: true,
      );

    } catch (e) {

      return AuthResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      print("STEP 1");
      final response =
          await client.auth.signUp(
        email: email,
        password: password,
      );

      print("SIGNUP RESPONSE:");
      print(response);

      print("STEP 2");

      final user = response.user;

      if (user == null) {
        return AuthResult(
          success: false,
          errorMessage: "User gagal dibuat",
        );
      }

      await client
          .from('users')
          .insert({
        'id': user.id,
        'username': username,
        'email': email, 
        // 'mbti_type': null,
        // 'profile_picture': 'default.png',
      });

      print("STEP 3");
      return AuthResult(
        success: true,
      );

    } catch (e, stack) {
      print("ERROR REGISTER:");
      print(e);

      print("STACK:");
      print(stack);

      return AuthResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Future<AuthResult> loginWithGoogle() async {
  //   try {
  //     await _client.auth.signInWithOAuth(Provider.google);
  //     await _restoreSession();
  //     if (_currentUser == null) {
  //       return AuthResult(
  //         success: false,
  //         errorMessage:
  //             'Login Google berhasil, tetapi profil pengguna tidak ditemukan.',
  //       );
  //     }
  //     return AuthResult(success: true);
  //   } catch (error) {
  //     return AuthResult(
  //       success: false,
  //       errorMessage: 'Login Google gagal: ${error.toString()}',
  //     );
  //   }
  // }

  Future<void> signOut() async {
    await client.auth.signOut();
  }
}


