#!/bin/bash
echo "🎯 COMPILACIÓN MÍNIMA FUNCIONAL"

export ANDROID_JAR=$PREFIX/share/java/android-34.jar
export JAVA_OPTS="-Dorg.fusesource.jansi.Ansi.disable=true"

rm -rf build
mkdir -p build

echo "🔍 Verificando archivos..."
echo "AndroidManifest.xml:"
grep -n "xmlns:android" app/src/main/AndroidManifest.xml || echo "❌ Sin namespace"
echo "Layout:"
grep -n "xmlns:android" app/src/main/res/layout/activity_main.xml || echo "❌ Sin namespace"

echo ""
echo "📦 Compilando Kotlin..."
kotlinc -cp "$ANDROID_JAR" \
        -d build/classes \
        app/src/main/java/com/webbrowser/MainActivity.kt

echo "🔄 Creando DEX..."
CLASS_FILES=$(find build/classes -name "*.class" | tr '\n' ' ')
echo "Archivos .class encontrados: $CLASS_FILES"

if [ -n "$CLASS_FILES" ]; then
    d8 --lib "$ANDROID_JAR" --output build/ $CLASS_FILES
else
    echo "❌ No hay archivos .class para convertir"
    exit 1
fi

echo "📄 Creando APK..."
aapt package -F build/webbrowser.apk \
    -I "$ANDROID_JAR" \
    -M app/src/main/AndroidManifest.xml \
    -S app/src/main/res \
    --min-sdk-version 21

echo "📦 Agregando DEX..."
if [ -f "build/classes.dex" ]; then
    cd build
    aapt add webbrowser.apk classes.dex
    cd ..
else
    echo "❌ No se encontró classes.dex"
    exit 1
fi

echo "✅ APK CREADA: build/webbrowser.apk"
ls -lh build/webbrowser.apk

echo ""
echo "🔍 Verificación final:"
if aapt list build/webbrowser.apk > /dev/null 2>&1; then
    echo "🎉 ¡APK VÁLIDA!"
    aapt list build/webbrowser.apk | head -10
else
    echo "❌ APK inválida"
fi
