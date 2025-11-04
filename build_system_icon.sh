#!/bin/bash
echo "🔧 APK CON ICONO DEL SISTEMA"

export ANDROID_JAR=$PREFIX/share/java/android-34.jar

rm -rf build_system
mkdir -p build_system

kotlinc -cp "$ANDROID_JAR" -d build_system/classes app/src/main/java/com/webbrowser/MainActivity.kt
CLASS_FILES=$(find build_system/classes -name "*.class" | tr '\n' ' ')
d8 --lib "$ANDROID_JAR" --output build_system/ $CLASS_FILES

aapt package -F build_system/webbrowser.apk \
    -I "$ANDROID_JAR" \
    -M app/src/main/AndroidManifest.xml \
    -S app/src/main/res \
    --min-sdk-version 21

cd build_system
aapt add webbrowser.apk classes.dex
cd ..

cp build_system/webbrowser.apk /sdcard/Download/webbrowser_system_icon.apk
echo "✅ webbrowser_system_icon.apk - Con icono del sistema"
