# ماشین‌حساب خطرناک (Khatarnak Calculator)

ماشین‌حساب گرافیکی، شیءگرا (Object-Oriented) و خفن، نوشته‌شده با Flutter/Dart برای اندروید و ویندوز.

## ویژگی‌ها
- طراحی نئون تیره با افکت شیشه‌ای (Glassmorphism) و دکمه‌های انیمیشنی
- موتور محاسباتی کاملاً شیءگرا: `Lexer` → `Parser` → `AST` → `evaluate()` (پشتیبانی از پرانتز، توان `^`، درصد `%`، اولویت درست عملگرها)
- تاریخچهٔ محاسبات با امکان استفادهٔ دوباره از نتایج قبلی
- پشتیبانی از اندروید ۷.۰ به بالا (`minSdkVersion 24`) و ویندوز ۷ / ۸.۱ / ۱۰ / ۱۱
- انتشار خودکار فایل APK و نصب‌کنندهٔ EXE ویندوز از طریق GitHub Actions در هر تگ نسخه

## ساختار پروژه
```
lib/
  engine/     منطق محاسباتی (Token, Lexer, AST, Parser, CalculatorController)
  models/     مدل داده دکمه‌ها (CalcButtonData)
  theme/      رنگ‌ها و گرادیان‌های نئون
  widgets/    ویجت‌های قابل استفاده مجدد (دکمه، نمایشگر، پنل تاریخچه، ظرف شیشه‌ای)
  screens/    صفحهٔ اصلی ماشین‌حساب
test/         تست‌های واحد موتور محاسباتی
assets/icon/  تصویر منبع آیکن برنامه (برای هر دو پلتفرم)
tool/         اسکریپت پایتون تولید آیکن (Pillow)
scripts/      اسکریپت‌های راه‌اندازی پلتفرم اندروید/ویندوز (محلی و CI)
installer/    اسکریپت Inno Setup برای ساخت نصب‌کنندهٔ ویندوز
.github/workflows/release.yml   پایپ‌لاین کامل CI/CD
```

> **نکته مهم:** پوشه‌های `android/` و `windows/` عمداً در مخزن قرار ندارند. این پوشه‌ها حاوی کد و فایل‌های باینری تولیدشدهٔ خودِ Flutter هستند (مثل gradle wrapper) که در هر ماشین ممکن است متفاوت باشند؛ به همین دلیل هم در محیط محلی (با `scripts/setup_local.sh`) و هم در GitHub Actions، این پوشه‌ها با دستور `flutter create` به‌صورت خودکار ساخته و سپس با `scripts/apply_platform_config.sh` پیکربندی می‌شوند (تنظیم `minSdkVersion 24` و غیره). این یک الگوی رایج و پایدار برای نگه‌داشتن مخزن تمیز است.

## اجرای محلی
پیش‌نیاز: نصب [Flutter SDK](https://docs.flutter.dev/get-started/install) (کانال stable، نسخه ۳.۲۴ یا بالاتر).

```bash
git clone <repo-url>
cd khatarnak_calculator
bash scripts/setup_local.sh

flutter run -d windows      # اجرا روی ویندوز
flutter run                 # اجرا روی اندروید (دستگاه یا شبیه‌ساز متصل)
```

## تست‌ها
```bash
flutter test
```

## انتشار نسخهٔ جدید (Release خودکار)
1. در صورت نیاز، نسخه را در `pubspec.yaml` به‌روزرسانی کنید.
2. یک تگ Git بسازید و پوش کنید:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. اکشن `Build & Release` (`.github/workflows/release.yml`) به‌صورت خودکار:
   - پلتفرم‌های اندروید و ویندوز را با `flutter create` می‌سازد و با `scripts/apply_platform_config.sh` پیکربندی می‌کند
   - آیکن برنامه را برای هر دو پلتفرم با `flutter_launcher_icons` تولید می‌کند
   - `app-release.apk` (نسخهٔ نصب برای اندروید ۷ به بالا) را می‌سازد
   - برنامهٔ ویندوز را build کرده و هم به‌صورت ZIP و هم به‌صورت یک نصب‌کنندهٔ تکی EXE (با Inno Setup، سازگار با ویندوز ۷ به بالا) بسته‌بندی می‌کند
   - یک GitHub Release با هر سه فایل (`*.apk`, `*-windows.zip`, `*-setup.exe`) منتشر می‌کند

همچنین می‌توانید فرآیند را دستی هم از تب **Actions → Build & Release → Run workflow** با ورودی نسخه (مثل `v1.0.0`) اجرا کنید.

## سازگاری
- **اندروید**: نسخهٔ ۷.۰ (Nougat, API 24) و بالاتر، تضمین‌شده توسط `minSdkVersion 24` در `android/app/build.gradle`.
- **ویندوز**: نصب‌کنندهٔ ساخته‌شده با Inno Setup (`MinVersion=6.1`) از ویندوز ۷ به بعد قابل نصب است. با این حال خودِ فریم‌ورک Flutter Desktop به‌طور رسمی فقط از ویندوز ۱۰ به بعد پشتیبانی می‌کند؛ اجرای برنامه روی ویندوز ۷/۸.۱ به وجود درایور گرافیکی سازگار با DirectX 11 (یا ANGLE) روی آن دستگاه بستگی دارد و تضمین رسمی از سمت تیم Flutter برای این دو نسخه وجود ندارد. روی ویندوز ۱۰ و ۱۱ کاملاً پشتیبانی‌شده و پایدار است.

## لایسنس
MIT — به فایل [LICENSE](LICENSE) مراجعه کنید.
