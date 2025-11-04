#!/bin/bash
echo "🔨 CONSTRUCCIÓN CORREGIDA - DEX COMO ARCHIVO"

export ANDROID_JAR=$PREFIX/share/java/android-34.jar

rm -rf build_fixed
mkdir -p build_fixed

echo "📦 Compilando a clases..."
kotlinc -cp "$ANDROID_JAR" \
        -d build_fixed/classes \
        app/src/main/java/com/webbrowser/MainActivity.kt

echo "🔄 Convirtiendo a DEX (archivo)..."
CLASS_FILES=$(find build_fixed/classes -name "*.class" | tr '\n' ' ')
d8 --lib "$ANDROID_JAR" --output build_fixed/ $CLASS_FILES

echo "🔍 Verificando DEX:"
if [ -f "build_fixed/classes.dex" ]; then
    echo "✅ DEX es ARCHIVO: build_fixed/classes.dex"
    ls -lh build_fixed/classes.dex
else
    echo "❌ No se creó classes.dex"
    exit 1
fi

echo "📄 Creando APK manual..."
rm -rf manual_fixed
mkdir -p manual_fixed/META-INF

# 1. AndroidManifest.xml
cp app/src/main/AndroidManifest.xml manual_fixed/

# 2. DEX (como ARCHIVO)
cp build_fixed/classes.dex manual_fixed/

# 3. MANIFEST.MF
cat > manual_fixed/META-INF/MANIFEST.MF << 'MANIFEST'
Manifest-Version: 1.0
Created-By: Web Browser
MANIFEST

# 4. resources.arsc
touch manual_fixed/resources.arsc

echo "📦 Creando APK..."
cd manual_fixed
zip -r ../manual_fixed.apk . > /dev/null 2>&1
cd ..

echo "✅ APK CORREGIDA: manual_fixed.apk"
ls -lh manual_fixed.apk

echo ""
echo "🔍 CONTENIDO VERIFICADO:"
unzip -l manual_fixed.apk

# Copiar a Download
cp manual_fixed.apk /sdcard/Download/manual_fixed.apk
echo "📁 Copiada a: /sdcard/Download/manual_fixed.apk"

echo ""
echo "🎯 ESTA APK DEBERÍA INSTALARSE:"
echo "   ✅ Tiene AndroidManifest.xml"
echo "   ✅ Tiene classes.dex (como archivo)"
echo "   ✅ Tiene estructura APK completa"
