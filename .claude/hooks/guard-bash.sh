#!/usr/bin/env bash
# Hook PreToolUse (Bash) da Fábrica SDD.
# Bloqueia comandos que (a) burlariam os gates humanos ou (b) têm efeito
# irreversível/externo que precisa ser feito por uma pessoa.
# É uma rede de segurança; a garantia final é o GitHub (branch protection,
# CODEOWNERS e environments com aprovadores).

command -v jq >/dev/null 2>&1 || { echo "Fábrica SDD: instale 'jq'. Bloqueando por segurança." >&2; exit 2; }

CMD="$(cat | jq -r '.tool_input.command // empty')"
[ -z "$CMD" ] && exit 0

block() {
  echo "⛔ Fábrica SDD — comando bloqueado: $1" >&2
  echo "Isso exige uma pessoa. Explique ao humano o que precisa ser feito e por quê, e pare." >&2
  exit 2
}

has() { printf '%s' "$CMD" | grep -Eq -- "$1"; }

# --- Gates e governança -------------------------------------------------------
has 'approve\.sh'                                && block "aprovação de gate (somente humanos)"
has '(approvals/|\.claude/(hooks|settings)|scripts/fabrica/|CODEOWNERS|fabrica-gates\.yml)' \
  && has '(>|tee |sed -i|mv |cp |rm |chmod |truncate|ln |git (rm|mv|checkout|restore))' \
  && block "alteração de arquivos de governança/aprovação"
has '(^|[;&| ])export +(SPECIFY_FEATURE|CLAUDE_PROJECT_DIR)=' && block "troca de contexto de feature"

# --- Git / GitHub: integração e publicação -----------------------------------
has 'git +push.*(--force([^-]|$)|-f( |$))'       && block "push forçado"
has 'git +push.*[ :](main|master)( |$)|git +push.*[ :]release/' && block "push direto em branch protegida"
has 'git +(reset +--hard|clean +-[a-z]*f)'       && block "descarte irreversível de trabalho"
has 'git +commit.*--no-verify'                   && block "commit sem hooks"
has 'gh +pr +(merge|review)'                     && block "merge/aprovação de PR (gate G4)"
has 'gh +(release +(create|delete|edit)|workflow +run|api .*(merges|/merge|reviews))' && block "release/execução de workflow"

# --- Deploy, infraestrutura e banco ------------------------------------------
has '(az +(deployment|webapp|functionapp|containerapp|aks|sql|group +delete)|kubectl +(apply|delete|replace|rollout|scale|edit)|helm +(install|upgrade|uninstall|rollback)|terraform +(apply|destroy|import)|pulumi +(up|destroy)|bicep +deploy)' \
  && block "deploy/alteração de infraestrutura (gate G6)"
has 'docker +push'                               && block "publicação de imagem"
has 'dotnet +nuget +push'                        && block "publicação de pacote"
has 'dotnet +ef +database +(update|drop)'        && block "migração aplicada em banco (gere o script com 'dotnet ef migrations script')"

# --- Destrutivos / supply chain ----------------------------------------------
has 'rm +-[a-zA-Z]*r[a-zA-Z]*f?.* +(/|~|\$HOME|\.)( |$)' && block "remoção recursiva ampla"
has '(curl|wget)[^|]*\| *(ba|z)?sh'              && block "execução de script remoto"
has '(cat|less|head|tail|grep).*(\.env|appsettings\.Production|secrets\.json|\.pfx|id_rsa)' && block "leitura de segredos"

exit 0
