# Task Planner

<div align="center">
  <img src="logo.png" alt="Task Planner Logo" width="400">
</div>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Claude AI](https://img.shields.io/badge/AI-Claude-blue.svg)](https://claude.ai/)

Un planificador de tareas de IA simple - Herramienta Bash que proporciona soporte paso a paso desde requisitos hasta implementación

> [English README](README_EN.md) | [日本語 README](README.md) | [中文 README](README_ZH.md) | [한국어 README](README_KO.md) | [Español README](README_ES.md) | [Français README](README_FR.md)

## Descripción General

Task Planner apoya todo el proceso desde la definición de requisitos hasta la implementación a través de las siguientes 3 etapas:

1. **Plan**: Crear planes de implementación detallados basados en requisitos
2. **Task**: Generar tareas específicas basadas en el plan
3. **Execute**: Ejecutar tareas y generar entregables en formato PR

## Características

- 🎯 Generar automáticamente planes, tareas e implementaciones paso a paso desde requisitos
- 🤖 Integración con Claude AI
- 📊 Visualización de progreso (spinner, estado, tiempo transcurrido)
- 📝 Generación de documentos estructurados (PLAN.md → TASK.md → PR.md)
- 📋 Gestión de lista de tareas
- ⚙️ Plantillas de prompts personalizables (directorio config/)

## Requisitos

- Bash (macOS/Linux)
- Claude CLI
- jq (para parsing JSON, opcional)

## Configuración

### Configuración Básica

1. Hacer el script ejecutable:

```bash
chmod +x task-planner.sh
```

2. Configurar la herramienta AI:

```bash
./task-planner.sh config claude    # Usar Claude CLI
```

### Integración en Proyectos Existentes

Pasos para integrar Task Planner en proyectos existentes:

#### 1. Copiar Archivos

```bash
# Navegar al directorio del proyecto existente
cd /path/to/your/project

# Copiar archivos de Task Planner
curl -O https://raw.githubusercontent.com/sakumoto-shota/TASK_PLANNER/main/task-planner.sh
curl -O https://raw.githubusercontent.com/sakumoto-shota/TASK_PLANNER/main/config/plan-prompt.md
curl -O https://raw.githubusercontent.com/sakumoto-shota/TASK_PLANNER/main/config/task-prompt.md
curl -O https://raw.githubusercontent.com/sakumoto-shota/TASK_PLANNER/main/config/execute-prompt.md

# O copiar desde este repositorio
cp /path/to/task_planner/task-planner.sh .
cp -r /path/to/task_planner/config .
```

#### 2. Establecer Permisos de Ejecución

```bash
chmod +x task-planner.sh
```

#### 3. Verificar Estructura de Directorios

Ejemplo de estructura de proyecto después de la integración:

```
your-project/
├── src/                  # Código fuente existente
├── docs/                 # Documentación existente
├── task-planner.sh       # ✅ Añadido
├── config/               # ✅ Añadido
│   ├── plan-prompt.md
│   ├── task-prompt.md
│   └── execute-prompt.md
└── AI_TASKS/             # ✅ Auto-creado durante la ejecución
    └── [task-name]/
        ├── PLAN.md
        ├── TASK.md
        └── PR.md
```

#### 4. Configurar .gitignore (Recomendado)

```bash
# Añadir a .gitignore (gestionar directorio AI_TASKS depende del proyecto)
echo "AI_TASKS/" >> .gitignore

# O excluir solo tareas en progreso
echo "AI_TASKS/*/plan_prompt.txt" >> .gitignore
echo "AI_TASKS/*/stream_output.json" >> .gitignore
```

#### 5. Personalización Específica del Proyecto

```bash
# Personalizar prompts para adaptarse al stack tecnológico del proyecto
vim config/plan-prompt.md
vim config/task-prompt.md
vim config/execute-prompt.md
```

## Uso

### Flujo de Trabajo de 3 Etapas

Task Planner progresa desde requisitos hasta implementación a través de las siguientes 3 etapas:

#### 1. Etapa Plan - Análisis de Requisitos y Diseño

```bash
./task-planner.sh plan "Implementar funcionalidad de login para aplicación web" login-feature
```

- **Entrada**: Texto de requisitos y nombre de tarea
- **Proceso**: IA analiza requisitos y crea plan de implementación detallado
- **Salida**: `PLAN.md` - Arquitectura, stack tecnológico, pasos de implementación detallados

#### 2. Etapa Task - Generación de Tareas Específicas

```bash
./task-planner.sh task login-feature
```

- **Entrada**: `PLAN.md` creado
- **Proceso**: Generar lista de tareas específicas ejecutables basadas en el plan
- **Salida**: `TASK.md` - Pasos de implementación en formato checklist

#### 3. Etapa Execute - Ejecución de Implementación

```bash
./task-planner.sh execute login-feature
```

- **Entrada**: `TASK.md` creado
- **Proceso**: IA realmente escribe código y crea/edita archivos
- **Salida**: `PR.md` - Reporte de completación de implementación y documentación de entregables

### Beneficios de la Ejecución Paso a Paso

- **Confirmación paso a paso**: El contenido puede ser revisado y ajustado en cada etapa
- **Mejora de calidad**: La calidad mejora a través de progresión detallada de plan → tarea → implementación
- **Reducción de riesgo**: El riesgo se reduce al poder revisar plan y tareas antes de la etapa de ejecución

### Lista de Comandos

| Comando   | Descripción                    | Ejemplo de Uso                                 |
| --------- | ------------------------------ | ---------------------------------------------- |
| `plan`    | Crear plan desde requisitos    | `./task-planner.sh plan "requisitos..." [task-name]` |
| `task`    | Generar tareas desde plan      | `./task-planner.sh task task-name`            |
| `execute` | Ejecutar tareas                | `./task-planner.sh execute task-name`         |
| `list`    | Mostrar lista de tareas        | `./task-planner.sh list`                      |
| `config`  | Configurar herramienta AI      | `./task-planner.sh config claude`             |
| `help`    | Mostrar información de ayuda   | `./task-planner.sh help`                      |

### Estructura de Archivos

La ejecución crea archivos en la siguiente estructura:

```
AI_TASKS/
└── [task-name]/
    ├── PLAN.md        # Plan de implementación detallado
    ├── TASK.md        # Procedimientos de tareas específicas
    └── PR.md          # Reporte de completación de implementación (entregable final)

config/
├── plan-prompt.md    # Plantilla de prompt para creación de plan
├── task-prompt.md    # Plantilla de prompt para creación de tareas
└── execute-prompt.md # Plantilla de prompt para ejecución
```

## Ejemplo de Salida

### Creación de Plan

```
╭─────────────────────────────────────────────────────────────────╮
│                        Task Planner                           │
╰─────────────────────────────────────────────────────────────────╯

▶ Creación de Plan
  Nombre de Tarea: login-feature
  Requisitos: Implementar funcionalidad de login para aplicación web

  IA creando plan ✅ Completado (01:23) [1250 tokens]

✅ Plan creado: AI_TASKS/login-feature/PLAN.md
  Siguiente paso: ./task-planner.sh task login-feature
```

## Características

- **Enfoque paso a paso**: Flujo claro de requisitos → plan → tarea → implementación
- **Retroalimentación en tiempo real**: Visualización de progreso durante procesamiento de IA
- **Salida estructurada**: Documentación unificada en formato Markdown
- **Gestión de historial**: Ver progreso de tareas de un vistazo
- **Personalizable**: Ajustar salida de IA editando plantillas de prompts

## ⚠️ Notas Importantes de Seguridad y Seguridad

### Permisos de Operación de Archivos del Comando execute

**La etapa execute otorga permisos extensivos de operación de archivos**

El comando `execute` otorga automáticamente la bandera `--dangerously-skip-permissions` a Claude CLI para realizar implementación real.

#### Operaciones Habilitadas

- Crear, editar, eliminar archivos
- Crear, eliminar directorios
- Ejecutar comandos del sistema
- Instalar dependencias
- Modificar archivos de configuración

### Lista de Verificación para Uso Seguro

**Por favor confirme antes de la ejecución:**

- [ ] Crear respaldos

  ```bash
  # Para repositorios Git
  git add . && git commit -m "Respaldo antes de Execute"

  # Copiar archivos importantes
  cp -r important_files/ backup/
  ```

- [ ] Verificar entorno de ejecución

  - Entorno de desarrollo, no producción
  - No se incluyen archivos importantes del sistema
  - Permisos de escritura apropiadamente restringidos

- [ ] Pre-revisar planes y tareas
  - El contenido de `PLAN.md` cumple expectativas
  - Los pasos de implementación de `TASK.md` son seguros
  - No se incluyen comandos sospechosos u operaciones peligrosas

### Entornos de Uso Recomendados

- **Directorios de desarrollo**: `/home/user/dev/`, `/Users/user/projects/`, etc.
- **Entornos virtuales**: Ejecución dentro de contenedores Docker, VMs
- **Sandboxes**: Entornos de desarrollo aislados
- **Control de versiones**: Proyectos bajo gestión Git

### Lugares a Evitar

- Directorios del sistema (`/usr/`, `/etc/`, `/System/`, etc.)
- Entornos de producción
- Directorios compartidos
- Directorios que contienen información sensible

## Personalización de Prompts

Puede personalizar el comportamiento de IA en cada etapa editando archivos Markdown en el directorio `config/`.

### Configuración de Archivos de Prompt

| Archivo            | Propósito                      | Momento                           | Ejemplos de Personalización      |
| ------------------ | ------------------------------ | --------------------------------- | --------------------------------- |
| `plan-prompt.md`   | Instrucciones para creación de plan | Cuando se ejecuta `./task-planner.sh plan` | Especificar métodos de diseño, ajustar formato de salida |
| `task-prompt.md`   | Instrucciones para creación de tareas | Cuando se ejecuta `./task-planner.sh task` | Especificar formato checklist, asignar prioridades |
| `execute-prompt.md`| Instrucciones para ejecución de implementación | Cuando se ejecuta `./task-planner.sh execute` | Estilo de codificación, instrucciones de procedimientos de prueba |

### Marcadores de Posición Disponibles

Los siguientes marcadores de posición se reemplazan automáticamente en plantillas de prompts:

- `{{TASK_NAME}}`: Nombre de tarea
- `{{REQUIREMENT}}`: Requisitos (para plan-prompt.md)
- `{{PLAN_CONTENT}}`: Contenido del plan (para task-prompt.md)
- `{{TASK_CONTENT}}`: Contenido de tarea (para execute-prompt.md)

### Ejemplo de Personalización

```markdown
# Ejemplo config/plan-prompt.md

Requisitos: {{REQUIREMENT}}
Nombre de Tarea: {{TASK_NAME}}

Por favor cree un plan de implementación detallado desde las siguientes perspectivas:

1. Diseño de arquitectura
2. Consideraciones de seguridad
3. Optimización de rendimiento
4. Estrategia de pruebas
5. Procedimientos de despliegue
```

## Ejemplos Prácticos y Casos de Uso

### Ejemplos de Uso Específicos por Proyecto

#### Desarrollo de Aplicaciones Web

```bash
# Implementación de REST API
./task-planner.sh plan "REST API con autenticación de usuario" user-auth-api
./task-planner.sh task user-auth-api
./task-planner.sh execute user-auth-api

# Características de frontend
./task-planner.sh plan "Pantalla de dashboard hecha en React" react-dashboard
```

#### Procesamiento y Análisis de Datos

```bash
# Construcción de pipeline de datos
./task-planner.sh plan "Herramienta de conversión CSV a PostgreSQL" csv-converter
./task-planner.sh task csv-converter

# Modelos de machine learning
./task-planner.sh plan "Implementación de modelo ML de clasificación de imágenes" image-classifier
```

#### DevOps y Automatización

```bash
# Configuración CI/CD
./task-planner.sh plan "Configuración de flujo de trabajo GitHub Actions" gh-workflow
./task-planner.sh task gh-workflow

# Construcción de infraestructura
./task-planner.sh plan "Entorno de desarrollo Docker Compose" docker-env
```

### Estructura de Carpetas Recomendada

```
project/
├── AI_TASKS/           # Tareas gestionadas por Task Planner
│   ├── feature-a/
│   ├── bugfix-b/
│   └── refactor-c/
├── src/               # Código fuente implementado
├── docs/              # Documentación
└── tests/             # Archivos de prueba
```

## Solución de Problemas

### Problemas Comunes y Soluciones

#### 1. Relacionados con Claude CLI

```bash
# Claude CLI no encontrado
which claude
# → Instalar: https://docs.anthropic.com/cli

# Error de autenticación
claude auth
# → Configurar clave API
```

#### 2. Errores de Permisos

```bash
# Sin permisos de ejecución
chmod +x task-planner.sh

# Sin permisos para crear directorio
sudo chown $USER:$USER /path/to/project
```

#### 3. Errores de Procesamiento de IA

- **Conexión de red**: Verificar conexión a internet
- **Límites de tasa de API**: Esperar un momento y reintentar
- **Prompt demasiado largo**: Acortar texto de requisitos y reintentar

#### 4. Errores de Procesamiento de Archivos

```bash
# Error de procesamiento JSON (jq no requerido pero recomendado)
# macOS
brew install jq
# Ubuntu
sudo apt install jq

# Error de permisos de creación de archivos
ls -la AI_TASKS/
# Verificar permisos y modificar si es necesario
```

### Métodos de Depuración

#### Verificación de Logs

```bash
# Verificar logs detallados durante procesamiento de IA
tail -f AI_TASKS/[task-name]/stream_output.json

# Verificar archivos creados
ls -la AI_TASKS/[task-name]/
```

#### Identificación de Problemas Paso a Paso

1. Falla en **etapa plan** → Revisar texto de requisitos
2. Falla en **etapa task** → Verificar contenido de PLAN.md
3. Falla en **etapa execute** → Verificar instrucciones de implementación de TASK.md

### Optimización de Rendimiento

- **Procesamiento paralelo**: Múltiples tareas pueden progresar en paralelo a través de etapas plan → task
- **Optimización de prompts**: Ajustar archivos `config/` para mejorar velocidad de respuesta
- **Utilización de caché**: Usar PLAN.md de tareas similares como plantillas de referencia

## Licencia y Contribución

### Licencia

Este proyecto se publica bajo la [Licencia MIT](LICENSE).

### Contribuir y Fork

- 🍴 **Libre de hacer fork**: Siéntase libre de hacer fork de este repositorio y personalizarlo según sus necesidades
- 🛠️ **Sugerencias de mejora**: Damos la bienvenida a sugerencias de mejora a través de Issues y Pull Requests
- 💡 **Compartir ideas**: También es bienvenido compartir ideas de nuevas características y ejemplos de uso

¡Construyamos una mejor herramienta juntos a través de la cooperación de todos!