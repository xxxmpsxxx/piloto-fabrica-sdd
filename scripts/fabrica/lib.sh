#!/usr/bin/env bash
# Biblioteca comum dos gates da Fábrica SDD.
# Usada por: approve.sh, verify-gates.sh, status.sh e pelos hooks do Claude Code.
#
# Gates com registro em arquivo (assinatura por hash do artefato):
#   G0 constituição   -> .specify/memory/constitution.md
#   G1 especificação  -> specs/<feature>/spec.md (+ discovery.md, checklists/)
#   G2 plano técnico  -> specs/<feature>/plan.md (+ research.md, data-model.md, contracts/, adr/)
#   G3 tarefas        -> specs/<feature>/tasks.md (checkboxes normalizados)
#   G5 aceite de QA   -> specs/<feature>/qa-report.md
# Gates sem arquivo (aplicados pelo GitHub):
#   G4 code review    -> aprovação humana do Pull Request (branch protection + CODEOWNERS)
#   G6 deploy         -> environments "staging"/"production" com required reviewers

set -o pipefail

fabrica_root() {
  if [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
    echo "$CLAUDE_PROJECT_DIR"
  else
    git rev-parse --show-toplevel 2>/dev/null || pwd
  fi
}

# Feature atual: variável SPECIFY_FEATURE (padrão do Spec Kit) ou nome da branch "NNN-nome".
fabrica_current_feature() {
  if [ -n "${SPECIFY_FEATURE:-}" ]; then
    echo "$SPECIFY_FEATURE"; return 0
  fi
  local b
  b="${GITHUB_HEAD_REF:-$(git -C "$(fabrica_root)" symbolic-ref --short -q HEAD 2>/dev/null)}"
  if [[ "$b" =~ ^[0-9]{3}- ]]; then
    echo "$b"; return 0
  fi
  return 1
}

fabrica_sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum | cut -d' ' -f1
  else
    shasum -a 256 | cut -d' ' -f1
  fi
}

fabrica_gate_name() {
  case "$1" in
    G0) echo "Constituição do projeto" ;;
    G1) echo "Especificação (requisitos)" ;;
    G2) echo "Plano técnico / arquitetura" ;;
    G3) echo "Tarefas de implementação" ;;
    G4) echo "Code review (Pull Request)" ;;
    G5) echo "Aceite de QA" ;;
    G6) echo "Deploy (GitHub Environments)" ;;
    *)  echo "desconhecido" ;;
  esac
}

# Lista (ordenada) dos arquivos que compõem o artefato de um gate.
fabrica_gate_files() {
  local gate="$1" feature="$2" root d
  root="$(fabrica_root)"
  d="$root/specs/$feature"
  case "$gate" in
    G0) [ -f "$root/.specify/memory/constitution.md" ] && echo "$root/.specify/memory/constitution.md" ;;
    G1)
      [ -f "$d/spec.md" ] && echo "$d/spec.md"
      [ -f "$d/discovery.md" ] && echo "$d/discovery.md"
      [ -d "$d/checklists" ] && find "$d/checklists" -type f -name '*.md' | LC_ALL=C sort
      ;;
    G2)
      [ -f "$d/plan.md" ] && echo "$d/plan.md"
      for f in research.md data-model.md quickstart.md; do [ -f "$d/$f" ] && echo "$d/$f"; done
      for sub in contracts adr; do
        [ -d "$d/$sub" ] && find "$d/$sub" -type f | LC_ALL=C sort
      done
      ;;
    G3) [ -f "$d/tasks.md" ] && echo "$d/tasks.md" ;;
    G5) [ -f "$d/qa-report.md" ] && echo "$d/qa-report.md" ;;
  esac
  return 0
}

# Hash do artefato. Em tasks.md, as caixas [x]/[X] viram [ ] para que marcar
# tarefas concluídas durante a implementação NÃO invalide o G3.
# Adicionar/alterar/remover tarefas invalida (exige nova aprovação).
fabrica_gate_hash() {
  local gate="$1" feature="$2" files root
  root="$(fabrica_root)"
  files="$(fabrica_gate_files "$gate" "$feature")"
  [ -z "$files" ] && return 1
  while IFS= read -r f; do
    printf '### %s\n' "${f#"$root"/}"
    if [ "$gate" = "G3" ]; then
      sed -E 's/\[[xX]\]/[ ]/g' "$f"
    else
      cat "$f"
    fi
    printf '\n'
  done <<< "$files" | tr -d '\r' | fabrica_sha256
}

fabrica_approval_file() {
  local gate="$1" feature="$2" root
  root="$(fabrica_root)"
  if [ "$gate" = "G0" ]; then
    echo "$root/.specify/approvals/G0.approved"
  else
    echo "$root/specs/$feature/approvals/$gate.approved"
  fi
}

# Status: APROVADO | PENDENTE | INVALIDADO | SEM-ARTEFATO
fabrica_gate_status() {
  local gate="$1" feature="$2" af current approved
  af="$(fabrica_approval_file "$gate" "$feature")"
  current="$(fabrica_gate_hash "$gate" "$feature")" || { echo "SEM-ARTEFATO"; return 0; }
  [ -f "$af" ] || { echo "PENDENTE"; return 0; }
  approved="$(grep -E '^hash:' "$af" | head -1 | awk '{print $2}')"
  if [ "$approved" = "$current" ]; then echo "APROVADO"; else echo "INVALIDADO"; fi
}

# Retorna 0 se todos os gates informados estão APROVADOS.
fabrica_require() {
  local feature="$1"; shift
  local g s ok=0
  for g in "$@"; do
    s="$(fabrica_gate_status "$g" "$feature")"
    if [ "$s" != "APROVADO" ]; then
      echo "  - $g ($(fabrica_gate_name "$g")): $s" >&2
      ok=1
    fi
  done
  return $ok
}
