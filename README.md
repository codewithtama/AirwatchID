# AirWatch ID

> **Monitor kualitas udara real-time untuk pengguna Indonesia.**  
> Dirancang dengan presisi. Dibangun untuk privasi mutlak.

---

## Tentang Aplikasi

**AirWatch ID** adalah aplikasi mobile Android yang menampilkan data kualitas udara secara real-time berdasarkan lokasi pengguna di seluruh Indonesia. Aplikasi ini menyajikan informasi polutan seperti PM2.5, PM10, Ozon, Nitrogen Dioksida, dan Karbon Monoksida dengan antarmuka yang bersih, modern, dan responsif.

Semua data divisualisasikan menggunakan indeks AQI (Air Quality Index) standar internasional, dilengkapi saran kesehatan dalam Bahasa Indonesia.

---

## Fitur Utama

- **Beranda Real-time** — Indikator AQI berbasis GPS dengan animasi lingkaran warna dinamis
- **Detail Polutan** — Breakdown PM2.5, PM10, O₃, NO₂, CO, Dust dengan grafik tren 24 jam
- **Prakiraan 7 Hari** — Prediksi kualitas udara mingguan dalam bentuk bar chart harian
- **Peta Kualitas Udara** — Visualisasi peta interaktif dengan overlay radius polusi
- **Bandingkan Kota** — Komparasi hingga 3 kota sekaligus dengan bar chart perbandingan
- **Statistik & Riwayat** — Heatmap kalender AQI harian, ringkasan terbaik/terburuk
- **Notifikasi Cerdas** — Peringatan otomatis saat AQI melonjak drastis atau melampaui batas
- **Home Widget Android** — Widget 2×1 di homescreen: kota, nilai AQI, status warna
- **Bagikan Kartu AQI** — Ekspor kartu informasi premium ke WhatsApp, Instagram, dll
- **Mode Offline** — Cache lokal otomatis, aplikasi tetap berfungsi tanpa internet

---

## Privasi Mutlak

AirWatch ID dirancang dengan prinsip **privasi-by-design**:

- ✦ **Tidak ada akun.** Tidak ada registrasi, tidak ada login.
- ✦ **Tidak ada pelacakan.** Tidak ada analitik pihak ketiga, tidak ada iklan, tidak ada telemetri.
- ✦ **Data tetap di perangkat Anda.** Seluruh cache tersimpan lokal menggunakan Hive database yang terenkripsi di perangkat.
- ✦ **Lokasi tidak dikirim ke server manapun.** Koordinat GPS hanya digunakan secara lokal untuk query API cuaca publik.
- ✦ **Tanpa API key pribadi.** Sumber data menggunakan endpoint publik Open-Meteo tanpa identitas pengguna.

> Anda adalah satu-satunya pemilik data Anda.

---

## Sumber Data

| Layanan | Kegunaan |
|---------|----------|
| [Open-Meteo Air Quality API](https://open-meteo.com/) | Data polutan real-time & prakiraan |
| [Open-Meteo Geocoding API](https://open-meteo.com/) | Pencarian nama kota |
| OpenStreetMap (via CartoDB) | Tile peta interaktif |

---

## Stack Teknologi

| Komponen | Teknologi |
|----------|-----------|
| Framework | Flutter 3.x (Dart) |
| State Management | Provider |
| Database Lokal | Hive |
| Grafik | fl_chart |
| Peta | flutter_map + latlong2 |
| Notifikasi | flutter_local_notifications |
| Font | Sora (Google Fonts) |

---

## Struktur Proyek

```
lib/
├── core/           → Konstanta, tema, utilitas AQI
├── data/
│   ├── api/        → Open-Meteo API service
│   ├── models/     → Model data + Hive adapter
│   └── repos/      → Repository dengan caching
├── providers/      → LocationProvider, AirQualityProvider
├── services/       → NotificationService
├── screens/        → home, detail, forecast, map, compare, stats, settings
└── widgets/        → aqi_card, pollutant_row, trend_chart, health_advice_card, share_card
```

---

## Hak Cipta & Lisensi

© 2026 **Dimas Alfa Pratama**. Seluruh hak cipta dilindungi.

Aplikasi ini merupakan karya pribadi yang **tidak dilisensikan untuk distribusi, modifikasi, atau penggunaan komersial** tanpa izin tertulis dari pemilik. Lihat [LICENSE](./LICENSE) untuk detail lengkap.

---

*Dibuat oleh **Dimas Alfa Pratama** — 2026*
