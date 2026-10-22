# Universe Desk · WWE 2K26

App web (PWA) para gerenciar o Universe Mode, com versão Android (WebView).

## Web / GitHub Pages
Settings → Pages → Deploy from a branch → `main` / `(root)`. Abra `https://SEU_USUARIO.github.io/NOME_DO_REPO/`.
Os dados ficam no `localStorage` do navegador; use a aba **Backup** para exportar/importar `.json`.

## Android
Pasta `android/`. O `build.sh` lê `../index.html` via `prepare_assets.py`.
Precisa de `android/tools/` (aapt2, dx.jar, android.jar) e JDK 17+. A keystore **não** está no repositório
(`*.keystore` no .gitignore): o `build.sh` cria uma nova se não existir — guarde a sua para poder atualizar o app.

## Gerar o APK automaticamente
Ao subir para o GitHub, a aba **Actions → Build APK** compila o app. Em 2–3 min o `UniverseDesk.apk` fica em **Releases → "latest"** (baixe pelo celular e instale).
Para o app atualizar por cima do já instalado, adicione sua keystore atual como segredo:
`base64 -w0 universedesk.keystore` → Settings → Secrets and variables → Actions → `KEYSTORE_B64` (senha/alias: `universedesk`).
