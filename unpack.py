import os
import re

with open('all_code.txt', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Извличане на pubspec.yaml
pubspec_match = re.search(r'=== PUBSPEC\.YAML ===\s*\n(.*?)(?=\n={10,}|\Z)', content, re.DOTALL)
if pubspec_match:
    with open('pubspec.yaml', 'w', encoding='utf-8') as f:
        f.write(pubspec_match.group(1).strip() + '\n')
    print("✅ Създаден: pubspec.yaml")

# 2. Извличане на всички .dart файлове
pattern = r'={10,}\s*\nФАЙЛ:\s*([^\n]+)\s*\n={10,}\s*\n(.*?)(?=\n={10,}|\Z)'
matches = re.findall(pattern, content, re.DOTALL)

for file_path, code in matches:
    file_path = file_path.strip()
    dir_name = os.path.dirname(file_path)
    if dir_name:
        os.makedirs(dir_name, exist_ok=True)
    with open(file_path, 'w', encoding='utf-8') as out:
        out.write(code.strip() + '\n')
    print(f"✅ Създаден: {file_path}")

# 3. GitHub Actions Workflow
os.makedirs('.github/workflows', exist_ok=True)
workflow_content = """name: Build Android APK

on:
  push:
    branches: [ "main" ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      - name: Recreate Android platform folder
        run: |
          if [ ! -d "android" ]; then
            flutter create . --platforms=android --org com.stanbg96.tiptop
          fi

      - name: Install dependencies
        run: flutter pub get

      - name: Build APK
        run: flutter build apk --release

      - name: Upload APK Artifact
        uses: actions/upload-artifact@v4
        with:
          name: TipTop-Game-Engine-APK
          path: build/app/outputs/flutter-apk/app-release.apk
"""
with open('.github/workflows/build.yml', 'w', encoding='utf-8') as wf:
    wf.write(workflow_content)
print("✅ Създаден: .github/workflows/build.yml")
