# test_01

Hướng dẫn cài đặt và chạy Flutter app.

> Repo sử dụng chủ yếu: **Dart (Flutter)** và một ph��n **C++/CMake** (native), kèm **Swift** (iOS).

---

## 1) Yêu cầu môi trường

### Flutter
- Cài **Flutter SDK** (khuyến nghị bản stable)
- Kiểm tra môi trường:
  ```bash
  flutter doctor
  ```

### Android (nếu chạy Android)
- Cài **Android Studio**
- Cài Android SDK + Android SDK Platform Tools
- Tạo/kiểm tra emulator hoặc cắm thiết bị thật (bật Developer options + USB debugging)

### iOS (nếu chạy iOS)
- Chỉ hỗ trợ trên **macOS**
- Cài **Xcode**
- Cài CocoaPods:
  ```bash
  sudo gem install cocoapods
  ```

---

## 2) Cài dependencies

Tại thư mục project:
```bash
flutter pub get
```

---

## 3) Chạy app (Development)

### Chạy trên Android
```bash
flutter run
```

### Chạy trên iOS (macOS)
```bash
cd ios
pod install
cd ..
flutter run
```

### Chạy chọn thiết bị cụ thể
Liệt kê thiết bị:
```bash
flutter devices
```

Chạy với device id:
```bash
flutter run -d <device_id>
```

---

## 4) Build bản phát hành (Release)

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
```

### iOS (cần macOS + Xcode)
```bash
flutter build ios --release
```
Sau đó mở Xcode để Archive/Export (Product → Archive).

---

## 5) Lỗi thường gặp

### `flutter doctor` báo thiếu SDK/License
Android licenses:
```bash
flutter doctor --android-licenses
```

### Lỗi CocoaPods (iOS)
Thử:
```bash
cd ios
pod repo update
pod install
cd ..
```

### Lỗi build (clean & chạy lại)
```bash
flutter clean
flutter pub get
flutter run
```
