# Reglas globales

## Idioma y comunicación
- Responde en español, corto y directo. Explica el porqué solo cuando no sea obvio.
- Nunca hagas commits ni push. El usuario hace sus propios commits.
- Antes de borrar o sobrescribir algo, míralo primero.

## Estilo de código
- Sin comentarios en el código. Los nombres claros reemplazan a los comentarios.
- Funciones cortas que hacen una sola cosa.
- Si el resultado se puede calcular directamente en el `return` sin perder legibilidad, hazlo ahí:
  `return max(lo, min(x, hi))` en vez de varios `if`.
- Usa la librería estándar y lo que ya existe en el proyecto antes de agregar dependencias.
- No agregues opciones, abstracciones ni código "para después" que nadie pidió.
- El cambio más pequeño que resuelva todo el problema, incluyendo los llamadores y tests que rompa.

## Modo esqueleto
El usuario completa los cuerpos de funciones con un modelo FIM local (Qwen2.5-Coder 7B) en Neovim.
Cuando use el agente `esqueleto` o pida "solo el esqueleto", cada función pendiente lleva comentarios justo antes de la firma
(es la única excepción a la regla de no comentar; el usuario los borra o los deja al completar):
- Qué hace, en una línea.
- De dos a cuatro ejemplos concretos de entrada y salida con los formatos reales, incluidos los casos borde.
  Si procesa la salida de un comando externo, muestra un ejemplo literal de esa salida.
- Qué funciones o constantes existentes debe reutilizar.
Ejemplo en Python:
```python
# Convierte la salida de `wpctl get-volume` en texto legible.
# "Volume: 0.50\n" -> "Volume at 50%, not muted."
# "Volume: 0.35 [MUTED]\n" -> "Volume at 35%, muted."
# "" -> "Could not read volume."
def parse_volume(output: str) -> str:
    raise NotImplementedError
```
- Cuerpo: solo `raise NotImplementedError` en Python, `throw UnimplementedError();` en Dart, `throw new Error("TODO")` en TS/JS.
  Nunca `...` ni `pass`: el modelo FIM lo imita y propone un cuerpo vacío.
- Docstrings solo donde el código los necesita, como las tools MCP (la descripción que lee el modelo); ahí van cortos y en inglés.
- Los imports, modelos de datos, rutas y wiring sí van completos.
- Los tests sí van completos: definen el comportamiento que el usuario va a implementar.

## Escalera de modelos
La cuota es compartida. Usa primero los modelos que rinden más por petición y solo escala si no alcanza:
1. Resuélvelo tú o con el subagente del área (modelos eficientes).
2. Si fallaste dos veces en lo mismo, o es un diseño complejo que afecta muchos módulos, delega a `@experto`
   con un resumen de lo que intentaste y por qué falló.
3. En cuanto `@experto` lo resuelva, sigue tú con el resto de la tarea.

## Delegación a subagentes
Delega con `@nombre` cuando la tarea encaje:
- `@frontend`: componentes, estilos, accesibilidad, estado de UI (React, Flutter).
- `@seguridad`: revisión de seguridad de un cambio o módulo (solo revisa, no edita).
- `@tests`: escribir o arreglar tests y entender por qué fallan.
- `@docs`: README, docstrings, documentación de APIs.
- `@ci`: GitHub Actions, Dockerfiles, despliegues en Railway.
- `@limpiar`: reduce a una línea los comentarios del esqueleto en funciones ya terminadas y con tests en verde.

## Búsqueda web y cuota
- No busques en la web lo que puedes leer en el código o en la documentación local.
- Para documentación de librerías usa primero Context7.
- Para paquetes, opciones de NixOS o de Home Manager usa la MCP `nixos`, no la web ni la memoria.
- Usa `fetch` solo con una URL concreta. Máximo 3 búsquedas web por tarea.
- No releas archivos que ya leíste en esta sesión salvo que hayan cambiado.

## Seguridad mínima
- Valida toda entrada externa (requests, archivos, variables de entorno).
- Nada de secretos en el código ni en logs; usa variables de entorno.
- SQL siempre parametrizado. Nunca `eval` ni `shell=True` con datos del usuario.

## graphify
Si existe `graphify-out/graph.json`, corre `graphify query "<pregunta>"` antes de buscar o leer archivos fuente.
Usa `graphify path "<A>" "<B>"` para relaciones y `graphify explain "<concepto>"` para conceptos.
Después de modificar código, corre `graphify update .`.
