---
description: "Fase 8 — Preparação de release (versão, changelog, notas, checklist de deploy) para o gate G6"
argument-hint: "[versão sugerida]"
---

# /fabrica.release — Release (gate G6)

Versão sugerida pelo humano (opcional): $ARGUMENTS

1. Confirme que a feature foi mergeada em `main` (`git log main`). Se não, pare.
2. Delegue ao **release-manager**: versão SemVer, `CHANGELOG.md`, `docs/releases/<versao>.md` (cliente + técnico) e checklist de deploy/rollback.
3. Delegue ao **devops-engineer** a conferência de que o workflow de CD tem: build da imagem, script de migração idempotente como artefato, environments `staging` e `production` com required reviewers, smoke tests pós-deploy.
4. Apresente o checklist ao humano.

Termine com:

> ⛔ **GATE G6 — Deploy.** Crie a tag/release no GitHub (`v<versão>`). O workflow de CD vai pedir aprovação no environment **staging** e, depois, em **production**. Aprove somente após conferir o checklist.

**Pare aqui. Você não cria tags, releases nem dispara deploy.**
