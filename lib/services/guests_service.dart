import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/guest.dart';

class GuestsService {
  GuestsService({this._client});

  final SupabaseClient? _client;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  Future<List<Guest>> listGuests({String? search}) async {
    var query = _supabase.from('guests').select();
    if (search != null && search.trim().isNotEmpty) {
      query = query.ilike('full_name', '%${search.trim()}%');
    }
    final rows = await query.order('full_name');
    return rows.map((g) => Guest.fromJson(g)).toList();
  }

  Future<Guest> createGuest({
    required String fullName,
    String? contactEmail,
    String? contactPhone,
    String? idNumber,
  }) async {
    final row = await _supabase.from('guests').insert({
      'full_name': fullName,
      'contact_email': contactEmail?.trim().isEmpty ?? true ? null : contactEmail!.trim(),
      'contact_phone': contactPhone?.trim().isEmpty ?? true ? null : contactPhone!.trim(),
      'id_number': idNumber?.trim().isEmpty ?? true ? null : idNumber!.trim(),
    }).select().single();
    return Guest.fromJson(row);
  }

  Future<Guest> updateGuest(Guest guest) async {
    final json = guest.toJson()..remove('id');
    final row =
        await _supabase.from('guests').update(json).eq('id', guest.id).select().single();
    return Guest.fromJson(row);
  }

  Future<void> deleteGuest(String id) =>
      _supabase.from('guests').delete().eq('id', id);
}
