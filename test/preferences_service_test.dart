import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aprender_a_controlar/services/preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PreferencesService Tests', () {
    test('Valores predeterminados correctos', () async {
      SharedPreferences.setMockInitialValues({});
      final service = await PreferencesService.getInstance();

      expect(service.modoOscuro, isFalse);
      expect(service.perfilActivo, 'Usuario Principal');
      expect(service.perfilesLista, ['Usuario Principal']);
      expect(service.onboardingVisto, isFalse);
      expect(service.tutorialCompletado, isFalse);
    });

    test('Guardado y lectura de preferencias', () async {
      SharedPreferences.setMockInitialValues({});
      final service = await PreferencesService.getInstance();

      await service.setModoOscuro(true);
      expect(service.modoOscuro, isTrue);

      await service.setPerfilActivo('Controlador Faena');
      expect(service.perfilActivo, 'Controlador Faena');

      await service.setPerfilesLista(['Usuario Principal', 'Controlador Faena']);
      expect(service.perfilesLista, ['Usuario Principal', 'Controlador Faena']);
    });
  });
}
