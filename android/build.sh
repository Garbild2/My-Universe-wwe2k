#!/usr/bin/env bash
# Gera UniverseDesk.apk sem Gradle: aapt2 + javac + dx + jarsigner.
set -euo pipefail
cd "$(dirname "$0")"
T=tools; B=build; OUT=UniverseDesk.apk
AAPT2=$T/aapt2; JAR=$T/android.jar

rm -rf $B && mkdir -p $B/classes
python3 prepare_assets.py

# 1) recursos + manifesto + assets
$AAPT2 compile --dir res -o $B/res.zip
$AAPT2 link -o $B/base.apk -I $JAR --manifest AndroidManifest.xml -R $B/res.zip -A assets \
  --min-sdk-version 21 --target-sdk-version 29 --version-code 2 --version-name 1.1 \
  -0 .html --auto-add-overlay

# 2) Java -> .class -> classes.dex (dx antigo só lê classes até versão 51)
javac -nowarn -source 8 -target 8 -bootclasspath $JAR -d $B/classes $(find src -name '*.java') 2>&1 | grep -v '^Note\|warning' || true
python3 - <<'PY'
import pathlib
for f in pathlib.Path("build/classes").rglob("*.class"):
    b = bytearray(f.read_bytes()); b[6:8] = (51).to_bytes(2, "big"); f.write_bytes(bytes(b))
PY
java -cp $T/dx.jar com.androidjarjar.dx.command.Main --dex --min-sdk-version=21 --output=$B/classes.dex $B/classes

# 3) juntar o dex ao APK
cp $B/base.apk $B/unsigned.apk
(cd $B && zip -q -j unsigned.apk classes.dex)

# 4) keystore (criada uma vez; GUARDE para poder atualizar o app depois)
[ -f universedesk.keystore ] || keytool -genkeypair -keystore universedesk.keystore -alias universedesk \
  -storepass universedesk -keypass universedesk -keyalg RSA -keysize 2048 -validity 36500 \
  -dname "CN=Universe Desk, O=Universe Desk, C=BR"

# 5) assinar (v1/JAR; compatível com Android 5+ para targetSdk 29)
cp $B/unsigned.apk $OUT
jarsigner -keystore universedesk.keystore -storepass universedesk -keypass universedesk \
  -sigalg SHA256withRSA -digestalg SHA-256 $OUT universedesk >/dev/null
echo "OK -> $OUT"
