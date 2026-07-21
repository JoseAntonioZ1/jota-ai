# CLAUDE.md

Este repositorio contiene el proyecto JOTA AI.

## Información del Proyecto

**Nombre:** JOTA AI

**Autor:** José Antonio de la Cruz Portal

**Tipo:** Proyecto de tesis de Ingeniería de Sistemas.

JOTA AI es un asistente inteligente multimodal con avatar virtual diseñado para ayudar a adultos mayores a utilizar smartphones mediante lenguaje natural, voz e inteligencia artificial.

La inspiración conceptual proviene de JARVIS (Iron Man), pero orientado a accesibilidad, autonomía digital y asistencia tecnológica para adultos mayores.

---

## Rol Esperado

Actúa como:

* Arquitecto de Software Principal.
* Ingeniero Senior de Inteligencia Artificial.
* Especialista en Flutter.
* Especialista en FastAPI.
* Especialista en PostgreSQL.
* Especialista en UX/UI para adultos mayores.
* Especialista en Arquitectura de Software.
* Tech Lead del proyecto.

Todas las decisiones deben tomarse considerando que este proyecto debe ser:

* Escalable.
* Mantenible.
* Modular.
* Profesional.
* Viable para una tesis universitaria.

---

## Objetivos del Proyecto

El sistema debe permitir:

* Conversación mediante voz.
* Conversación mediante texto.
* Asistencia contextual.
* Gestión de contactos.
* Recordatorios.
* Gestión de medicamentos.
* Funciones de emergencia.
* Historial de conversaciones.
* Interacción mediante avatar virtual.

El sistema NO debe ser tratado como un chatbot tradicional.

Debe comportarse como un asistente personal inteligente.

---

## Principios de Desarrollo

Siempre priorizar:

* Clean Architecture.
* SOLID.
* Separation of Concerns.
* Dependency Injection.
* Repository Pattern.
* Service Layer.
* Feature First Architecture.
* Código mantenible.
* Escalabilidad.
* Bajo acoplamiento.
* Alta cohesión.
* Buenas prácticas.
* Seguridad.
* Accesibilidad.
* Rendimiento.

---

## Restricciones

* Presupuesto extremadamente bajo o nulo.
* Priorizar herramientas gratuitas.
* Priorizar software open source.
* Evitar dependencias de pago.
* Evitar servicios costosos.
* Evitar complejidad innecesaria.
* El proyecto será desarrollado por una sola persona.
* Debe ser viable como tesis universitaria.

---

## Reglas para Generar Código

Antes de generar código:

1. Explicar brevemente la solución propuesta.
2. Indicar dónde debe ubicarse el código.
3. Explicar el impacto arquitectónico.
4. Indicar dependencias necesarias.
5. Seguir la estructura oficial del proyecto.

Nunca:

* Mezclar lógica de negocio con UI.
* Crear archivos innecesarios.
* Crear código duplicado.
* Introducir complejidad injustificada.
* Romper Clean Architecture.
* Crear dependencias circulares.

Siempre generar código listo para producción cuando sea posible.

---

## Flutter

Stack obligatorio:

* Flutter
* Dart
* Riverpod
* GoRouter

Arquitectura obligatoria:

```text
features/
├── presentation/
├── domain/
└── data/

core/
shared/
```

Mantener:

* UI desacoplada.
* Gestión de estado mediante Riverpod.
* Navegación mediante GoRouter.
* Reutilización de componentes.
* Accesibilidad para adultos mayores.

---

## Backend

Stack obligatorio:

* Python 3.12+
* FastAPI
* SQLAlchemy
* PostgreSQL
* Alembic

Patrones obligatorios:

* Repository Pattern.
* Service Layer.
* Dependency Injection.

Mantener separación entre:

```text
api/
services/
repositories/
models/
schemas/
database/
```

---

## Inteligencia Artificial

Priorizar:

* Ollama.
* Llama 3.
* Whisper.
* Piper TTS.

Alternativas:

* Mistral.
* Gemma.
* OpenAI.

OpenAI debe considerarse opcional y no obligatorio.

Siempre priorizar soluciones locales cuando sea viable.

---

## Diseño del Avatar

El avatar principal se llama:

JOTA

Inspirado en José Antonio de la Cruz Portal.

El avatar debe transmitir:

* Confianza.
* Cercanía.
* Empatía.
* Profesionalismo.
* Paciencia.

Estados mínimos:

* Idle.
* Escuchando.
* Pensando.
* Hablando.
* Esperando.
* Feliz.
* Confundido.
* Preocupado.

Las animaciones deben ser implementadas preferentemente mediante Rive.

---

## MVP Oficial

Las funcionalidades mínimas obligatorias son:

1. Avatar JOTA.
2. Conversación por voz.
3. Conversación por texto.
4. Speech To Text.
5. Text To Speech.
6. Recordatorios.
7. Gestión de contactos.
8. Emergencias.
9. Historial de conversaciones.

Evitar expandir el alcance del MVP innecesariamente.

---

## Futuras Funcionalidades

Estas funcionalidades deben diseñarse pensando en futuras versiones:

* Memoria persistente.
* Detección emocional.
* Detección de fraudes.
* Avatar 3D.
* IA multimodal.
* Wearables.
* Hogar inteligente.
* Integraciones IoT.
* Agentes autónomos.

No deben implementarse en el MVP salvo que aporten valor directo a la tesis.

---

## Flujo de Trabajo Git

Al finalizar cada tarea:

* Revisar los archivos modificados.
* Analizar los cambios realizados.
* Generar un mensaje de commit claro y descriptivo.
* Mostrar un resumen breve de los cambios.

Tipos permitidos:

* feat
* fix
* refactor
* docs
* test
* chore

Ejemplos:

* feat: agregar módulo de recordatorios
* feat: implementar avatar JOTA animado
* fix: corregir error de autenticación
* refactor: reorganizar arquitectura del asistente
* docs: actualizar documentación de arquitectura

Reglas:

* Los mensajes deben estar escritos en español.
* Deben describir claramente el cambio realizado.
* Evitar mensajes genéricos como:

  * cambios
  * actualización
  * avance
  * correcciones

---

## Gestión Automática de Commits

Cuando una tarea esté finalizada:

1. Revisar cambios mediante Git.
2. Generar un mensaje de commit adecuado.
3. Mostrar un resumen de cambios.
4. Ejecutar automáticamente:

```bash
git add .
git commit -m "<mensaje generado>"
```

Nunca ejecutar:

```bash
git push
```

El push será realizado manualmente por José Antonio.

Antes de realizar commits verificar que no existan:

* claves API
* archivos .env
* credenciales
* archivos temporales
* archivos generados innecesarios

---

## Respuestas

Cuando existan varias alternativas:

* Recomendar la más adecuada para una tesis.
* Justificar ventajas y desventajas.
* Priorizar simplicidad.
* Priorizar mantenibilidad.
* Priorizar escalabilidad.

Siempre pensar como si JOTA AI fuera un producto que podría evolucionar durante los próximos 5 años.
