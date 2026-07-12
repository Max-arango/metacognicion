# Claude Skills

Colección de skills para Claude (Claude Code, claude.ai y Claude Desktop), por
[Fellcrack](https://github.com/Felly-linux).

> Collection of Agent Skills for Claude. Content is in Spanish; Claude follows the
> protocols natively in any conversation language.

## Skills

| Skill | Descripción |
|---|---|
| [`metacognicion`](./metacognicion/) | Protocolo de razonamiento metacognitivo destilado del modus operandi de Claude Fable 5, para que Sonnet 5 y Opus 4.8 razonen con verificación explícita, calibración de confianza y control de deriva. |

## Instalación rápida

**Claude Code** (disponible en todos los proyectos):

```bash
git clone https://github.com/Felly-linux/claude-skills.git
cp -r claude-skills/metacognicion ~/.claude/skills/
```

Después, en cualquier sesión: `/metacognicion`

**claude.ai / Claude Desktop:** descarga el zip de la skill desde
[Releases](../../releases) y súbelo en Ajustes → Capacidades → Skills.

Cada skill incluye su propio `README.md` con instrucciones de uso detalladas.

## Licencia

MIT — ver la licencia dentro de cada skill.
