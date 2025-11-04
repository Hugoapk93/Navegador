#!/bin/bash
echo "🔨 CONSTRUCCIÓN MANUAL COMPLETA"

rm -rf manual_apk
mkdir -p manual_apk/META-INF

echo "📦 Compilando código..."
kotlinc -cp "$ANDROID_JAR" -d manual.dex -include-runtime app/src/main/java/com/webbrowser/MainActivity.kt

echo "📄 Creando estructura APK..."
# 1. AndroidManifest.xml
cp app/src/main/AndroidManifest.xml manual_apk/

# 2. DEX
cp manual.dex manual_apk/classes.dex

# 3. MANIFEST.MF
cat > manual_apk/META-INF/MANIFEST.MF << 'MANIFEST'
Manifest-Version: 1.0
Created-By: Web Browser
Built-By: Termux
MANIFEST

# 4. resources.arsc (vacío pero necesario)
touch manual_apk/resources.arsc

echo "📦 Creando APK..."
cd manual_apk
zip -r ../manual_browser.apk . > /dev/null 2>&1
cd ..

echo "✅ APK MANUAL: manual_browser.apk"
ls -lh manual_browser.apk

echo "🔍 Contenido EXACTO:"
unzip -l manual_browser.apk

# Copiar a Download
cp manual_browser.apk /sdcard/Download/manual_browser.apk
echo "📁 Copiada a: /sdcard/Download/manual_browser.apk"
