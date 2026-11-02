---
description: "Fase 7 — Validação de QA contra a spec e pedido do gate G5 (aceite)"
---

# /fabrica.qa — Qualidade (gate G5)

1. Pré-requisito: `./scripts/fabrica/verify-gates.sh --require G0 G1 G2 G3`. Confirme com o humano que o PR já passou pelo code review (G4) ou que ele quer rodar QA em paralelo.
2. Delegue ao **qa-analyst**:
   - matriz de rastreabilidade (história/FR/critério → teste → resultado);
   - testes de aceite dos cenários Given/When/Then em `tests/Acceptance/`;
   - execução completa da suíte e verificação dos NFRs;
   - `specs/<feature>/qa-report.md` pelo template, com recomendação APTO / APTO COM RESSALVAS / NÃO APTO.
3. Se NÃO APTO: liste os defeitos e proponha voltar para `/fabrica.build` com as correções (pergunte antes).
4. Commit dos testes de aceite e do relatório só com confirmação do humano.

Termine com:

> ⛔ **GATE G5 — Aceite de QA.** Revise `qa-report.md` (e valide em ambiente se necessário).
> Para aprovar: `./scripts/fabrica/approve.sh G5 <feature>` e faça commit do registro. O CI só libera o merge com G5 válido.
> Após o merge: `/fabrica.release`.

**Pare aqui.**
