import 'package:supabase/supabase.dart';

void main() async {
  final client = SupabaseClient(
    'https://ycskqtrbzmfsugyxpldm.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inljc2txdHJiem1mc3VneXhwbGRtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAwMjgxNzUsImV4cCI6MjA5NTYwNDE3NX0.yuygyDeXGd4A3r0-rZC5w5B2G6aOq_VY2CkwrKrSCtU'
  );

  final username = 'testuser12345';
  final email = 'testuser12345@gmail.com';
  final password = 'password123';

  try {
    print("Checking if username exists...");
    final existingUser = await client
        .from('users')
        .select('id')
        .eq('username', username)
        .maybeSingle();
    print("Existing user: $existingUser");

    print("Attempting signUp...");
    final response = await client.auth.signUp(email: email, password: password);
    print("SignUp successful. User ID: ${response.user?.id}");

    if (response.user != null) {
      print("Attempting to insert into users table...");
      await client.from('users').insert({
        'id': response.user!.id,
        'username': username,
        'email': email,
      });
      print("Insert successful!");
    }
  } catch (e, stack) {
    print("EXCEPTION CAUGHT!");
    print(e.toString());
    print(stack.toString());
  }
}
