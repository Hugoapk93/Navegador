#!/bin/bash
echo "🎯 MÉTODO SIMPLE Y FUNCIONAL"

export ANDROID_JAR=$PREFIX/share/java/android-34.jar

rm -rf simple_build
mkdir -p simple_build

echo "📦 Compilando directamente a DEX archivo..."
# Esto debería crear un ARCHIVO .dex
kotlinc -cp "$ANDROID_JAR" \
        -d simple_build/temp.dex \
        -include-runtime \
        app/src/main/java/com/webbrowser/MainActivity.kt

echo "🔍 Verificando resultado..."
if [ -d "simple_build/temp.dex" ]; then
    echo "❌ Se creó directorio temp.dex/"
    # Convertir directorio a archivo
    cd simple_build/temp.dex
    zip -r ../classes.dex . > /dev/null 2>&1
    cd ../..
    echo "✅ Convertido directorio a classes.dex"
else
    echo "✅ temp.dex es ARCHIVO"
    mv simple_build/temp.dex simple_build/classes.dex
fi

echo "📄 Creando APK..."
mkdir -p simple_apk/META-INF
cp app/src/main/AndroidManifest.xml simple_apk/
cp simple_build/classes.dex simple_apk/

cat > simple_apk/META-INF/MANIFEST.MF << 'MANIFEST'
Manifest-Version: 1.0
Created-By: Simple Browser
MANIFEST

touch simple_apk/resources.arsc

cd simple_apk
zip -r ../simple_fixed.apk . > /dev/null 2>&1
cd ..

echo "✅ APK SIMPLE: simple_fixed.apk"
ls -lh simple_fixed.apk

echo "🔍 Contenido:"
unzip -l simple_fixed.apk

# Copiar a Download
cp simple_fixed.apk /sdcard/Download/simple_fixed.apk
echo "📁 Copiada a: /sdcard/Download/simple_fixed.apk"
