import 'package:supabase_flutter/supabase_flutter.dart';
class AuthResult {
  final bool success;
  final String? errorMessage;

  AuthResult({required this.success, this.errorMessage});
}

class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();

  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(
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
          await _client.auth.signUp(
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

      await _client
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

  Future<AuthResult> loginWithGoogle() async {
    // try {
    //   await _client.auth.signInWithOAuth(
    //     Provider.google,
    //   );

    //   return AuthResult(
    //     success: true,
    //   );

    // } catch (error) {
    //   return AuthResult(
    //     success: false,
    //     errorMessage:
    //         'Login Google gagal: ${error.toString()}',
    //   );
    // }
    return AuthResult(
      success: false,
      errorMessage: 'Login Google belum diaktifkan',
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<List<Map<String, dynamic>>> getQuestions() async {
    final response =
        await _client
            .from('questions')
            .select()
            .order('id');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> saveAnswer({
    required String userId,
    required int questionId,
    required int answerValue,
  }) async {

    await _client
        .from('answers')
        .upsert({
      'user_id': userId,
      'question_id': questionId,
      'answer_value': answerValue,
    },
      onConflict: 'user_id,question_id',
    );
  }
}


