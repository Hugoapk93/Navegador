#!/bin/bash
echo "📦 COMPILACIÓN CON MANIFEST GARANTIZADO"

export ANDROID_JAR=$PREFIX/share/java/android-34.jar

rm -rf build_manifest
mkdir -p build_manifest

echo "🔨 Paso 1: Compilar código..."
kotlinc -cp "$ANDROID_JAR" \
        -d build_manifest/classes \
        app/src/main/java/com/webbrowser/MainActivity.kt

CLASS_FILES=$(find build_manifest/classes -name "*.class" | tr '\n' ' ')
d8 --lib "$ANDROID_JAR" --output build_manifest/ $CLASS_FILES

echo "🔨 Paso 2: Crear APK base CON manifest..."
# Crear un archivo vacío primero para forzar la estructura
touch build_manifest/empty.txt

aapt package -F build_manifest/base.apk \
    -I "$ANDROID_JAR" \
    -M app/src/main/AndroidManifest.xml \
    -S app/src/main/res \
    --min-sdk-version 21

echo "🔨 Paso 3: Verificar base.apk..."
if unzip -l build_manifest/base.apk | grep -q "AndroidManifest.xml"; then
    echo "✅ Base APK tiene AndroidManifest.xml"
else
    echo "❌ Base APK NO tiene AndroidManifest.xml"
    # Forzar la creación incluyendo un archivo dummy
    aapt package -F build_manifest/base.apk \
        -I "$ANDROID_JAR" \
        -M app/src/main/AndroidManifest.xml \
        -S app/src/main/res \
        -0 txt \
        --min-sdk-version 21
fi

echo "🔨 Paso 4: Agregar DEX..."
cd build_manifest
aapt add base.apk classes.dex
cd ..

mv build_manifest/base.apk build_manifest/webbrowser.apk

echo "✅ APK FINAL: build_manifest/webbrowser.apk"
ls -lh build_manifest/webbrowser.apk

echo ""
echo "🔍 VERIFICACIÓN FINAL:"
unzip -l build_manifest/webbrowser.apk | head -10
