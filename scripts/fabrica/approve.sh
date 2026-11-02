#!/usr/bin/env bash
# Registra a APROVAÇÃO HUMANA de um gate da Fábrica SDD.
#
# Uso:  ./scripts/fabrica/approve.sh <G0|G1|G2|G3|G5> [feature] [-m "comentário"]
#
# Proteções:
#  - Só roda em terminal interativo (TTY). Agentes não têm TTY.
#  - Recusa execução dentro do Claude Code (variável CLAUDECODE).
#  - Exige digitar a confirmação "APROVO <gate>".
#  - Grava o hash do artefato: se o artefato mudar depois, a aprovação é invalidada.
#  - O hook guard-bash.sh bloqueia qualquer tentativa de agente chamar este script.
# A garantia final é o GitHub: CODEOWNERS sobre */approvals/* + branch protection.

set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"

usage() { echo "Uso: $0 <G0|G1|G2|G3|G5> [feature] [-m \"comentário\"]"; exit 1; }

[ $# -ge 1 ] || usage
GATE="$1"; shift
FEATURE=""; COMMENT=""
while [ $# -gt 0 ]; do
  case "$1" in
    -m) COMMENT="${2:-}"; shift 2 ;;
    *)  FEATURE="$1"; shift ;;
  esac
done

case "$GATE" in G0|G1|G2|G3|G5) ;; G4|G6)
  echo "$GATE é aprovado no GitHub (G4 = review do PR, G6 = environment de deploy)."; exit 1 ;;
  *) usage ;;
esac

if [ -n "${CLAUDECODE:-}" ] || [ ! -t 0 ] || [ ! -t 1 ]; then
  echo "❌ Aprovações só podem ser feitas por um humano, em terminal interativo." >&2
  exit 3
fi

if [ "$GATE" = "G0" ]; then
  FEATURE="-"
elif [ -z "$FEATURE" ]; then
  FEATURE="$(fabrica_current_feature)" || { echo "Não identifiquei a feature. Informe-a: $0 $GATE 001-minha-feature" >&2; exit 1; }
fi

# Pré-requisitos em ordem: não se aprova G2 sem G1 válido, etc.
case "$GATE" in
  G2) PRE=(G0 G1) ;;
  G3) PRE=(G0 G1 G2) ;;
  G5) PRE=(G0 G1 G2 G3) ;;
  G1) PRE=(G0) ;;
  *)  PRE=() ;;
esac
if [ ${#PRE[@]} -gt 0 ] && ! fabrica_require "$FEATURE" "${PRE[@]}"; then
  echo "❌ Gates anteriores não estão aprovados (lista acima)." >&2
  exit 4
fi

HASH="$(fabrica_gate_hash "$GATE" "$FEATURE")" || { echo "❌ Artefato do $GATE não encontrado." >&2; exit 5; }
ROOT="$(fabrica_root)"

echo "════════════════════════════════════════════════════════"
echo " Gate $GATE — $(fabrica_gate_name "$GATE")"
echo " Feature: $FEATURE"
echo " Artefatos revisados:"
fabrica_gate_files "$GATE" "$FEATURE" | sed "s#^$ROOT/#   • #"
echo " Hash: $HASH"
echo "════════════════════════════════════════════════════════"
echo "Confirme que você LEU e REVISOU os artefatos acima."
read -r -p "Digite 'APROVO $GATE' para aprovar: " CONFIRM
[ "$CONFIRM" = "APROVO $GATE" ] || { echo "Aprovação cancelada."; exit 6; }

if [ -z "$COMMENT" ]; then
  read -r -p "Comentário (opcional): " COMMENT
fi

AF="$(fabrica_approval_file "$GATE" "$FEATURE")"
mkdir -p "$(dirname "$AF")"
{
  echo "gate: $GATE"
  echo "nome: $(fabrica_gate_name "$GATE")"
  echo "feature: $FEATURE"
  echo "hash: $HASH"
  echo "aprovador: $(git config user.name 2>/dev/null || whoami) <$(git config user.email 2>/dev/null || echo '-')>"
  echo "data: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "comentario: ${COMMENT:--}"
} > "$AF"

echo "✅ $GATE aprovado. Registro: ${AF#"$ROOT"/}"
echo "   Faça commit desse arquivo (ele será revisado pelos CODEOWNERS no PR)."
