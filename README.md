# ماشین‌حساب خطرناک (Khatarnak Calculator)

ماشین‌حساب گرافیکی، شیءگرا (Object-Oriented) و خفن، نوشته‌شده با Flutter/Dart برای اندروید و ویندوز.

## ویژگی‌ها
- طراحی نئون تیره با افکت شیشه‌ای (Glassmorphism) و دکمه‌های انیمیشنی
- موتور محاسباتی کاملاً شیءگرا: `Lexer` → `Parser` → `AST` → `evaluate()`
- تاریخچهٔ محاسبات با امکان استفادهٔ دوباره از نتایج قبلی
- پشتیبانی از اندروید ۷.۰ به بالا (`minSdkVersion 24`) و ویندوز ۷ / ۸.۱ / ۱۰ / ۱۱
- انتشار خودکار فایل APK و نصب‌کنندهٔ EXE ویندوز از طریق GitHub Actions در هر تگ نسخه

## ساختار پروژه
```
lib/
  engine/     منطق محاسباتی (Token, Lexer, AST, Parser, CalculatorController)
  models/     مدل داده دکمه‌ها (CalcButtonData)
  theme/      رنگ‌ها و گرادیان‌های نئون
  widgets/    ویجت‌های قابل استفاده مجدد
  screens/    صفحهٔ اصلی ماشین‌حساب
test/         تست‌های واحد موتور محاسباتی
assets/icon/  تصویر منبع آیکن برنامه (برای هر دو پلتفرم)
tool/         اسکریپت پایتون تولید آیکن (Pillow)
scripts/      اسکریپت‌های راه‌اندازی پلتفرم اندروید/ویندوز (محلی و CI)
installer/    اسکریپت Inno Setup برای ساخت نصب‌کنندهٔ ویندوز
.github/workflows/release.yml   پایپ‌لاین کامل CI/CD
flutter_launcher_icons-android.yaml   تنظیمات آیکن‌سازی مخصوص اندروید
flutter_launcher_icons-windows.yaml   تنظیمات آیکن‌سازی مخصوص ویندوز
```

> **نکته مهم:** پوشه‌های `android/` و `windows/` عمداً در مخزن قرار ندارند؛ هم در محیط محلی (`scripts/setup_local.sh`) و هم در GitHub Actions با `flutter create` به‌صورت خودکار ساخته و با `scripts/apply_platform_config.sh` پیکربندی می‌شوند (تنظیم `minSdkVersion 24`).

> **نکته:** آیکون‌سازی برای هر پلتفرم در یک فایل تنظیمات جدا انجام می‌شود (`flutter_launcher_icons-android.yaml` و `flutter_launcher_icons-windows.yaml`) تا روی CI وقتی فقط یکی از پوشه‌های اندروید/ویندوز موجود است، خطای PathNotFound رخ ندهد.

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
3. اکشن `Build & Release` به‌صورت خودکار APK و EXE را می‌سازد و در یک GitHub Release منتشر می‌کند.

همچنین می‌توانید از تب **Actions → Build & Release → Run workflow** هم به‌صورت دستی اجرا کنید.

## سازگاری
- **اندروید**: نسخهٔ ۷.۰ (Nougat, API 24) و بالاتر.
- **ویندوز**: نصب‌کنندهٔ Inno Setup (`MinVersion=6.1`) از ویندوز ۷ به بعد قابل نصب است؛ فریم‌ورک Flutter Desktop به‌طور رسمی از ویندوز ۱۰ به بعد پشتیبانی می‌کند.

## لایسنس
MIT — به فایل [LICENSE](LICENSE) مراجعه کنید.
