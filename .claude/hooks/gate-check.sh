#!/usr/bin/env bash
# Hook PreToolUse (Write|Edit|MultiEdit|NotebookEdit) da Fábrica SDD.
# Impede que agentes escrevam artefatos de uma fase sem a aprovação humana da fase anterior.
#
#   Sempre bloqueado p/ agentes: registros de aprovação, .claude/, scripts/fabrica/,
#                                CODEOWNERS e o workflow de gates.
#   specs/<f>/spec.md            -> exige G0
#   specs/<f>/plan.md e anexos   -> exige G0 G1
#   specs/<f>/tasks.md           -> exige G0 G1 G2
#   specs/<f>/qa-report.md       -> exige G0 G1 G2 G3
#   código/infra (todo o resto)  -> exige G0 G1 G2 G3 numa branch de feature
#   livres: docs/, demais arquivos em specs/, .specify/ (exceto approvals), *.md da raiz
#
# exit 2 = bloqueia e mostra o motivo ao agente.

ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
# shellcheck source=../../scripts/fabrica/lib.sh
source "$ROOT/scripts/fabrica/lib.sh" 2>/dev/null || { echo "Fábrica SDD: lib.sh ausente — bloqueando por segurança." >&2; exit 2; }

command -v jq >/dev/null 2>&1 || { echo "Fábrica SDD: instale 'jq' (necessário para os gates). Bloqueando por segurança." >&2; exit 2; }

INPUT="$(cat)"
FILE="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty')"
[ -z "$FILE" ] && exit 0

case "$FILE" in /*) ;; *) FILE="$ROOT/$FILE" ;; esac
REL="${FILE#"$ROOT"/}"

block() {
  echo "⛔ Fábrica SDD — bloqueado: $REL" >&2
  echo "$1" >&2
  exit 2
}

# 1) Arquivos de governança: somente humanos alteram.
case "$REL" in
  */approvals/*|.specify/approvals/*) block "Registros de aprovação só são criados por humanos via ./scripts/fabrica/approve.sh." ;;
  .claude/*|scripts/fabrica/*|.github/CODEOWNERS|.github/workflows/fabrica-gates.yml)
    block "Arquivo de governança da fábrica. Proponha a mudança ao humano responsável em vez de editá-lo." ;;
esac

need() {
  local feature="$1"; shift
  local msg
  if ! msg="$(fabrica_require "$feature" "$@" 2>&1)"; then
    block "Gates necessários para esta fase não estão aprovados:
$msg
Peça ao humano responsável para revisar e executar ./scripts/fabrica/approve.sh <gate>."
  fi
}

# 2) Artefatos SDD por fase.
if [[ "$REL" =~ ^specs/([^/]+)/(.*)$ ]]; then
  F="${BASH_REMATCH[1]}"; P="${BASH_REMATCH[2]}"
  case "$P" in
    spec.md)                                     need "$F" G0 ;;
    plan.md|research.md|data-model.md|quickstart.md|contracts/*|adr/*) need "$F" G0 G1 ;;
    tasks.md)                                    need "$F" G0 G1 G2 ;;
    qa-report.md)                                need "$F" G0 G1 G2 G3 ;;
  esac
  exit 0
fi

# 3) Áreas livres (documentação e infraestrutura do Spec Kit).
case "$REL" in
  docs/*|.specify/*|fabrica/*|CLAUDE.md|README.md|CHANGELOG.md) exit 0 ;;
esac

# 4) Implementação (código, testes, pipelines, infra).
FEATURE="$(fabrica_current_feature)" || block "Implementação só acontece numa branch de feature (NNN-nome) criada pelo fluxo /fabrica.spec."
need "$FEATURE" G0 G1 G2 G3
exit 0
