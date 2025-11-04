#!/bin/bash

# Script gradlew simplificado para GitHub Actions
echo "Using system Gradle via Gradle Wrapper"

# Usar gradle del sistema si está disponible
if command -v gradle &> /dev/null; then
    gradle "$@"
else
    echo "Error: Gradle not found in system"
    echo "Please install Gradle or use a proper Gradle Wrapper"
    exit 1
fi
