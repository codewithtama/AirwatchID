---
name: flutter-security-audit
description: "Use when: mencari celah aplikasi Flutter, audit keamanan, menemukan bug/kerentanan, review izin, deep link, penyimpanan, jaringan, autentikasi, dan dependency risks."
---

# Flutter Security Audit Skill

Tujuan skill ini adalah membantu menemukan potensi celah atau bug pada aplikasi Flutter, lalu menyusun rekomendasi perbaikan yang realistis.

## Fokus utama
- Izin dan akses perangkat
- Penyimpanan lokal dan data sensitif
- Komunikasi jaringan dan TLS
- Input validation dan sanitasi
- Keamanan deep link, intent, dan navigasi
- Dependency / package / SDK yang berisiko
- Log, error handling, dan kebocoran informasi

## Alur kerja

### 1. Pahami arsitektur aplikasi
- Baca struktur proyek: `lib/`, `android/`, `ios/`, `pubspec.yaml`, `README.md`.
- Identifikasi entry point, provider/state, API client, storage, dan autentikasi.
- Catat bagian yang paling kritis: login, token, lokasi, file upload, notifikasi, dan deep link.

### 2. Cari potensi celah yang sering muncul
Periksa hal berikut secara berturut-turut:
1. Izin lokasi, notifikasi, kamera, storage, dan akses jaringan.
2. Data yang disimpan di lokal (Hive, SharedPreferences, file cache, SQLite).
3. Endpoint API dan header token, secret, atau API key yang mungkin tertulis di kode.
4. Input dari pengguna, URL, file path, query params, dan deep links.
5. Paket dependency yang lama atau tidak aman.
6. Penggunaan `dart:io`, `http`, `dio`, file system, dan plugin native.

### 3. Uji logika dan alur pengguna
- Coba jalur normal dan jalur error.
- Periksa apakah aplikasi menampilkan data sensitif di UI, log, atau exception message.
- Cari kemungkinan bypass, crash, stale state, atau improper permission handling.

### 4. Beri bukti dan dampak
Untuk setiap temuan, tulis:
- Lokasi temuan (file / baris / fungsi)
- Risiko yang mungkin terjadi
- Dampak jika dieksploitasi
- Saran perbaikan yang konkret

### 5. Prioritaskan temuan
Gunakan prioritas:
- Tinggi: akses data sensitif, izin berlebihan, token leakage, deep link abuse
- Menengah: validasi lemah, logging terlalu verbose, dependency lama
- Rendah: UX/consistency, pesan error yang kurang aman

## Decision points
- Jika aplikasi memerlukan lokasi / kamera / notifikasi, cek apakah izin diminta hanya saat dibutuhkan.
- Jika ada API token atau secret, cek apakah disimpan di kode atau di konfigurasi publik.
- Jika ada deep link atau intent handling, cek apakah bisa dipicu dari sumber yang tidak dipercaya.
- Jika ada state management, cek apakah data sensitif bisa diakses dari widget lain yang tidak seharusnya.

## Quality criteria
Skill ini dianggap selesai jika hasil audit berisi:
- Ringkasan temuan yang jelas
- Prioritas risiko
- Bukti lokasi kode dan skenario potensi serangan
- Rekomendasi perbaikan yang bisa langsung diterapkan

## Output yang diharapkan
Saat dipakai, jawab dengan format:
1. Temuan utama
2. Risiko dan dampak
3. Lokasi kode / bukti
4. Rekomendasi perbaikan
5. Langkah verifikasi

## Catatan keamanan
Jangan mencoba mengeksploitasi data pengguna nyata atau sistem produksi. Fokus pada audit, penilaian risiko, dan perbaikan aman.
