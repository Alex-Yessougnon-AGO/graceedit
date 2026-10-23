# GraceEdit — Prompt de génération du logo

Prompt adapté du prompt AMARALIS pour le projet GraceEdit. Copier le bloc ci-dessous tel quel dans l'outil de génération d'images.

## Prompt à copier

```text
Crée un logo professionnel et distinctif pour « GraceEdit », une application mobile créative Android-first. GraceEdit commence comme un éditeur vidéo fiable et rapide, puis évolue vers un studio créatif complet (vidéo, graphisme, audio, identité de marque) assisté par intelligence artificielle. L'écriture officielle du nom est « GraceEdit » : un seul mot, avec un G majuscule et un E majuscule.

Conçois un symbole géométrique minimaliste et intemporel utilisant intelligemment l'espace négatif. Le symbole doit suggérer subtilement le montage, la coupe, la précision et la création, ainsi que la lettre « G » de GraceEdit, sans représenter littéralement un bouton de lecture, des ciseaux, une caméra, une pellicule, un clap de cinéma, une timeline complète, un pinceau, une baguette magique, des étincelles, un cerveau, un robot ou un circuit électronique.

L'espace négatif peut évoquer de manière abstraite une coupe nette, un segment (un « clip ») détaché ou en cours de déplacement, ou une ouverture qui forme un « G » stylisé. Le symbole doit être suffisamment original pour devenir reconnaissable indépendamment du nom de la marque, et ne doit pas ressembler à un logo d'application existant (ni à celui d'un éditeur vidéo, ni à celui d'un moteur de recherche).

Construis une identité visuelle moderne, sérieuse, précise et accessible, qui inspire confiance aux créateurs de contenu, aux petits commerces et aux débutants, tout en restant crédible pour des usages avancés. Le logo doit fonctionner pour une application mobile-first comme pour une marque logicielle durable.

Palette sobre : noir profond (#14151A), ivoire chaud (#F6F2EA) et une seule couleur d'accent vermillon (#E2542B), utilisée uniquement sur un petit élément du symbole. Évite les couleurs criardes. Le logo doit fonctionner parfaitement en monochrome, sans l'accent.

Associe le symbole à un logotype « GraceEdit » en typographie sans empattement moderne, neutre et parfaitement lisible, avec des proportions équilibrées, un espacement maîtrisé entre les lettres et une bonne prise en charge des accents. Le logotype doit rester net sur l'écran d'accueil de l'application, l'icône d'application, la page de lancement (splash), les réseaux sociaux, la fiche de l'application sur le store et les documents imprimés.

Le logo doit être :

* immédiatement identifiable ;
* lisible à très petite taille (16 px) ;
* reconnaissable même sans le nom GraceEdit ;
* facilement utilisable comme icône d'application Android (icône adaptative) et comme favicon ;
* efficace sur fond clair et fond sombre ;
* reproductible en monochrome ;
* simple à dessiner en vectoriel, avec un minimum de formes et de points ;
* intemporel plutôt que dépendant d'une tendance graphique passagère.

Présente uniquement une proposition de logo final soigneusement travaillée, centrée sur un fond uni, avec :

1. le symbole + le logotype GraceEdit ;
2. le symbole seul ;
3. la version monochrome noire ;
4. la version monochrome blanche sur fond noir.

La composition doit rester extrêmement propre et minimaliste. Aucun mockup de téléphone, d'écran d'application, de boutique ou de carte de visite. Aucun décor inutile.

Évite absolument :

* les boutons de lecture (triangle « play ») ;
* les ciseaux, les caméras, les pellicules et les claps ;
* les timelines dessinées littéralement ;
* les étincelles, les étoiles « IA », les baguettes magiques, les cerveaux, les robots et les circuits ;
* les mains, les visages et les silhouettes ;
* les initiales « G » trop évidentes ou banales ;
* les logos ressemblant à des marques existantes ;
* les dégradés ;
* les ombres ;
* les effets 3D, de verre ou de lueur ;
* les effets métalliques ;
* les icônes génériques ;
* les détails décoratifs inutiles ;
* les symboles trop complexes ;
* les typographies fantaisistes difficiles à lire.

Le résultat final doit donner l'impression d'un outil de création sérieux, précis et durable, capable d'évoluer d'un simple éditeur vidéo vers un studio créatif complet.
```

## Où le logo apparaît dans le projet

| Emplacement | Version à utiliser | Remarque |
|---|---|---|
| Écran de lancement (splash) | Symbole seul, centré | Fond ivoire en clair, noir profond en sombre. Pas d'animation lourde. |
| Premier lancement (onboarding) | Symbole + logotype | Une seule fois, en haut de l'écran. |
| Barre supérieure de l'accueil | Symbole seul, petite taille | Taille minimale 24 dp. |
| Réglages > À propos | Symbole + logotype | Avec le numéro de version. |
| Icône d'application Android | Symbole seul | Doit tenir dans la zone de sécurité de l'icône adaptative. |
| Icône de notification | Monochrome (blanc) | Android impose une silhouette d'une seule couleur. |
| Favicon / page web | Symbole seul | Lisible à 16 px. |
| Écran d'export (fin de vidéo) | Aucun par défaut | Un filigrane ne doit jamais être imposé sans que l'utilisateur le choisisse. |

## Règles d'usage

- Zone de protection : au moins la hauteur de la barre du « G » autour du logo.
- Taille minimale : symbole seul 16 px (favicon), symbole + logotype 96 px de large.
- Sur fond sombre, utiliser la version blanche ou la version couleur avec le noir remplacé par l'ivoire. Ne jamais poser la version noire sur un fond sombre.
- Ne pas étirer, pivoter, ajouter d'ombre ni changer l'accent vermillon.

## Notes de production

- Les fichiers SVG fournis sont un **brouillon vectoriel** dessiné par code, pas une image générée par IA. Ils servent de point de départ, ou de référence pour juger les images produites par le prompt ci-dessus.
- Le logotype utilise la police Inter (licence SIL OFL), convertie en tracés : aucune police n'est à installer. Vérifier la licence avant publication commerciale.
- Aucune recherche d'antériorité ou de marque n'a été faite. À réaliser avant tout dépôt ou publication sur un store.
