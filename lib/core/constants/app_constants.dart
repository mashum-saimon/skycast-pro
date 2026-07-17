/// Central place for every constant used across SkyCast Pro.
///
/// IMPORTANT:
/// Replace [AppConstants.apiKey] with your own OpenWeatherMap API key.
/// Get a free key at: https://openweathermap.org/api
class AppConstants {
  AppConstants._();

  // ---------------------------------------------------------------------
  // API
  // ---------------------------------------------------------------------
  static const String apiKey = '169c1542189761bde04aaa3e986d1da5';
 /// True only when someone has actually replaced the placeholder above.
static bool get isApiKeyConfigured =>
    apiKey.trim().isNotEmpty &&
    apiKey != 'YOUR_OPENWEATHERMAP_API_KEY';

  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String geoUrl = 'https://api.openweathermap.org/geo/1.0';
  static const String iconBaseUrl = 'https://openweathermap.org/img/wn';

  static const String currentWeatherEndpoint = '/weather';
  static const String forecastEndpoint = '/forecast';
  static const String airPollutionEndpoint = '/air_pollution';
  static const String geoDirectEndpoint = '/direct';

  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;

  // ---------------------------------------------------------------------
  // DATABASE
  // ---------------------------------------------------------------------
  static const String dbName = 'skycast_pro.db';
  static const int dbVersion = 2;

  static const String tableSavedCities = 'saved_cities';
  static const String tableSearchHistory = 'search_history';
  static const String tableWeatherCache = 'weather_cache';
  static const String tableRecentlyViewed = 'recently_viewed';
  static const String tableUsers = 'users';

  // ---------------------------------------------------------------------
  // APP
  // ---------------------------------------------------------------------
  static const String appName = 'SkyCast Pro';
  static const String appTagline = 'Weather, refined.';

  static const int splashDurationMs = 2600;
  static const int searchDebounceMs = 450;
  static const int pageSize = 6;

  static const Duration cacheValidity = Duration(hours: 3);

  // ---------------------------------------------------------------------
  // PREFERENCES KEYS
  // ---------------------------------------------------------------------
  static const String prefThemeMode = 'pref_theme_mode';
  static const String prefUnits = 'pref_units';
  static const String prefLastCity = 'pref_last_city';
}
