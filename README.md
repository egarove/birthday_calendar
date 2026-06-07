# Birthday Calendar 🎂

¡Nunca más olvides un cumpleaños! **Birthday Calendar** es una aplicación móvil desarrollada en **Flutter** que te permite registrar los cumpleaños de tus seres queridos, almacenarlos de forma segura en la nube y recibir notificaciones personalizadas tanto el día del cumpleaños como el día anterior.

---

## Características

- **Autenticación**: Registro e inicio de sesión con correo/contraseña o cuenta de Google (Firebase Auth).
- **Sincronización en la nube**: Datos almacenados en Cloud Firestore, accesibles desde cualquier dispositivo.
- **Notificaciones locales inteligentes**:
  - Notificación el **día del cumpleaños** a las 00:00 (medianoche).
  - Notificación el **día de antes** a las 10:00 para que tengas tiempo de comprar un regalo.
  - Alerta de **inactividad a los 360 días** recordándote abrir la app para que las notificaciones se reprogramen.
- **Orden automático**: La lista de cumpleaños se ordena por la proximidad de la siguiente fecha.

---

## Tecnologías empleadas

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Backend**: [Firebase](https://firebase.google.com/) — Firestore, Firebase Auth, Google Sign-In
- **Notificaciones Locales**: `flutter_local_notifications`
- **Timezones**: `timezone` y `flutter_timezone`

---

## Requisitos Previos

- **Flutter SDK** (versión estable más reciente)
- **Android Studio** o **VS Code** con extensiones de Flutter/Dart

---

## Configuración y Despliegue

### 1. Clonar el repositorio
```bash
git clone https://github.com/tu-usuario/birthday_calendar.git
cd birthday_calendar
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Ejecutar la aplicación
```bash
flutter run
```

---
