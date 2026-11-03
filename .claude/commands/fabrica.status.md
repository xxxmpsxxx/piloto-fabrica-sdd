---
description: "Mostra em que fase a feature atual está, os gates e o próximo passo"
---

# /fabrica.status

1. `git status -sb` e identifique a feature pela branch (`NNN-nome`).
2. Verifique G0, G1, G2, G3 e G5 como descrito no CLAUDE.md (só com git e Read).
3. Se existir `tasks.md`, conte tarefas `[X]` e `[ ]` por história.
4. Se houver PR da branch: `gh pr view --json state,reviewDecision,statusCheckRollup` (somente leitura).
5. Responda em até 8 linhas: gates (✅ aprovado, ⏳ pendente, ⚠️ invalidado), tarefas, PR e **o próximo passo** (normalmente `/fabrica.run` para continuar).
