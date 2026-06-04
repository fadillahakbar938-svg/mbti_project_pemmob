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

    final pattern = '%$trimmed%';
    final orFilter = 'username.ilike.$pattern,email.ilike.$pattern';

    print('DEBUG searchUsers: query=$trimmed, pattern=$pattern, exclude=$excludeUserId');

    try {
      List<Map<String, dynamic>> response;

      if (excludeUserId != null && excludeUserId.isNotEmpty) {
        response = await _client
            .from('users')
            .select('id, username, email, mbti_type, profile_picture')
            .or(orFilter)
            .neq('id', excludeUserId)
            .limit(limit);
      } else {
        response = await _client
            .from('users')
            .select('id, username, email, mbti_type, profile_picture')
            .or(orFilter)
            .limit(limit);
      }

      print('DEBUG searchUsers result count: ${response.length}');
      print('DEBUG searchUsers results: $response');

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stack) {
      print('DEBUG searchUsers ERROR: $e');
      print('DEBUG searchUsers STACK: $stack');
      return [];
    }
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

/// Kirim friend request
  Future<void> sendFriendRequest({
    required String senderId,
    required String receiverId,
  }) async {
    // Hanya cek satu arah: sender ini ke receiver ini
    // Tidak cek dua arah agar A bisa request ke B meski B sudah request ke A
    final existingList = await _client
        .from('friend_requests')
        .select('id')
        .eq('sender_id', senderId)
        .eq('receiver_id', receiverId)
        .order('id', ascending: false)
        .limit(1);

    if (existingList.isNotEmpty) return; // Sudah pernah kirim, skip

    await _client.from('friend_requests').insert({
      'sender_id': senderId,
      'receiver_id': receiverId,
      'status': 'pending',
    });
  }

/// Batalkan / hapus friend request
Future<void> cancelFriendRequest({
  required String senderId,
  required String receiverId,
}) async {
  await _client
      .from('friend_requests')
      .delete()
      .eq('sender_id', senderId)
      .eq('receiver_id', receiverId)
      .eq('status', 'pending');
}

/// Cek status friend request antara dua user
/// Return: 'none' | 'pending' | 'accepted' | 'rejected'
  Future<String> getFriendRequestStatus({
    required String currentUserId,
    required String otherUserId,
  }) async {
    // Cek request yang kita kirim
    final sentList = await _client
        .from('friend_requests')
        .select('status')
        .eq('sender_id', currentUserId)
        .eq('receiver_id', otherUserId)
        .order('id', ascending: false)
        .limit(1);

    if (sentList.isNotEmpty) return sentList.first['status'] as String? ?? 'none';

    // Cek request yang masuk dari orang lain
    final receivedList = await _client
        .from('friend_requests')
        .select('status')
        .eq('sender_id', otherUserId)
        .eq('receiver_id', currentUserId)
        .order('id', ascending: false)
        .limit(1);

    if (receivedList.isNotEmpty) {
      final status = receivedList.first['status'] as String? ?? 'none';
      if (status == 'accepted') return 'accepted';
      if (status == 'pending') return 'incoming';
    }

    return 'none';
  }

/// Ambil daftar teman (status = 'accepted')
Future<List<Map<String, dynamic>>> getFriends(String userId) async {
  final response = await _client
      .from('friend_requests')
      .select('''
        id, status, created_at,
        sender:users!sender_id(id, username, mbti_type, profile_picture),
        receiver:users!receiver_id(id, username, mbti_type, profile_picture)
      ''')
      .or('sender_id.eq.$userId,receiver_id.eq.$userId')
      .eq('status', 'accepted');

  return List<Map<String, dynamic>>.from(response);
}

/// Ambil daftar match (dari match_history + join ke mbti_compatibility)
Future<List<Map<String, dynamic>>> getMatches(String userId) async {
  final historyResponse = await _client
      .from('match_history')
      .select('''
        id, created_at, user_mbti, friend_mbti,
        friend:users!friend_id(id, username, mbti_type, profile_picture)
      ''')
      .eq('user_id', userId)
      .order('created_at', ascending: false);
      
  final List<Map<String, dynamic>> matches = List<Map<String, dynamic>>.from(historyResponse);
  
  for (var i = 0; i < matches.length; i++) {
    final m1 = matches[i]['user_mbti'] as String;
    final m2 = matches[i]['friend_mbti'] as String;
    
    final type1 = m1.compareTo(m2) <= 0 ? m1 : m2;
    final type2 = m1.compareTo(m2) <= 0 ? m2 : m1;
    
    final compat = await _client
        .from('mbti_compatibility')
        .select('compatibility_percentage, summary')
        .eq('mbti_type_1', type1)
        .eq('mbti_type_2', type2)
        .maybeSingle();
        
    matches[i]['compatibility_percentage'] = compat?['compatibility_percentage'] ?? 50;
    matches[i]['summary'] = compat?['summary'] ?? "Belum ada data kecocokan.";
  }
  
  matches.sort((a, b) => (b['compatibility_percentage'] as int).compareTo(a['compatibility_percentage'] as int));

  return matches;
}

/// Ambil detail match lengkap berdasarkan match_history_id
Future<Map<String, dynamic>?> getMatchDetail(int historyId) async {
  final history = await _client
      .from('match_history')
      .select('''
        id, created_at, user_mbti, friend_mbti, user_id, friend_id,
        user:users!user_id(id, username, profile_picture),
        friend:users!friend_id(id, username, profile_picture)
      ''')
      .eq('id', historyId)
      .maybeSingle();
      
  if (history == null) return null;
  
  final m1 = history['user_mbti'] as String;
  final m2 = history['friend_mbti'] as String;
  
  final type1 = m1.compareTo(m2) <= 0 ? m1 : m2;
  final type2 = m1.compareTo(m2) <= 0 ? m2 : m1;
  
  final compat = await _client
      .from('mbti_compatibility')
      .select('*')
      .eq('mbti_type_1', type1)
      .eq('mbti_type_2', type2)
      .maybeSingle();
      
  if (compat != null) {
    history['compatibility'] = compat;
  }
  
  return history;
}

/// Ambil semua pending friend requests yang masuk ke user ini
Future<List<Map<String, dynamic>>> getIncomingFriendRequests(
  String userId,
) async {
  final response = await _client
      .from('friend_requests')
      .select('''
        id, status, created_at,
        sender:users!sender_id(id, username, profile_picture)
      ''')
      .eq('receiver_id', userId)
      .eq('status', 'pending')
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(response);
}

/// Terima friend request
Future<void> acceptFriendRequest(int requestId) async {
  await _client
      .from('friend_requests')
      .update({'status': 'accepted'})
      .eq('id', requestId);
}

  /// Hapus pertemanan (unfriend)
  Future<void> removeFriend({
    required String currentUserId,
    required String friendId,
  }) async {
    await _client
        .from('friend_requests')
        .delete()
        .or('and(sender_id.eq.$currentUserId,receiver_id.eq.$friendId),and(sender_id.eq.$friendId,receiver_id.eq.$currentUserId)');
  }

/// Tolak friend request
Future<void> rejectFriendRequest(int requestId) async {
  await _client
      .from('friend_requests')
      .update({'status': 'rejected'})
      .eq('id', requestId);
}

/// Cek apakah ada pending request yang dikirim user ini ke target
/// Return: created_at dari request jika ada, null jika tidak ada
  Future<DateTime?> getOutgoingPendingRequestTime({
    required String senderId,
    required String receiverId,
  }) async {
    final response = await _client
        .from('friend_requests')
        .select('created_at')
        .eq('sender_id', senderId)
        .eq('receiver_id', receiverId)
        .eq('status', 'pending')
        .order('id', ascending: false)
        .limit(1);

    if (response.isEmpty) return null;
    return DateTime.tryParse(response.first['created_at'].toString());
  }
/// Jumlah total match yang sudah dilakukan user
  Future<int> getTotalMatches(String userId) async {
    final response = await _client
        .from('match_history')
        .select('id')
        .eq('user_id', userId);
    return response.length;
  }

  /// Jumlah kartu karakter yang sudah terbuka
  /// Sumber: MBTI tipe dari riwayat tes sendiri + MBTI teman dari match
  Future<int> getTotalCards(String userId) async {
    final unlockedTypes = await getUnlockedCardTypes(userId);
    return unlockedTypes.length;
  }

  /// Set MBTI type yang sudah terbuka sebagai kartu (untuk CharacterCards widget)
  Future<Set<String>> getUnlockedCardTypes(String userId) async {
    final Set<String> unlocked = {};

    // 1. Dari riwayat tes sendiri (tiap tipe unik = 1 kartu)
    try {
      final results = await _client
          .from('results')
          .select('mbti_type')
          .eq('user_id', userId);
      for (final r in results) {
        final mbti = r['mbti_type'] as String?;
        if (mbti != null &&
            mbti.isNotEmpty &&
            mbti.toUpperCase() != 'NULL') {
          unlocked.add(mbti.toUpperCase());
        }
      }
    } catch (_) {}

    // 2. Dari match dengan teman (MBTI teman = kartu baru)
    try {
      final matches = await _client
          .from('match_history')
          .select('friend_mbti')
          .eq('user_id', userId);
      for (final m in matches) {
        final mbti = m['friend_mbti'] as String?;
        if (mbti != null &&
            mbti.isNotEmpty &&
            mbti.toUpperCase() != 'NULL') {
          unlocked.add(mbti.toUpperCase());
        }
      }
    } catch (_) {}

    return unlocked;
  }

  // ── Match Requests & Compatibility ──

  Future<void> sendMatchRequest({
    required String senderId,
    required String receiverId,
  }) async {
    final list = await _client
        .from('match_requests')
        .select('id')
        .or('and(sender_id.eq.$senderId,receiver_id.eq.$receiverId),and(sender_id.eq.$receiverId,receiver_id.eq.$senderId)')
        .order('id', ascending: false)
        .limit(1);

    if (list.isNotEmpty) {
      final existingId = list.first['id'];
      await _client.from('match_requests').update({
        'sender_id': senderId,
        'receiver_id': receiverId,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      }).eq('id', existingId);
    } else {
      await _client.from('match_requests').insert({
        'sender_id': senderId,
        'receiver_id': receiverId,
        'status': 'pending',
      });
    }
  }

  /// Batalkan / hapus match request
  Future<void> cancelMatchRequest({
    required String senderId,
    required String receiverId,
  }) async {
    await _client
        .from('match_requests')
        .delete()
        .eq('sender_id', senderId)
        .eq('receiver_id', receiverId)
        .eq('status', 'pending');
  }

  /// Cek status match request antara dua user
  /// Return: 'none' | 'pending' | 'incoming' | 'accepted' | 'rejected'
  Future<String> getMatchRequestStatus({
    required String currentUserId,
    required String otherUserId,
  }) async {
    // Cek request yang kita kirim
    final sentList = await _client
        .from('match_requests')
        .select('status')
        .eq('sender_id', currentUserId)
        .eq('receiver_id', otherUserId)
        .order('id', ascending: false)
        .limit(1);

    if (sentList.isNotEmpty) return sentList.first['status'] as String? ?? 'none';

    // Cek request yang masuk dari orang lain
    final receivedList = await _client
        .from('match_requests')
        .select('status')
        .eq('sender_id', otherUserId)
        .eq('receiver_id', currentUserId)
        .order('id', ascending: false)
        .limit(1);

    if (receivedList.isNotEmpty) {
      final status = receivedList.first['status'] as String? ?? 'none';
      if (status == 'accepted') return 'accepted';
      if (status == 'pending') return 'incoming';
    }

    return 'none';
  }

  /// Ambil semua pending match requests yang masuk ke user ini
  Future<List<Map<String, dynamic>>> getIncomingMatchRequests(
    String userId,
  ) async {
    final response = await _client
        .from('match_requests')
        .select('''
          id, status, created_at,
          sender:users!sender_id(id, username, mbti_type, profile_picture)
        ''')
        .eq('receiver_id', userId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Terima match request dan buat hasil kecocokan di match_results
  Future<void> acceptMatchRequest(int requestId) async {
    // 1. Ambil data request untuk tahu siapa sender dan receiver
    final req = await _client
        .from('match_requests')
        .select('sender_id, receiver_id')
        .eq('id', requestId)
        .single();

    final senderId = req['sender_id'] as String;
    final receiverId = req['receiver_id'] as String;

    // 2. Update status request ke accepted
    await _client
        .from('match_requests')
        .update({'status': 'accepted'})
        .eq('id', requestId);

    // 3. Ambil data MBTI masing-masing user
    final senderProfile = await getUserProfile(senderId);
    final receiverProfile = await getUserProfile(receiverId);

    final senderMbti = senderProfile?['mbti_type'] as String? ?? 'INFP';
    final receiverMbti = receiverProfile?['mbti_type'] as String? ?? 'INFJ';

    // 4. Simpan riwayat match (dua arah agar kedua user bisa melihat di tab Matched)
    // Arah 1: Dari sisi Receiver melihat Sender
    await _client.from('match_history').insert({
      'user_id': receiverId,
      'friend_id': senderId,
      'user_mbti': receiverMbti,
      'friend_mbti': senderMbti,
    });

    // Arah 2: Dari sisi Sender melihat Receiver
    await _client.from('match_history').insert({
      'user_id': senderId,
      'friend_id': receiverId,
      'user_mbti': senderMbti,
      'friend_mbti': receiverMbti,
    });
  }

  /// Tolak match request
  Future<void> rejectMatchRequest(int requestId) async {
    await _client
        .from('match_requests')
        .update({'status': 'rejected'})
        .eq('id', requestId);
  }

  /// Hapus riwayat match antara dua user
  Future<void> deleteMatchHistory({
    required String currentUserId,
    required String friendId,
  }) async {
    // Hapus dari match_history (kedua arah)
    await _client
        .from('match_history')
        .delete()
        .or('and(user_id.eq.$currentUserId,friend_id.eq.$friendId),and(user_id.eq.$friendId,friend_id.eq.$currentUserId)');
        
    // Hapus juga riwayat dari match_requests agar bersih dan bisa match ulang dari awal
    await _client
        .from('match_requests')
        .delete()
        .or('and(sender_id.eq.$currentUserId,receiver_id.eq.$friendId),and(sender_id.eq.$friendId,receiver_id.eq.$currentUserId)');
  }

  /// Ambil semua match request yang melibatkan user saat ini
  Future<List<Map<String, dynamic>>> getMatchRequests(String userId) async {
    final response = await _client
        .from('match_requests')
        .select()
        .or('sender_id.eq.$userId,receiver_id.eq.$userId')
        .order('id', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

}

