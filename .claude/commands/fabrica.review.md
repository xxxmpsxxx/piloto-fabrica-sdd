---
description: "Fase 6 — Revisão automática (código + segurança) e preparação do Pull Request para o gate G4"
---

# /fabrica.review — Revisão e PR (gate G4)

1. Pré-requisito: `./scripts/fabrica/verify-gates.sh --require G0 G1 G2 G3` e todas as tarefas de `tasks.md` marcadas `[X]` (se não, liste as pendentes e pare).
2. Em paralelo, delegue ao **code-reviewer** e ao **security-reviewer** a revisão do diff `main...HEAD`.
3. Consolide os dois retornos em `specs/<feature>/review-report.md` (achados, severidade, rastreabilidade FR → código → testes, pacotes vulneráveis).
4. Achados BLOQUEANTES/CRÍTICOS/ALTOS: proponha as correções e pergunte se o humano autoriza o **dotnet-developer** a aplicá-las. Repita a revisão depois.
5. Prepare a descrição do PR seguindo `.github/pull_request_template.md` (links para spec, plano, tarefas, review-report, como testar).
6. Pergunte se pode fazer push da branch e abrir o PR com `gh pr create`. Só execute com "sim" explícito. **Nunca** aprove nem faça merge.

Termine com:

> ⛔ **GATE G4 — Code review humano.** Um revisor (CODEOWNER) deve aprovar o PR no GitHub. O CI de gates exige G0–G3 válidos.
> Em seguida: `/fabrica.qa`.

**Pare aqui.**
