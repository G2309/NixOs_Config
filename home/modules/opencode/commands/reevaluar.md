---
description: Reevalúa qué modelo de OpenCode Go usa cada agente; pega después la tabla de modelos de la consola
agent: build
---
Reevalúa la asignación de modelos de mis agentes de opencode con la tabla de OpenCode Go que pego al final.

## Dónde está la configuración actual
- Modelo principal (`build`, `plan`) y `small_model`: `/home/gustavo/Progra/NixOs_Config/home/modules/opencode/default.nix`
- Subagentes: `/home/gustavo/Progra/NixOs_Config/home/modules/opencode/agents/*.md`, línea `model:`
Lee esos archivos primero para saber qué usa cada agente hoy.

## Cómo calcular
Peticiones al mes ≈ "Est. requests / 5 hr" × 5. Los IDs van con el formato `opencode-go/<id>`;
si dudas del ID exacto, consulta `https://opencode.ai/inference/go/v1/models`.

## Niveles
| Nivel | Peticiones al mes | Calidad mínima | Agentes |
|---|---|---|---|
| Abundante | más de 20.000 | Escribe bien | `@docs`, `@ci`, `small_model` |
| Diario | 3.000 a 20.000 | Fuerte en código: cerca de los mejores modelos abiertos en benchmarks de agentes (SWE-bench Pro, DeepSWE) | `build`, `esqueleto`, `@tests`, `@frontend` |
| Puntual | 500 a 3.000 | Muy fuerte, o especialista en el área | `@seguridad` |
| Rescate | menos de 500 | El mejor disponible | `@experto` |

## Reglas
- Para cada agente elige el modelo más barato que cumpla la calidad de su nivel, no el mejor.
- Las promociones no cuentan: si un modelo tiene límite o descuento temporal, evalúalo con su límite normal.
  Si ese límite normal no se conoce, no lo asignes.
- No cambies un agente por una diferencia de 1 o 2 puntos en un benchmark.
- No uses modelos "Free" ni "Contributor" para agentes fijos: pueden desaparecer o entrenar con los datos.
- Si necesitas datos de calidad, consulta como máximo 3 fuentes, por ejemplo `https://www.morphllm.com/swe-bench-pro`.
  Si un modelo no tiene datos confiables, dilo y no lo asignes a niveles Diario o superiores.

## Qué entregar
1. Una tabla: agente, modelo actual, modelo recomendado, peticiones al mes, motivo en una línea.
2. Aplica solo los cambios que mejoren claramente, editando la línea `model:` de cada archivo.
3. Al final dime qué cambiaste y recuérdame correr `nrs`.

## Tabla de modelos de este mes
$ARGUMENTS
