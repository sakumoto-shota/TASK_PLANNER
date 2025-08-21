# Task Planner

<div align="center">
  <img src="logo.png" alt="Task Planner Logo" width="400">
</div>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Claude AI](https://img.shields.io/badge/AI-Claude-blue.svg)](https://claude.ai/)

Un planificateur de tâches IA simple - Outil Bash qui fournit un support étape par étape des exigences à l'implémentation

> [English README](README_EN.md) | [日本語 README](README.md) | [中文 README](README_ZH.md) | [한국어 README](README_KO.md) | [Español README](README_ES.md) | [Français README](README_FR.md)

## Aperçu

Task Planner prend en charge l'ensemble du processus de la définition des exigences à l'implémentation à travers les 3 étapes suivantes :

1. **Plan** : Créer des plans d'implémentation détaillés basés sur les exigences
2. **Task** : Générer des tâches spécifiques basées sur le plan
3. **Execute** : Exécuter les tâches et produire des livrables au format PR

## Fonctionnalités

- 🎯 Générer automatiquement des plans, tâches et implémentations étape par étape à partir des exigences
- 🤖 Intégration avec Claude AI
- 📊 Affichage visuel du progrès (spinner, statut, temps écoulé)
- 📝 Génération de documents structurés (PLAN.md → TASK.md → PR.md)
- 📋 Gestion de liste de tâches
- ⚙️ Modèles de prompts personnalisables (répertoire config/)

## Prérequis

- Bash (macOS/Linux)
- Claude CLI
- jq (pour l'analyse JSON, optionnel)

## Configuration

### Configuration de Base

1. Rendre le script exécutable :

```bash
chmod +x task-planner.sh
```

2. Configurer l'outil IA :

```bash
./task-planner.sh config claude    # Utiliser Claude CLI
```

### Intégration dans des Projets Existants

Étapes pour intégrer Task Planner dans des projets existants :

#### 1. Copier les Fichiers

```bash
# Naviguer vers le répertoire du projet existant
cd /path/to/your/project

# Copier les fichiers Task Planner
curl -O https://raw.githubusercontent.com/sakumoto-shota/TASK_PLANNER/main/task-planner.sh
curl -O https://raw.githubusercontent.com/sakumoto-shota/TASK_PLANNER/main/config/plan-prompt.md
curl -O https://raw.githubusercontent.com/sakumoto-shota/TASK_PLANNER/main/config/task-prompt.md
curl -O https://raw.githubusercontent.com/sakumoto-shota/TASK_PLANNER/main/config/execute-prompt.md

# Ou copier depuis ce dépôt
cp /path/to/task_planner/task-planner.sh .
cp -r /path/to/task_planner/config .
```

#### 2. Définir les Permissions d'Exécution

```bash
chmod +x task-planner.sh
```

#### 3. Vérifier la Structure des Répertoires

Exemple de structure de projet après intégration :

```
your-project/
├── src/                  # Code source existant
├── docs/                 # Documentation existante
├── task-planner.sh       # ✅ Ajouté
├── config/               # ✅ Ajouté
│   ├── plan-prompt.md
│   ├── task-prompt.md
│   └── execute-prompt.md
└── AI_TASKS/             # ✅ Auto-créé lors de l'exécution
    └── [task-name]/
        ├── PLAN.md
        ├── TASK.md
        └── PR.md
```

#### 4. Configurer .gitignore (Recommandé)

```bash
# Ajouter à .gitignore (gérer le répertoire AI_TASKS dépend du projet)
echo "AI_TASKS/" >> .gitignore

# Ou exclure seulement les tâches en cours
echo "AI_TASKS/*/plan_prompt.txt" >> .gitignore
echo "AI_TASKS/*/stream_output.json" >> .gitignore
```

#### 5. Personnalisation Spécifique au Projet

```bash
# Personnaliser les prompts pour s'adapter à la pile technologique du projet
vim config/plan-prompt.md
vim config/task-prompt.md
vim config/execute-prompt.md
```

## Utilisation

### Flux de Travail en 3 Étapes

Task Planner progresse des exigences à l'implémentation à travers les 3 étapes suivantes :

#### 1. Étape Plan - Analyse des Exigences et Conception

```bash
./task-planner.sh plan "Implémenter la fonctionnalité de connexion pour application web" login-feature
```

- **Entrée** : Texte des exigences et nom de la tâche
- **Traitement** : L'IA analyse les exigences et crée un plan d'implémentation détaillé
- **Sortie** : `PLAN.md` - Architecture, pile technologique, étapes d'implémentation détaillées

#### 2. Étape Task - Génération de Tâches Spécifiques

```bash
./task-planner.sh task login-feature
```

- **Entrée** : `PLAN.md` créé
- **Traitement** : Générer une liste de tâches spécifiques exécutables basées sur le plan
- **Sortie** : `TASK.md` - Étapes d'implémentation au format checklist

#### 3. Étape Execute - Exécution de l'Implémentation

```bash
./task-planner.sh execute login-feature
```

- **Entrée** : `TASK.md` créé
- **Traitement** : L'IA écrit réellement le code et crée/édite les fichiers
- **Sortie** : `PR.md` - Rapport de complétion d'implémentation et documentation des livrables

### Avantages de l'Exécution Étape par Étape

- **Confirmation étape par étape** : Le contenu peut être révisé et ajusté à chaque étape
- **Amélioration de la qualité** : La qualité s'améliore grâce à une progression détaillée plan → tâche → implémentation
- **Réduction des risques** : Le risque est réduit en pouvant réviser le plan et les tâches avant l'étape d'exécution

### Liste des Commandes

| Commande  | Description                    | Exemple d'Utilisation                         |
| --------- | ------------------------------ | ---------------------------------------------- |
| `plan`    | Créer un plan à partir des exigences | `./task-planner.sh plan "exigences..." [task-name]` |
| `task`    | Générer des tâches à partir du plan | `./task-planner.sh task task-name`            |
| `execute` | Exécuter les tâches            | `./task-planner.sh execute task-name`         |
| `list`    | Afficher la liste des tâches   | `./task-planner.sh list`                      |
| `config`  | Configurer l'outil IA         | `./task-planner.sh config claude`             |
| `help`    | Afficher les informations d'aide | `./task-planner.sh help`                      |

### Structure des Fichiers

L'exécution crée des fichiers dans la structure suivante :

```
AI_TASKS/
└── [task-name]/
    ├── PLAN.md        # Plan d'implémentation détaillé
    ├── TASK.md        # Procédures de tâches spécifiques
    └── PR.md          # Rapport de complétion d'implémentation (livrable final)

config/
├── plan-prompt.md    # Modèle de prompt pour création de plan
├── task-prompt.md    # Modèle de prompt pour création de tâches
└── execute-prompt.md # Modèle de prompt pour exécution
```

## Exemple de Sortie

### Création de Plan

```
╭─────────────────────────────────────────────────────────────────╮
│                        Task Planner                           │
╰─────────────────────────────────────────────────────────────────╯

▶ Création de Plan
  Nom de Tâche : login-feature
  Exigences : Implémenter la fonctionnalité de connexion pour application web

  IA créant le plan ✅ Terminé (01:23) [1250 tokens]

✅ Plan créé : AI_TASKS/login-feature/PLAN.md
  Prochaine étape : ./task-planner.sh task login-feature
```

## Caractéristiques

- **Approche étape par étape** : Flux clair des exigences → plan → tâche → implémentation
- **Retour en temps réel** : Affichage du progrès pendant le traitement IA
- **Sortie structurée** : Documentation unifiée au format Markdown
- **Gestion de l'historique** : Voir le progrès des tâches d'un coup d'œil
- **Personnalisable** : Ajuster la sortie IA en éditant les modèles de prompts

## ⚠️ Notes Importantes de Sécurité et de Sûreté

### Permissions d'Opération de Fichiers de la Commande execute

**L'étape execute accorde des permissions étendues d'opération de fichiers**

La commande `execute` accorde automatiquement le drapeau `--dangerously-skip-permissions` à Claude CLI pour effectuer l'implémentation réelle.

#### Opérations Activées

- Créer, éditer, supprimer des fichiers
- Créer, supprimer des répertoires
- Exécuter des commandes système
- Installer des dépendances
- Modifier des fichiers de configuration

### Liste de Vérification pour un Utilisation Sûre

**Veuillez confirmer avant l'exécution :**

- [ ] Créer des sauvegardes

  ```bash
  # Pour les dépôts Git
  git add . && git commit -m "Sauvegarde avant Execute"

  # Copier les fichiers importants
  cp -r important_files/ backup/
  ```

- [ ] Vérifier l'environnement d'exécution

  - Environnement de développement, pas de production
  - Aucun fichier système important inclus
  - Permissions d'écriture appropriément restreintes

- [ ] Pré-réviser les plans et tâches
  - Le contenu de `PLAN.md` répond aux attentes
  - Les étapes d'implémentation de `TASK.md` sont sûres
  - Aucune commande suspecte ou opération dangereuse incluse

### Environnements d'Utilisation Recommandés

- **Répertoires de développement** : `/home/user/dev/`, `/Users/user/projects/`, etc.
- **Environnements virtuels** : Exécution dans des conteneurs Docker, VMs
- **Sandboxes** : Environnements de développement isolés
- **Contrôle de version** : Projets sous gestion Git

### Endroits à Éviter

- Répertoires système (`/usr/`, `/etc/`, `/System/`, etc.)
- Environnements de production
- Répertoires partagés
- Répertoires contenant des informations sensibles

## Personnalisation des Prompts

Vous pouvez personnaliser le comportement de l'IA à chaque étape en éditant les fichiers Markdown dans le répertoire `config/`.

### Configuration des Fichiers de Prompt

| Fichier            | Objectif                       | Moment                            | Exemples de Personnalisation     |
| ------------------ | ------------------------------ | --------------------------------- | --------------------------------- |
| `plan-prompt.md`   | Instructions pour création de plan | Quand `./task-planner.sh plan` est exécuté | Spécifier méthodes de conception, ajuster format de sortie |
| `task-prompt.md`   | Instructions pour création de tâches | Quand `./task-planner.sh task` est exécuté | Spécifier format checklist, assigner priorités |
| `execute-prompt.md`| Instructions pour exécution d'implémentation | Quand `./task-planner.sh execute` est exécuté | Style de codage, instructions procédures de test |

### Espaces Réservés Disponibles

Les espaces réservés suivants sont automatiquement remplacés dans les modèles de prompts :

- `{{TASK_NAME}}` : Nom de la tâche
- `{{REQUIREMENT}}` : Exigences (pour plan-prompt.md)
- `{{PLAN_CONTENT}}` : Contenu du plan (pour task-prompt.md)
- `{{TASK_CONTENT}}` : Contenu de la tâche (pour execute-prompt.md)

### Exemple de Personnalisation

```markdown
# Exemple config/plan-prompt.md

Exigences : {{REQUIREMENT}}
Nom de Tâche : {{TASK_NAME}}

Veuillez créer un plan d'implémentation détaillé des perspectives suivantes :

1. Conception d'architecture
2. Considérations de sécurité
3. Optimisation des performances
4. Stratégie de test
5. Procédures de déploiement
```

## Exemples Pratiques et Cas d'Usage

### Exemples d'Utilisation Spécifiques par Projet

#### Développement d'Applications Web

```bash
# Implémentation d'API REST
./task-planner.sh plan "API REST avec authentification utilisateur" user-auth-api
./task-planner.sh task user-auth-api
./task-planner.sh execute user-auth-api

# Fonctionnalités frontend
./task-planner.sh plan "Écran de tableau de bord fait en React" react-dashboard
```

#### Traitement et Analyse de Données

```bash
# Construction de pipeline de données
./task-planner.sh plan "Outil de conversion CSV vers PostgreSQL" csv-converter
./task-planner.sh task csv-converter

# Modèles d'apprentissage automatique
./task-planner.sh plan "Implémentation de modèle ML de classification d'images" image-classifier
```

#### DevOps et Automatisation

```bash
# Configuration CI/CD
./task-planner.sh plan "Configuration de flux de travail GitHub Actions" gh-workflow
./task-planner.sh task gh-workflow

# Construction d'infrastructure
./task-planner.sh plan "Environnement de développement Docker Compose" docker-env
```

### Structure de Dossiers Recommandée

```
project/
├── AI_TASKS/           # Tâches gérées par Task Planner
│   ├── feature-a/
│   ├── bugfix-b/
│   └── refactor-c/
├── src/               # Code source implémenté
├── docs/              # Documentation
└── tests/             # Fichiers de test
```

## Dépannage

### Problèmes Courants et Solutions

#### 1. Liés à Claude CLI

```bash
# Claude CLI non trouvé
which claude
# → Installer : https://docs.anthropic.com/cli

# Erreur d'authentification
claude auth
# → Définir la clé API
```

#### 2. Erreurs de Permissions

```bash
# Pas de permissions d'exécution
chmod +x task-planner.sh

# Pas de permissions pour créer un répertoire
sudo chown $USER:$USER /path/to/project
```

#### 3. Erreurs de Traitement IA

- **Connexion réseau** : Vérifier la connexion internet
- **Limites de taux API** : Attendre un moment et réessayer
- **Prompt trop long** : Raccourcir le texte des exigences et réessayer

#### 4. Erreurs de Traitement de Fichiers

```bash
# Erreur de traitement JSON (jq non requis mais recommandé)
# macOS
brew install jq
# Ubuntu
sudo apt install jq

# Erreur de permissions de création de fichiers
ls -la AI_TASKS/
# Vérifier les permissions et modifier si nécessaire
```

### Méthodes de Débogage

#### Vérification des Logs

```bash
# Vérifier les logs détaillés pendant le traitement IA
tail -f AI_TASKS/[task-name]/stream_output.json

# Vérifier les fichiers créés
ls -la AI_TASKS/[task-name]/
```

#### Identification des Problèmes Étape par Étape

1. Échec **étape plan** → Réviser le texte des exigences
2. Échec **étape task** → Vérifier le contenu de PLAN.md
3. Échec **étape execute** → Vérifier les instructions d'implémentation de TASK.md

### Optimisation des Performances

- **Traitement parallèle** : Plusieurs tâches peuvent progresser en parallèle à travers les étapes plan → task
- **Optimisation des prompts** : Ajuster les fichiers `config/` pour améliorer la vitesse de réponse
- **Utilisation du cache** : Utiliser PLAN.md de tâches similaires comme modèles de référence

## Licence et Contribution

### Licence

Ce projet est publié sous la [Licence MIT](LICENSE).

### Contribuer et Fork

- 🍴 **Libre de faire un fork** : N'hésitez pas à faire un fork de ce dépôt et à le personnaliser selon vos besoins
- 🛠️ **Suggestions d'amélioration** : Nous accueillons les suggestions d'amélioration via Issues et Pull Requests
- 💡 **Partage d'idées** : Le partage d'idées de nouvelles fonctionnalités et d'exemples d'utilisation est également bienvenu

Construisons un meilleur outil ensemble grâce à la coopération de tous !