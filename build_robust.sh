#!/bin/bash
echo "================================================"
echo "🔧 COMPILADOR ROBUSTO PARA APK ANDROID"
echo "================================================"

# Configuración
export ANDROID_JAR=$PREFIX/share/java/android-34.jar
export JAVA_OPTS="-Dorg.fusesource.jansi.Ansi.disable=true"
APK_NAME="webbrowser_robust.apk"
BUILD_DIR="build_robust"

# Función para mostrar errores
show_error() {
    echo "❌ ERROR: $1"
    echo "💡 SOLUCIÓN: $2"
}

# Función para verificar paso
check_step() {
    if [ $? -eq 0 ]; then
        echo "✅ $1"
    else
        show_error "$2" "$3"
        return 1
    fi
}

# Limpiar build anterior
echo ""
echo "🧹 PASO 1: LIMPIANDO BUILD ANTERIOR..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
check_step "Directorio limpio" "No se pudo crear directorio $BUILD_DIR" "Verificar permisos"

# Verificar archivos esenciales
echo ""
echo "🔍 PASO 2: VERIFICANDO ARCHIVOS ESENCIALES..."

echo "📁 AndroidManifest.xml:"
if [ -f "app/src/main/AndroidManifest.xml" ]; then
    echo "   ✅ Existe"
    echo "   📊 Tamaño: $(ls -la app/src/main/AndroidManifest.xml | cut -d' ' -f5)"
    echo "   🔍 Namespace: $(grep -q "xmlns:android" app/src/main/AndroidManifest.xml && echo "✅ Presente" || echo "❌ Faltante")"
    echo "   📝 Package: $(grep "package=" app/src/main/AndroidManifest.xml | head -1)"
else
    show_error "AndroidManifest.xml no encontrado" "Crear archivo en app/src/main/AndroidManifest.xml"
    exit 1
fi

echo "📁 MainActivity.kt:"
if [ -f "app/src/main/java/com/webbrowser/MainActivity.kt" ]; then
    echo "   ✅ Existe"
    echo "   📊 Tamaño: $(ls -la app/src/main/java/com/webbrowser/MainActivity.kt | cut -d' ' -f5)"
    echo "   🔍 Clase principal: $(grep -q "class MainActivity" app/src/main/java/com/webbrowser/MainActivity.kt && echo "✅ Encontrada" || echo "❌ No encontrada")"
else
    show_error "MainActivity.kt no encontrado" "Crear archivo en app/src/main/java/com/webbrowser/MainActivity.kt"
    exit 1
fi

echo "📁 Recursos:"
if [ -d "app/src/main/res" ]; then
    echo "   ✅ Directorio res existe"
    find app/src/main/res -type f -name "*.xml" | while read file; do
        echo "   📄 $file: $(grep -q "xmlns:android" "$file" && echo "✅ NS OK" || echo "❌ Sin namespace")"
    done
else
    echo "   ⚠️  Directorio res no existe (continuando...)"
    mkdir -p app/src/main/res/values
fi

# Verificar Android SDK
echo ""
echo "🔍 PASO 3: VERIFICANDO ANDROID SDK..."
if [ -f "$ANDROID_JAR" ]; then
    echo "   ✅ Android JAR: $ANDROID_JAR"
    echo "   📊 Tamaño: $(ls -lh "$ANDROID_JAR" | cut -d' ' -f5)"
else
    show_error "Android JAR no encontrado" "Instalar: pkg install android-sdk-build-tools"
    exit 1
fi

# Verificar herramientas
echo ""
echo "🔧 PASO 4: VERIFICANDO HERRAMIENTAS..."
for tool in kotlinc d8 aapt; do
    if command -v $tool >/dev/null 2>&1; then
        echo "   ✅ $tool: $(which $tool)"
    else
        show_error "$tool no encontrado" "Instalar: pkg install kotlin android-tools"
        exit 1
    fi
done

# Compilar Kotlin
echo ""
echo "📦 PASO 5: COMPILANDO KOTLIN..."
echo "   🎯 Comando: kotlinc -cp \"$ANDROID_JAR\" -d $BUILD_DIR/classes app/src/main/java/com/webbrowser/MainActivity.kt"

kotlinc -cp "$ANDROID_JAR" \
        -d "$BUILD_DIR/classes" \
        app/src/main/java/com/webbrowser/MainActivity.kt 2>&1 | while read line; do
    case "$line" in
        *error:*)
            echo "   ❌ $line"
            ;;
        *warning:*)
            echo "   ⚠️  $line"
            ;;
        *)
            echo "   📝 $line"
            ;;
    esac
done

check_step "Kotlin compilado" "Error en compilación Kotlin" "Revisar sintaxis del código"

# Verificar archivos .class generados
echo ""
echo "🔍 PASO 6: VERIFICANDO ARCHIVOS .CLASS..."
CLASS_FILES=$(find "$BUILD_DIR/classes" -name "*.class" 2>/dev/null)
if [ -n "$CLASS_FILES" ]; then
    echo "   ✅ Archivos .class generados:"
    echo "$CLASS_FILES" | while read file; do
        echo "      📄 $file"
    done
else
    show_error "No se generaron archivos .class" "Revisar código Kotlin y dependencias"
    exit 1
fi

# Convertir a DEX
echo ""
echo "🔄 PASO 7: CONVIRTIENDO A DEX..."
echo "   🎯 Comando: d8 --lib \"$ANDROID_JAR\" --output $BUILD_DIR/ $CLASS_FILES"

d8 --lib "$ANDROID_JAR" \
   --output "$BUILD_DIR/" \
   $CLASS_FILES 2>&1 | while read line; do
    case "$line" in
        *error:*)
            echo "   ❌ $line"
            ;;
        *warning:*)
            echo "   ⚠️  $line"
            ;;
        *Info:*)
            echo "   ℹ️  $line"
            ;;
        *)
            echo "   📝 $line"
            ;;
    esac
done

check_step "Conversión DEX completada" "Error en conversión DEX" "Verificar archivos .class"

# Verificar classes.dex
echo ""
echo "🔍 PASO 8: VERIFICANDO CLASSES.DEX..."
if [ -f "$BUILD_DIR/classes.dex" ]; then
    echo "   ✅ classes.dex creado"
    echo "   📊 Tamaño: $(ls -lh "$BUILD_DIR/classes.dex" | cut -d' ' -f5)"
    echo "   🔍 Tipo: $(file "$BUILD_DIR/classes.dex" 2>/dev/null || echo "Archivo DEX")"
else
    show_error "classes.dex no creado" "Verificar conversión D8"
    exit 1
fi

# Crear APK
echo ""
echo "📄 PASO 9: CREANDO APK..."
echo "   🎯 Comando: aapt package -F $BUILD_DIR/$APK_NAME -I \"$ANDROID_JAR\" -M app/src/main/AndroidManifest.xml -S app/src/main/res --min-sdk-version 21"

aapt package -F "$BUILD_DIR/$APK_NAME" \
    -I "$ANDROID_JAR" \
    -M app/src/main/AndroidManifest.xml \
    -S app/src/main/res \
    --min-sdk-version 21 2>&1 | while read line; do
    case "$line" in
        *error:*)
            echo "   ❌ $line"
            ;;
        *warning:*)
            echo "   ⚠️  $line"
            ;;
        *)
            echo "   📝 $line"
            ;;
    esac
done

check_step "APK base creada" "Error creando APK base" "Verificar recursos y AndroidManifest.xml"

# Verificar APK base
echo ""
echo "🔍 PASO 10: VERIFICANDO APK BASE..."
if [ -f "$BUILD_DIR/$APK_NAME" ]; then
    echo "   ✅ APK base creada"
    echo "   📊 Tamaño: $(ls -lh "$BUILD_DIR/$APK_NAME" | cut -d' ' -f5)"
    echo "   🔍 Contenido:"
    unzip -l "$BUILD_DIR/$APK_NAME" 2>/dev/null | while read line; do
        if echo "$line" | grep -q "AndroidManifest.xml"; then
            echo "      ✅ $line"
        elif echo "$line" | grep -q "classes.dex"; then
            echo "      ⚠️  $line (se agregará después)"
        else
            echo "      📄 $line"
        fi
    done
else
    show_error "APK base no creada" "Verificar comando aapt package"
    exit 1
fi

# Agregar DEX a APK
echo ""
echo "📦 PASO 11: AGREGANDO DEX A APK..."
echo "   🎯 Comando: cd $BUILD_DIR && aapt add $APK_NAME classes.dex"

cd "$BUILD_DIR"
aapt add "$APK_NAME" classes.dex 2>&1 | while read line; do
    case "$line" in
        *error:*)
            echo "   ❌ $line"
            ;;
        *warning:*)
            echo "   ⚠️  $line"
            ;;
        *)
            echo "   📝 $line"
            ;;
    esac
done
cd ..

check_step "DEX agregado a APK" "Error agregando DEX" "Verificar estructura APK"

# Verificación final
echo ""
echo "🔍 PASO 12: VERIFICACIÓN FINAL..."
if [ -f "$BUILD_DIR/$APK_NAME" ]; then
    echo "   ✅ APK FINAL CREADA: $BUILD_DIR/$APK_NAME"
    echo "   📊 Tamaño final: $(ls -lh "$BUILD_DIR/$APK_NAME" | cut -d' ' -f5)"
    
    echo ""
    echo "   📋 CONTENIDO COMPLETO:"
    unzip -l "$BUILD_DIR/$APK_NAME" 2>/dev/null | while read line; do
        if echo "$line" | grep -q "AndroidManifest.xml"; then
            echo "      ✅ $line"
        elif echo "$line" | grep -q "classes.dex"; then
            echo "      ✅ $line"
        elif echo "$line" | grep -q "META-INF"; then
            echo "      📄 $line"
        elif echo "$line" | grep -q "resources.arsc"; then
            echo "      📄 $line"
        elif echo "$line" | grep -q "res/"; then
            echo "      📄 $line"
        fi
    done
    
    # Verificar con aapt
    echo ""
    echo "   🔧 VERIFICACIÓN CON AAPT:"
    if aapt dump badging "$BUILD_DIR/$APK_NAME" 2>/dev/null | grep -q "package:"; then
        echo "      ✅ APK VÁLIDA - Puede ser instalada"
        aapt dump badging "$BUILD_DIR/$APK_NAME" 2>/dev/null | grep "package:" | head -1
    else
        echo "      ⚠️  APK creada pero aapt no puede verificarla"
    fi
else
    show_error "APK final no creada" "Revisar todos los pasos anteriores"
    exit 1
fi

# Copiar a Download
echo ""
echo "📁 PASO 13: COPIANDO A DOWNLOAD..."
cp "$BUILD_DIR/$APK_NAME" "/sdcard/Download/$APK_NAME"
if [ $? -eq 0 ]; then
    echo "   ✅ COPIADA: /sdcard/Download/$APK_NAME"
else
    echo "   ⚠️  No se pudo copiar a Download (¿termux-setup-storage?)"
    echo "   📍 Ubicación local: $(pwd)/$BUILD_DIR/$APK_NAME"
fi

echo ""
echo "================================================"
echo "🎉 COMPILACIÓN COMPLETADA"
echo "================================================"
echo ""
echo "📱 PRÓXIMOS PASOS:"
echo "   1. Instalar /sdcard/Download/$APK_NAME en Android"
echo "   2. Probar la aplicación"
echo "   3. Reportar cualquier error"
echo ""
echo "🔧 SI HAY ERRORES:"
echo "   - Revisar los mensajes de error arriba"
echo "   - Verificar archivos de código y recursos"
echo "   - Ejecutar este script nuevamente para diagnóstico"
