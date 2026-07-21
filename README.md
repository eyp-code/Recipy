# Recipy - Minimalist Tarif Uygulaması

Karanlık mod odaklı, sade ve hızlı bir Flutter tarif saklama uygulaması. Recipy; tarif ekleme, kategoriye göre filtreleme, adım adım hazırlık takibi, yerel yedekleme ve istatistik ekranlarını tek bir minimalist deneyimde toplar.

## Özellikler

- Sıcak yemek tonlarına sahip minimalist koyu tema
- Hive ile yerel tarif depolama
- Tarif ekleme ve düzenleme
- Malzeme ve hazırlık adımı yönetimi
- Puan, kategori, hazırlık süresi, porsiyon, zorluk derecesi ve favori durumu desteği
- Dinamik malzeme ve hazırlık adımı alanları
- Tarif detay ekranında interaktif kontrol listesi
- Kategori filtreleri:
  - Tümü
  - Tavuk
  - Makarna
  - Tatlı
  - Çorba
  - Vejetaryen
- Sıralama seçenekleri:
  - Puan
  - En Yeni
  - A-Z
- Tarif listesi başlığının yanındaki hızlı `Tarif Ekle` aksiyonu
- Günün rastgele tarif kartı
- JSON dışa ve içe aktarma desteği
- Toplam tarif, ortalama puan ve en yüksek puanlı tarifi gösteren istatistik paneli
- İlk açılış deneyimi
- Açılış ekranı ve özel uygulama ikonları

## Kullanılan Teknolojiler

- Flutter
- Dart
- Hive / Hive Flutter
- JSON Serializable
- GoRouter
- Google Fonts
- Shared Preferences
- File Picker
- Share Plus
- Path Provider
- Flutter Launcher Icons
- Flutter Native Splash

## APK İndir

En güncel Android APK dosyasına GitHub **Releases** sayfasından ulaşabilirsiniz.

1. Depoyu GitHub üzerinde açın.
2. Sayfanın sağ tarafındaki **Releases** bölümüne gidin.
3. En son sürümü açın.
4. **Assets** kısmından `.apk` dosyasını indirin.
5. Gerekiyorsa dosyayı Android cihazınıza aktarın.
6. APK dosyasını açın.
7. Android izin isterse bilinmeyen kaynaklardan yüklemeye izin verin.

> APK dosyalarını her zaman projenin resmi GitHub Releases sayfasından indirin.

## Yerelde Çalıştırma

Bilgisayarınızda Flutter'ın kurulu ve yapılandırılmış olduğundan emin olun.

```bash
flutter pub get
flutter run
```

Model değişikliklerinden sonra üretilen JSON dosyalarının yenilenmesi gerekirse:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Proje Yapısı

```text
lib/
├── core/
│   ├── router.dart
│   └── recipe_sort_option.dart
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── features/
│   └── onboarding/
├── theme/
├── ui/
│   └── screens/
└── viewmodels/
```


## Lisans

Bu projede henüz bir lisans dosyası bulunmamaktadır. Projenin kullanım ve dağıtım koşullarını açıkça belirtmek için uygun bir `LICENSE` dosyası ekleyebilirsiniz.
