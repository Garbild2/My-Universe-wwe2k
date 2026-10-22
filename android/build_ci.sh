#!/usr/bin/env bash
# Gera UniverseDesk.apk usando o Android SDK já instalado (GitHub Actions ubuntu-latest).
set -euo pipefail
cd "$(dirname "$0")"
SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-/usr/local/lib/android/sdk}}"
BT=$(ls -d "$SDK"/build-tools/* | sort -V | tail -1)
JAR=$(ls -d "$SDK"/platforms/android-*/android.jar | sort -V | tail -1)
VCODE="${VERSION_CODE:-2}"; VNAME="${VERSION_NAME:-1.1}"
B=build; OUT=UniverseDesk.apk
echo "build-tools: $BT | android.jar: $JAR"

rm -rf $B && mkdir -p $B/classes
python3 prepare_assets.py

"$BT/aapt2" compile --dir res -o $B/res.zip
"$BT/aapt2" link -o $B/base.apk -I "$JAR" --manifest AndroidManifest.xml -R $B/res.zip -A assets \
  --min-sdk-version 21 --target-sdk-version 29 --version-code "$VCODE" --version-name "$VNAME" \
  -0 .html --auto-add-overlay

javac --release 8 -nowarn -classpath "$JAR" -d $B/classes $(find src -name '*.java')
"$BT/d8" --lib "$JAR" --min-api 21 --output $B $(find $B/classes -name '*.class')

cp $B/base.apk $B/unsigned.apk
(cd $B && zip -q -j unsigned.apk classes.dex)
"$BT/zipalign" -f -p 4 $B/unsigned.apk $B/aligned.apk

KS=universedesk.keystore
if [ -n "${KEYSTORE_B64:-}" ]; then echo "$KEYSTORE_B64" | base64 -d > $B/$KS; KS=$B/$KS
else
  echo "AVISO: sem segredo KEYSTORE_B64 -> gerando chave nova (o app NÃO atualiza por cima de versões assinadas com outra chave)"
  keytool -genkeypair -keystore $B/ks.jks -alias universedesk -storepass universedesk -keypass universedesk \
    -keyalg RSA -keysize 2048 -validity 36500 -dname "CN=Universe Desk, O=Universe Desk, C=BR"; KS=$B/ks.jks
fi
"$BT/apksigner" sign --ks "$KS" --ks-pass pass:universedesk --key-pass pass:universedesk \
  --ks-key-alias universedesk --out $OUT $B/aligned.apk
"$BT/apksigner" verify $OUT && echo "OK -> $OUT"
