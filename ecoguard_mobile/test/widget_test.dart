import 'package:flutter_test/flutter_test.dart';
import 'package:ecoguard_mobile/main.dart'; // Pastikan path ini benar

void main() {
  testWidgets('EcoGuard smoke test', (WidgetTester tester) async {
    // 1. Build aplikasi kita (EcoGuardApp, bukan MyApp)
    await tester.pumpWidget(const EcoGuardApp());

    // 2. Verifikasi apakah judul aplikasi muncul di layar
    expect(find.text('EcoGuard Finance'), findsOneWidget);
  });
}
