---
description: "Prepara o repositório para a Fábrica SDD (executar uma vez): ferramentas, Spec Kit, constituição, GitHub"
---

# /fabrica.setup

Faça tudo você mesmo. O humano só responde às perguntas da etapa 2 e clica em "Sim" quando o Claude Code pedir permissão.
Mostre o progresso em uma linha por etapa. Se algo falhar, tente corrigir sozinho uma vez; se não der, explique em 2 linhas e pergunte.

## 1. Diagnóstico (sem perguntar nada)
- Sistema operacional (Windows / macOS / Linux / WSL) e shell em uso.
- `git --version`, `gh auth status`, `dotnet --list-sdks`, `uvx --version`, `docker version` (Docker é opcional agora; necessário para testes de integração).
- `git rev-parse --show-toplevel` deve ser a pasta atual. Se a pasta atual não for a raiz de um repositório git, pare e diga: "Abra o Claude Code na pasta raiz do repositório."
- `gh repo view --json nameWithOwner,visibility,defaultBranchRef` e `git status -sb`.
- Restos da versão anterior do kit: `.claude/hooks/`, `scripts/fabrica/`, `.specify/approvals/*.approved`, `install.sh`, `.claude/settings.fabrica.json`, os comandos antigos `.claude/commands/fabrica.{discovery,spec,plan,tasks,build,review,qa,release}.md` e os workflows `.github/workflows/cd.yml` e `.github/workflows/ai-review.yml` (agora ficam em `fabrica/opcional/`).

## 2. Perguntas (uma única mensagem, com sugestões)
Pergunte de uma vez, só o que o diagnóstico não respondeu:
1. **Visibilidade** (só se o repositório for privado): "Seu GitHub é Free. Em repositório privado o GitHub não impõe os gates (só o Claude Code os respeita). Tornar público para o piloto? (sugestão: sim, com dados fictícios)"
2. **Segundo revisor**: "Há outra pessoa (outro login GitHub) para aprovar PRs? Se não, o PR continua obrigatório e o merge feito por você é o G4." Peça o login, se houver.
3. **Ferramentas faltando**: liste e ofereça instalar (uv: `powershell -c "irm https://astral.sh/uv/install.ps1 | iex"` no Windows, `curl -LsSf https://astral.sh/uv/install.sh | sh` nos demais).

## 3. Limpeza e base
- Remova os restos da versão anterior encontrados no diagnóstico (o Claude Code pedirá confirmação para `rm`).
- Se não existir `global.json`: `dotnet new globaljson --sdk-version <maior SDK instalado> --roll-forward latestFeature`. Se não existir `.gitignore`: `dotnet new gitignore`.
- Crie `docs/piloto/registro.md` (se não existir) com a tabela: Data | Fase | O que aconteceu | Ajuste.
- Crie `.github/CODEOWNERS`: `* @<dono>` (e `@<revisor>` se informado). O Claude Code pedirá confirmação.
- `git add -A` e `git commit -m "chore: kit da Fábrica SDD v2"`.

## 4. Spec Kit
- Se não existir `.specify/`: `uvx --from git+https://github.com/github/spec-kit.git specify init --here --force --ai claude --script <ps no Windows nativo, sh nos demais>`.
- Confira que o Spec Kit não alterou os arquivos da fábrica: `git diff --stat -- CLAUDE.md .claude/settings.json .claude/agents .claude/commands/fabrica.*`. Se alterou, restaure com `git checkout -- <arquivo>`; se ele **adicionou** conteúdo ao CLAUDE.md, mantenha só o bloco dele ao final, sem apagar o da fábrica.
- Registre a versão do Spec Kit em `docs/piloto/registro.md`. Commit: `chore: Spec Kit inicializado`.

## 5. Constituição (G0)
- Se `.specify/memory/constitution.md` ainda for o modelo vazio do Spec Kit: rode **/speckit.constitution** usando `fabrica/constitution-base.md` (projeto: nome do repositório). Se já tiver conteúdo real, mantenha.
- Commit e então `/fabrica.aprovar G0` (o humano clica "Sim").

## 6. Enviar e proteger
1. Se escolheu público: `gh repo edit <dono>/<repo> --visibility public --accept-visibility-change-consequences`.
2. `git push -u origin main` (o Claude Code pedirá confirmação; é o último push direto na main).
3. Label: `gh label create fabrica-excecao --color B60205 --description "PR sem spec, autorizado por mantenedor" --force`.
4. Ruleset da main (só se o repositório for público ou a conta tiver plano pago). Crie o arquivo `.git/fabrica-ruleset.json` (fica fora do versionamento) e aplique com `gh api -X POST repos/<dono>/<repo>/rulesets --input .git/fabrica-ruleset.json`:
```json
{
  "name": "fabrica-main",
  "target": "branch",
  "enforcement": "active",
  "conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    { "type": "pull_request", "parameters": {
        "required_approving_review_count": 1,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": true,
        "require_last_push_approval": false,
        "required_review_thread_resolution": false } },
    { "type": "required_status_checks", "parameters": {
        "strict_required_status_checks_policy": false,
        "required_status_checks": [ { "context": "build-test" }, { "context": "gates" } ] } }
  ]
}
```
   **Sem segundo revisor**: use `"required_approving_review_count": 0` e `"require_code_owner_review": false` (o PR e os checks continuam obrigatórios; o merge feito pelo humano é o G4).
   Se a API recusar por plano (erro 403 com "Upgrade"), registre em `docs/piloto/registro.md` que os gates não são impostos pelo GitHub e siga.
5. Confira: `gh api repos/<dono>/<repo>/rulesets`.

## 7. Pronto
Responda em até 6 linhas: o que foi configurado, o que ficou de fora (se algo) e:
> Pronto. Para começar: **/fabrica.run <descreva a funcionalidade>**. Eu conduzo tudo e paro só quando precisar da sua decisão.
