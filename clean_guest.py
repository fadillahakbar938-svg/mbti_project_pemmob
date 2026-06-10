import re

def clean_landing():
    path = r'D:\My Folder\TUGAS KULIAH\Semester 4\Pemrograman Mobile\AAAA_UAS\mbti_project_pemmob\lib\landing_page.dart'
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Hapus tombol guest
    content = re.sub(
        r'(?s)const SizedBox\(height: 12\),\s*// Tombol MASUK SEBAGAI GUEST.*?child: const Text\(\s*\'Masuk sebagai Guest\'.*?\),\s*\),\s*\),\s*\),',
        '',
        content
    )

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)


def clean_dashboard():
    path = r'D:\My Folder\TUGAS KULIAH\Semester 4\Pemrograman Mobile\AAAA_UAS\mbti_project_pemmob\lib\dashboard_page.dart'
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Hapus variabel _isGuest
    content = re.sub(r'\s*bool _isGuest = true;', '', content)
    content = re.sub(r'\s*_isGuest = (true|false);', '', content)

    # 2. Redirect jika null
    content = re.sub(
        r'(?s)if \(authUser == null\) \{.*?return;\s*\}',
        '''if (authUser == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/landing');
      }
      return;
    }''',
        content
    )

    # 3. Bersihkan _isGuest ternary di UI
    content = re.sub(r'_isGuest \? \'-\' : (totalMatches\.toString\(\))', r'\1', content)
    content = re.sub(r'_isGuest \? \'-\' : (totalCards\.toString\(\))', r'\1', content)
    
    # onTap: _isGuest ? _showGuestWarning : () {
    content = re.sub(r'onTap:\s*_isGuest\s*\?\s*_showGuestWarning\s*:\s*(\(\)\s*\{)', r'onTap: \1', content)
    
    # onTap: _isGuest ? () => _showGuestWarning(context) : () => Navigator.pushNamed
    content = re.sub(r'onTap:\s*_isGuest\n\s*\?\s*\(\)\s*=>\s*_showGuestWarning\(context\)\n\s*:\s*(\(\)\s*=>\s*Navigator\.pushNamed)', r'onTap: \1', content)

    # onTap: _isGuest ? () => _showGuestWarning(context) : ... (sebaris)
    content = re.sub(r'onTap:\s*_isGuest\s*\?\s*\(\)\s*=>\s*_showGuestWarning\(context\)\s*:\s*(\(\)\s*=>\s*Navigator\.pushNamed)', r'onTap: \1', content)

    # 4. Hapus method _showGuestWarning
    content = re.sub(r'(?s)\s*void _showGuestWarning.*?\}\);?\s*\}', '', content)

    # 5. Hapus logika _isGuest di _buildProfileMenu
    # Wait, the best way to handle the logout button is just to replace !_isGuest logic
    content = re.sub(r'if \(!_isGuest\) await SupabaseService\.instance\.signOut\(\);', 'await SupabaseService.instance.signOut();', content)
    content = re.sub(r'_isGuest\s*\?\s*\'Login / Daftar\'\s*:\s*\'Logout\'', "'Logout'", content)

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

clean_landing()
clean_dashboard()
print("Selesai membersihkan!")
