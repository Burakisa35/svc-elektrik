#!/usr/bin/env bash
# koruma.py testi: Claude Code'un hook'a verdiği JSON'u taklit eder. Çalıştırma: bash .claude/hooks/koruma-test.sh
cd "$(dirname "$0")/../.." || exit 1
export CLAUDE_PROJECT_DIR="$PWD"
kalan=0
dene() { # beklenen(2=engel,0=izin) araç alan değer
  local json; json=$(python3 -c 'import json,sys;print(json.dumps({"tool_name":sys.argv[1],"tool_input":{sys.argv[2]:sys.argv[3]}}))' "$2" "$3" "$4")
  printf '%s' "$json" | python3 .claude/hooks/koruma.py 2>/dev/null; local c=$?
  if [ "$c" = "$1" ]; then echo "GEÇTİ [$c] $2: $4"; else echo "KALDI [beklenen $1, gelen $c] $2: $4"; kalan=$((kalan+1)); fi
}
# Engellenmeli
dene 2 Write file_path "knowledge/brands/x.md"
dene 2 Edit  file_path "$PWD/docs/VERI_MODELI.md"
dene 2 Write file_path "src/../knowledge/x.md"
dene 2 Bash command "echo x > knowledge/x.md"
dene 2 Bash command "echo x >> ./docs/briefs/a.md"
dene 2 Bash command "printf x | tee knowledge/a.md"
dene 2 Bash command "cp /tmp/a docs/decisions/"
dene 2 Bash command "mv src/a.md knowledge/a.md"
dene 2 Bash command "rm -rf docs"
dene 2 Bash command "sed -i 's/a/b/' knowledge/_SPEC.md"
dene 2 Bash command "python3 -c \"open('knowledge/x','w').write('1')\""
dene 2 Bash command "node -e \"require('fs').writeFileSync('docs/x','1')\""
dene 2 Bash command "cd knowledge && echo x > y"
dene 2 Bash command "D=docs; echo x > \$D/a"
dene 2 Bash command "git checkout HEAD -- docs/README.md"
dene 2 Bash command "find knowledge -name '*.md' -delete"
# İzin verilmeli
dene 0 Write file_path "src/CLAUDE.md"
dene 0 Write file_path "supabase/migrations/0005_x.sql"
dene 0 Bash command "cat knowledge/_SPEC.md"
dene 0 Bash command "grep -rn diafon knowledge/ 2>&1"
dene 0 Bash command "git show origin/setup/foundation:docs/briefs/004-code-md-uygulama.md"
dene 0 Bash command "ls docs/ >/dev/null"
dene 0 Bash command "echo x > src/a.txt"
dene 0 Bash command "git merge origin/setup/foundation"
echo "--- kalan=$kalan"
exit "$kalan"
