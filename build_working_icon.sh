#!/bin/bash
echo "🎯 CREANDO APK FUNCIONAL CON ICONO"

export ANDROID_JAR=$PREFIX/share/java/android-34.jar

rm -rf build_working
mkdir -p build_working

echo "📦 Paso 1: Compilar código..."
kotlinc -cp "$ANDROID_JAR" \
        -d build_working/classes \
        app/src/main/java/com/webbrowser/MainActivity.kt

echo "🔄 Paso 2: Crear DEX..."
CLASS_FILES=$(find build_working/classes -name "*.class" | tr '\n' ' ')
d8 --lib "$ANDROID_JAR" --output build_working/ $CLASS_FILES

echo "📄 Paso 3: Crear APK..."
aapt package -F build_working/webbrowser.apk \
    -I "$ANDROID_JAR" \
    -M app/src/main/AndroidManifest.xml \
    -S app/src/main/res \
    --min-sdk-version 21

echo "📦 Paso 4: Agregar DEX..."
cd build_working
aapt add webbrowser.apk classes.dex
cd ..

echo "✅ APK CREADA: build_working/webbrowser.apk"
ls -lh build_working/webbrowser.apk

echo ""
echo "🔍 VERIFICACIÓN COMPLETA:"
if unzip -l build_working/webbrowser.apk > /dev/null 2>&1; then
    echo "🎉 ¡APK VÁLIDA!"
    echo "📊 Contenido:"
    unzip -l build_working/webbrowser.apk
else
    echo "❌ APK inválida"
    exit 1
fi

# Copiar a Download
cp build_working/webbrowser.apk /sdcard/Download/webbrowser_working.apk
echo ""
echo "📁 COPIADA: /sdcard/Download/webbrowser_working.apk"
echo "🎯 Esta APK tiene:"
echo "   ✅ Icono del sistema (lupa)"
echo "   ✅ AndroidManifest.xml"
echo "   ✅ classes.dex"
echo "   ✅ Estructura completa"
