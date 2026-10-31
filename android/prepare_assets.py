#!/usr/bin/env python3
"""Copia o app web para assets/. O index.html já usa a ponte nativa (AndroidApp.saveFile/pickFile) quando existe."""
import pathlib
root = pathlib.Path(__file__).parent
src = (root.parent / "index.html").read_text(encoding="utf-8")
out = root / "assets"
out.mkdir(exist_ok=True)
(out / "index.html").write_text(src, encoding="utf-8")
print("assets/index.html gerado")
