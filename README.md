<img width="1254" height="1254" alt="ic_launcher" src="https://github.com/user-attachments/assets/b95cd208-cda5-4b68-b30c-d0e27b03beea" />

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

## Capturas

<img width="1001" height="2048" alt="WhatsApp Image 2026-06-07 at 11 39 21" src="https://github.com/user-attachments/assets/23b7bf1a-3de1-41ec-a7db-7ee954376700" />
<img width="1080" height="2186" alt="WhatsApp Image 2026-06-07 at 11 39 22" src="https://github.com/user-attachments/assets/afd9c0b4-8db7-47d1-830f-f54044533bb8" />
<img width="1080" height="2159" alt="WhatsApp Image 2026-06-07 at 11 39 21 (3)" src="https://github.com/user-attachments/assets/1de02d5e-7b3c-4a8f-82ba-f6b2e26db80a" />
<img width="1080" height="2167" alt="WhatsApp Image 2026-06-07 at 11 39 21 (2)" src="https://github.com/user-attachments/assets/918542e4-bf17-4c4b-8848-3b2dde472457" />
<img width="1010" height="2048" alt="WhatsApp Image 2026-06-07 at 11 39 21 (1)" src="https://github.com/user-attachments/assets/593a2e99-49c4-4e24-a852-d3df1d0698e9" />
<img width="1080" height="338" alt="WhatsApp Image 2026-06-07 at 11 40 42" src="https://github.com/user-attachments/assets/cdb07b27-d6e3-4505-81ee-8dc469670fbb" />

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
