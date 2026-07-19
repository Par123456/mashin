#!/usr/bin/env bash
# راه‌اندازی محلی پروژه: ساخت پوشه‌های پلتفرم (اگر وجود ندارند)، پیکربندی
# و تولید آیکن‌های برنامه. بعد از این اسکریپت می‌توانید `flutter run` را اجرا کنید.
set -euo pipefail

ORG="com.khatarnak"
PROJECT_NAME="khatarnak_calculator"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

if [ ! -d android ]; then
  echo "در حال ساخت پوشهٔ اندروید..."
  flutter create --platforms=android --org "$ORG" --project-name "$PROJECT_NAME" .
fi

if [ ! -d windows ]; then
  echo "در حال ساخت پوشهٔ ویندوز..."
  flutter create --platforms=windows --org "$ORG" --project-name "$PROJECT_NAME" .
fi

bash scripts/apply_platform_config.sh android
bash scripts/apply_platform_config.sh windows

flutter pub get
dart run flutter_launcher_icons

echo "آماده است! برای اجرا:"
echo "  flutter run -d windows      # ویندوز"
echo "  flutter run                 # اندروید (دستگاه/شبیه‌ساز متصل)"
