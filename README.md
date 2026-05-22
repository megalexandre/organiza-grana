## Testes de Integracao
### 1) Subir o WireMock
## Build e Empacotamento

### Gerar versao Android (APK release)

```bash
flutter build apk --release
```

### Gerar versao Linux (bundle release)

```bash
flutter pub get
flutter build linux --release
```

Saida do bundle:

```text
build/linux/x64/release/bundle/
```

### Gerar pacote .deb (Linux)

Passo a passo para criar um instalador Debian a partir do bundle Linux:

1. Gere o bundle release:

```bash
flutter pub get
flutter build linux --release
```

2. Monte a estrutura Debian, copie o bundle e gere o pacote:

```bash
APP_NAME=acal
APP_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
ARCH=amd64
PKG_ROOT=dist/deb/${APP_NAME}_${APP_VERSION}_${ARCH}

rm -rf "$PKG_ROOT"
mkdir -p "$PKG_ROOT/DEBIAN" "$PKG_ROOT/opt/$APP_NAME" "$PKG_ROOT/usr/bin" "$PKG_ROOT/usr/share/applications"

cp -a build/linux/x64/release/bundle/. "$PKG_ROOT/opt/$APP_NAME/"

cat > "$PKG_ROOT/usr/bin/$APP_NAME" << 'EOF'
#!/usr/bin/env sh
exec /opt/acal/acal "$@"
EOF
chmod 755 "$PKG_ROOT/usr/bin/$APP_NAME"

cat > "$PKG_ROOT/usr/share/applications/$APP_NAME.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=Acal
Exec=acal
Terminal=false
Categories=Utility;
EOF

cat > "$PKG_ROOT/DEBIAN/control" << EOF
Package: $APP_NAME
Version: $APP_VERSION
Section: utils
Priority: optional
Architecture: $ARCH
Maintainer: alex <alex@local>
Depends: libc6 (>= 2.31), libgtk-3-0
Description: Acal Flutter desktop application
EOF

dpkg-deb --build "$PKG_ROOT"
```

3. O arquivo .deb sera gerado em:

```text
dist/deb/acal_<versao>_amd64.deb
```

4. Instale localmente para validar:

```bash
sudo dpkg -i dist/deb/acal_<versao>_amd64.deb
```

Se houver dependencias pendentes:

```bash
sudo apt-get -f install
```

Painel do WireMock:

```text
http://localhost:8080/__admin/mappings
```

//flutter run -d chrome --web-browser-flag="--disable-web-security"

-- para testar no emulador
flutter emulators --launch Pixel_6
flutter run -d Pixel_6

-- build web
./scripts/build_web.sh
docker build -t alexandreqrz/granaapp:latest . &&
docker push alexandreqrz/granaapp:latest

-- build android 
flutter pub get
flutter build apk --release --dart-define=API_BASE_URL=https://app.project-deploy.shop/api/api