# Assam Local Service

Doorstep local services app for Assam — Electrician, Plumber, Carpenter, Barber, Mason, Home Cleaning, Painter, AC Repair.

## Features

- Google & Facebook login
- Browse services by category with rate list
- Book doorstep service (COD)
- Live location (Assam-focused)
- Service Partner registration & online/offline mode
- Incoming order popups for partners
- In-app chat + WhatsApp
- Order status updates + completion OTP
- Admin panel (store products, partners, live orders)
- Multi-language UI (English / Assamese / Bengali)
- Push notifications (FCM + local)

## Project Structure

```
lib/
├── main.dart
├── app.dart                    # MaterialApp, routes, theme
├── core/
│   ├── constants/              # colors, strings, categories, admin emails
│   ├── theme/                  # AppTheme
│   └── utils/
├── models/                     # PartnerModel, OrderModel
├── services/                   # Auth, Location, Notifications
├── screens/
│   ├── auth/
│   ├── home/
│   ├── booking/
│   ├── provider/
│   ├── profile/
│   ├── chat/
│   ├── maps/
│   └── admin/
└── widgets/
```

## Setup

1. Clone the repo
2. Add your `google-services.json` (Android) under `android/app/`
3. Configure Firebase (Auth, Firestore, Messaging)
4. Run:

```bash
flutter pub get
flutter run
```

## Build APK

```bash
flutter build apk --release
```

GitHub Actions workflow is included under `.github/workflows/build-apk.yml`.

## Admin access

Admin panel is gated by email listed in `lib/core/constants/app_constants.dart`  
(`AppConstants.adminEmails`). Prefer moving this to a Firestore `role: admin` field later.

## Tech stack

- Flutter 3.x
- Firebase Auth, Firestore, Cloud Messaging
- Google Maps / Geolocator
- Google Sign-In + Facebook Auth

---

Made with ❤️ in Assam
