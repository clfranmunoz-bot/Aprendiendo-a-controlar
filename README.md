# Aprender a Controlar

Aplicación móvil desarrollada en Flutter orientada a la formación y apoyo operacional de controladores de sondajes en faenas mineras.

## Descripción

**Aprender a Controlar** es una herramienta educativa y de campo que permite a los controladores de sondajes:
- Aprender los procedimientos fundamentales de control de sondajes paso a paso
- Practicar cálculos operacionales (recuperación, contra, fondo de pozo, regularización)
- Evaluar sus conocimientos teóricos mediante quizzes con puntaje
- Controlar el avance de su turno mediante checklists persistentes
- Consultar un glosario técnico de términos de perforación
- Registrar fotográficamente las bandejas de testigo con ayuda memoria
- Revisar procedimientos y documentos obligatorios de la operación

## Plataformas soportadas

| Plataforma | Estado |
|---|---|
| Android | ✅ APK disponible |
| iOS | ✅ Compatible |
| macOS | ✅ Compatible |
| Web | ⚠️ Compatibilidad parcial (cámara simulada) |

## Requisitos previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Android Studio (para emulador Android) o Xcode (para iOS/macOS)

## Instalación y ejecución

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en macOS (recomendado para desarrollo)
flutter run -d macos

# Compilar APK de release para Android
flutter build apk --release

# Compilar para iOS
flutter build ios
```

## Estructura del proyecto

```
lib/
├── main.dart                  # Entry point, sistema de acceso y router principal
├── models/                    # Modelos de datos (Pregunta, Problema, Sección, etc.)
├── screens/                   # Pantallas de la aplicación
│   ├── home_screen.dart       # Pantalla principal con slots personalizables
│   ├── calculadoras_screen.dart
│   ├── quiz_screen.dart
│   ├── ejercicios_screen.dart
│   ├── checklist_screen.dart
│   ├── camara_screen.dart
│   ├── glosario_screen.dart
│   └── ...
├── utils/                     # Lógica y datos
│   ├── app_colors.dart        # Sistema de colores (modo claro/oscuro)
│   ├── app_routes.dart        # Constantes de rutas de navegación
│   ├── calculos_sondajes.dart # Motor de generación de problemas matemáticos
│   ├── secciones_data.dart    # Catálogo de secciones de la app
│   └── ...
└── widgets/                   # Componentes reutilizables
    ├── hero_block.dart        # Bloque principal con slots personalizables
    ├── drawer_menu.dart       # Menú lateral de navegación
    └── ...
```

## Sistema de acceso

La aplicación implementa un sistema de acceso por contraseña con rotación mensual. Las contraseñas **no están almacenadas en el código fuente**; solo se guardan sus hashes SHA-256. El administrador del sistema gestiona el mapeo de contraseñas de forma independiente al repositorio.

## Capturas de pantalla

| Inicio | Calculadoras | Checklist |
|---|---|---|
| ![Inicio](home_screen.png) | ![Calculadoras](calculadoras_screen.png) | ![Checklist](checklist_screen.png) |

| Cámara | Glosario |
|---|---|
| ![Cámara](camara_screen.png) | ![Glosario](glosario_screen.png) |
