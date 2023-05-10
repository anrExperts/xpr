# xpr

XPR est un outil de dépouillement de sources archivistiques basé sur des technologies XML réalisé dans le cadre de l’ANR Experts.

Les données archivistiques ont été dépouillées à l’aide d’une application développée avec des technologies XML dans le cadre du projet. La base de données XML native [BaseX](https://basex.org) a permis la création d’une API REST développée en [XQuery](https://www.w3.org/XML/Query/) qui soutient l’ensemble du travail. Plusieurs formulaires dynamiques ont été développés avec [XForms](https://www.w3.org/TR/xforms11/) afin de permettre la mise à jour des dépouillements, de pouvoir renseigner la prosopographie et pour disposer de formulaires spécifiques pour le traitement de certaines sources telles que les inventaires après décès ou des annuaires. Cette application permet à l’équipe de partager les données au fur et à mesure de la réalisation du travail et de publier les résultats avant d’avoir terminé les dépouillements. L’utilisation de la base de données permet également de faire des requêtes riches pour des usages statistiques, des analyses de réseau ou pour produire des visualisations dynamiques.

### Bibliographie

- Château-Dutier, Emmanuel, et Josselin Morvan. 2021. « Un outil de dépouillement de sources archivistiques basé sur des technologies XML ». Dans *Colloque Humanistica 2021 - Recueil des résumés*. , 78‑80. Rennes, 10-12 mai 2021 (France). https://doi.org/10.5281/zenodo.4745006.

## Documentation

### Licence

GNU General Public License

### Dépendances

- [BaseX](https://basex.org) >9
- XSLTForms 2

### Installation

- Cloner le répertoire et placer dans le répertoire `webapp` de BaseX
- Lancer BaseX avec le script d’exécution `bin/basexhttp`
- Installer les données du projet (https://github.com/anrExperts/data)
- Accéder à l’application sur le localhost de basexhttp

## L’ANR Experts

**Pratiques des savoirs entre jugement et innovation. Experts, expertises du bâtiment, Paris 1690-1790 – ANR EXPERTS**

Depuis le Moyen Âge et probablement plus tôt, les autorités publiques confient à des personnes qu’elles estiment et qualifient compétentes l’action d’émettre un avis sur le savoir technique et scientifique, que ce soit dans le domaine gracieux comme contentieux. Cette recherche conduite dans le cadre d’un projet d’ANR vise à examiner, à partir d’un secteur économique majeur – celui du bâtiment à l’époque moderne –, le mécanisme de l’expertise : comment la langue technique régulatrice et maîtrisée des experts s’impose à la société, comment leur compétence technique se convertit en autorité, voire parfois en « abus d’autorité » ? L’existence d’un fonds d’archives exceptionnel (A.N. Z1J) qui conserve l’ensemble des procès-verbaux d’expertise du bâtiment parisien de 1643 à 1792 nous a permis de lancer une enquête pluridisciplinaire (juridique, économique et architecturale) de grande envergure sur la question de l’expertise qui connaît, à partir de 1690, un tournant particulier. En effet, les experts se divisent alors en deux branches différentes exerçant deux activités concurrentes, parfois complémentaires : les architectes et les entrepreneurs.

Notre recherche s’intéresse donc à la communauté des experts parisiens du bâtiment de 1690 à 1790. Les experts se répartissent, depuis cette époque, en deux cohortes d’architectes experts bourgeois et d’experts entrepreneurs. Nous étudions la structuration de cette communauté et l’activité des experts. Deux grands chantiers sont menés de front, d’une part l’établissement d’une prosopographie des 266 experts parisiens mais aussi un dépouillement systématique d’un échantillon de dix années de procès-verbaux d’expertise sur toute la période (en particulier, sous-séries V1 Lettres de provisions d’offices, Z1J Chambre et Greffiers des bâtiments, aux Archives nationales de France, Almanachs royaux, œuvres et travaux publiés, BnF).

https://anr.fr/Projet-ANR-17-CE26-0006
