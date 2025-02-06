
#!/bin/bash

# Ruta al archivo pubspec.yaml
PUBSPEC_FILE="pubspec.yaml"

# Extraer la línea de versión
VERSION_LINE=$(grep 'version:' $PUBSPEC_FILE)

# Extraer el build number
BUILD_NUMBER=$(echo $VERSION_LINE | awk -F '+' '{print $2}')

# Incrementar el build number
NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))

# Reemplazar el build number en pubspec.yaml
sed -i '' "s/version: \([0-9]*\.[0-9]*\.[0-9]*\)+$BUILD_NUMBER/version: \1+$NEW_BUILD_NUMBER/" $PUBSPEC_FILE

echo "Compiled number version incremented into $NEW_BUILD_NUMBER"
