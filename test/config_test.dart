import 'package:flutter_test/flutter_test.dart';

import 'package:hotelms/config/app_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await AppConfig.load();
  });

  test('loads SUPABASE_URL from .env', () {
    final url = AppConfig.supabaseUrl;
    expect(url, isNotEmpty);
    expect(url, startsWith('https://'));
  });

  test('loads SUPABASE_ANON_KEY from .env', () {
    expect(AppConfig.supabaseAnonKey, isNotEmpty);
  });
}
