# Registro do piloto — Fábrica SDD

Spec Kit instalado: `specify-cli` 1.2.7.dev0 (integração `claude`, scripts `sh`).

| Data | Fase | O que aconteceu | Ajuste no kit |
|------|------|-----------------|---------------|
| 2026-11-02 | Setup (A4) | `specify init --ai claude` falhou: flag removida | Usar `--integration claude --non-interactive` |
| 2026-11-02 | Setup (A4) | Spec Kit 1.2.7 instala skills (`/speckit-constitution`) em `.claude/skills`, não comandos `/speckit.constitution` | Roteiro e README do kit devem citar `/speckit-*` |
| 2026-11-02 | Setup (A4) | Windows ARM64: `uv` falha ao instalar Python gerenciado e `cryptography` não tem wheel ARM64 | Python 3.13 x64 em `C:\Python313-x64` + `uvx --python <caminho>` |
| 2026-11-02 | Setup (A4) | Só um usuário GitHub (xxxmpsxxx): CODEOWNERS aponta tudo para ele; autor não aprova o próprio PR | Rever ruleset na B3 |

## Pendências
