// EcoConnect API Constants - All endpoints in Indonesian where possible

class AppConstants {
  AppConstants._();

  // ── Base URL ─────────────────────────────────────────────────────
  // Production API. Override with --dart-define=API_BASE_URL=... when needed.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mafalqi-ecoconnect-backend.hf.space/api',
  );

  // ── Auth ─────────────────────────────────────────────────────────
  static const String daftar = '$baseUrl/auth/daftar';
  static const String masuk  = '$baseUrl/auth/masuk';

  // ── Aksi (Phase 1 new endpoints) ─────────────────────────────────
  static const String actions = '$baseUrl/actions';
  static const String checkin = '$baseUrl/checkin';

  // ── Komunitas (Phase 1 new endpoints) ────────────────────────────
  static const String communities = '$baseUrl/communities';
  static String toggleCommunityJoin(int id) => '$baseUrl/communities/$id/join';
  static String communityMessages(int id) => '$baseUrl/communities/$id/messages';

  // ── Profil & Papan Peringkat ──────────────────────────────────────
  static String profil(int id) => '$baseUrl/profil/$id';
  static const String updateProfil = '$baseUrl/profil';
  static const String papanPeringkat = '$baseUrl/papan-peringkat';
  static const String riwayat = '$baseUrl/riwayat';

  // ── Grup (legacy, still supported) ───────────────────────────────
  static const String grup = '$baseUrl/grup';
  static String bergabungGrup(int id) => '$baseUrl/grup/$id/bergabung';
  static String pesanGrup(int id) => '$baseUrl/grup/$id/pesan';

  // ── Legacy Tugas ──────────────────────────────────────────────────
  static const String tugas = '$baseUrl/tugas';
  static String tugasSelesai(int id) => '$baseUrl/tugas/$id/selesai';

  // ── Onboarding Categories (Hick's Law: max 5) ────────────────────
  static const List<Map<String, String>> kategoriOnboarding = [
    {'nama': 'Diet Vegan',         'emoji': '🥗', 'deskripsi': 'Kurangi konsumsi produk hewani'},
    {'nama': 'Hemat Energi',       'emoji': '⚡', 'deskripsi': 'Hemat listrik & energi sehari-hari'},
    {'nama': 'Transportasi Hijau', 'emoji': '🚲', 'deskripsi': 'Pilih transportasi ramah lingkungan'},
    {'nama': 'Kelola Sampah',      'emoji': '♻️', 'deskripsi': 'Daur ulang & kurangi sampah plastik'},
    {'nama': 'Hemat Air',          'emoji': '💧', 'deskripsi': 'Gunakan air secara bijak'},
  ];

  // ── Shared Pref Keys ─────────────────────────────────────────────
  static const String keyToken  = 'eco_token';
  static const String keyUserId = 'eco_user_id';
  static const String keyUser   = 'eco_user';
}
