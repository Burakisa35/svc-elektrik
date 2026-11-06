#!/usr/bin/env python3
"""PreToolUse koruması: Claude Code knowledge/ ve docs/ altına yazamaz (kök CLAUDE.md, roller).

Çıkış 2 = engelle (stderr Claude'a gösterilir), 0 = izin ver.
Sınır: Bash'te yol komut metninde geçmiyorsa (betik dosyası yolu kendisi hesaplıyorsa) yakalanmaz.
"""
import json
import os
import re
import sys

KORUNAN = ("knowledge", "docs")
YAZAN_ARACLAR = {"Edit", "Write", "MultiEdit", "NotebookEdit"}

# Korunan dizin adının bir yol bileşeni olarak geçmesi: knowledge/, ./docs, /abs/knowledge, D=docs, "docs"
YOL = re.compile(r"(?:^|[\s'\"=/:;&|(])(?:\./)?(?:" + "|".join(KORUNAN) + r")(?=/|\s|$|['\";&|)])")

# Yazma/değiştirme belirtileri. Yorumlayıcılar da sayılır: yolu metinde geçen bir betik yazabilir.
YAZMA = re.compile(
    r">|\btee\b|\bcp\b|\bmv\b|\brm\b|\brmdir\b|\bsed\b[^|;&]*\s-i|\bperl\b[^|;&]*\s-i|\btruncate\b|\btouch\b"
    r"|\bmkdir\b|\bln\b|\brsync\b|\bdd\b|\binstall\b|\bchmod\b|\bchown\b|\bunzip\b|\btar\b|\bpatch\b"
    r"|\bcd\b|\bpushd\b|-delete\b|-exec\b|\bxargs\b"
    r"|\bgit\s+(?:mv|rm|checkout|restore|apply|reset|clean|stash|am|cherry-pick|revert)\b"
    r"|\b(?:python3?|node|deno|bun|perl|ruby|php|bash|sh|zsh|awk|gawk)\b"
)
# Yazma sayılmayan yönlendirmeler: 2>&1, >/dev/null, 2>/dev/null
ZARARSIZ = re.compile(r"\d*>&\d|\d*>\s*/dev/null")


def engelle(neden):
    print(f"Koruma: {neden}. knowledge/ ve docs/ sohbet Claude'unun alanıdır; "
          "Claude Code yazamaz (kök CLAUDE.md). Hata bulduysan Burak'a bildir.", file=sys.stderr)
    sys.exit(2)


def korunan_mu(yol, kok):
    tam = os.path.realpath(os.path.join(kok, yol))
    for d in KORUNAN:
        alan = os.path.realpath(os.path.join(kok, d))
        if tam == alan or tam.startswith(alan + os.sep):
            return True
    return False


def main():
    try:
        veri = json.load(sys.stdin)
    except Exception:
        engelle("hook girdisi okunamadı (güvenli tarafta kalındı)")
    arac = veri.get("tool_name", "")
    girdi = veri.get("tool_input") or {}
    kok = os.environ.get("CLAUDE_PROJECT_DIR") or veri.get("cwd") or os.getcwd()

    if arac in YAZAN_ARACLAR:
        yol = girdi.get("file_path") or girdi.get("notebook_path") or ""
        if yol and korunan_mu(yol, kok):
            engelle(f"{arac} → {yol}")
    elif arac == "Bash":
        komut = girdi.get("command", "")
        if YOL.search(komut) and YAZMA.search(ZARARSIZ.sub("", komut)):
            engelle(f"Bash komutu korunan dizine dokunuyor: {komut[:120]}")
    sys.exit(0)


if __name__ == "__main__":
    main()
