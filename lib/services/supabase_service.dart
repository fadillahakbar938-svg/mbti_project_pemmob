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

  SupabaseUser? get currentUser => null;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (email.contains('@') && password.length >= 6) {
      return AuthResult(success: true);
    }
    return AuthResult(success: false, errorMessage: 'Invalid credentials');
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    String? fullName,
    String? nim,
    String? jurusan,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (email.contains('@') && password.length >= 6) {
      return AuthResult(success: true);
    }
    return AuthResult(success: false, errorMessage: 'Registration failed');
  }

  Future<AuthResult> loginWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // For now, simulate success
    return AuthResult(success: true);
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Simulate clearing a session or auth token.
  }
}
