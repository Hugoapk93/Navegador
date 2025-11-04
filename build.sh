#!/bin/bash
echo "🌐 COMPILANDO NAVEGADOR WEB SIMPLIFICADO"

export ANDROID_JAR=$PREFIX/share/java/android-34.jar
export JAVA_OPTS="-Dorg.fusesource.jansi.Ansi.disable=true"

rm -rf build
mkdir -p build

echo "📦 Compilando Kotlin..."
kotlinc -cp "$ANDROID_JAR" \
        -d build/classes \
        app/src/main/java/com/webbrowser/MainActivity.kt

echo "🔄 Creando DEX..."
CLASS_FILES=$(find build/classes -name "*.class" | tr '\n' ' ')
d8 --lib "$ANDROID_JAR" --output build/ $CLASS_FILES

echo "📄 Creando APK..."
aapt package -F build/webbrowser.apk \
    -I "$ANDROID_JAR" \
    -M app/src/main/AndroidManifest.xml \
    -S app/src/main/res \
    --min-sdk-version 21

echo "📦 Agregando DEX..."
cd build
aapt add webbrowser.apk classes.dex
cd ..

echo "✅ NAVEGADOR COMPILADO: build/webbrowser.apk"
ls -lh build/webbrowser.apk

echo ""
echo "🔍 Verificación:"
aapt list build/webbrowser.apk

echo ""
echo "📱 ¡Listo para instalar!"
