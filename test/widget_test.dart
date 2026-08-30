// Prueba básica de widget para la app "Aprender a Controlar".
// Se actualizará con pruebas específicas de cada módulo en etapas posteriores.

import 'package:flutter_test/flutter_test.dart';
import 'package:aprender_a_controlar/main.dart';

void main() {
  testWidgets('App arranca sin errores', (WidgetTester tester) async {
    await tester.pumpWidget(
      const AprenderAControlarApp(
        modoOscuroInicial: false,
        accesoAutorizadoInicial: true,
        appBloqueadaInicial: false,
        intentosIniciales: 0,
        perfilActivoInicial: 'Usuario Principal',
        perfilesIniciales: ['Usuario Principal'],
        necesitaValidacion28Inicial: false,
        appBloqueada28Inicial: false,
        intentos28Iniciales: 0,
      ),
    );
    // Solo verifica que la app se construye sin lanzar excepciones.
    expect(find.byType(AprenderAControlarApp), findsOneWidget);
  });
}
