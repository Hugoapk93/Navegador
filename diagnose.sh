#!/bin/bash
echo "🔍 DIAGNÓSTICO COMPLETO DEL SISTEMA"

echo ""
echo "📋 1. VERIFICACIÓN DE PAQUETES:"
pkg list-installed | grep -E "(kotlin|android|openjdk)" || echo "   ⚠️  Paquetes no encontrados"

echo ""
echo "📋 2. VARIABLES DE ENTORNO:"
echo "   ANDROID_JAR: ${ANDROID_JAR:-No configurado}"
echo "   JAVA_HOME: ${JAVA_HOME:-No configurado}"
echo "   PATH: $PATH"

echo ""
echo "📋 3. HERRAMIENTAS DISPONIBLES:"
for tool in java kotlin kotlinc d8 aapt apksigner; do
    if command -v $tool >/dev/null 2>&1; then
        echo "   ✅ $tool: $(which $tool)"
        $tool -version 2>/dev/null | head -1 || echo "      No version info"
    else
        echo "   ❌ $tool: No encontrado"
    fi
done

echo ""
echo "📋 4. ESTRUCTURA DEL PROYECTO:"
find . -type f \( -name "*.kt" -o -name "*.xml" \) -not -path "./build_*" | sort

echo ""
echo "📋 5. ANDROIDMANIFEST.XML:"
if [ -f "app/src/main/AndroidManifest.xml" ]; then
    echo "   ✅ Existe"
    grep -E "(package=|android:name=|action.MAIN)" app/src/main/AndroidManifest.xml | head -5
else
    echo "   ❌ No existe"
fi

echo ""
echo "🎯 RECOMENDACIONES:"
echo "   1. Ejecutar: ./build_robust.sh"
echo "   2. Revisar todos los errores mostrados"
echo "   3. Corregir problemas paso a paso"
