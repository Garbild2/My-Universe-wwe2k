#!/usr/bin/env python3
"""Copia o app web para assets/ aplicando 1 ajuste só para Android:
 'Baixar backup' usa a ponte nativa (blob: download não funciona em WebView).
 A importação de arquivo já está no index.html (usa AndroidApp.pickFile quando existe)."""
import pathlib, sys
root = pathlib.Path(__file__).parent
src = (root.parent / "index.html").read_text(encoding="utf-8")

old_export = "function exportJSON() { const blob="
new_export = ("function exportJSON() { if (window.AndroidApp && AndroidApp.saveFile) "
              "{ AndroidApp.saveFile('wwe-universe-backup.json','application/json',JSON.stringify(S,null,2)); return; } const blob=")
assert src.count(old_export) == 1, "exportJSON não encontrado"
src = src.replace(old_export, new_export)

out = root / "assets"
out.mkdir(exist_ok=True)
(out / "index.html").write_text(src, encoding="utf-8")
print("assets/index.html gerado")
