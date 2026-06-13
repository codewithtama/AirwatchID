# AirWatch ID — Agent Prompt

Build a Flutter Android app: **AirWatch ID** — air quality monitor untuk user Indonesia.

## STACK
Provider, http, Hive, fl_chart, geolocator, geocoding, flutter_local_notifications, home_widget, permission_handler, intl

## STRUCTURE
```
lib/
├── core/           → constants.dart, theme.dart, utils.dart
├── data/api/       → open_meteo_service.dart
├── data/models/    → air_quality.dart (Hive model)
├── data/repos/     → air_quality_repo.dart
├── providers/      → location_provider.dart, air_quality_provider.dart
├── screens/        → home, detail, compare, history, settings
└── widgets/        → aqi_card, pollutant_row, trend_chart, health_advice_card
```

## DATA SOURCE
**Open-Meteo Air Quality API** — 100% gratis, tanpa API key, tanpa registrasi.

Endpoint:
```
https://air-quality-api.open-meteo.com/v1/air-quality
  ?latitude={lat}
  &longitude={lng}
  &hourly=pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,ozone,dust
  &timezone=auto
```

Untuk search kota gunakan **Open-Meteo Geocoding API** (juga gratis, tanpa key):
```
https://geocoding-api.open-meteo.com/v1/search?name={city}&count=5&language=id
```

Tidak ada token/key yang perlu disimpan. Hapus `constants.dart` token placeholder.

## FEATURES
- **Home** — AQI realtime via GPS, circle indicator berwarna per level, health advice bahasa Indonesia, pull-to-refresh, offline fallback dari Hive cache
- **Detail** — breakdown PM2.5/PM10/O3/NO2/CO/SO2 + 24h line chart (fl_chart)
- **Compare** — cari dan bandingkan hingga 3 kota, bar chart
- **Settings** — threshold notif custom, interval auto-refresh, clear cache
- **Notifikasi** — alert kalau AQI lewati threshold user
- **Home Widget** — Android 2x1, tampilkan kota + AQI + warna background

## AQI COLOR MAP
| AQI | Warna | Label |
|-----|-------|-------|
| 0-50 | Green | Baik |
| 51-100 | Yellow | Sedang |
| 101-150 | Orange | Tidak Sehat (Sensitif) |
| 151-200 | Red | Tidak Sehat |
| 201-300 | Purple | Sangat Tidak Sehat |
| 301+ | Maroon | Berbahaya |

## DESIGN
- AMOLED dark theme (background pure black)
- UI copy bahasa Indonesia
- Shimmer loading pada cards
- Animasi transisi warna AQI circle

## BUILD ORDER
constants → theme → utils → models → api service → repo → providers → widgets → screens
