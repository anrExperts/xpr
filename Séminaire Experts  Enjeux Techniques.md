# Séminaire Experts : Enjeux Techniques

 

## Modélisation de données

Une des principales tâches de notre projet consiste au dépouillement de sources d'archives. L'utilisation de l'outil informatique nécessite de réfléchir à la mise en place d'un modèle de données, afin de s'assurer que les informations collectées permettront de répondre aux questions soulevées par la recherche et qu'elles pourront donner lieu à l’ensemble des exploitations informatiques envisagées (exploration des réseaux professionnels, éditorialisation et exposition des données), tout en accordant une attention particulière à l’interopérabilité et la pérennisation dans les choix des technologies et des modèles documentaires employés.

Notre objet d'étude repose donc sur deux corpus : 

- un inventaire détaillé des expertises ;
- un dictionnaire prosopographique des experts.

### Un alignement vers les standards existants

Nous souhaitons, afin de respecter les normes de descriptions archivistiques et permettre le partage de nos données, nous aligner sur les standards en vigeur, et il est important de les avoir en tête dès le début, car ils peuvent influencer les modèles de données pour le traitement informatique des sources.

Par exemple, dans le cadre d'un partenariat envisagé avec les Archives nationales, ces dernières auront besoin de produire des instruments de recherche répondant à la normes ISAD-G pour la description archivistique. De même, en ce qui concerne la description des personnes et des corps constitués, il existe le standard de description ISAAR-CPF.

Grâce au soutien de la Mission GIP en 2016, qui a permis de mener une première étude sur deux années, 1726 et 1776, puis l'inscription du projet dans le cadre d'une ANR, nous avons notamment pu tester différents formats, "en condition", et ainsi mettre au jour certaines limitations.

L'équipe a commencé par élaborer deux fiches de saisie afin d'identifier les informations qui doivent être collectées lors du dépouillement.

La première fiche concerne les procès-verbaux d'expertise et on y retrouve :

- des éléments qui permettent l'identification du PV d'expertise (cote archivistique, numéro du dossier, descriptions physiques, date du procès-verbal) ; 
- des informations pertinentes pour le signalement des affaires, notamment l'adresse de l'édifice expertisé ;
- l'analyse de l'acte d'expertise (le type d’acte, l’institution requérante, le genre de l’expertise, gracieuse ou contentieuse, sa cause, les experts et les greffiers, les parties, enfin des éléments concernant les conclusions ou le dispositif de l’expertise et son coût).

La seconde fiche concerne les experts, et elle servira notre étude prosopographique.

#### Définition d’un modèle de dépouillement dédié

Dans le cadre d'un partenariat envisagé avec les Archives nationales, celles-ci ont besoin de pouvoir produire des instruments de recherche respectant la norme ISAD-G, qui s'exprime généralement au travers du format XML-EAD.

Ce format, qui présente l’avantage d’autoriser la description hiérarchique des fonds (fonds, sous-fonds, articles, dossiers, pièces, etc.). Et, à l’intérieur d’un même enregistrement, de répéter facilement les éléments de description ou de baliser des contenus en vue de l’indexation, nous semble être un support tout indiqué pour notre travail de dépouillement, tout en bénéficiant des avantages liés à l'utilisation des technologies XML, en particulier en ce qui concerne la portabilité des données.

Toutefois, ce format n'offre pas un niveau de description suffisant pour notre étude. Un des premier enjeux consistera donc à introduire des éléments de description plus pertinents, certainement sous un espace de nom différent, afin d'obtenir un modèle capable de répondre à nos interrogations.

Récemment, Laurent Romary s'est servi du langage de modélisation de la Text Encoding Initiative (TEI), ODD, pour reformuler le format EAD. Dans la mesure où nous prévoyons de transcrire avec la TEI certains documents pour mettre en lumière des cas d'expertise particulièrement interessants, l'utilisation d'ODD nous semble particulièrement pertinente pour établir notre modèle de données. Il permettra par la suite de générer des schémas XML Schema ou RelaxNG pour le contrôle de la saisie dans les éditeurs XML ou pour la validation dans le cadre de la construction d’une application XML. Cette la validation par un schéma nous permettra donc de contraindre nos pratiques d'encodage et d'atteindre ainsi une certaine constance dans notre saisie.

#### La gestion des données prosopographiques

En ce qui concerne les données prospographiques, nous avons souhaité mener au préalable un recensement des projets en prosopographie numérique, afin d'identifier les outils et les pratiques utilisés par la communauté des chercheurs. Malheureusement, nous n'avons trouvé que peu de réponses concernant les aspects techniques de ce champ.

En revanche, nous avons pu expérimenter certaines solutions. La norme ISAAR-CPF peut s'exprimer par le moyen du format XML-EAC-CPF. Ce dernier possède l'avantage d'autoriser la description des réseaux, ce qui correspond à l'une de nos problématiques, et d'être aligné sur le modèle conceptuel du CIDOC-CRM, nous permettant ainsi d'envisager assez facilement une publication de nos données dans des formats du web sémantique et leur exposition comme données liées (Linked Open Data).

Globalement, ce format nous permet d'encoder la quasi totalité des données prosopographiques que nous souhaitons relever. En revanche, son utilisation nous est apparue parfois forcée et peu naturelle, et nous avons identifié quelques lacunes pour notre objet, comme l'impossibilité de relier directement un élément d’information à sa source ou de gérer des informations contradictoires en fonction de leur provenance.

Notre recencement nous a également permis d'échanger avec des acteurs du domaine et de tirer parti de leur expérience. Laurent Romary, que nous avons déjà évoqué, nous a notamment aiguillés vers la TEI pour constituer notre base de données prosopographique, même si ce format nécessitera des adaptations pour répondre à notre problématique et un effort pour l'aligner vers une ontologie, afin d'exposer nos données sur le web sémantique.

Cette possibilité fait sens, car comme nous l'avons vu c'est un format que nous pourrons utliser par ailleurs et qui nous permettra de formuler l'intégralité de notre modèle de données, c'est-à-dire pour le dépouillement des PV d'expertise et pour notre prosopographie, avec un seul langage de modélisation,  ODD ; sans parler du fait que la TEI est un format que nous sommes plusieurs a avoir déjà utilisé dans le cadre d'autres projets.

### La création d’une application de saisie dynamique

Comme nous aurons essentiellement à faire avec des formats XML, nous nous acheminons vers le déploiement d’une base de données XML native pour la gestion des données. Cette technologie permet de facilement publier des site web et des métadonnées mais aussi de définir des requêtes dans la base à l’aide du langage XQuery.

Afin de faciliter la saisie du dépouillement, l’application proposera des formulaires ergonomiques qui pourront être développés avec XForms ou bien en JavaScript <!--à l’aide d’un framework comme AngularJS, React ou Vue.js-->. L’outil devrait aussi optionnellement supporter plusieurs utilisateurs et une journalisation des modifications. Toutefois, ce dernier aspect n’est pas jugé prioritaire compte-tenu du fait qu’il est possible d’organiser le travail de manière segmentaire.

Un important travail devra être consacré à l’ergonomie des interfaces afin de faciliter la saisie. La plate-forme devra également permettre un fonctionnement dans un environnement collaboratif et tirer parti des technologies XML pour l’application de contrôles et  de validation.

### L’exposition et le partage des données

Afin de faciliter la réutilisation des contenus produits dans le cadre de la recherche, il conviendra de privilégier l’emploi de modèles partagés par d’autres acteurs. Le choix initial des formats archivistiques répondait bien, de prime abord, à ces prérequis d’autant qu’EAC-CPF avait déjà fait l’objet d’un mapping vers l’ontologie patrimoniale promue par l’ICOM, CIDOC-CRM. L’obligation de développer nos propres modèles pour mieux répondre aux besoins de la recherche ne doit pas impliquer pour autant l’abandon des enjeux d’interopérabilité.

Quelques soient les modèles développés, ceux-ci seront conçus en compatibilité avec les modèles archivistiques EAD et EAC-CPF de sorte à pouvoir être convertis. Surtout, les choix de modélisation devront avoir recours à des ontologies bien documentées dans le monde de l’information historique. Nous sommes actuellement en train de procéder au recensement de ces modèles et à leur comparaison, notamment BIO-CRM, qui est une extension du CIDOC-CRM pour les aspects biographiques, et Symogih pour les données historiques. Par la richesse de structuration, les données liées présentent notamment un fort potentiel pour l’analyse de réseau que nous essayerons d’exploiter le plus possible.

L’utilisation de XQuery et de RESTXQ permettra notamment de proposer un accès REST aux entités sous la forme de jeux de données liées conformes aux standards du web sémantique. Plusieurs formats seront ainsi disponibles au format RDF : N3, RDF+XML, Turtle, etc. Ces jeux de données pourront faire l’objet de diverses représentation et visualisation en utilisant des bibliothèques informatiques dédiés.