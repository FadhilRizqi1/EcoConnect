import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import 'auth_service.dart';

class ApiService {
  ApiService._();

  // ── Helpers ──────────────────────────────────────────────────────

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await AuthService.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Map<String, dynamic> _parse(http.Response res) {
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 400) {
      throw ApiException(
        statusCode: res.statusCode,
        message: body['error'] ?? body['pesan'] ?? 'Terjadi kesalahan',
      );
    }
    return body as Map<String, dynamic>;
  }

  // ── Auth ─────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> daftar({
    required String nama,
    required String email,
    required String password,
    required String kategori,
  }) async {
    final res = await http.post(
      Uri.parse(AppConstants.daftar),
      headers: await _headers(auth: false),
      body: jsonEncode({'name': nama, 'email': email, 'password': password, 'category': kategori}),
    );
    return _parse(res);
  }

  static Future<Map<String, dynamic>> masuk({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse(AppConstants.masuk),
      headers: await _headers(auth: false),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _parse(res);
  }

  // ── Actions (new endpoint) ────────────────────────────────────────

  static Future<List<dynamic>> getActions({String? kategori}) async {
    final uri = Uri.parse(AppConstants.actions).replace(
      queryParameters: kategori != null ? {'kategori': kategori} : null,
    );
    final res = await http.get(uri, headers: await _headers());
    final data = _parse(res);
    return data['aksi'] as List<dynamic>? ?? [];
  }

  static Future<Map<String, dynamic>> checkIn({
    required int actionId,
    required double inputValue,
    String notes = '',
  }) async {
    final res = await http.post(
      Uri.parse(AppConstants.checkin),
      headers: await _headers(),
      body: jsonEncode({
        'action_id': actionId,
        'input_value': inputValue,
        'notes': notes,
      }),
    );
    return _parse(res);
  }

  // ── Profil & Leaderboard ─────────────────────────────────────────

  static Future<Map<String, dynamic>> getProfil(int userId) async {
    final res = await http.get(
      Uri.parse(AppConstants.profil(userId)),
      headers: await _headers(),
    );
    return _parse(res);
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse(AppConstants.updateProfil),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return _parse(res);
  }

  static Future<List<dynamic>> getLeaderboard() async {
    final res = await http.get(
      Uri.parse(AppConstants.papanPeringkat),
      headers: await _headers(),
    );
    final data = _parse(res);
    return data['peringkat'] as List<dynamic>? ?? [];
  }

  static Future<Map<String, dynamic>> getRiwayat() async {
    final res = await http.get(
      Uri.parse(AppConstants.riwayat),
      headers: await _headers(),
    );
    return _parse(res);
  }

  // ── Komunitas (new endpoint) ──────────────────────────────────────

  static Future<List<dynamic>> getCommunities({String? kategori}) async {
    final uri = Uri.parse(AppConstants.communities).replace(
      queryParameters: kategori != null ? {'kategori': kategori} : null,
    );
    final res = await http.get(uri, headers: await _headers());
    final data = _parse(res);
    return data['komunitas'] as List<dynamic>? ?? [];
  }

  static Future<List<dynamic>> getCommunityMessages(int communityId) async {
    final res = await http.get(
      Uri.parse(AppConstants.communityMessages(communityId)),
      headers: await _headers(),
    );
    final data = _parse(res);
    return data['pesan'] as List<dynamic>? ?? [];
  }

  static Future<Map<String, dynamic>> toggleJoinCommunity(int communityId) async {
    final res = await http.post(
      Uri.parse(AppConstants.toggleCommunityJoin(communityId)),
      headers: await _headers(),
    );
    return _parse(res);
  }

  static Future<Map<String, dynamic>> sendCommunityMessage(
    int communityId,
    String message,
  ) async {
    final res = await http.post(
      Uri.parse(AppConstants.communityMessages(communityId)),
      headers: await _headers(),
      body: jsonEncode({'message': message}),
    );
    return _parse(res);
  }
}

/// Typed API error for clean error handling in UI
class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => message;
}
