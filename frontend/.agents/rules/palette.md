---
trigger: always_on
---

---
description: "Strict UI styling and theme rules for Flutter based on the Octet.Design 'SaaS analytics features' color palette."
globs: ["**/*.dart"]
alwaysApply: true
---

# Règles Strictes du Design System - Palette de Couleurs Diag Plus Mobile

En tant qu'assistant de code IA, tu **dois** respecter de manière inflexible la palette graphique spécifiée ci-dessous pour toute génération d'interfaces, de widgets, de styles ou de thèmes Flutter. L'utilisation de couleurs génériques ou de la palette par défaut de Material Design est **strictement interdite**.

---

## 1. Tokens de la Palette Exclusive (Hexadécimaux)

Tu dois transcrire et mapper ces codes hexadécimaux exacts dans le code Dart en utilisant la syntaxe Flutter `Color(0xFF...)` :

* **Brilliance :** `#FDFCFC` (`Color(0xFFFDFCFC)`)
    * *Usage :* Arrière-plan principal de l'application (Background), grandes zones de fond.
* **Violet Essence :** `#E6E4E6` (`Color(0xFFE6E4E6)`)
    * *Usage :* Bordures subtiles, lignes de séparation (dividers), fonds de cartes secondaires ou états désactivés.
* **Palladium :** `#B1B1B1` (`Color(0xFFB1B1B1)`)
    * *Usage :* Textes secondaires, icônes secondaires, placeholders ou légendes de graphiques.
* **Night Black :** `#2F3035` (`Color(0xFF2F3035)`)
    * *Usage :* Texte principal, titres, icônes principales, éléments d'interface à fort contraste.
* **Precious Persimmon :** `#F87941` (`Color(0xFFF87941)`)
    * *Usage :* **Couleur Primaire**. Boutons d'action principaux (CTA), états actifs, éléments mis en valeur (highlights).
* **No Way Rosé :** `#F9B095` (`Color(0xFFF9B095)`)
    * *Usage :* **Couleur Secondaire** / Accents doux. Badges, fonds de boutons secondaires, opacités de surbrillance ou dégradés.

---

## 2. Directives d'Implémentation Flutter

### 2.1. Centralisation dans le ThemeData
* Toutes les couleurs doivent être appliquées via le `Theme.of(context)` global configuré avec un `ColorScheme` propre. 
* **INTERDICTION STRICTE :** Ne saisis jamais de couleurs en dur (`Colors.orange`, `Colors.black`, ou des valeurs Hex arbitraires) directement au milieu des widgets (`Container`, `Text`, etc.).

### 2.2. Configuration du Code (Exemple à suivre pour l'IA)
Lorsque tu initialises ou modifies le thème de l'application, utilise exclusivement cette structure de mapping :

```dart
final ColorScheme diagPlusColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: const Color(0xFFF87941),       // Precious Persimmon
  secondary: const Color(0xFFF9B095),     // No Way Rosé
  surface: const Color(0xFFFDFCFC),       // Brilliance
  background: const Color(0xFFFDFCFC),    // Brilliance
  error: Colors.redAccent,                // Exception tolérée pour les erreurs critiques
  onPrimary: const Color(0xFFFDFCFC),     // Brilliance (Texte blanc sur bouton orange)
  onSecondary: const Color(0xFF2F3035),   // Night Black
  onSurface: const Color(0xFF2F3035),     // Night Black
  onBackground: const Color(0xFF2F3035),  // Night Black
);
### 2.3. Gestion des Textes et Contrastes

    Titres et textes par défaut : Applique systématiquement la couleur Night Black (0xFF2F3035) via Theme.of(context).colorScheme.onBackground.

    Sous-titres et indications : Utilise Palladium (0xFFB1B1B1) pour marquer la hiérarchie visuelle.

## 3. Interdictions Absolues pour l'IA

    INTERDICTION : Ne jamais utiliser les constantes de la classe Colors de Flutter (ex: Colors.blue, Colors.grey, Colors.white).

    INTERDICTION : Ne génère aucun composant mobile possédant un fond sombre (Dark Mode) à moins qu'un ColorScheme spécifique basé sur l'inversion stricte de cette palette ne te soit demandé.

    INTERDICTION : Pas de dégradés multicolores excentriques hors de l'association de Precious Persimmon et No Way Rosé.