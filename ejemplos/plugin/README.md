# Estructura de plugin de Claude Code (distribución)

La skill se distribuye también como plugin. Estructura mínima: copia el contenido de este
repo dentro de la carpeta `skills/metacognicion/` de un plugin:

```
mi-plugin/
├── .claude-plugin/
│   └── plugin.json
└── skills/
    └── metacognicion/   ← el contenido de este repo (SKILL.md, analisis-cognitivo.md,
                            ejemplos/, estado/, herramientas/, PLAN.md, CONTRIBUTING.md)
```

`.claude-plugin/plugin.json`:

```json
{
  "name": "metacognicion",
  "version": "1.5.0",
  "description": "Protocolo de razonamiento metacognitivo R1-R6 con instrumentación medible para agentes de código.",
  "author": { "name": "Fellcrack", "email": "fellcrack@protonmail.com" },
  "repository": "https://github.com/Max-arango/metacognicion",
  "license": "MIT",
  "skills": ["skills/metacognicion"]
}
```

> Nota: verifica el schema vigente de `plugin.json` en la documentación de Claude Code
> antes de publicar en un marketplace; este ejemplo cubre la estructura canónica.
