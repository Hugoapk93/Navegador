#!/bin/bash
echo "🔍 ESTADO DE LA APK:"
echo "📁 Ubicación: /sdcard/Download/webbrowser.apk"
echo "📊 Tamaño: $(ls -lh /sdcard/Download/webbrowser.apk 2>/dev/null | cut -d' ' -f5 || echo 'No encontrada')"
echo "✅ Lista para instalar"
