---
trigger: always_on
---

---
description: "Antigravity system rules for Flutter development using MVVM architecture, Riverpod state management, Material design components, and Dart style guidelines."
globs: ["**/*.dart"]
alwaysApply: true
---

# Directives de Développement Flutter (MVVM + Riverpod)

En tant qu'assistant IA, tu dois suivre scrupuleusement ce code de conduite et ces règles techniques pour toute génération, modification ou refactorisation de code Dart/Flutter dans ce projet.

---

## 1. Style de Code et Lisibilité

* **Concision :** Écris un code source concis, efficace et moderne.
* **Maintenabilité :** Privilégie la lisibilité et fournis des exemples de code précis et testables.
* **DRY (Don't Repeat Yourself) :** Évite la duplication de code. Modularise systématiquement les widgets et les fonctions en composants réutilisables.
* **Nommage explicite :** Utilise des noms de variables descriptifs. Intègre des verbes auxiliaires pour les booléens (ex: `isLoading`, `hasError`).
* **Longueur des lignes :** Pour garantir la lisibilité, aucune ligne de code ne doit dépasser **80 caractères**.
* **Contrôle de flux :** Utilise obligatoirement des accolades `{}` pour toutes les structures de contrôle (`if`, `for`, `while`, etc.).
* **Chaînes de caractères :** Utilise exclusivement des guillemets simples (`'`). Évite les guillemets doubles (`"`) pour maintenir une cohérence stricte.
* **Documentation :** Utilise les commentaires de manière proactive pour documenter la logique complexe et faciliter la maintenance.

---

## 2. Architecture Logicielle (MVVM Strict)

Le projet implémente rigoureusement le pattern **MVVM (Model-View-ViewModel)**. La structure sous `/lib` est sectorisée de la manière suivante :

* `lib/models/` : Modèles de données et définitions de types (**Model**).
* `lib/viewmodels/` : Gestion de l'état et logique métier (**ViewModel**).
* `lib/views/widgets/` : Widgets graphiques réutilisables et atomiques (**View**).
* `lib/views/screens/` : Widgets composants les écrans complets (**View**).
* `lib/services/` : Classes de services dédiées aux appels API et aux accès de données (Repository/Service).
* `lib/utils/` : Fonctions d'aide (helpers) et constantes globales.

---

## 3. Gestion de l'État (State Management)

* **Framework :** Utilise exclusivement **Riverpod** pour implémenter une gestion d'état efficace et réactive.
* **Séparation des concepts :** L'état doit être intégralement géré au sein du *ViewModel*. La *View* doit uniquement consommer cet état et notifier le *ViewModel* des actions de l'utilisateur.

---

## 4. Conventions de Nommage

* **Fichiers et Dossiers :** Utilise le format `lowercase_with_underscores` (snake_case) (ex: `auth_wizard.dart`).
* **Classes, Enums, Typedefs, Types génériques :** Utilise le format `UpperCamelCase`.
* **Variables, Fonctions, Membres de classe (méthodes, propriétés) :** Utilise le format `lowerCamelCase`.

---

## 5. Organisation des Imports

Dans chaque fichier Dart, trie les imports dans l'ordre impératif suivant (sépare chaque groupe par un saut de ligne) :

1. Les packages natifs de Dart (`dart:...`).
2. Les packages tiers externes (`package:...`).
3. Les imports relatifs aux fichiers locaux du projet (`../`, `src/...`).

---

## 6. Bonnes Pratiques Dart & UI

* **Typage Stricte :** Exploite pleinement la sécurité de typage de Dart. Utilise le typage statique dans tout le code et tire parti de l'inférence de type dès que possible.
* **Composants :** Utilise exclusivement les widgets de la bibliothèque **Material Design**.
* **Thématisation :** Uniformise les styles en utilisant `ThemeData`. Ne définis pas de styles arbitraires en dur dans les widgets.

---

## 7. Optimisation des Performances

* **Stateless vs Stateful :** Privilégie systématiquement l'utilisation de `StatelessWidget` lorsque le widget n'a pas besoin de stocker un état local mutable.
* **Constructeurs Const :** Utilise les constructeurs `const` dès que les widgets ou les objets sont immuables afin d'optimiser les cycles de build de Flutter.