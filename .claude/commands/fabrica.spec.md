---
description: "Fase 2 — Especificação SDD (specify → clarify → checklist) e pedido do gate G1"
argument-hint: "<slug do discovery>"
---

# /fabrica.spec — Especificação (gate G1)

Discovery: `docs/discovery/$ARGUMENTS.md`

1. Pré-requisito: `./scripts/fabrica/verify-gates.sh --require G0`. Se falhar, pare e explique.
2. Leia o discovery. Se houver perguntas marcadas como bloqueantes e sem resposta, liste-as e pare.
3. Execute o fluxo do Spec Kit **/speckit.specify** passando como descrição o conteúdo essencial do discovery (problema, histórias priorizadas, critérios de aceite, regras, NFRs, fora de escopo). Se não puder invocar o comando diretamente, leia o arquivo do comando/skill do Spec Kit em `.claude/` e siga as instruções dele. Isso cria a branch `NNN-<nome>` e `specs/NNN-<nome>/spec.md`.
4. Copie o discovery para `specs/NNN-<nome>/discovery.md` (faz parte do artefato aprovado no G1).
5. Delegue ao **spec-reviewer** a revisão do `spec.md`.
6. Execute **/speckit.clarify** usando as perguntas do revisor. As respostas são do **humano**: pergunte, aguarde e registre. Nunca responda por ele.
7. Execute **/speckit.checklist** para gerar checklists de qualidade de requisitos (segurança, UX, dados, conforme o domínio).
8. Rode `./scripts/fabrica/verify-gates.sh` e mostre o status.

Termine com exatamente este bloco (preenchendo a feature):

> ⛔ **GATE G1 — Especificação.** Revise `specs/<feature>/spec.md`, `discovery.md` e `checklists/`.
> Para aprovar, no seu terminal: `./scripts/fabrica/approve.sh G1 <feature>`
> Para pedir mudanças, descreva-as aqui. Depois de aprovado: `/fabrica.plan`.

**Pare aqui.**
