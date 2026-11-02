---
description: "Mostra em que fase a feature atual está, os gates e o próximo passo"
---

# /fabrica.status

1. Rode `./scripts/fabrica/verify-gates.sh` e `git status -sb`.
2. Se existir `specs/<feature>/tasks.md`, conte tarefas `[X]` vs `[ ]` por fase/história.
3. Se `gh` estiver disponível, verifique se há PR aberto para a branch (`gh pr view --json state,reviewDecision,statusCheckRollup`), sem alterar nada.
4. Responda em até 10 linhas: fase atual, gates (✅/⏳/⚠️), pendências e **o próximo comando** a rodar.
   - Gate ⚠️ INVALIDADO = o artefato mudou depois da aprovação; explique qual arquivo e que precisa de nova revisão humana.
