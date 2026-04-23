# Başarabilirim! 🎯

Kişisel takip uygulaması — sigara bırakma, diyet, ders ve proje yönetimi.

## Proje Yapısı

```
lib/
├── main.dart                    # Uygulama girişi & ana navigasyon
├── theme.dart                   # Renkler & tema
├── models/
│   ├── smoke_model.dart         # Sigara veri modeli
│   ├── diet_model.dart          # Diyet veri modeli
│   ├── study_model.dart         # Ders veri modeli
│   └── project_model.dart       # Proje veri modeli
├── providers/
│   └── app_provider.dart        # Merkezi state yönetimi
├── screens/
│   ├── smoke_screen.dart        # Sigara ekranı
│   ├── diet_screen.dart         # Diyet ekranı
│   ├── study_screen.dart        # Ders takip ekranı
│   └── projects_screen.dart     # Projeler ekranı
└── widgets/
    └── shared_widgets.dart      # Paylaşılan bileşenler
```

## Kurulum

### Gereksinimler
- Flutter SDK 3.x
- Dart 3.x

### Adımlar

```bash
# 1. Bağımlılıkları yükle
flutter pub get

# 2. Android için çalıştır
flutter run

# 3. iOS için çalıştır (macOS gerekli)
flutter run -d ios

# 4. Release APK oluştur (Android)
flutter build apk --release

# 5. Release IPA oluştur (iOS, macOS gerekli)
flutter build ipa --release
```

## Özellikler

### 🚬 Sigara Modülü
- Günlük içilen sigara sayacı
- Günlük limit belirleme
- Paket fiyatı & adet ayarı
- Tasarruf ve günlük maliyet hesaplama
- Aylık maliyet tahmini

### 🥗 Diyet Modülü
- Günlük kalori hedefi
- Öğün ekleme / silme
- Su tüketimi takibi (bardak sayacı)
- Dairesel ilerleme göstergesi

### 📚 Ders Modülü
- Canlı kronometre ile çalışma seansi
- Konu/ders adıyla başlatma
- Biten seansları listeleme
- Günlük toplam çalışma süresi

### 🗂 Projeler Modülü
- Proje oluşturma (öncelik, açıklama, son tarih)
- Alt görev ekleme ve takibi
- İlerleme çubuğu
- Tamamlama durumu

## Bağımlılıklar

| Paket | Kullanım |
|-------|----------|
| `provider` | State yönetimi |
| `shared_preferences` | Yerel veri saklama |
| `google_fonts` | DM Sans + Space Mono |
| `intl` | Türkçe tarih formatı |
