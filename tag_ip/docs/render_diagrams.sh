#!/usr/bin/env bash
# =============================================================================
# Script de rendu des diagrammes Mermaid — Projet TagIp
# =============================================================================
# Prérequis : Installer mmdc (Mermaid CLI) via npm :
#   npm install -g @mermaid-js/mermaid-cli
#
# Usage :
#   ./render_diagrams.sh                    # Génère tous les diagrammes
#   ./render_diagrams.sh --watch            # Mode watch (re-génère à chaque modif)
# =============================================================================

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

INPUTS=(
  "database_architecture.mmd"
  "mcd_diagramme.mmd"
  "mld_diagramme.mmd"
)

OUTPUT_DIR="rendered"
mkdir -p "$OUTPUT_DIR"

# Options Mermaid pour un rendu professionnel
# - backgroundColor: fond blanc
# - theme: base (personnalisable)
# - fontSize: texte lisible
MMDC_OPTS=(
  --backgroundColor "#FFFFFF"
  --theme "base"
  --width 2400
  --height 1800
  --scale 2
)

render_all() {
  echo "🎨 Génération des diagrammes Mermaid..."
  for input in "${INPUTS[@]}"; do
    base="${input%.*}"
    output="$OUTPUT_DIR/${base}.png"
    echo "   → $input → $output"
    mmdc -i "$input" -o "$output" "${MMDC_OPTS[@]}" 2>/dev/null || {
      echo "   ⚠ Erreur sur $input (mmdc installé ?)"
    }
  done
  echo "✅ Terminé → $OUTPUT_DIR/"
}

if [ "${1:-}" = "--watch" ]; then
  echo "📡 Mode watch activé — Ctrl+C pour arrêter"
  render_all
  while inotifywait -q -e modify ./*.mmd 2>/dev/null || fswatch -o ./*.mmd 2>/dev/null; do
    render_all
  done
else
  render_all
fi
