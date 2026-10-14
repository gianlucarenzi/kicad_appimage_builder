#!/bin/bash
set -e

# Nome dell'immagine Docker
DOCKER_IMAGE_NAME="kicad-appimage-builder"
# Percorso del Dockerfile
DOCKERFILE_PATH="Dockerfile.kicad"
# Architettura dell'AppImage: x86_64, aarch64 o armhf (default: quella della macchina).
# Un'architettura diversa da quella della macchina richiede QEMU (binfmt_misc).
APPIMAGE_ARCH="${APPIMAGE_ARCH:-$(uname -m)}"
case "$APPIMAGE_ARCH" in
    x86_64)        DOCKER_PLATFORM=linux/amd64;  MULTIARCH=x86_64-linux-gnu ;;
    aarch64)       DOCKER_PLATFORM=linux/arm64;  MULTIARCH=aarch64-linux-gnu ;;
    armhf|armv7l)  APPIMAGE_ARCH=armhf
                   DOCKER_PLATFORM=linux/arm/v7; MULTIARCH=arm-linux-gnueabihf ;;
    *) echo "Architettura non supportata: $APPIMAGE_ARCH (x86_64, aarch64, armhf)" >&2; exit 1 ;;
esac
# Nome dell'immagine Docker
DOCKER_IMAGE_NAME="$DOCKER_IMAGE_NAME-$APPIMAGE_ARCH"
# Nome del file AppImage nel container (deve corrispondere a quanto definito nel Dockerfile)
APPIMAGE_FILENAME="KiCad-5.1.12-$APPIMAGE_ARCH.AppImage"
# Versione della release del builder (es. 2.0.1): da RELEASE_VERSION o dall'ultimo tag git
RELEASE_VERSION="${RELEASE_VERSION:-$(git describe --tags 2>/dev/null | sed 's/^v//')}"
# Nome finale del file AppImage in output (include la versione della release, se nota)
OUTPUT_FILENAME="KiCad-5.1.12${RELEASE_VERSION:+-$RELEASE_VERSION}-$APPIMAGE_ARCH.AppImage"
# Directory di output per l'AppImage
OUTPUT_DIR="$(pwd)/output"

echo "Avvio della creazione dell'AppImage di KiCad 5.1.12 per $APPIMAGE_ARCH..."

# 1. Costruisci l'immagine Docker
echo "Step 1: Costruzione dell'immagine Docker '$DOCKER_IMAGE_NAME'..."
# Il "." finale indica il contesto di build, ovvero la directory corrente
# BuildKit: il builder classico ignora --platform se l'immagine base è già in locale
DOCKER_BUILDKIT=1 docker build --platform "$DOCKER_PLATFORM" \
    --build-arg APPIMAGE_ARCH="$APPIMAGE_ARCH" --build-arg MULTIARCH="$MULTIARCH" \
    -t "$DOCKER_IMAGE_NAME" -f "$DOCKERFILE_PATH" .

echo "Immagine Docker costruita con successo."

# 2. Estrai l'AppImage dal container
echo "Step 2: Estrazione dell'AppImage '$APPIMAGE_FILENAME' dal container..."
mkdir -p "$OUTPUT_DIR"
# Crea un container (senza avviarlo, quindi senza emulazione) e ne copia l'AppImage
CONTAINER_ID=$(docker create --platform "$DOCKER_PLATFORM" "$DOCKER_IMAGE_NAME")
trap 'docker rm -f "$CONTAINER_ID" >/dev/null' EXIT
docker cp "$CONTAINER_ID:/build/$APPIMAGE_FILENAME" "$OUTPUT_DIR/$OUTPUT_FILENAME"

echo "AppImage estratta con successo in '$OUTPUT_DIR/$OUTPUT_FILENAME'."

# 3. Rendi l'AppImage eseguibile
echo "Step 3: Rendere l'AppImage eseguibile..."
chmod +x "$OUTPUT_DIR/$OUTPUT_FILENAME"

echo "Successo! L'AppImage di KiCad 5.1.12 è stata creata e resa eseguibile."
echo "Puoi eseguirla con: $OUTPUT_DIR/$OUTPUT_FILENAME"
echo "Oppure semplicemente cliccandoci sopra dopo averla resa eseguibile."
