# KiCad 5.1.12 AppImage Builder

Progetto per creare un AppImage funzionante di KiCad 5.1.12 basato su Ubuntu 20.04, compatibile con Debian 12 e altri sistemi Linux moderni.

## Caratteristiche

- ✅ Basato su Ubuntu 20.04 (Focal Fossa)
- ✅ Include Python 3.8 bundled per il supporto agli script
- ✅ Include tutte le librerie KiCad (simboli, footprint, modelli 3D)
- ✅ Gestione corretta dei loader gdk-pixbuf per la compatibilità con sistemi moderni
- ✅ Disabilitazione di ibus per evitare conflitti con Debian 12
- ✅ Cache dei loader PNG rigenerato dinamicamente al runtime

## Prerequisiti

- Docker installato e funzionante
- Circa 7-8 GB di spazio disco disponibile

## Build

Per costruire l'AppImage, esegui semplicemente:

```bash
./build_kicad_appimage.sh
```

Lo script:
1. Costruisce l'immagine Docker con KiCad 5.1.12 e tutte le dipendenze
2. Crea l'AppDir con i binari e le librerie necessarie
3. Genera l'AppImage finale
4. Estrae l'AppImage nella directory `output/`

## Build Automatico con GitHub Actions

Il progetto include una workflow GitHub Actions che esegue il build automaticamente.

### Setup su GitHub

1. Crea un repository su GitHub
2. Aggiungi il remote e fai push:

```bash
git remote add origin https://github.com/TUO_USERNAME/kicad_appimage_builder.git
git push -u origin master
```

### Trigger della Workflow

La workflow si attiva automaticamente quando:
- ✅ Fai push sul branch `master`
- ✅ Crei un tag che inizia con `v` (es: `v1.0.0`)
- ✅ Apri una Pull Request verso `master`
- ✅ Avvii manualmente dalla sezione Actions di GitHub

### Download degli Artifacts

Dopo ogni build riuscito:
1. Vai su **Actions** nel repository GitHub
2. Seleziona il workflow run completato
3. Scarica l'artifact `KiCad-5.1.12-AppImage`

Gli artifacts sono disponibili per 30 giorni.

### Creare una Release

Per creare una release automatica con l'AppImage allegato:

```bash
# Crea e pusha un tag versione
git tag -a v1.0.0 -m "Release v1.0.0 - KiCad 5.1.12 AppImage"
git push origin v1.0.0
```

Questo creerà automaticamente:
- Una GitHub Release con l'AppImage scaricabile
- Note di release con istruzioni per l'uso
- Link permanente all'AppImage

## Output

L'AppImage generato sarà disponibile in:
```
output/KiCad-5.1.12-x86_64.AppImage
```

## Utilizzo

Rendi l'AppImage eseguibile (se necessario):
```bash
chmod +x output/KiCad-5.1.12-x86_64.AppImage
```

Esegui KiCad:
```bash
./output/KiCad-5.1.12-x86_64.AppImage
```

### Debug Mode

Per visualizzare informazioni di debug sul caricamento dei loader gdk-pixbuf:
```bash
KICAD_DEBUG=1 ./output/KiCad-5.1.12-x86_64.AppImage
```

## Struttura del Progetto

- `Dockerfile.kicad` - Dockerfile principale per costruire l'AppImage
- `build_kicad_appimage.sh` - Script di build che orchestra il processo
- `output/` - Directory contenente l'AppImage generato (esclusa da git)

## Note Tecniche

### Problemi Risolti

1. **Crash gdk-pixbuf**: Risolto copiando `gdk-pixbuf-query-loaders` dalla posizione corretta in Ubuntu 20.04
2. **Cache loader PNG**: Il cache viene rigenerato dinamicamente al runtime con i percorsi corretti
3. **Conflitti ibus**: Disabilitato completamente per evitare errori con glib in Debian 12

### Compatibilità

Testato su:
- ✅ Debian 12 (Bookworm)
- ✅ Ubuntu 20.04 (sistema di build)

Dovrebbe funzionare su qualsiasi distribuzione Linux moderna con GLIBC 2.31+

## Licenza

Questo progetto è uno script di build per KiCad. KiCad stesso è distribuito sotto licenza GPL v3+.

## Riferimenti

- [KiCad Official Website](https://www.kicad.org/)
- [KiCad 5.1 PPA](https://launchpad.net/~kicad/+archive/ubuntu/kicad-5.1-releases)
- [AppImage Documentation](https://docs.appimage.org/)
