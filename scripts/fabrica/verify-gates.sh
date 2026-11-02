#!/usr/bin/env bash
# Verifica o estado dos gates de uma feature. Usado localmente e no CI.
#
# Uso:
#   ./scripts/fabrica/verify-gates.sh                 # mostra status da feature atual
#   ./scripts/fabrica/verify-gates.sh --require G0 G1 G2 G3   # falha (exit 1) se algum não estiver APROVADO
#   ./scripts/fabrica/verify-gates.sh --feature 001-x --require G5
set -uo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"

FEATURE=""; REQUIRE=()
while [ $# -gt 0 ]; do
  case "$1" in
    --feature) FEATURE="$2"; shift 2 ;;
    --require) shift; while [ $# -gt 0 ] && [[ "$1" =~ ^G[0-6]$ ]]; do REQUIRE+=("$1"); shift; done ;;
    *) echo "Argumento desconhecido: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$FEATURE" ]; then
  FEATURE="$(fabrica_current_feature)" || FEATURE=""
fi

if [ ${#REQUIRE[@]} -gt 0 ]; then
  if [ -z "$FEATURE" ]; then
    # Sem feature só é possível exigir G0.
    for g in "${REQUIRE[@]}"; do
      if [ "$g" != "G0" ]; then
        echo "❌ Branch fora do padrão NNN-nome: não há feature/spec associada." >&2
        exit 1
      fi
    done
  fi
  if fabrica_require "${FEATURE:--}" "${REQUIRE[@]}"; then
    echo "✅ Gates ${REQUIRE[*]} aprovados para ${FEATURE:-repositório}."
    exit 0
  else
    echo "❌ Gates pendentes/invalidados para ${FEATURE:-repositório} (lista acima)." >&2
    exit 1
  fi
fi

echo "Feature: ${FEATURE:-(nenhuma — branch fora do padrão NNN-nome)}"
for g in G0 G1 G2 G3 G5; do
  if [ "$g" != "G0" ] && [ -z "$FEATURE" ]; then continue; fi
  s="$(fabrica_gate_status "$g" "${FEATURE:--}")"
  case "$s" in
    APROVADO) icon="✅" ;; PENDENTE) icon="⏳" ;; INVALIDADO) icon="⚠️ " ;; *) icon="·" ;;
  esac
  printf '  %s %s %-30s %s\n' "$icon" "$g" "$(fabrica_gate_name "$g")" "$s"
done
echo "  ·  G4 Code review (Pull Request)     -> GitHub"
echo "  ·  G6 Deploy                         -> GitHub Environments"
