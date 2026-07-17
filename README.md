# 🌤️ SkyCast Pro

A premium, enterprise-grade weather application built with **Flutter**, **Clean Architecture**, **Riverpod**, and **SQLite**. Designed to feel like a product from Apple, Google Material 3, or a premium fintech app — luxury, minimal, elegant, and buttery smooth.

---

## 📖 Project Overview

SkyCast Pro delivers real-time weather, hourly and 7-day forecasts, air quality, and a fully offline-capable experience. Users can search any city worldwide, save favorites, rename saved cities, and browse recently viewed locations — all backed by a local SQLite cache so the app keeps working even without internet.

---

## ✨ Features

| Category | Details |
|---|---|
| **Splash Screen** | Animated logo, fade + scale transitions, auto-navigates to Home |
| **Home Screen** | Current conditions, animated gradient background, hourly & 7-day forecast, favorites, recents, pull-to-refresh |
| **Detail Screen** | Full metrics, temperature trend chart, sunrise/sunset, wind direction, AQI |
| **Search** | Debounced (450ms) live search via geocoding API, recent search history |
| **CRUD** | Create / rename / favorite / delete saved cities — 100% local SQLite |
| **Pagination** | Local "Load More" pagination over saved cities (API has no native pagination) |
| **Offline Mode** | Automatic fallback to cached weather with a persistent offline banner |
| **Error Handling** | Retry-able error states, empty states, network/server/unknown failure types |
| **Loading States** | Shimmer skeleton loaders |
| **Responsive** | Built with `flutter_screenutil`, adapts across phones and tablets |
| **Theming** | Material 3, Light / Dark / System, persisted via `SharedPreferences` |
| **Location** | GPS-based "current location" weather via `geolocator` |
| **Animations** | Hero transitions, `AnimatedContainer`, fade/slide page transitions, animated gradient backgrounds |

---

## 🏗️ Architecture

SkyCast Pro follows **Clean Architecture** with strict separation of concerns and the **Repository Pattern**:

```
Presentation  →  Domain  →  Data
   (UI/State)   (Business)  (API/DB)
```

- **Domain layer** has zero dependency on Flutter or any package except `equatable`/`dartz` — pure business logic (entities, repository contracts, use cases).
- **Data layer** implements the domain contracts, talking to `Dio` (remote) and `sqflite` (local), and always returns `Either<Failure, T>` (via `dartz`) so the UI layer never deals with raw exceptions.
- **Presentation layer** uses Riverpod `StateNotifier`s per feature (weather, search, saved cities, theme, connectivity) — no `setState` except trivial local UI concerns (text field clear button, focus).

### Offline strategy
Every successful weather fetch is cached to SQLite. If the device is offline (checked via `connectivity_plus`) or the API call fails with a network error, the repository transparently falls back to the last cached reading for that city and flags the state as `isFromCache`, which drives the offline banner.

---

## 📁 Folder Structure

```
lib/
├── core/
│   ├── constants/        → app_constants.dart (API keys, table names, durations)
│   ├── theme/            → app_colors.dart, app_theme.dart (Light/Dark M3 themes)
│   ├── utils/            → failure.dart (typed error hierarchy)
│   └── network/          → api_client.dart (Dio wrapper), network_info.dart
├── data/
│   ├── models/           → WeatherModel, ForecastModel, CityModel (JSON + SQLite mapping)
│   ├── datasources/      → remote (OpenWeatherMap) & local (sqflite) data sources
│   └── repositories/     → WeatherRepositoryImpl (orchestrates remote/local/offline)
├── domain/
│   ├── entities/         → WeatherEntity, ForecastEntity, CityEntity
│   ├── repositories/     → WeatherRepository (abstract contract)
│   └── usecases/         → GetCurrentWeather, GetForecast, SearchCity, CRUD use cases
├── presentation/
│   ├── screens/          → splash, home, detail, search
│   ├── widgets/          → glass_card, animated background, forecast lists, metric tiles, etc.
│   ├── providers/        → Riverpod providers & StateNotifiers
│   └── routing/          → go_router configuration
├── services/             → location_service.dart (GPS)
├── database/             → database_helper.dart (SQLite schema/migrations)
├── app.dart              → Root MaterialApp.router widget
└── main.dart             → Entry point
```

---

## 📦 Packages Used

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `dio` | HTTP client |
| `sqflite` / `path` / `path_provider` | Local relational storage |
| `shared_preferences` | Lightweight key-value prefs (theme mode) |
| `go_router` | Declarative routing & transitions |
| `google_fonts` | Premium typography (Inter Tight / Inter) |
| `flutter_screenutil` | Responsive sizing |
| `cached_network_image` | Image caching (available for raster icon use) |
| `lottie` | Drop-in slot for Lottie animations |
| `shimmer` | Loading skeletons |
| `fl_chart` | Temperature trend chart |
| `connectivity_plus` | Online/offline detection |
| `geolocator` / `permission_handler` | GPS location & permissions |
| `equatable` | Value equality for entities/state |
| `dartz` | Functional `Either<Failure, T>` error handling |
| `intl` | Date/time formatting |
| `logger` | Structured debug logging |

---

## 🌐 API Used

**[OpenWeatherMap](https://openweathermap.org/api)** — Current Weather, 5 Day / 3 Hour Forecast, Geocoding, and Air Pollution endpoints (all available on the free tier).

> ⚠️ Before running the app, open `lib/core/constants/app_constants.dart` and replace:
> ```dart
> static const String apiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
> ```
> with your own free API key from https://openweathermap.org/api.

---

## ▶️ How to Run

This repository ships the complete `lib/` source tree, `pubspec.yaml`, lint config, and `.gitignore`. Platform folders (`android/`, `ios/`, etc.) are intentionally not included since they're auto-generated — this keeps the deliverable lean and avoids shipping stale platform boilerplate.

```bash
# 1. Place this project folder somewhere on your machine, then:
cd skycast_pro

# 2. Generate the native platform projects
flutter create . --platforms=android,ios

# 3. Install dependencies
flutter pub get

# 4. Add your API key in lib/core/constants/app_constants.dart

# 5. Run on a connected device or emulator
flutter run
```

### Requirements
- Flutter 3.24+ / Dart 3.5+
- An OpenWeatherMap API key (free tier is sufficient)
- Location permissions enabled on the test device for GPS-based weather

---

## 🖼️ Screenshots

> _Add your screenshots here after running the app:_
>
> `assets/screenshots/splash.png` · `assets/screenshots/home.png` · `assets/screenshots/detail.png` · `assets/screenshots/search.png`

---

## 🧱 Code Quality

- SOLID principles: each use case does one thing; repositories depend on abstractions, not concrete data sources.
- Reusable, composable widgets (`GlassCard`, `WeatherMetricTile`, `WeatherIconWidget`, etc.) shared across Home/Detail screens.
- No business logic in widgets — all data flows through Riverpod `StateNotifier`s.
- Consistent naming and minimal, purposeful comments.

---

## 📝 Notes & Possible Extensions

- Weather alerts and push notifications are structurally easy to add via a background `WorkManager`/`Dio` poll against the `/onecall` alerts field (requires a One Call API subscription).
- UV Index is left as `N/A` when unavailable on the free tier — swap in the One Call API for full UV data.
- Lottie animation assets are wired into `pubspec.yaml` (`assets/lottie/`) — drop in `.json` files and swap `WeatherIconWidget` for `Lottie.asset(...)` for even richer motion.
