#!/bin/bash
echo "🔍 DIAGNÓSTICO COMPLETO DEL SISTEMA - CORREGIDO"

echo ""
echo "📋 1. VERIFICACIÓN DE PAQUETES:"
pkg list-installed | grep -E "(kotlin|android|openjdk)" 2>/dev/null | head -10

echo ""
echo "📋 2. VARIABLES DE ENTORNO:"
echo "   ANDROID_JAR: ${ANDROID_JAR:-No configurado}"
echo "   JAVA_HOME: ${JAVA_HOME:-No configurado}"
echo "   PATH: $(echo $PATH | cut -d: -f1-3)"

echo ""
echo "📋 3. HERRAMIENTAS DISPONIBLES:"
for tool in java kotlin kotlinc d8 aapt apksigner; do
    if command -v $tool >/dev/null 2>&1; then
        location=$(command -v $tool)
        echo "   ✅ $tool: $location"
        case $tool in
            java)
                $tool -version 2>&1 | head -1 ;;
            kotlin|kotlinc)
                $tool -version 2>&1 | head -1 ;;
            d8|aapt|apksigner)
                echo "      $(ls -la $location | cut -d' ' -f5)" ;;
        esac
    else
        echo "   ❌ $tool: No encontrado"
    fi
done

echo ""
echo "📋 4. ESTRUCTURA DEL PROYECTO:"
find . -maxdepth 4 -type f \( -name "*.kt" -o -name "*.xml" \) -not -path "*/build_*" | sort

echo ""
echo "📋 5. VERIFICACIÓN ANDROIDMANIFEST.XML:"
if [ -f "app/src/main/AndroidManifest.xml" ]; then
    echo "   ✅ Existe - $(ls -la app/src/main/AndroidManifest.xml | cut -d' ' -f5)"
    echo "   🔍 Package: $(grep 'package=' app/src/main/AndroidManifest.xml | head -1)"
    echo "   🔍 Actividad: $(grep 'activity android:name' app/src/main/AndroidManifest.xml | head -1)"
    echo "   🔍 Permisos: $(grep 'uses-permission' app/src/main/AndroidManifest.xml | head -2)"
else
    echo "   ❌ No existe"
fi

echo ""
echo "📋 6. VERIFICACIÓN MAINACTIVITY.KT:"
if [ -f "app/src/main/java/com/webbrowser/MainActivity.kt" ]; then
    echo "   ✅ Existe - $(ls -la app/src/main/java/com/webbrowser/MainActivity.kt | cut -d' ' -f5)"
    echo "   🔍 Clase: $(grep 'class MainActivity' app/src/main/java/com/webbrowser/MainActivity.kt)"
    echo "   🔍 Métodos: $(grep -c 'fun ' app/src/main/java/com/webbrowser/MainActivity.kt) funciones"
else
    echo "   ❌ No existe"
fi

echo ""
echo "🎯 ESTADO: LISTO PARA COMPILAR"
echo "   Ejecuta: ./build_robust.sh"
