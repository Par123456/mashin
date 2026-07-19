#!/usr/bin/env bash
# این اسکریپت بعد از `flutter create` اجرا می‌شود و تنظیمات سفارشی پروژه (مانند
# حداقل نسخهٔ اندروید) را روی پوشههای تولیدشده اعمال می‌کند.
set -euo pipefail

TARGET="${1:-}"

patch_file() {
  local file="$1"
  local pattern="$2"
  local replacement="$3"
  if [ -f "$file" ]; then
    python3 - "$file" "$pattern" "$replacement" <<'PYEOF'
import re
import sys

path, pattern, replacement = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path, "r", encoding="utf-8") as f:
    content = f.read()
new_content = re.sub(pattern, replacement, content)
if new_content != content:
    with open(path, "w", encoding="utf-8") as f:
        f.write(new_content)
    print(f"patched: {path}")
PYEOF
  fi
}

case "$TARGET" in
  android)
    echo "تنطیم minSdkVersion روی ۲۴ (اندروید ۷.۰ Nougat)..."
    # قالب Groovy (build.gradle)
    patch_file "android/app/build.gradle" 'minSdkVersion[[:space:]]+flutter\.minSdkVersion' 'minSdkVersion 24'
    patch_file "android/app/build.gradle" 'minSdk[[:space:]]*=[[:space:]]*flutter\.minSdkVersion' 'minSdk = 24'
    # قالب Kotlin DSL (build.gradle.kts)
    patch_file "android/app/build.gradle.kts" 'minSdk[[:space:]]*=[[:space:]]*flutter\.minSdkVersion\.get\(\)' 'minSdk = 24'
    patch_file "android/app/build.gradle.kts" 'minSdk[[:space:]]*=[[:space:]]*flutter\.minSdkVersion' 'minSdk = 24'
    echo "پیکربندی اندروید انجام شد."
    ;;
  windows)
    echo "پیکربندی اجباری ویندوزی لازم نیست؛ نام پروژه/سازمان در زمان ساخت تنظیم می‌شود."
    ;;
  *)
    echo "استفاده: $0 [android|windows]" >&2
    exit 1
    ;;
esac
