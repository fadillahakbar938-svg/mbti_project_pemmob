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

  /// Profil dari tabel `users` (username, email, mbti_type, profile_picture, created_at, dll.).
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    
    final response = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (response == null) return null;
    return Map<String, dynamic>.from(response);
  }

  /// Hasil tes terbaru dari tabel `results` untuk indikator persentase.
  Future<Map<String, dynamic>?> getLatestResult(String userId) async {
    try {
      final response = await _client
          .from('results')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (response != null) {
        return Map<String, dynamic>.from(response);
      }
    } catch (_) {
      // Fallback jika kolom created_at belum ada di tabel results.
    }

    final fallback = await _client
        .from('results')
        .select()
        .eq('user_id', userId)
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();
    if (fallback == null) return null;
    return Map<String, dynamic>.from(fallback);
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

  Future<List<Map<String, dynamic>>> getUserAnswers(
    String userId,
  ) async {

    final response =
        await _client
            .from('answers')
            .select('''
              answer_value,
              questions(
                target
              )
            ''')
            .eq('user_id', userId);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> calculateMbti(
    String userId,
  ) async {

    final answers =
        await getUserAnswers(userId);

    int e = 0;
    int i = 0;
    int s = 0;
    int n = 0;
    int t = 0;
    int f = 0;
    int j = 0;
    int p = 0;

    for(final item in answers){

      final target =
          item['questions']['target'];

      final int score =
          (item['answer_value'] as num).toInt();

      switch(target){

        case 'E':
          e += score;
          break;

        case 'I':
          i += score;
          break;

        case 'S':
          s += score;
          break;

        case 'N':
          n += score;
          break;

        case 'T':
          t += score;
          break;

        case 'F':
          f += score;
          break;

        case 'J':
          j += score;
          break;

        case 'P':
          p += score;
          break;
      }
    }

    double percentage(int a, int b) {
      return a / (a + b) * 100;
    }

    final ePercent = percentage(e, i);
    final iPercent = percentage(i, e);

    final sPercent = percentage(s, n);
    final nPercent = percentage(n, s);

    final tPercent = percentage(t, f);
    final fPercent = percentage(f, t);

    final jPercent = percentage(j, p);
    final pPercent = percentage(p, j);

    final mbti =
        (e >= i ? 'E' : 'I') +
        (s >= n ? 'S' : 'N') +
        (t >= f ? 'T' : 'F') +
        (j >= p ? 'J' : 'P');

    return {
      'mbti_type': mbti,

      'score_e': e,
      'score_i': i,

      'score_s': s,
      'score_n': n,

      'score_t': t,
      'score_f': f,

      'score_j': j,
      'score_p': p,

      'e_percent': ePercent,
      'i_percent': iPercent,

      's_percent': sPercent,
      'n_percent': nPercent,

      't_percent': tPercent,
      'f_percent': fPercent,

      'j_percent': jPercent,
      'p_percent': pPercent,
    };
    
  }

  /// Cari pengguna lain berdasarkan username atau ID (UUID).
  Future<List<Map<String, dynamic>>> searchUsers({
    required String query,
    String? excludeUserId,
    int limit = 20,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final escaped = trimmed.replaceAll(',', '');
    final pattern = '%$escaped%';

    var request = _client
        .from('users')
        .select('id, username, email, mbti_type, profile_picture');

    if (excludeUserId != null && excludeUserId.isNotEmpty) {
      request = request.neq('id', excludeUserId);
    }

    final response = await request
        .or('username.ilike.$pattern,email.ilike.$pattern,id.ilike.$pattern')
        .limit(limit);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> saveResult({
    required String userId,
    required Map<String,dynamic> result,
  }) async {

    // update users
    await _client
        .from('users')
        .update({
          'mbti_type': result['mbti_type'],
        })
        .eq('id', userId);

    await _client
        .from('results')
        .insert({

      'user_id': userId,

      'mbti_type':
          result['mbti_type'],

      'score_e': result['score_e'],
      'score_i': result['score_i'],
      'score_s': result['score_s'],
      'score_n': result['score_n'],
      'score_t': result['score_t'],
      'score_f': result['score_f'],
      'score_j': result['score_j'],
      'score_p': result['score_p'],
    });
  }

  Future<int> getTotalTests(
  String userId,
) async {

  final response =
      await _client
          .from('results')
          .select('id')
          .eq('user_id', userId);

  return response.length;
}
Future<Map<String,dynamic>?> getMbtiProfile(
  String mbtiType,
) async {

  final response =
      await _client
          .from('mbti_profiles')
          .select()
          .eq(
            'mbti_type',
            mbtiType,
          )
          .maybeSingle();

  return response;
}
}


