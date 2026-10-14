#!/bin/bash
set -e

# Nome dell'immagine Docker
DOCKER_IMAGE_NAME="kicad-appimage-builder"
# Percorso del Dockerfile
DOCKERFILE_PATH="Dockerfile.kicad"
# Nome del file AppImage nel container (deve corrispondere a quanto definito nel Dockerfile)
APPIMAGE_FILENAME="KiCad-5.1.12-x86_64.AppImage"
# Versione della release del builder (es. 2.0.1): da RELEASE_VERSION o dall'ultimo tag git
RELEASE_VERSION="${RELEASE_VERSION:-$(git describe --tags 2>/dev/null | sed 's/^v//')}"
# Nome finale del file AppImage in output (include la versione della release, se nota)
OUTPUT_FILENAME="KiCad-5.1.12${RELEASE_VERSION:+-$RELEASE_VERSION}-x86_64.AppImage"
# Directory di output per l'AppImage
OUTPUT_DIR="$(pwd)/output"

echo "Avvio della creazione dell'AppImage di KiCad 5.1.12..."

# 1. Costruisci l'immagine Docker
echo "Step 1: Costruzione dell'immagine Docker '$DOCKER_IMAGE_NAME'..."
# Il "." finale indica il contesto di build, ovvero la directory corrente
docker build -t "$DOCKER_IMAGE_NAME" -f "$DOCKERFILE_PATH" .

echo "Immagine Docker costruita con successo."

# 2. Estrai l'AppImage dal container
echo "Step 2: Estrazione dell'AppImage '$APPIMAGE_FILENAME' dal container..."
mkdir -p "$OUTPUT_DIR"
# Esegue un container temporaneo per copiare l'AppImage
# --rm rimuove il container una volta terminato
# --entrypoint cat permette di leggere il contenuto del file
docker run --rm --entrypoint cat "$DOCKER_IMAGE_NAME" /build/"$APPIMAGE_FILENAME" > "$OUTPUT_DIR/$OUTPUT_FILENAME"

echo "AppImage estratta con successo in '$OUTPUT_DIR/$OUTPUT_FILENAME'."

# 3. Rendi l'AppImage eseguibile
echo "Step 3: Rendere l'AppImage eseguibile..."
chmod +x "$OUTPUT_DIR/$OUTPUT_FILENAME"

echo "Successo! L'AppImage di KiCad 5.1.12 è stata creata e resa eseguibile."
echo "Puoi eseguirla con: $OUTPUT_DIR/$OUTPUT_FILENAME"
echo "Oppure semplicemente cliccandoci sopra dopo averla resa eseguibile."
