xquery version "3.0";
module namespace xpr.xpr = "xpr.xpr";
(:~
 : This xquery module is an application for xpr
 :
 : @author emchateau & sardinecan (ANR Experts)
 : @since 2019-01
 : @licence GNU http://www.gnu.org/licenses
 : @version 0.2
 :
 : xpr is free software: you can redistribute it and/or modify
 : it under the terms of the GNU General Public License as published by
 : the Free Software Foundation, either version 3 of the License, or
 : (at your option) any later version.
 :
 :)

import module namespace G = 'xpr.globals' at './globals.xqm' ;
import module namespace xpr.mappings.html = 'xpr.mappings.html' at './mappings.html.xqm' ;
import module namespace xpr.models.xpr = 'xpr.models.xpr' at './models.xpr.xqm' ;
import module namespace xpr.models.networks = 'xpr.models.networks' at './models.networks.xqm' ;
import module namespace xpr.models.statistics = 'xpr.models.statistics' at './models.statistics.xqm' ;
import module namespace xpr.autosave = 'xpr.autosave' at './autosave.xqm' ;
import module namespace xpr.manifest = 'xpr.manifest' at './manifest.xqm' ;
import module namespace Session = 'http://basex.org/modules/session';
import module namespace functx = "http://www.functx.com";

declare namespace rest = "http://exquery.org/ns/restxq" ;
declare namespace file = "http://expath.org/ns/file" ;
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization" ;
declare namespace db = "http://basex.org/modules/db" ;
declare namespace web = "http://basex.org/modules/web" ;
declare namespace update = "http://basex.org/modules/update" ;
declare namespace perm = "http://basex.org/modules/perm" ;
declare namespace user = "http://basex.org/modules/user" ;
declare namespace session = 'http://basex.org/modules/session' ;
declare namespace http = "http://expath.org/ns/http-client" ;
declare namespace json = "http://basex.org/modules/json" ;

declare namespace ev = "http://www.w3.org/2001/xml-events" ;
(:declare namespace eac = "eac" ;:)
declare namespace eac = "https://archivists.org/ns/eac/v2" ;
declare namespace rico = "rico" ;

declare namespace map = "http://www.w3.org/2005/xpath-functions/map" ;
declare namespace xf = "http://www.w3.org/2002/xforms" ;
declare namespace xlink = "http://www.w3.org/1999/xlink" ;

declare namespace xpr = "xpr" ;
declare default element namespace "xpr" ;
declare default function namespace "xpr.xpr" ;

declare default collation "http://basex.org/collation?lang=fr" ;

(:~
 : This resource function defines the application root
 : @return redirect to the home page or to the install
 :)
declare 
  %rest:path("/xpr")
  %output:method("xml")
function index() {
  if (db:exists("xpr"))
    then web:redirect("/xpr/home") 
    else web:redirect("/xpr/install") 
};

(:~
 : This resource function defines the application root
 : @return redirect to the home page or to the install
 :)
declare
  %rest:path("/")
  %output:method("xml")
function root() {
    web:redirect("/xpr/about")
};

(:~
 : This resource function install
 : @return create the db
 : @todo create the prosopo db
 :)
declare 
  %rest:path("/xpr/install")
  %output:method("xml")
  %updating
function install() {
  if (db:exists("xpr")) 
    then (
      update:output("La base xpr existe déjà, voulez-vous l’écraser ?")
     )
    else (
      update:output("La base a été créée"),
      db:create( "xpr", <xpr/>, "z1j.xml", map {"chop" : fn:false()} )
      )
};

(:~
 : This resource function export the z1j database into the base-dir
 : @return redirect to the expertises list
 : @todo change the export path
 :)
declare
  %rest:path("/xpr/export")
function z1jExport(){
  db:export("xpr", '/sites/expertdb/resource/data/db/', map { 'method': 'xml' }),
  web:redirect("/xpr/expertises/view")
};

(:~
 : This resource function defines the application home
 : @return redirect to the expertises list
 :)
declare 
  %rest:path("/xpr/home")
  %output:method("xml")
function home() {
  web:redirect("/xpr/expertises/view")
};

(:~
 : This resource function creates the about page
 : @return an about page
 :)
declare
  %rest:path("/xpr/about")
  %output:method("html")
function about() {
  let $content := map {
      'title' : 'À propos de l’ANR Experts',
      'data' :
      <div>
        <section class="alternate">
        <br/>
        <br/>
        <h2>Pratiques des savoirs entre jugement et innovation. Experts, expertises du bâtiment, Paris 1690-1790 – ANR EXPERTS</h2>
        <p>Notre projet vise à examiner, à partir d’un secteur économique majeur — celui du bâtiment à l’époque moderne —, le mécanisme de l’expertise : comment la langue technique régulatrice des experts s’impose à la société, comment leur compétence se convertit en autorité, voire parfois en « abus d’autorité » ? L’existence d’un fonds d’archives exceptionnel (AN Z<sup>1J</sup>) qui conserve l’ensemble des procès-verbaux d’expertise du bâtiment parisien de 1643 à 1792 nous permet de lancer une enquête pluridisciplinaire d’envergure sur la question de l’expertise qui connaît, à partir de 1690, un tournant particulier. En effet, les experts, autrefois uniquement gens de métiers, se divisent en deux branches exerçant deux activités concurrentes, parfois complémentaires : l’architecture et l’entreprise de construction.</p>
        <p>La base de notre travail consistera d’abord à établir parallèlement deux corpus : d’une part, un dictionnaire prosopographique des 234 experts exerçant de 1690 à 1790 ; d’autre part, l’inventaire et l’analyse des procès-verbaux d’expertise sur la même période. Au regard de l’immensité du fond, nous travaillerons sur un groupe de près de 10 000 expertises par le biais d’un sondage au 1/10<sup>e</sup> sur les dix années de 1696 à 1786, espacées chacune de 10 ans. Chaque expertise sera inventoriée, indexée, numérisée et analysée dans le détail. L’ensemble fera l’objet d’une étude sérielle sur le siècle parcouru, mais surtout d’un travail approfondi sur son contenu. Deux questions seront résolues : 1° Comment la décision de l’expert se prend-elle ? Quels savoirs y sont convoqués ? 2° Comment ces experts parviennent à innover dans domaine de leur compétence ? Le projet correspond au moins à trois enjeux contemporains.</p>
        <p>Le premier concerne le rapport au risque et à l’innovation sociale. Comment affronter des situations à risque permet d’innover techniquement, voire socialement ? La confrontation à des incertitudes ouvre des possibilités de résoudre des conflits entre des communautés opposées. Tenant compte de la partition des fonctions d’experts, la mission d’expertise se différencie-t-elle selon la qualité de son auteur ? Les experts en viennent, souvent grâce à l’expertise, à innover dans le champ d’activité qui est le leur. Ainsi, pourquoi l’expertise induit-elle l’innovation ?</p>
        <p>Le second concerne la part du droit dans la prise de décision démocratique. Comment le droit peut-il servir entre les mains de non-juristes ? La diffusion des principes du droit dans la vie citoyenne permet un usage de ces derniers dans la vie publique mais également dans des domaines de la vie privée. Dans le cadre de notre projet, comment et pourquoi des experts, non juristes mais au fait du droit, argumenteront en droit et persuaderont le juge de leur position ?</p>
        <p>Le troisième concerne la régulation des valeurs de biens. Quels critères faut-il mettre en avant pour échafauder une hiérarchie des choses ? Une stricte normalisation objective de ces critères peut ne pas apparaître souhaitable face aux lois du marché qui par leur rigueur nécessiteraient un contrebalancement de règles subjectivées. Précisément, comment les experts du bâtiment ont-ils mis en place les critères objectifs et subjectifs d’estimation de la valeur des biens immobiliers ?</p>
        <p>Rejoignant l’idée d’« abus d’autorité » de l’expert, le fait que plusieurs types de savoirs, et plusieurs groupes sociaux, partagent l’expertise, diminuerait-il le risque d’abus d’autorité et au-delà le risque technique en général ?</p>
        <p>Les résultats de cette recherche sont présentés dans une base de connaissances collaborative accueillie sur un site dédié sur lequel l’ensemble des corpus seront accessibles à la communauté des chercheurs. L’analyse d’<em>exempla</em> fera l’objet d’une éditorialisation particulière sous forme d’exposition virtuelle pour le grand public. La synthèse de nos résultats sera consignée dans un ouvrage et deux rencontres nationale et internationale viendront clore le projet.</p></section>
        <section class="alternate">
          <div>
            <h2>Responsables du projet</h2>
            <ul>
              <li>Robert Carvais, CNRS (UMR 7074)</li>
              <li>Emmanuel Chateau-Dutier, Université de Montréal (CRIHN)</li>
              <li>Valérie Nègre, Université Paris I (UMR 8066)</li>
              <li>Michela Barbot, CNRS (UMR 8533)</li>
            </ul>
          </div>
          <div>
            <h2>Co-chercheurs</h2>
            <ul>
              <li>Juliette Hernu-Belaud (Chercheuse post-doctorale ANR Experts)</li>
              <li>Léonore Losserand (Chercheuse post-doctorale ANR Experts)</li>
              <li>Yvon Plouzennec (Chercheur post-doctorale ANR Experts)</li>
            </ul>
          </div>
          <div>
            <h2>Ingénieur d’étude</h2>
            <ul>
              <li>Josselin Morvan</li>
            </ul>
          </div>
          <div>
            <h2>Partenaires</h2>
            <ul>
              <li><a href="https://anr.fr/Projet-ANR-17-CE26-0006">Agence nationale de recherche, projet ANR-17-CE26-0006</a></li>
              <li><a href="http://www.gip-recherche-justice.fr">Mission de recherche Droit &amp; Justice (2015-2017)</a></li>
              <li><a href="https://www.archives-nationales.culture.gouv.fr">Archives Nationales de France</a></li>
              <li>Ce projet a bénéficié du soutien du <a href="https://sites.haa.pitt.edu/na-dah/">Getty Advanced Workshop on Network Analysis and Digital Art History (NA+DAH)</a></li>
            </ul>
          </div>
        </section>
      </div>
    }
    let $outputParam := map {
      'layout' : "template.xml"
      (: 'mapping' : xpr.mappings.html:listXpr2html(map:get($content, 'data'), map{}) :)
    }
    return xpr.models.xpr:wrapper($content, $outputParam)
};

(:~ Login page (visible to everyone). :)
declare
  %rest:path("xpr/meteo")
  %output:method("html")
function meteo() {
  let $expertises := getExpertises()
  let $biographies := getBiographies()
  let $inventories := getInventories()
  return
    <html>
      <head>
        <title>!xpr¡</title>
        <meta charset="UTF-8"/>
      </head>
      <body>
        <div>
          <h1>Météo des experts</h1>
          <div class="expertises">
            <h2>Expertises</h2>
            <ul>
              <li>{ fn:count($expertises/expertise) || ' expertises enregistrées dans la base de données' }</li>
              <li>{ fn:count($expertises/expertise[descendant::localControl[@localType='detailLevel']/term[fn:normalize-space(.) = 'completed']]) || ' expertises complètes' }</li>
              <li>{ fn:count($expertises/expertise[descendant::localControl[@localType='detailLevel']/term[fn:normalize-space(.) = 'in progress']]) || ' expertises en cours de dépouillement' }</li>
              <li>{ fn:count($expertises/expertise[descendant::localControl[@localType='detailLevel']/term[fn:normalize-space(.) = 'to revise']]) || ' expertises à revoir' }</li>
              <li>{ fn:count(fn:distinct-values($expertises/expertise/descendant::idno[@type='unitid'])) || ' dossiers dépouillés' }
                <ul>{
                  for $unitid in fn:distinct-values($expertises/expertise/descendant::idno[@type='unitid'])
                  return <li>{ fn:count($expertises/expertise/descendant::idno[@type='unitid'][. = $unitid]) || ' expertises cotées "' || $unitid || '"' }</li>
                }</ul>
              </li>
            </ul>
          </div>
          <div class="prosopographie">
            <h2>Prosopographie</h2>
            <ul>
              <li>{fn:count($biographies/eac:eac-cpf) || ' fiches prosopographiques enregistrées dans la base de données'}
                <ul>{
                  for $entityType in fn:distinct-values($biographies/descendant::eac:identity/@localType)
                  return <li>{ fn:count($biographies/eac:eac[descendant::eac:identity[@localType = $entityType]]) || ' entités ayant pour qualité "' ||$entityType || '"' }</li>
                }</ul>
              </li>
              <li>{ fn:count($biographies/eac:eac[descendant::eac:localControl[@localType='detailLevel']/eac:term[fn:normalize-space(.) = 'completed']]) || ' fiches complètes' }</li>
              <li>{ fn:count($biographies/eac:eac[descendant::eac:localControl[@localType='detailLevel']/eac:term[fn:normalize-space(.) = 'in progress']]) || ' fiches en cours de dépouillement' }</li>
              <li>{ fn:count($biographies/eac:eac[descendant::eac:localControl[@localType='detailLevel']/eac:term[fn:normalize-space(.) = 'to revise']]) || ' fiches à revoir' }</li>
            </ul>
          </div>
          <div class="iad">
            <h2>Inventaires après-décès</h2>
            <ul>
              <li>{ fn:count($inventories/inventory) || ' inventaires après-décès enregistrés dans la base de données' }</li>
              <li>{ fn:count($inventories/inventory[descendant::localControl[@localType='detailLevel']/term[fn:normalize-space(.) = 'completed']]) || ' inventaires complets' }</li>
              <li>{ fn:count($inventories/inventory[descendant::localControl[@localType='detailLevel']/term[fn:normalize-space(.) = 'in progress']]) || ' inventaires en cours de dépouillement' }</li>
              <li>{ fn:count($inventories/inventory[descendant::localControl[@localType='detailLevel']/term[fn:normalize-space(.) = 'to revise']]) || ' inventaires à revoir' }</li>
            </ul>
          </div>
        </div>
      </body>
    </html>
};

(:~
 : this function defines a static files directory for the app
 : @param $file file or unknown path
 : @return binary file
 :)
declare
  %rest:path('xpr/files/{$file=.+}')
function xpr.xpr:file($file as xs:string) as item()+ {
  let $path := file:base-dir() || 'files/' || $file
  return
    (
      web:response-header( map {'media-type' : web:content-type($path)}),
      file:read-binary($path)
    )
};

(:~
 : this variable defines style for status & query functions
 : @rmq to be removed
 :)
declare variable $xpr.xpr:style :=
  <style>
    body {{
      font-family: sans-serif; /* 1 */
      background-color: #fff;
      color: #E73E0D;
    }}
    html {{
      line-height: 1.15; /* 2 */
      -ms-text-size-adjust: 100%; /* 3 */
      -webkit-text-size-adjust: 100%; /* 3 */
    }}
    main {{
      width: 95%;
      margin:auto;
    }}
    table {{
      display: inline;
      border-collapse:collapse;
    }}
    thead td {{
      background-color: #E73E0D;
      color:#fff;
      min-width:50px;
    }}
    div:not(.detail) thead td {{
      height:400px;
      writing-mode:vertical-rl;
    }}
    td {{
      border: 0.15em solid ;
    }}
    tbody td {{
      text-align: center;
    }}
    main div {{
      margin-bottom: 3em;
    }}
  </style>;

(:~
 : This resource function lists all the expertises
 : @return an ordered list of expertises in xml
 :)
declare 
  %rest:path("/xpr/expertises")
  %rest:produces('application/xml')
  %output:method("xml")
function getExpertises() {
  <expertises>{ db:open('xpr', 'xpr/expertises') }</expertises>
};

(:~
 : This resource function edits a new expertise
 : @return an xforms to edit an expertise
:)
declare
  %rest:path("xpr/expertises/new")
  %output:method("xml")
  %perm:allow("expertises")
function newExpertise() {
  let $content := map {
    'instance' : '',
    'model' : ('xprExpertiseModel.xml', 'xprAutosaveModel.xml'),
    'trigger' : 'xprExpertiseTrigger.xml',
    'form' : 'xprExpertiseForm.xml'
  }
  let $outputParam := map {
    'layout' : "template.xml"
  }
  return
    (processing-instruction xml-stylesheet { fn:concat("href='", $G:xsltFormsPath, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    xpr.models.xpr:wrapper($content, $outputParam)
    )
};

(:~
 : This function creates new expertises
 : @param $param content to insert in the database
 : @param $refere the callback url
 : @return update the database with an updated content and an 200 http
 : @bug change of cote and dossier doesn’t work
 :)
declare
  %rest:path("xpr/expertises/put")
  %output:method("xml")
  %rest:header-param("Referer", "{$referer}", "none")
  %rest:PUT("{$param}")
  %perm:allow("expertises", "write")
  %updating
function putExpertise($param, $referer) {
  let $db := db:open("xpr")
  let $user := fn:normalize-space(user:list-details(Session:get('id'))/@name)
  return
    if (fn:ends-with($referer, 'modify')) then
      let $location := fn:analyze-string($referer, 'xpr/expertises/(.+?)/modify')//fn:group[@nr='1']
      let $id := fn:replace(fn:lower-case($param/expertise/sourceDesc/idno[@type="unitid"]), '/', '-') || 'd' || fn:format-integer($param/expertise/sourceDesc/idno[@type="item"], '000') || $param/expertise/sourceDesc/idno[@type="supplement"]
      let $param :=
        copy $d := $param
        modify(
          replace value of node $d/expertise/@xml:id with $id,
          replace value of node $d/expertise/control/maintenanceHistory/maintenanceEvent[1]/agent with $user,
          for $place at $i in $d/expertise/description[categories/category[@type="estimation"]]/places/place
          let $idPlace := fn:generate-id($place)
          where $place[fn:not(@xml:id)]
          return(
            insert node attribute xml:id {$idPlace} into $place,
            insert node attribute ref {fn:concat('#', $idPlace)} into $d/expertise/description/conclusions/estimates/place[$i]
          )
        )
        return $d
      return(
      (:
        @rmq avec db:replace, l'ordre des arguments est à l'inverse de db:add : d'abord l'ancien fichier, puis le nouveau
        avec Basex 10.x, db:replace devient db:put, et l'ordre est aligné avec db:add
      :)
        db:replace('xpr', 'xpr/expertises/'|| $location ||'.xml', $param),
        db:rename("xpr", 'xpr/expertises/'|| $location ||'.xml', 'xpr/expertises/'|| $id ||'.xml'),
        update:output((
          <rest:response>
            <http:response status="200" message="test">
              <http:header name="Content-Language" value="fr"/>
              <http:header name="Content-Type" value="text/plain; charset=utf-8"/>
            </http:response>
          </rest:response>,
          <result>
            <id>{$id}</id>
            <message>La ressource a été modifiée.</message>
            <url></url>
          </result>
        ))
      )
    else
      let $id := fn:replace(fn:lower-case($param/expertise/sourceDesc/idno[@type="unitid"]), '/', '-') || 'd' || fn:format-integer($param/expertise/sourceDesc/idno[@type="item"], '000') || $param/expertise/sourceDesc/idno[@type="supplement"]
      let $param :=
        copy $d := $param
        modify(
          insert node attribute xml:id {$id} into $d/*,
          replace value of node $d/expertise/control/maintenanceHistory/maintenanceEvent[1]/agent with $user,
          for $place at $i in $d/expertise/description[categories/category[@type="estimation"]]/places/place
          let $idPlace := fn:generate-id($place)
          return(
            insert node attribute xml:id {$idPlace} into $place,
            insert node attribute ref {fn:concat('#', $idPlace)} into $d/expertise/description/conclusions/estimates/place[$i]
          )
        )
        return $d
      return(
        db:add('xpr', $param, 'xpr/expertises/'|| $id ||'.xml'),
        update:output((
          <rest:response>
            <http:response status="200" message="test">
              <http:header name="Content-Language" value="fr"/>
            </http:response>
          </rest:response>,
          <result>
            <id>{$id}</id>
            <message>La ressource a été créée.</message>
            <url></url>
          </result>
        ))
      )
};

(:~
 : This resource function lists all the expertises
 : @return an ordered list of expertises in html
 :)
declare
  %rest:path("/xpr/expertises/view")
  %rest:produces('application/html')
  %rest:query-param("start", "{$start}", 1)
  %rest:query-param("count", "{$count}", 50)
  %output:method("html")
  %output:html-version('5.0')
function getExpertisesHtml($start as xs:integer, $count as xs:integer) {
 let $content := map {
    'title' : 'Liste des expertises',
    'data' : getExpertises()
  }
  let $outputParam := map {
    'layout' : "listeExpertise.xml",
    'mapping' : xpr.mappings.html:listXpr2html(map:get($content, 'data'), map{})
  }
  return xpr.models.xpr:wrapper($content, $outputParam)
};

(:~
 : This resource function lists all the expertises
 : @return an ordered list of expertises in json
 : @todo to develop
 :)
declare
  %rest:path("/xpr/expertises/json")
  %rest:POST("{$body}")
  %rest:produces('application/json')
  %output:media-type('application/json')
  %output:method('json')
function getExpertisesJson($body) {
  let $body := json:parse( $body, map{"format" : "xquery"})
  let $db := db:open('xpr')
  let $expertises := getExpertises()
  let $prosopo := $db/xpr/bio
  (:map:merge(for $x in //emp return map{$x!name : $x!@salary}):)
  let $dateCount := map:merge(
    for $group in $expertises/expertise
    for $year in $group/sourceDesc/unitdate
    group by $year
    return map { $year : fn:count($group/self::node()) }
  )
  let $experts := map:merge(
    for $expert in $prosopo/eac:eac[descendant::eac:otherEntityType[fn:normalize-space(eac:term)='expert']]/@xml:id
    return map { $expert : xpr.mappings.html:getEntityName($expert) }
  )
  let $meta := map {
      'start' : $body?start,
      'count' : $body?count,
      'totalExpertises' : fn:count($expertises/expertise),
      'datesCount' : $dateCount,
      'experts' : $experts
  }
  let $content := array{
    for $expertise in fn:subsequence($expertises/expertise, $body?start, $body?count)
    return map{
      'id' : fn:normalize-space($expertise/@xml:id),
      'dates' : array{
        fn:sort($expertise//sessions/date/fn:normalize-space(@when[. castable as xs:date]))
      },
      'experts' : array{ for $expert in $expertise//experts/expert[fn:normalize-space(@ref)!=''] return xpr.mappings.html:getEntityName($expert/fn:substring-after(@ref, '#'))},
      'expertsId' : array{
        $expertise//participants/experts/expert[fn:normalize-space(@ref)!='']/fn:normalize-space(@ref)
      },
      'greffiers' : array{
        $expertise//clerks/clerk/persName/fn:string-join(*, ', ')
      },
      'case' : $expertise//procedure/*[fn:local-name() = 'case']/fn:normalize-space(),
      'thirdParty' : if($expertise//experts/expert[@context='third-party']) then 'true' else 'false'
    }
  }
  return map{
    "meta": $meta,
    "content": $content
  }
};

(:~
 : This resource function lists all the expertises
 : @return an ordered list of expertises with saxonjs
 :)
declare
  %rest:path("/xpr/expertises/saxon")
  %rest:produces('application/html')
  %output:method("html")
function getExpertisesSaxon() {
  let $content := map {
    'data' : db:open('xpr', 'xpr/expertises'),
    'trigger' : '',
    'form' : ''
  }
  let $outputParam := map {
    'layout' : "listeExpertiseSaxon.xml"
  }
  return xpr.models.xpr:wrapper($content, $outputParam)
};

(:~
 : This resource function lists all the expertises
 : @return an ordered list of expertises with xforms
 :)
declare 
  %rest:path("/xpr/expertises/xforms")
  %rest:produces('text/html')
  %output:method("xml")
function getExpertisesXforms() {
  let $content := map {
    'instance' : '',
    'model' : 'xprListModel.xml',
    'trigger' : '',
    'form' : 'xprList.xml'
  }
  let $outputParam := map {
    'layout' : "template.xml"
  }
  return(
    processing-instruction xml-stylesheet { fn:concat("href='", $G:xsltFormsPath, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    xpr.models.xpr:wrapper($content, $outputParam)
  )
};

(:~
 : This resource function lists all the expertises
 : @return an ordered table of expertises in html
 :)
declare
  %rest:path("/xpr/expertises/table")
  (:%rest:POST("{$body}"):)
  %rest:produces('application/html')
  %output:method("html")
function getExpertisesTable() {
  (: let $body := json:parse( $body, map{"format" : "xquery"}) :)
  let $db := db:open('xpr')
  let $expertises := $db/xpr/expertises
  let $prosopo := $db/xpr/bio
  (:map:merge(for $x in //emp return map{$x!name : $x!@salary}):)
  let $dateCount := map:merge(
    for $group in $expertises/expertise
    for $year in $group/sourceDesc/unitdate
    group by $year
    return map { $year : fn:count($group/self::node()) }
  )
  let $experts := map:merge(
    for $expert in $prosopo/eac:eac[descendant::eac:otherEntityType[fn:normalize-space(eac:term)='expert']]/@xml:id
    return map { $expert : xpr.mappings.html:getEntityName($expert) }
  )
  (:let $meta := map {
      'start' : $body?start,
      'count' : $body?count,
      'totalExpertises' : fn:count($expertises/expertise),
      'datesCount' : $dateCount,
      'experts' : $experts
  }:)
  let $content :=
    <table>
      <tbody>
        <tr>
          <th>id</th>
          <th>Dates</th>
          <th>Experts</th>
          <th>Greffiers</th>
          <th>Cas</th>
          <th>Tiers expertise</th>
        </tr>{
        for $expertise in $expertises/expertise
        let $dates := fn:sort($expertise//sessions/date/fn:normalize-space(@when[. castable as xs:date]))
        let $experts :=
          for $expert in $expertise//experts/expert[fn:normalize-space(@ref)!='']
          return array{
            $expert/fn:substring-after(@ref, '#'),
            xpr.mappings.html:getEntityName($expert/fn:substring-after(@ref, '#'))
          }

        let $clerks :=
          for $clerk in $expertise//clerks/clerk[fn:normalize-space(@ref)!='']
          return array{
            $clerk/fn:substring-after(@ref, '#'),
            xpr.mappings.html:getEntityName($clerk/fn:substring-after(@ref, '#'))
          }
        return
          <tr>
            <td><a href="/xpr/expertises/{fn:normalize-space($expertise/@xml:id)}/view">{fn:normalize-space($expertise/@xml:id)}</a></td>
            <td>{fn:string-join($dates, ' ; ')}</td>
            <td>{for $expert at $i in $experts return (<a href="/xpr/biographies/{array:get($expert, 1)}/view">{array:get($expert, 2)}</a>, if(fn:count($experts) > $i) then ' ; ')}</td>
            <td>{for $clerk at $i in $clerks return (<a href="/xpr/biographies/{array:get($clerk, 1)}/view">{array:get($clerk, 2)}</a>, if(fn:count($clerk) > $i) then ' ; ')}</td>
            <td>{$expertise//procedure/*[fn:local-name() = 'case']/fn:normalize-space()}</td>
            <td>{if($expertise//experts/expert[@context='third-party']) then 'true' else 'false'}</td>
          </tr>
        }
      </tbody>
    </table>

  return $content
};

(:~
 : This resource function lists all the expertises’ ids
 : @return an xml list the expertises with theire @xml:id
 :)
declare
  %rest:path("/xpr/expertises/ids")
  %rest:produces('application/xml')
  %output:method("xml")
function getExpertisesId() {
  <expertises>{
    for $expertise in getExpertises()/expertise
    return <expertise xmlns="xpr" xml:id="{$expertise/@xml:id}"></expertise>
  }</expertises>
};

(:~
 : This resource function lists all the expertises of an expert
 : @return an ordered list of expertises in xml
 : @todo check for multiple value for expert
 :)
declare
  %rest:path("/xpr/expertises/experts")
  %rest:produces('application/xml')
  %output:method("xml")
  %rest:query-param('ids', '{$ids}', 'xpr0001')
function getExpertises($ids as xs:string) {
  if($ids) then
    <expertises>{ db:open('xpr', 'xpr/expertises')/*:expertise[descendant::*:expert/@ref='#'||$ids] }</expertises>
  else
    <expertises>{ db:open('xpr', 'xpr/expertises') }</expertises>
};

(:~
 : This resource function returns an expertise item
 : @param $id the expertise id
 : @return an expertise item in xml (xpr)
 :)
declare 
  %rest:path("xpr/expertises/{$id}")
  %output:method("xml")
function getExpertise($id) {
  db:open('xpr', 'xpr/expertises')/expertise[@xml:id=$id]
};

(:~
 : This resource function modify an expertise item
 : @param $id the expertise id
 : @return an xforms to edit the expertise
 :)
declare
  %rest:path("xpr/expertises/{$id}/modify")
  %output:method("xml")
  %perm:allow("expertises")
function modifyExpertise($id) {
  let $content := map {
    'instance' : $id,
    'path' : 'expertises',
    'model' : ('xprExpertiseModel.xml', 'xprAutosaveModel.xml'),
    'trigger' : 'xprExpertiseTrigger.xml',
    'form' : 'xprExpertiseForm.xml'
  }
  let $outputParam := map {
    'layout' : "template.xml"
  }
  return(
    processing-instruction xml-stylesheet { fn:concat("href='", $G:xsltFormsPath, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    xpr.models.xpr:wrapper($content, $outputParam)
  )
};

(:~
 : This resource function returns an expertise item
 : @param $id the expertise id
 : @return an expertise item in html
 : @todo use html templating
 :)
declare
  %rest:path("xpr/expertises/{$id}/view")
  %rest:produces('application/html')
  %output:method("html")
function getExpertiseHtml($id) {
  let $content := map {
    'data' : getExpertise($id),
    'trigger' : '',
    'form' : ''
  }
  let $outputParam := map {
    'layout' : "ficheExpertise.xml",
    'mapping' : xpr.mappings.html:xpr2html(map:get($content, 'data'), map{})
  }
  return xpr.models.xpr:wrapper($content, $outputParam)
};

(:~
 : This resource function returns an expertise item
 : @param $id the expertise id
 : @return an expertise item in json
 : @todo to develop
 :)
declare
  %rest:path("xpr/expertises/{$id}/json")
  %rest:produces('application/json')
  %output:media-type('application/json')
  %output:method('json')
function getExpertiseJson($id) {
  let $expertise := getExpertise($id)
  let $meta := map{
    'id' : fn:normalize-space($expertise/@xml:id),
    'cote' : $expertise/sourceDesc/idno[@type='unitid'] => fn:string(),
    'dossier' : $expertise/sourceDesc/idno[@type='item'] => fn:string(),
    'unitdate' : $expertise/sourceDesc/unitdate => fn:string(),
    'facsimile' : map {
        'start' : $expertise/sourceDesc/facsimile/@from => fn:normalize-space(),
        'end' : $expertise/sourceDesc/facsimile/@to => fn:normalize-space()
      },
    'supplement' : $expertise/sourceDesc/idno[@type='supplement'] => fn:string(),
    'extent' : $expertise/sourceDesc/physDesc/extent => fn:normalize-space(),
    'sketch' : $expertise/sourceDesc/physDesc/extent/@sketch => fn:normalize-space(),
    'appendices' : if($expertise/sourceDesc/physDesc/extent/appendices/appendice[fn:normalize-space(.)!='']) then array{
      for $appendice in $expertise/sourceDesc/physDesc/extent/appendices/appendice[fn:normalize-space(.)!='']
      return map{
        'type' : array{
          for $type in $appendice/type
          return $type => fn:normalize-space()
        },
        'extent' : $appendice/extent => fn:normalize-space(),
        'description' : $appendice/desc => fn:normalize-space(),
        'note' : $appendice/note => fn:normalize-space()
      }
     },
    'maintenance' : if($expertise/control/maintenanceHistory/maintenanceEvent[fn:normalize-space(.)!='']) then array {
      for $maintenanceEvent in $expertise/control/maintenanceHistory/maintenanceEvent[fn:normalize-space(.)!='']
      return xpr.mappings.html:getMaintenanceEvent($maintenanceEvent, map{})
    }
  }
  let $content := map{
    'addresses' : if($expertise/description/places/place[fn:normalize-space(.)!='']) then array{
      for $place in $expertise/description/places/place[fn:normalize-space(.)!='']
      return xpr.mappings.html:getAddress($place, map{}) => fn:string-join() => fn:normalize-space()
    },
    'dates' : if($expertise//sessions/date[fn:normalize-space(@when)!='']) then array{
      fn:sort($expertise//sessions/date/fn:normalize-space(@when[. castable as xs:date]))
    },
    'sessions' : if($expertise/description/sessions/date[fn:normalize-space(@type)!='' or fn:normalize-space(@when)!='']) then array{
    (:@rmq : use array instead of map:merge because the latter combine duplicate keys:)
      for $session in $expertise/description/sessions/date[fn:normalize-space(@type)!='' or fn:normalize-space(@when)!='']
      return map{
        fn:normalize-space($session/@type) : fn:normalize-space($session/@when)
      }
    },
    'designation' : if($expertise/description/categories/designation[@rubric='true'])
      then $expertise/description/categories/designation => fn:normalize-space() || ' (en rubrique)'
      else $expertise/description/categories/designation => fn:normalize-space(),
    'categories' : if($expertise/description/categories/category[fn:normalize-space(.)!='']) then array{
      for $category in $expertise/description/categories/category[fn:normalize-space(.)!='']
      return $category => fn:normalize-space()
    },
    'framework' : if($expertise/description/procedure/framework[fn:normalize-space(.)!='']) then $expertise/description/procedure/framework/@type || ' - ' || fn:normalize-space($expertise/description/procedure/framework) else '',
    'origination' : $expertise/description/procedure/origination => fn:normalize-space(),
    'sentences' : if($expertise/description/procedure/sentences/sentence[fn:normalize-space(.)!='']) then array{
      for $sentence in $expertise/description/procedure/sentences/sentence[fn:normalize-space(.)!='']
      return map {
        'orgName' : $sentence/orgName => fn:normalize-space(),
        'dates' : if($sentence/date[fn:normalize-space(@when)!='']) then array{
          for $date in $sentence/date[fn:normalize-space(@when)!='']
          return $date/@when => fn:normalize-space()
        }
      }
    },
    'case' : $expertise/description/procedure/case => fn:normalize-space(),
    'objects' : if($expertise/description/procedure/objects/object[fn:normalize-space(.)!='']) then array{
      for $object in $expertise/description/procedure/objects/object[fn:normalize-space(.)!='']
      return $object => fn:normalize-space()
    },
    'experts' : if($expertise//experts/expert[fn:normalize-space(@ref)!='']) then array{
      for $expert in $expertise//experts/expert[fn:normalize-space(@ref)!='']
      return map{
        'id' : $expert/fn:substring-after(@ref, '#'),
        'name' : xpr.mappings.html:getEntityName($expert/fn:substring-after(@ref, '#')),
        (:'quality' : ($expert/title[fn:normalize-space(.)!=''], $context, $appointment) => fn:string-join(', ') || '.',:)
        'title' : $expert/title => fn:normalize-space(),
        'context' : $expert/@context => fn:normalize-space(),
        'appointment' : $expert/@appointment => fn:normalize-space()
      }
    },
    'clerks' : if($expertise/description/participants/clerks/clerk[fn:normalize-space(.)!='']) then array{
      for $clerk in $expertise/description/participants/clerks/clerk[fn:normalize-space(.)!='']
      return fn:string-join($clerk/persName/*[fn:normalize-space(.)!='']/functx:capitalize-first(fn:normalize-space()), ', ')
    },
    'parties' : if($expertise/description/participants/parties/party[fn:normalize-space(.)!='']) then array {
      for $party in $expertise/description/participants/parties/party[fn:normalize-space(.)!='']
      return map{
        'role' : $party/@role => fn:normalize-space(),
        'presence' : $party/@presence => fn:normalize-space(),
        'intervention' : $party/@intervention => fn:normalize-space(),
        'persons' : if($party/person[fn:normalize-space(.)!='']) then array{
          for $person in $party/person[fn:normalize-space(.)!='']
          return map{
            'name' : fn:string-join($person/persName/*[fn:normalize-space(.)!='']/functx:capitalize-first(fn:normalize-space()), ', '),
            'occupation' : $person/occupation => fn:normalize-space()
          }
        },
        'status' : $party/status => fn:normalize-space(),
        'expert' : if($party/expert[fn:normalize-space(@ref) !='']) then map {
          'id' : $party/expert/fn:substring-after(fn:normalize-space(@ref), '#'),
          'name' : xpr.mappings.html:getEntityName($party/expert/fn:substring-after(@ref, '#'))
        },
        'representatives' : if($party/representative[fn:normalize-space(.)!='']) then array{
          for $representative in $party/representative[fn:normalize-space(.)!='']
          return map {
              'name' : fn:string-join($representative/persName/*[fn:normalize-space(.)!='']/functx:capitalize-first(fn:normalize-space()), ', '),
              'occupation' : $representative/occupation => fn:normalize-space()
            }
        },
        'prosecutors' : if($party/prosecutor[fn:normalize-space(.)!='']) then array{
          for $prosecutor in $party/prosecutor[fn:normalize-space(.)!='']
          return fn:string-join($prosecutor/persName/*[fn:normalize-space(.)!='']/functx:capitalize-first(fn:normalize-space()), ', ')

        }
      }
    },
    'craftmen' : if($expertise/description/participants/craftmen/craftman[fn:normalize-space(.) != '']) then array{
      for $craftman in $expertise/description/participants/craftmen/craftman[fn:normalize-space(.) != '']
      return map{
        'name' : fn:string-join($craftman/persName/*[fn:normalize-space(.)!='']/functx:capitalize-first(fn:normalize-space()), ', '),
        'occupation' : $craftman/occupation => fn:normalize-space()
      }
    },
    'agreement' : $expertise/description/conclusions/agreement => fn:normalize-space(),
    'opinions' : if($expertise/description/conclusions/opinion[fn:normalize-space(.)!='']) then array{
      for $opinion in $expertise/description/conclusions/opinion[fn:normalize-space(.)!='']
      return map {
        'experts' : if($opinion[fn:normalize-space(@ref)!='']) then array{
          for $expert in fn:tokenize($opinion/@ref)
          return map{
            'id': fn:substring-after($expert, '#') => fn:normalize-space(),
            'name' : xpr.mappings.html:getEntityName(fn:substring-after($expert, '#'))
          }
        },
        'opinion' : $opinion => fn:normalize-space()
      }
    },
    'arrangement' : $expertise/description/conclusions/arrangement => fn:normalize-space(),
    'estimate' : xpr.mappings.html:getValue($expertise/description/conclusions/estimate[fn:string-join(@*)!=''], map{}),
    'estimates' : if($expertise/description/conclusions/estimates/place[fn:normalize-space(.)!='' or appraisal[fn:string-join((@l, @s, @d))!='']]) then array{
      for $place in $expertise/description/conclusions/estimates/place[fn:normalize-space(.)!='' or appraisal[fn:string-join((@l, @s, @d))!='']]
      let $ref := fn:substring-after($place/@ref, '#')
      let $placeName := xpr.mappings.html:getAddress($expertise/description/places/place[@xml:id=$ref], map{}) => fn:string-join() => fn:normalize-space()
      return map{
        'placeName' : $placeName,
        'appraisals' : if($place/appraisal[fn:normalize-space(.)!='' or fn:string-join((@l, @s, @d))!='']) then array{
          for $appraisal in $place/appraisal[fn:normalize-space(.)!='' or fn:string-join((@l, @s, @d))!='']
          return map{
            'description' : fn:normalize-space($appraisal/desc),
            'value' : xpr.mappings.html:getValue($appraisal, map{})
          }
        }
      }
    },
    'fees' : if($expertise/description/conclusions/fees/fee[fn:string-join((@l, @s, @d))!='']) then array{
      for $fee in $expertise/description/conclusions/fees/fee[fn:string-join((@l, @s, @d))!='']
      return xpr.mappings.html:getFee($fee, map{})
    },
    'totalFees' : xpr.mappings.html:getValue($expertise/description/conclusions/fees/total, map{}),
    'expertsExpense' : xpr.mappings.html:getValue($expertise/description/conclusions/expenses/expense[@type='expert'], map{}),
    'clerksExpense' : xpr.mappings.html:getValue($expertise/description/conclusions/expenses/expense[@type='clerk'], map{}),
    'analysis' : $expertise/description/analysis => fn:normalize-space(),
    'noteworthy' : $expertise/description/noteworthy => fn:normalize-space()
  }
  return map {
      'meta' : $meta,
      'content' : $content
  }
};

(:~
 : This resource function returns an expertise item
 : @param $id the expertise id
 : @return an expertise item in html with saxon
 :)
declare 
  %rest:path("xpr/expertises/{$id}/saxon")
  %rest:produces('application/html')
  %output:method("html")
function getExpertiseSaxon($id) {
  let $content := map {
    'data' : getExpertise($id),
    'trigger' : '',
    'form' : ''
  }
  let $outputParam := map {
    'layout' : "ficheExpertiseSaxon.xml"
  }
  return xpr.models.xpr:wrapper($content, $outputParam)
};

(:~
 : Permissions: expertises
 : Checks if the current user is granted; if not, redirects to the login page.
 : @param $perm map with permission data
 :)
declare
    %perm:check('xpr/expertises', '{$perm}')
function permExpertise($perm) {
  let $user := Session:get('id')
  return
    if((fn:empty($user) or fn:not(user:list-details($user)/*:info/*:grant/@type = $perm?allow)) and fn:ends-with($perm?path, 'new'))
      then web:redirect('/xpr/login/')
    else if((fn:empty($user) or fn:not(user:list-details($user)/*:info/*:grant/@type = $perm?allow)) and fn:ends-with($perm?path, 'modify'))
      then web:redirect('/xpr/login')
    else if((fn:empty($user) or fn:not(user:list-details($user)/*:info/*:grant/@type = $perm?allow[1] and user:list-details($user)/*:database[@pattern='xpr']/@permission = $perm?allow[2])) and fn:ends-with($perm?path, 'put'))
      then web:redirect('/xpr/login')
};

(:~
 : This resource function lists the entities
 : @return an xml list of persons/corporate bodies
 :)
declare 
  %rest:path("/xpr/biographies")
  %rest:produces('application/xml')
  %output:method("xml")
function getBiographies() {
  <bio>{ db:open('xpr', 'xpr/biographies') }</bio>
};

(:~
 : This resource function creates an new entity
 : @return an xforms for the entity
:)
declare
  %rest:path("xpr/biographies/new")
  %output:method("xml")
  %perm:allow("prosopography")
function newBiography() {
  let $content := map {
    'instance' : '',
    'model' : ('xprEacModel.xml', 'xprEacNoValidationModel.xml'),
    'trigger' : 'xprEacTrigger.xml',
    'form' : 'xprEacForm.xml'
  }
  let $outputParam := map {
    'layout' : "template.xml"
  }
  return(
    processing-instruction xml-stylesheet { fn:concat("href='", $G:xsltForms16Path, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    xpr.models.xpr:wrapper($content, $outputParam)
  )
};

(:~
 : This function consumes new entity
 : @param $param content
 :)
declare
  %rest:path("xpr/biographies/put")
  %output:method("xml")
  %rest:header-param("Referer", "{$referer}", "none")
  %rest:PUT("{$param}")
  %perm:allow("prosopography")
  %updating
function putBiography($param, $referer) {
  let $db := db:open("xpr")
  (:let $user := fn:normalize-space(user:list-details(Session:get('id'))/@name):)
  return
    if ($param/*/@xml:id) then
      let $location := fn:analyze-string($referer, 'xpr/biographies/(.+?)/modify')//fn:group[@nr='1']
      return db:replace('xpr', 'xpr/biographies/'|| $location ||'.xml', $param)
    else
      let $type := switch ($param//eac:identity/eac:entityType/@value)
        case 'person' return 'xprPerson'
        case 'org' return 'xprOrg'
        case 'family' return 'xprFamily'
        default return 'xprOther'
      let $id := $type || fn:generate-id($param)
      let $param :=
        copy $d := $param
        modify(
          insert node attribute xml:id {$id} into $d/*,
          replace value of node $d//eac:recordId with $id
        )
        return $d
      return(
        db:add('xpr', $param, 'xpr/biographies/'|| $id ||'.xml'),
        update:output((
          <rest:response>
            <http:response status="200" message="">
              <http:header name="Content-Language" value="fr"/>
              <http:header name="Content-Type" value="text/plain; charset=utf-8"/>
            </http:response>
          </rest:response>,
          <result>
            <id>{$id}</id>
            <message>Une nouvelle entité a été ajoutée : {$param//eac:nameEntry[@preferred='true']/eac:part}.</message>
          </result>
        ))
      )
};

(:~
 : This resource function lists all the entities
 : @return an ordered list of expertises in html
 :)
declare
  %rest:path("xpr/biographies/view")
  %rest:produces('application/html')
  %output:method("html")
  %output:html-version('5.0')
function getBiographiesHtml() {
 let $content := map {
    'title' : 'Liste des entités',
    'data' : getBiographies()
  }
  let $outputParam := map {
    'layout' : "listeProsopo.xml",
    'mapping' : xpr.mappings.html:listEac2html(map:get($content, 'data'), map{})
  }
  return xpr.models.xpr:wrapper($content, $outputParam)
};

(:~
 : This resource function lists all the entities
 : @return an ordered list of entities in json
 :)
declare
  %rest:path("/xpr/biographies/json")
  %rest:POST("{$body}")
  %rest:produces('application/json')
  %output:media-type('application/json')
  %output:method('json')
function getBiographiesJson($body) {
  let $body := json:parse( $body, map{"format" : "xquery"})
  let $biographies := getBiographies()

  let $meta := map {
    'start' : $body?start,
    'count' : $body?count,
    'qualities' : map:merge(
      for $quality in fn:distinct-values($biographies/eac:eac//eac:identity//eac:otherEntityType/eac:term[fn:normalize-space(.)!=''])
      return map{
        fn:normalize-space($quality) : switch($quality)
          case 'expert' return 'expert (tableau)'
          case 'mason' return 'maçon'
          case 'altExpert' return 'expert (non inscrit)'
          case 'person' return 'autre personne'
          case 'office' return 'office d’expert'
          case 'family' return 'famille'
          case 'org' return 'institution'
          default return ''
      }
    ),
    'totalBiographies' : fn:count($biographies/eac:eac)
  }
  let $content := array{
    for $biography in fn:subsequence($biographies/eac:eac, $body?start, $body?count)
    let $quality := switch($biography//eac:identity//eac:otherEntityType/eac:term)
      case 'expert' return 'expert (tableau)'
      case 'mason' return 'maçon'
      case 'altExpert' return 'expert (non inscrit)'
      case 'person' return 'autre personne'
      case 'office' return 'office d’expert'
      case 'family' return 'famille'
      case 'org' return 'institution'
      default return ''
    return map{
      'id' : fn:normalize-space($biography/@xml:id),
      'name' : xpr.mappings.html:getEntityName($biography/@xml:id),
      'quality' : $quality
    }
  }
  return map{
    "meta": $meta,
    "content": $content
  }
};

(:~
 : This resource function lists all the entities
 : @return an ordered list of entities with saxon
 :)
declare
  %rest:path("/xpr/biographies/saxon")
  %rest:produces('application/html')
  %output:method("html")
function getBiographiesSaxon() {
  let $content := map {
    'data' : getBiographies(),
    'trigger' : '',
    'form' : ''
  }
  let $outputParam := map {
    'layout' : "listeProsopoSaxon.xml"
  }
  return xpr.models.xpr:wrapper($content, $outputParam)
};

(:~
 : This resource function get an entity
 : @return an xml representation of an entity
 :)
declare
  %rest:path("xpr/biographies/{$id}")
  %output:method("xml")
function getBiography($id) {
  db:open('xpr', 'xpr/biographies/'||$id||'.xml')
};

(:~
 : This resource function modify an entity
 : @return an xforms to modify an entity
 :)
declare
  %rest:path("xpr/biographies/{$id}/modify")
  %output:method("xml")
  %perm:allow("prosopography")
function modifyBiography($id) {
  let $content := map {
    'instance' : $id,
    'path' : 'biographies',
    'model' : ('xprEacModel.xml', 'xprEacNoValidationModel.xml'),
    'trigger' : 'xprEacTrigger.xml',
    'form' : 'xprEacForm.xml'
  }
  let $outputParam := map {
    'layout' : "template.xml"
  }
  return
    (processing-instruction xml-stylesheet { fn:concat("href='", $G:xsltForms16Path, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    xpr.models.xpr:wrapper($content, $outputParam)
    )
};

(:~
 : This resource function show an entity
 : @return an html view of an entity with xquery templating
 :)
declare
  %rest:path("/xpr/biographies/{$id}/view")
  %rest:produces('application/html')
  %output:method("html")
  %output:html-version('5.0')
function getBiographyHtml($id) {
  let $content := map {
    'title' : 'Fiche de ' || $id,
    'data' : getBiography($id)/eac:eac,
    'trigger' : '',
    'form' : ''
  }
  let $outputParam := map {
    'layout' : "ficheProsopo.xml",
    'mapping' : xpr.mappings.html:eac2html(map:get($content, 'data'), map{})
  }
  return xpr.models.xpr:wrapper($content, $outputParam)
};

(:~
 : This resource function lists an entities
 : @return an ordered list of entities in json
 :)
declare
  %rest:path("/xpr/biographies/{$id}/json")
  %rest:produces('application/json')
  %output:media-type('application/json')
  %output:method('json')
function getBiographyJson($id) {
  let $biography := xpr.xpr:getBiography($id)
  let $expertises := getExpertises()/expertise[descendant::experts/expert[@ref = '#' || $id]]
  let $meta := map {}
  let $content := map{
    'id' : fn:normalize-space($biography/eac:eac/eac:control/eac:recordId),
    'authorizedForm' : xpr.mappings.html:getEntityName(fn:normalize-space($biography/eac:eac/@xml:id)),
    'alternativeForms' : if($biography/eac:eac/eac:cpfDescription/eac:identity/eac:nameEntry[@preferredForm != 'true'][fn:normalize-space(.)!='']) then array{
      for $alternativeForm in $biography/eac:eac/eac:cpfDescription/eac:identity/eac:nameEntry[@preferredForm != 'true'][fn:normalize-space(.)!='']
      return
      map:merge((
          map{'sources' : array{xpr.mappings.html:getSources($alternativeForm/@sourceReference, $biography/eac:eac/eac:control/eac:sources, map{})}},
          map{'parts' : array{
            for $part in $alternativeForm/eac:part
            let $d := xpr.mappings.html:getPart($part, map{})
            return
              map{'key' : $d[1], 'part': $d[2]}
          }}
      ))
    },
    'existDates' : xpr.mappings.html:getEacDates($biography/eac:eac/eac:cpfDescription/eac:description/eac:existDates/eac:dateRange, $biography/eac:eac/eac:control/eac:sources, map{}),
    'sex' : $biography/eac:eac/eac:cpfDescription/eac:description/eac:localDescriptions/eac:localDescription[@localType='sex']/eac:term => fn:normalize-space(),
    (:'places' : if($biography/eac:cpfDescription/eac:description/eac:places/eac:place[fn:normalize-space(.)!='']) then array{
      for $place in $biography/eac:cpfDescription/eac:description/eac:places/eac:place[fn:normalize-space(.)!='']
      return map{
        'placeRole' : $place/eac:placeRole => fn:normalize-space(),
        'placeEntry' : $place/eac:placeEntry => fn:normalize-space(),
        'dates' : if($place/eac:dateSet/*[descendant-or-self::*/@standardDate != '' or descendant-or-self::*/@notAfter != '' or descendant-or-self::*/@notBefore != '']) then array{
          for $date in $place/eac:dateSet/*[descendant-or-self::*/@standardDate != '' or descendant-or-self::*/@notAfter != '' or descendant-or-self::*/@notBefore != '']
          return if($date/self::eac:dateRange) then map{
            'from' : map{
              'precision' : $date/eac:fromDate/@*[fn:local-name = ('standardDate', 'notBefore', 'notAfter')]/fn:local-name(),
              'date' : $date/eac:fromDate/@*[fn:local-name = ('standardDate', 'notBefore', 'notAfter')] => fn:normalize-space()
            },
            'to' : map{
              'precision' : $date/eac:toDate/@*[fn:local-name = ('standardDate', 'notBefore', 'notAfter')]/fn:local-name(),
              'date' : $date/eac:toDate/@*[fn:local-name = ('standardDate', 'notBefore', 'notAfter')] => fn:normalize-space()
            }
          } else map{
            'precision' : $date/@*[fn:local-name = ('standardDate', 'notBefore', 'notAfter')]/fn:local-name(),
            'date' : $date/@*[fn:normalize-space(.)!=''] => fn:normalize-space(),
            'sources' : if($date/xpr:source[@xlink:href!='']) then array{
              for $source in $date/xpr:source[@xlink:href!='']
              return map{
                'id' : $source/@xlink:href => fn:substring-after('#'),
                'source' : xpr.mappings.html:getSource($source, map{}),
                'note' : $source => fn:normalize-space()
              }
            }
          }
        },
        'note' : $place/eac:descriptiveNote/eac:p => fn:normalize-space()
      }
    },:)
    'occupations' : if($biography/eac:eac/eac:cpfDescription/eac:description/eac:occupations/eac:occupation[fn:normalize-space(.)!='']) then array{
      for $occupation in $biography/eac:eac/eac:cpfDescription/eac:description/eac:occupations/eac:occupation[fn:normalize-space(.)!='']
      return map{
        'occupation' : $occupation/eac:term => fn:normalize-space(),
        'dates' : if($occupation/*[self::eac:date or self::eac:dateRange or self::eac:dateSet][.//@*[fn:normalize-space(.) castable as xs:date or xs:gYearMonth or xs:gYear]]) then array { xpr.mappings.html:getEacDates($occupation/*[self::eac:date or self::eac:dateRange], $biography/eac:eac/eac:control/eac:sources, map{})},
        'sources' : if(fn:normalize-space($occupation/@sourceReference) != '') then xpr.mappings.html:getEacSourceReference($occupation/@sourceReference, $biography/eac:eac/eac:control/eac:sources)
      }
    },
    'functions' : if($biography/eac:eac/eac:cpfDescription/eac:description/eac:functions/eac:function[fn:normalize-space(.)!='']) then array{
      for $function in $biography/eac:eac/eac:cpfDescription/eac:description/eac:functions/eac:function[fn:normalize-space(.)!='']
      return map{
        'function' : $function/eac:term => fn:normalize-space(),
        'dates' : if($function/*[self::eac:date or self::eac:dateRange or self::eac:dateSet][.//@*[fn:normalize-space(.) castable as xs:date or xs:gYearMonth or xs:gYear]]) then xpr.mappings.html:getEacDates($function/*[self::eac:date or self::eac:dateRange], $biography/eac:eac/eac:control/eac:sources, map{}),
        'sources' : if(fn:normalize-space($function/@sourceReference) != '') then xpr.mappings.html:getEacSourceReference($function/@sourceReference, $biography/eac:eac/eac:control/eac:sources)
      }
    },
    'events' : if($biography/eac:eac/eac:cpfDescription/eac:description/eac:biogHist/eac:chronList/eac:chronItem[fn:normalize-space(.)!='']) then array{
      for $event in $biography/eac:eac/eac:cpfDescription/eac:description/eac:biogHist/eac:chronList/eac:chronItem[fn:normalize-space(.)!='']
      return map{
        'event' : $event/eac:event => fn:normalize-space(),
        'place' : if($event/eac:place[fn:normalize-space(.)!='']) then $event/eac:place => fn:normalize-space(),
        (:@todo participants ?:)
        'sources' : if(fn:normalize-space($event/@sourceReference) != '') then xpr.mappings.html:getEacSourceReference($event/@sourceReference, $biography/eac:eac/eac:control/eac:sources),
        'dates' : if($event/*[self::eac:date or self::eac:dateRange or self::eac:dateSet][.//@*[fn:normalize-space(.) castable as xs:date or xs:gYearMonth or xs:gYear]]) then xpr.mappings.html:getEacDates($event/*[self::eac:date or self::eac:dateRange or self::eac:dateSet], $biography/eac:eac/eac:control/eac:sources, map{})
      }
    },
    'relations' : if(fn:count($biography/eac:eac/eac:cpfDescription/eac:relations/eac:relation[fn:normalize-space(.)!='']) > 0) then array{
      for $relation in $biography/eac:eac/eac:cpfDescription/eac:relations/eac:relation[fn:normalize-space(.)!=''] return map{
        'relation' : $relation/eac:targetEntity/eac:part[@localType='full'] => fn:normalize-space(),
        'roles' : if($relation/eac:targetRole[fn:normalize-space(.)!='']) then array{
          for $role in $relation/eac:targetRole
          let $sources := $relation/eac:relationType[@id = fn:substring-after($role/@target, '#')]/@sourceReference
          return map{
            'role' : $role => fn:normalize-space(),
            'sources' : if(fn:normalize-space($sources) != '') then xpr.mappings.html:getEacSourceReference($sources, $biography/eac:eac/eac:control/eac:sources)
          }
        },
        'events' : if($relation/@target[fn:normalize-space(.)!='']) then array{
          for $event in fn:tokenize($relation/@target, ' ')
          let $eventId := fn:substring-after($event, '#')
          return map{
            'event' : $biography//eac:chronItem[@id = $eventId]/eac:event => fn:normalize-space()
          }
        }
      }
    },
    'expertises' : if(fn:count($expertises) > 0) then array{
      for $expertise in $expertises order by $expertise/@xml:id return map {
        'id' : $expertise/@xml:id => fn:normalize-space(),
        'dates' : if($expertise//sessions/date[fn:normalize-space(@when[. castable as xs:date])]) then array{
          fn:sort($expertise//sessions/date/fn:normalize-space(@when[. castable as xs:date]))
        }
      }
    }
  }
  return map {
    'meta' : $meta,
    'content' : $content
  }
};

(:~
 : This resource function show an entity
 : @return an html view of an entity
 :)
declare
  %rest:path("/xpr/biographies/{$id}/saxon")
  %rest:produces('application/html')
  %output:method("html")
function getBiographySaxon($id) {
  let $content := map {
    'data' : getBiography($id),
    'trigger' : '',
    'form' : ''
  }
  let $outputParam := map {
    'layout' : "ficheProsopoSaxon.xml"
  }
  return xpr.models.xpr:wrapper($content, $outputParam)
};

(:~
 : This resource function modify an entity
 : @return an xforms to modify an entity
 : @todo everywhere replace instance/$path with a direct link to the resource (model.xpr.xqm => getModels)
 : @rmq abandonned because it was to complicated to treat the content with xforms
 :)
declare
  %rest:path("xpr/biographies/{$id}/xforms")
  %output:method("xml")
function getBiographyXforms($id) {
  let $content := map {
    'instance' : ($id, getExpertises($id)),
    'path' : 'biographies',
    'model' : 'xprProsopoViewModel.xml',
    'trigger' : '',
    'form' : 'xprProsopoViewForm.xml'
  }
  let $outputParam := map {
    'layout' : "template.xml"
  }
  return
    (processing-instruction xml-stylesheet { fn:concat("href='", $G:xsltFormsPath, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    xpr.models.xpr:wrapper($content, $outputParam)
    )
};

(:~
 : This resource function get the activity of an entity
 : @return an xml/svg representation of the activity
 : @bug order sessions dates
 :)
declare
  %rest:path("xpr/biographies/{$id}/activity")
  %rest:produces('application/svg+xml')
  %output:method("xml")
function getExpertActivity($id) {
  let $expertises := getExpertises()/expertise
  let $expert := getBiography($id)

  let $length := fn:count($G:years) * 50

  let $activity :=
    <xpr:activity>{
      for $year in $G:years
      return
        <xpr:year>
          <xpr:label>{$year}</xpr:label>
          <xpr:quantity>{fn:count($expertises[description/participants/experts[expert[fn:substring-after(@ref, '#') = $id]]][description/sessions[date[1][fn:matches(@when, xs:string($year), 'i')]]])}</xpr:quantity>
        </xpr:year>
    }</xpr:activity>

  let $maxHeight := fn:max($activity//xpr:quantity)

  let $color := "orangered"

  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%">
      <g transform="translate(0,{$maxHeight + 20})">
        <line x1="0" y1="0" x2="{$length}" y2="0" stroke="purple" stroke-width="1"/>
        <line x1="0" y1="-{$length}" x2="0" y2="0" stroke="purple" stroke-width="2"/>
        {for $year at $i in $activity/xpr:year
        let $xPosition := ($i - 1) * 40
        let $position := $i
        return (
          element rect {
            attribute x {$xPosition},
            attribute y {-$year/xpr:quantity},
            attribute height {$year/xpr:quantity},
            attribute width {"35"},
            attribute fill {$color}
          },
          element text {
            attribute x {$xPosition},
            attribute y {"15"},
            $year/xpr:label => fn:normalize-space()
          },
          element text {
            attribute x {$xPosition},
            attribute y {-$year/xpr:quantity + 5},
            if($year/xpr:quantity > 0) then $year/xpr:quantity => fn:normalize-space()
          }
        )}
      </g>
    </svg>
  )
};

(:~
 : Permissions: biographies
 : Checks if the current user is granted; if not, redirects to the login page.
 : @param $perm map with permission data
 :)
declare
    %perm:check('xpr/biographies', '{$perm}')
function permBiographies($perm) {
  let $user := Session:get('id')
  return
    if((fn:empty($user) or fn:not(user:list-details($user)/*:info/*:grant/@type = $perm?allow)) and fn:ends-with($perm?path, 'new'))
      then web:redirect('/xpr/login')
    else if((fn:empty($user) or fn:not(user:list-details($user)/*:info/*:grant/@type = $perm?allow)) and fn:ends-with($perm?path, 'modify'))
      then web:redirect('/xpr/login')
    else if((fn:empty($user) or fn:not(user:list-details($user)/*:info/*:grant/@type = $perm?allow)) and fn:ends-with($perm?path, 'put'))
      then web:redirect('/xpr/login')
};

(:~
 : This resource function edits new inventory
 : @return an xforms for the inventory
:)
declare
  %rest:path("xpr/clerks")
  %output:method("xml")
function pickAClerk() {
  let $content := map {
    'instance' : '',
    'model' : 'xprRandomModel.xml',
    'trigger' : '',
    'form' : 'xprRandomForm.xml'
  }
  let $outputParam := map {
    'layout' : "template.xml"
  }
  return
    (processing-instruction xml-stylesheet { fn:concat("href='", $G:xsltFormsPath, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    xpr.models.xpr:wrapper($content, $outputParam)
    )
};

(:~
 : This resource function edits new inventory
 : @return an xforms for the inventory
:)
declare
  %rest:path("xpr/clerks/{$id}")
  %output:method("xml")
function getExpertisesByClerk($id) {
  let $db := getExpertises()
  let $expertises := $db/expertise[descendant::clerk[fn:substring-after(@ref, '#') = $id]]
  return <expertises>{$expertises}</expertises>
};

(:~
 : This resource function lists the persons or corporate bodies
 : @return an xml list of persons/corporate bodies
 :)
declare
  %rest:path("/xpr/clerks/{$id}/random")
  %rest:produces('application/xml')
  %output:method("xml")
function getRandomExpertise($id) {
  let $expertises := getExpertisesByClerk($id)
  let $random := random:integer(fn:count($expertises/*:expertise))
  let $expertise := $expertises/expertise[$random]
  return (
    <results xmlns="xpr">
      <id>{$expertise/@xml:id => fn:normalize-space()}</id>
      <extent>{$expertise/sourceDesc/physDesc/extent => fn:normalize-space()}</extent>
      <sketch>{$expertise/sourceDesc/physDesc/extent/@sketch => fn:normalize-space()}</sketch>
      <clerk>{fn:string-join($expertise/description/participants/clerks/clerk/fn:string-join(persName/*[fn:normalize-space(.)!=''], ', '), ' ; ')}</clerk>
      <facsimile>{$expertise/sourceDesc/facsimile/@from => fn:normalize-space()}</facsimile>
    </results>
  )
};

(:~
 : This resource function lists all the inventories
 : @return a xml ressource of all the inventories
 :)
declare 
  %rest:path("/xpr/inventories")
  %rest:produces('application/xml')
  %output:method("xml")
function getInventories() {
  <posthumousInventories>{ db:open('xpr', 'xpr/inventories') }</posthumousInventories>
};

(:~
 : This resource function edits new inventory
 : @return an xforms for the inventory
:)
declare
  %rest:path("xpr/inventories/new")
  %output:method("xml")
  %perm:allow("posthumusInventory")
function newInventory() {
  let $content := map {
    'instance' : '',
    'model' : ('xprInventoryModel.xml', 'xprProsopoModel.xml'),
    'trigger' : 'xprInventoryTrigger.xml',
    'form' : 'xprInventoryForm.xml'
  }
  let $outputParam := map {
    'layout' : "template.xml"
  }
  return
    (processing-instruction xml-stylesheet { fn:concat("href='", $G:xsltFormsPath, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    xpr.models.xpr:wrapper($content, $outputParam)
    )
};

(:~
 : This function consumes new inventory
 : @param $param content
 : @todo modify
 :)
declare
  %rest:path("xpr/inventories/put")
  %output:method("xml")
  %rest:header-param("Referer", "{$referer}", "none")
  %rest:PUT("{$param}")
  %perm:allow("posthumusInventory")
  %updating
function putInventory($param, $referer) {
  let $db := db:open("xpr")
  let $id := fn:generate-id($param)
  let $user := fn:normalize-space(user:list-details(Session:get('id'))/@name)
    return
      if (fn:ends-with($referer, 'modify'))
      then
        let $location := fn:analyze-string($referer, 'xpr/inventories/(.+?)/modify')//fn:group[@nr='1']
        let $param :=
          copy $d := $param
          modify (replace value of node $d/inventory/control/maintenanceHistory/maintenanceEvent[1]/agent with $user)
          return $d
        return (
          db:replace('xpr', 'xpr/inventories/'|| $location ||'.xml', $param),
          update:output(
           (
            <rest:response>
              <http:response status="200" message="test">
                <http:header name="Content-Language" value="fr"/>
                <http:header name="Content-Type" value="text/plain; charset=utf-8"/>
              </http:response>
            </rest:response>,
            <result><message>L'inventaire {$location} a été modifié.</message></result>
           )
          )
        )
      else
        let $param :=
          copy $d := $param
          modify (
            insert node attribute xml:id {$id} into $d/*,
            replace value of node $d/inventory/control/maintenanceHistory/maintenanceEvent[1]/agent with $user
          )
          return $d
        return (
          db:add('xpr', $param, 'xpr/inventories/'|| $id ||'.xml'),
          update:output(
            (<rest:response>
              <http:response status="200" message="test">
                <http:header name="Content-Language" value="fr"/>
                <http:header name="Content-Type" value="text/plain; charset=utf-8"/>
              </http:response>
            </rest:response>,
            <result>
              <id>{$id}</id>
              <message>L'inventaire {$id} a été enregistré.</message>
            </result>)
          )
        )
};

(:~
 : This resource function lists all the inventories
 : @return an ordered list of inventories in html
 :)
declare
  %rest:path("/xpr/inventories/view")
  %rest:produces('application/html')
  %output:method("html")
  %output:html-version('5.0')
function getInventoriesHtml() {
 let $content := map {
    'title' : 'Liste des inventaires après-décès',
    'data' : getInventories()
  }
  let $outputParam := map {
    'layout' : "listeInventaires.xml",
    'mapping' : xpr.mappings.html:listIad2html(map:get($content, 'data'), map{})
  }
  return xpr.models.xpr:wrapper($content, $outputParam)
};

(:~
 : This resource function lists all the inventories
 : @return an ordered list of inventories in json
 : @todo to develop
 :)
declare
  %rest:path("/xpr/inventories/json")
  %rest:POST("{$body}")
  %rest:produces('application/json')
  %output:media-type('application/json')
  %output:method('json')
function getInventoriesJson($body) {
  let $body := json:parse( $body, map{"format" : "xquery"})
  let $inventories := getInventories()

  let $meta := map {
      'start' : $body?start,
      'count' : $body?count,
      'totalSources' : fn:count($inventories/inventory)
  }
  let $content := array{
    for $inventory in fn:subsequence($inventories/inventory, $body?start, $body?count)
    return map{
      'id' : $inventory/@xml:id => fn:normalize-space(),
      'mark' : $inventory/sourceDesc/idno[@type='unitid'] => fn:normalize-space(),
      'expert' : xpr.mappings.html:getEntityName(fn:substring-after($inventory/sourceDesc/expert/@ref, '#')),
      'date' : $inventory/sourceDesc/date/@standardDate => fn:normalize-space()
    }
  }
  return map{
    "meta": $meta,
    "content": $content
  }
};

(:~
 : This resource function returns an inventory item
 : @param $id the inventory id
 : @return an inventory item in xml (xpr)
 :)
declare
  %rest:path("xpr/inventories/{$id}")
  %output:method("xml")
function getInventory($id) {
  db:open('xpr', 'xpr/inventories/'||$id||'.xml')
};

(:~
 : This resource function modify an inventory
 : @return an xforms to modify an inventory
 :)
declare
  %rest:path("xpr/inventories/{$id}/modify")
  %output:method("xml")
  %perm:allow("posthumusInventory")
function modifyInventory($id) {
  let $content := map {
    'instance' : $id,
    'path' : 'inventories',
    'model' : ('xprInventoryModel.xml', 'xprProsopoModel.xml'),
    'trigger' : 'xprInventoryTrigger.xml',
    'form' : 'xprInventoryForm.xml'
  }
  let $outputParam := map {
    'layout' : "template.xml"
  }
  return
    (processing-instruction xml-stylesheet { fn:concat("href='", $G:xsltFormsPath, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    xpr.models.xpr:wrapper($content, $outputParam)
    )
};

(:~
 : This resource function returns an inventory
 : @return an inventory in json
 : @todo to develop
 :)
declare
  %rest:path("/xpr/inventories/{$id}/json")
  %rest:produces('application/json')
  %output:media-type('application/json')
  %output:method('json')
function getInventoryJson($id) {
  let $inventory := getInventory($id)/inventory

  let $meta := map {}
  let $content := map{
    'id' : $inventory/@xml:id => fn:normalize-space(),
    'mark' : $inventory/sourceDesc/idno[@type='unitid'] => fn:normalize-space(),
    'expert' : xpr.mappings.html:getEntityName(fn:substring-after($inventory/sourceDesc/expert/@ref, '#')),
    'date' : $inventory/sourceDesc/date/@standardDate => fn:normalize-space()
  }
  return map{
    "meta": $meta,
    "content": $content
  }
};

(:~
 : Permissions: inventories
 : Checks if the current user is granted; if not, redirects to the login page.
 : @param $perm map with permission data
 :)
declare
    %perm:check('xpr/inventories', '{$perm}')
function permInventories($perm) {
  let $user := Session:get('id')
  return
    if((fn:empty($user) or fn:not(user:list-details($user)/*:info/*:grant/@type = $perm?allow)) and fn:ends-with($perm?path, 'new'))
      then web:redirect('/xpr/login')
    else if((fn:empty($user) or fn:not(user:list-details($user)/*:info/*:grant/@type = $perm?allow)) and fn:ends-with($perm?path, 'modify'))
      then web:redirect('/xpr/login')
    else if((fn:empty($user) or fn:not(user:list-details($user)/*:info/*:grant/@type = $perm?allow)) and fn:ends-with($perm?path, 'put'))
      then web:redirect('/xpr/login')
};

(:~
 : This resource function lists all the expertises
 : @return an ordered list of expertises with 2 or more categories in xml
 :)
declare
  %rest:path("/xpr/dualcat")
  %rest:produces('application/xml')
  %output:method("xml")
function getExpertisesDualCategories() {
  <expertises>{ db:open('xpr')/xpr/expertises/expertise[fn:count(descendant::category) > 1] }</expertises>
};

(:~
 : This resource function lists all the expertises with 2 or more categories
 : @return an ordered list of expertises with 2 or more categories in html
 :)
declare
  %rest:path("/xpr/dualcat/view")
  %rest:produces('application/html')
  %output:method("html")
  %output:html-version('5.0')
function getExpertisesDualCategoriesHtml() {
 let $content := map {
    'title' : 'Liste des expertises avec plusieurs catégories d‘expertise',
    'data' : getExpertisesDualCategories()
  }
  let $outputParam := map {
    'layout' : "listeExpertise.xml",
    'mapping' : xpr.mappings.html:listXpr2html(map:get($content, 'data'), map{})
  }
  return xpr.models.xpr:wrapper($content, $outputParam)
};

(:~
 : This resource function lists the persons or corporate bodies
 : @return an xml list of persons/corporate bodies
 :)
declare
  %rest:path("/xpr/xforms")
  %rest:produces('application/xml')
  %output:method("xml")
function getDataXforms() {
  let $id := request:parameter('data')
  let $param := request:parameter('param')
  let $db := db:open('xpr')
  let $biographies := getBiographies()
  return (
    if($id = 'getSourceId') then <source localType="new" xml:id="{'xprSource' || fn:generate-id($db)}"/>
    else if ($param = 'getAgent') then <agent xmlns="">{fn:normalize-space(user:list-details(Session:get('id'))/@name)}</agent>
    else $biographies/bio/eac:eac[@xml:id = $id]
  )

};

(:~
 : This resource function lists the persons or corporate bodies
 : @return an xml list of persons/corporate bodies
 :)
declare
  %rest:path("/xpr/search/bio/{$person}")
  %rest:produces('application/xml')
  %output:method("xml")
function getTerm($person) {
  let $prosopo := getBiographies()/eac:eac
  return (
    <results xmlns="">{
      for $person in $prosopo[fn:normalize-space(eac:cpfDescription/eac:identity) contains text {$person} all words using fuzzy]
      return <result xml:id="{$person/@xml:id}">{$person/descendant::eac:nameEntry[@preferredForm='true'][@status='authorized'][1]/eac:part[@localType='full'] => fn:normalize-space()}</result>
    }</results>
  )
};

(:~
 : This resource function lists all the entities
 : @return an ordered xml ressource of all the entities with @xml:id, @type and an authorized form of the name
 : @todo collation for order by (for accent)
 :)
declare
  %rest:path("/xpr/entities")
  %rest:produces('application/xml')
  %output:method("xml")
function getEntities() {
  <entities xmlns="xpr">{
    for $entity in getBiographies()/eac:eac
      let $id := $entity/@xml:id
      order by fn:lower-case($entity//eac:nameEntry[@preferredForm='true'][@status='authorized'][1])
    return
      <entity xml:id="{$id}" type="{fn:string-join($entity//eac:otherEntityTypes/eac:otherEntityType/eac:term, ' ')}"><label>{$entity//eac:nameEntry[@preferredForm='true'][@status='authorized'][1]/eac:part/text()}</label></entity>
  }</entities>
};

(:~ Login page (visible to everyone). :)
declare
  %rest:path("xpr/login")
  %output:method("html")
function login() {
  <html>
    Please log in:
    <form action="/xpr/login/check" method="post">
      <input name="name"/>
      <input type="password" name="pass"/>
      <input type="submit"/>
    </form>
  </html>
};

(:
 : this function checks if the user is registered
 :)
declare
  %rest:path("xpr/login/check")
  %rest:query-param("name", "{$name}")
  %rest:query-param("pass", "{$pass}")
function login($name, $pass) {
  try {
    user:check($name, $pass),
    Session:set('id', $name),
    web:redirect("/")
  } catch user:* {
    web:redirect("/")
  }
};

(:
 : this function logs out current user
 :)
declare
  %rest:path("xpr/logout")
function logout() {
  Session:delete('id'),
  web:redirect("/")
};

(:~
 : This resource function edits a new user
    : @return an xforms to edit a new user
:)
declare
  %rest:path("xpr/users/new")
  %output:method("xml")
  %perm:allow("admin", "write")
function newUser() {
  let $content := map {
    'instance' : '',
    'model' : 'xprUserModel.xml',
    'trigger' : '',
    'form' : 'xprUserForm.xml'
  }
  let $outputParam := map {
    'layout' : "template.xml"
  }
  return
    (processing-instruction xml-stylesheet { fn:concat("href='", $G:xsltFormsPath, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    xpr.models.xpr:wrapper($content, $outputParam)
    )
};

(:~
 : This function creates new user in dba.
 : @todo return creation message
 : @todo control for duplicate user.
 :)
declare
  %rest:path("xpr/users/put")
  %output:method("xml")
  %rest:header-param("Referer", "{$referer}", "none")
  %rest:PUT("{$param}")
  %perm:allow("admin", "write")
  %updating
function putUser($param, $referer) {
  let $user := $param
  let $userName := fn:normalize-space($user/*:user/*:name)
  let $userPwd := fn:normalize-space($user/*:user/*:password)
  let $userPermission := fn:normalize-space($user/*:user/*:permission)
  let $userInfo :=
    <info xmlns="">{
        for $right in $user/*:user/*:info/*:grant
        return <grant type="{$right/@type}">{fn:normalize-space($right)}</grant>
    }</info>
  return
    user:create(
      $userName,
      $userPwd,
      $userPermission,
      'xpr',
      $userInfo)
};

(:~
 : This resource returns a xml file with all the expertises of a user
 : @return an xml resource
 :)
declare
  %rest:path("xpr/users/expertises/{$user}")
  %rest:produces('application/html')
  %output:method("xml")
function getUsersExpertises($user) {
  <expertises xmlns="xpr">{ db:open('xpr')//expertise[descendant::agent[fn:normalize-space(.) = $user]] }</expertises>
};

(:~
 : This resource returns a list with all the expertises of a user
 : @return an ordered list of expertises in html
 :)
declare
  %rest:path("xpr/users/expertises/{$user}/view")
  %rest:produces('application/html')
  %output:method("html")
  %output:html-version('5.0')
function getUsersExpertisesHtml($user) {
 let $content := map {
    'title' : 'Liste des expertises',
    'data' : getUsersExpertises($user)
  }
  let $outputParam := map {
    'layout' : "listeExpertise.xml",
    'mapping' : xpr.mappings.html:listXpr2html(map:get($content, 'data'), map{})
  }
  return xpr.models.xpr:wrapper($content, $outputParam)
};


declare
    %perm:check('xpr/users', '{$perm}')
function permUsers($perm) {
  let $user := Session:get('id')
  return
    if((fn:empty($user) or fn:not(user:list-details($user)/*:database[parent::*:user/@permission = $perm?allow[1]][@pattern='xpr']/@permission = $perm?allow[2])) and fn:ends-with($perm?path, 'new'))
      then web:redirect('/xpr/login')
    else if((fn:empty($user) or fn:not(user:list-details($user)/*:database[parent::*:user/@permission = $perm?allow[1]][@pattern='xpr']/@permission = $perm?allow)) and fn:ends-with($perm?path, 'modify'))
      then web:redirect('/xpr/login')
    else if((fn:empty($user) or fn:not(user:list-details($user)/*:database[parent::*:user/@permission = $perm?allow[1]][@pattern='xpr']/@permission = $perm?allow)) and fn:ends-with($perm?path, 'put'))
      then web:redirect('/xpr/login')
};

(:~
 : This function
 :)
declare
  %rest:path("xpr/csv/expertises")
  %output:method("csv")
  %output:csv("header=yes")
  %rest:produces("text/plain")
function getCsvExpertises() {
 <csv>{
  let $data := db:open('xpr', 'xpr/expertises')
  for $expertise in $data/expertise
  return element record {
    element unitid {$expertise/sourceDesc/idno[@type="unitid"] => fn:normalize-space()},
    element item {$expertise/sourceDesc/idno[@type="item"] => fn:normalize-space()},
    element supplement {$expertise/sourceDesc/idno[@type="supplement"] => fn:normalize-space()},
    element facsimile {$expertise/sourceDesc/facsimile/(@from, @to) => fn:string-join(" | ")},
    element sketch {$expertise/sourceDesc/physDesc/extent/@sketch => fn:normalize-space()},
    element extent {$expertise/sourceDesc/physDesc/extent => fn:normalize-space()},
    element nbAppendice {$expertise/sourceDesc/physDesc/appendices/appendice => fn:count()},
    element sessions {$expertise/description/sessions/date/fn:concat(@when, ' ; ', @type) => fn:string-join(" | ")},
    (:element experts {$expertise/description/participants/experts/expert[@ref!=""]/xpr.mappings.html:getEntityName(fn:substring-after(@ref, '#')) => fn:string-join(" | ")},:)
    (:tous les lieux n'ont pas la même structure s'ils sont à paris, banlieue, etc.:)
    element places {$expertise/description/places/place/fn:concat(@type, ' ; ', fn:string-join(descendant::node()[fn:not(node())], " ; ")) => fn:string-join(" | ")},
    element categories {$expertise/description/categories/category => fn:string-join(" | ")},
    element designation {$expertise/description/categories/designation => fn:normalize-space()},
    element rubric {$expertise/description/categories/designation/@rubric => fn:normalize-space()},
    element framework {$expertise/description/procedure/framework => fn:normalize-space()},
    element frameworkType {$expertise/description/procedure/framework/@type => fn:normalize-space()},
    element origination {$expertise/description/procedure/origination => fn:normalize-space()},
    element originationType {$expertise/description/procedure/origination/@type => fn:normalize-space()},
    element sentences {$expertise/description/procedure/sentences/sentence/fn:concat(fn:normalize-space(orgName), " : ", fn:string-join(date/@when, ' ; ')) => fn:string-join(" | ")},
    element case {$expertise/description/procedure/case => fn:normalize-space()},
    element objects {$expertise/description/procedure/objects/object => fn:string-join(' | ')}}
 }</csv>
};

(:
 : this function returns the list of experts, clerks and expertises (with only 1 category) for a year.
 :)
declare
  %rest:path("/xpr/data/{$year}")
  %rest:produces("application/xml")
  %output:method("xml")
  %rest:query-param("format", "{$format}", "xml")
function getDataByYear($year as xs:string, $format as xs:string) {
    let $queryParam := map{
      'year' : $year,
      'format' : $format
    }
    let $content := map{
      'expertises' : xpr.models.networks:getExpertisesByYear($queryParam),
      'experts' : xpr.models.networks:getExpertsByYear($queryParam),
      'clerks' : xpr.models.networks:getClerksByYear($queryParam)
    }

    let $outputParam := map{}

    return
      <xpr>{
        $content?expertises,
        $content?experts,
        $content?clerks
      }</xpr>
};

(:
 : this function returns the experts data for a specific year.
 :)
declare
  %rest:path("/xpr/data/{$year}/experts")
  %rest:produces("application/csv")
  %output:method("csv")
  %rest:query-param("format", "{$format}", "csv")
function getExpertsDataByYear($year as xs:string, $format as xs:string) {
    let $queryParam := map{
      'year' : $year,
      'format' : $format
    }
    let $content := map{
      'experts' : xpr.models.networks:getExpertsByYear($queryParam)
    }
    let $outputParam := map{}
    return xpr.models.networks:getFormatedExpertsData($queryParam, $content, $outputParam)
};

(:
 : this function returns clerks data for a specific year.
 :)
declare
  %rest:path("/xpr/data/{$year}/clerks")
  %rest:produces("application/csv")
  %output:method("csv")
  %rest:query-param("format", "{$format}", "csv")
function getClerksDataByYear($year as xs:string, $format as xs:string) {
    let $queryParam := map{
      'year' : $year,
      'format' : $format
    }

    let $content := map{
      'clerks' : xpr.models.networks:getClerksByYear($queryParam)
    }

    let $outputParam := map{

    }
    return xpr.models.networks:getFormatedClerksData($queryParam, $content, $outputParam)
};

(:
 : this function returns expertises data for a specific year.
 :)
declare
  %rest:path("/xpr/data/{$year}/expertises")
  %rest:produces("application/csv")
  %output:method("csv")
  %rest:query-param("format", "{$format}", "csv")
function getExpertisesDataByYear($year as xs:string, $format as xs:string) {
    let $queryParam := map{
      'year' : $year,
      'format' : $format
    }

    let $content := map{
      'expertises' : xpr.models.networks:getExpertisesByYear($queryParam),
      'experts' : xpr.models.networks:getExpertsByYear($queryParam)
    }

    let $outputParam := map{

    }
    return xpr.models.networks:getFormatedExpertisesData($queryParam, $content, $outputParam)
};

(:~
 : This function consumes 
 : @param $year content
 : 
 :)
declare
  %rest:path("xpr/networks/{$year}")
  %output:method("json")
  %rest:produces("application/json")
function getNetworks($year) {
  let $expertises := getExpertises()//expertise[sourceDesc/unitdate[fn:normalize-space(.) = $year]][fn:count(.//participants/experts/expert) = 2]
  let $experts := fn:distinct-values(getExpertises()//expertise[sourceDesc/unitdate[fn:normalize-space(.) = $year]]//participants/experts/expert/@ref)
  
  let $nodes := 
    for $expert in $experts
    return map {
      'id' : $expert,
      'name' : $expert
    }
  
  let $edges := 
    for $expertise in $expertises
    return map {
      'source_id' : fn:string($expertise//participants/experts/expert[1]/@ref),
      'target_id' : fn:string($expertise//participants/experts/expert[2]/@ref)
    }
  return 
  map {
    'nodes' : array{$nodes},
    'links' : array{$edges}
  }
};

(:~
 : This function consumes 
 : @param $year content
 : 
 :)
declare
  %rest:path("xpr/networks/{$year}/viz")
  %output:method("html")
function getNetworkViz($year) {
<html>
    <head>
        <title></title>
    </head>
    <body>
    <svg width="1000" height="1000"></svg>
    <script src="https://d3js.org/d3.v4.min.js"></script>
    <script>

var svg = d3.select("svg"),
    width = +svg.attr("width"),
    height = +svg.attr("height");

var simulation = d3.forceSimulation()
    .force("link", d3.forceLink().id(function(d) {{ return d.id; }}))
    .force("charge", d3.forceManyBody().strength(-80))
    .force("center", d3.forceCenter(width / 2, height / 2));


d3.json("/xpr/networks/{$year}", function(error, graph) {{
  if (error) throw error;
  
  graph.links.forEach(function(d){{
    d.source = d.source_id;    
    d.target = d.target_id;
  }});           

  var link = svg.append("g")
                .style("stroke", "#aaa")
                .selectAll("line")
                .data(graph.links)
                .enter().append("line");

  var node = svg.append("g")
            .attr("class", "nodes")
  .selectAll("circle")
            .data(graph.nodes)
  .enter().append("circle")
          .attr("r", 2)
          .call(d3.drag()
              .on("start", dragstarted)
              .on("drag", dragged)
              .on("end", dragended));
  
  var label = svg.append("g")
      .attr("class", "labels")
      .selectAll("text")
      .data(graph.nodes)
      .enter().append("text")
        .attr("class", "label")
        .text(function(d) {{ return d.name; }});

  simulation
      .nodes(graph.nodes)
      .on("tick", ticked);

  simulation.force("link")
      .links(graph.links);

  function ticked() {{
    link
        .attr("x1", function(d) {{ return d.source.x; }})
        .attr("y1", function(d) {{ return d.source.y; }})
        .attr("x2", function(d) {{ return d.target.x; }})
        .attr("y2", function(d) {{ return d.target.y; }});

    node
         .attr("r", 10)
         .style("fill", "#d9d9d9")
         .style("stroke", "#969696")
         .style("stroke-width", "1px")
         .attr("cx", function (d) {{ return d.x+6; }})
         .attr("cy", function(d) {{ return d.y-6; }});
    
    label
    		.attr("x", function(d) {{ return d.x; }})
            .attr("y", function (d) {{ return d.y; }})
            .style("font-size", "10px").style("fill", "#4393c3");
  }}
}});

function dragstarted(d) {{
  if (!d3.event.active) simulation.alphaTarget(0.3).restart()
  simulation.fix(d);
}}

function dragged(d) {{
  simulation.fix(d, d3.event.x, d3.event.y);
}}

function dragended(d) {{
  if (!d3.event.active) simulation.alphaTarget(0);
  simulation.unfix(d);
}}

</script>
    </body>
</html>

};

(:
 : this function returns a resource with expertises network for a specific year.
 :)
declare
  %rest:path("/xpr/networks/{$year}/expertises")
  %rest:produces("application/csv")
  %output:method("csv")
  %rest:query-param("format", "{$format}", "csv")
function getExpertisesNetworkByYear($year as xs:string, $format as xs:string) {
  let $queryParam := map{
    'year' : $year,
    'format' : $format
  }
  let $content := map{
    'expertises' : xpr.models.networks:getExpertisesByYear($queryParam),
    'experts' : xpr.models.networks:getExpertsByYear($queryParam)
  }
  let $outputParam := map{}

  return xpr.models.networks:getFormatedExpertisesNetwork($queryParam, $content, $outputParam)
};

(:
 : this function returns csv resource for clerks network by year.
 :)
declare
  %rest:path("/xpr/networks/{$year}/clerks")
  %rest:produces("application/csv")
  %output:method("csv")
  %rest:query-param("format", "{$format}", "csv")
function getClerksNetworkByYear($year as xs:string, $format as xs:string) {
    let $queryParam := map{
      'year' : $year,
      'format' : $format
    }

    let $content := map{
      'expertises' : xpr.models.networks:getExpertisesByYear($queryParam),
      'experts' : xpr.models.networks:getExpertsByYear($queryParam),
      'clerks' : xpr.models.networks:getClerksByYear($queryParam)
    }

    let $outputParam := map{

    }
    return xpr.models.networks:getFormatedClerksNetwork($queryParam, $content, $outputParam)
};

(:
 : this function returns csv resource for categories network by year.
 :)
declare
  %rest:path("/xpr/networks/{$year}/categories")
  %rest:produces("application/csv")
  %output:method("csv")
  %rest:query-param("format", "{$format}", "csv")
function getCategoriesNetworkByYear($year as xs:string, $format as xs:string) {
  let $queryParam := map{
    'year' : $year,
    'format' : $format
  }
  let $content := map{
    'expertises' : xpr.models.networks:getExpertisesByYear($queryParam),
    'experts' : xpr.models.networks:getExpertsByYear($queryParam)
  }
  let $outputParam := map{}

  return xpr.models.networks:getFormatedCategoriesNetwork($queryParam, $content, $outputParam)
};

(:~
 :
 :)
declare
  %rest:path("/xpr/reseau")
  %rest:produces("application/xml")
  %output:method("xml")
  %rest:query-param("format", "{$format}", "gexf")
function getReseau($format as xs:string) {
  xpr.models.networks:getExpertsCollaborations(map{})
};

(:
 :view doesn't work for now
 :)
declare
  %rest:path("/xpr/reseau/view")
  %rest:produces("application/xml")
  %output:method("xml")
  %rest:query-param("format", "{$format}", "gexf")
function getReseauHtml($format as xs:string) {
  let $content := map {
      'title' : 'Liste des expertises',
      'data' : getReseau($format)
    }
    let $outputParam := map {
      'layout' : "listeExpertise.xml",
      'mapping' : xpr.mappings.html:listXpr2html(map:get($content, 'data'), map{})
    }
    return xpr.models.xpr:wrapper($content, $outputParam)
};

(:~
 :
 :)
declare
  %rest:path("/xpr/reseau/{$year}")
  %rest:produces("application/xml")
  %output:method("xml")
  %rest:query-param("format", "{$format}", "gexf")
function getReseauByYear($year as xs:string, $format as xs:string) {
  let $queryParam := map{
    'year' : $year,
    'format' : $format
  }
  return xpr.models.networks:getExpertsCollaborations($queryParam)
};

(:
 : view doesn't work for now
 :)
declare
  %rest:path("/xpr/reseau/{$year}/view")
  %rest:produces("application/xml")
  %output:method("xml")
  %rest:query-param("format", "{$format}", "gexf")
function getReseauByYearHtml($year as xs:string, $format as xs:string) {
  let $content := map {
      'title' : 'Liste des expertises',
      'data' : xpr.models.networks:getExpertsCollaborations($year)
  }
  let $outputParam := map {
      'layout' : "listeExpertise.xml",
      'mapping' : xpr.mappings.html:listXpr2html(map:get($content, 'data'), map{})
  }

  return xpr.models.xpr:wrapper($content, $outputParam)
};

(:~
 : This resource function lists all the expertises
 : @return an ordered list of expertises in json
 : @todo to develop
 :)
declare
  %rest:path("/xpr/statistics")
  %rest:produces('application/json')
  %output:media-type('application/json')
  %output:method('json')
function getStatistics() {
  let $db := db:open("xpr")
  let $expertises := getExpertises()/expertise
  (:@todo experts:)
  let $experts := getBiographies()/*:eac
  (:let $years := fn:distinct-values($db/xpr/expertises/expertise/description/sessions/date[1][@when castable as xs:date][fn:ends-with(fn:string(fn:year-from-date(@when)), '6')]/fn:year-from-date(@when)):)
  (:let $expertises := map {
    "corpus" : getExpertisesStatistics(""),
    "expertisesByYear" : array{
      for $year in $years
      return map {
        $year : getExpertisesStatistics($year)
      }
    }
  }:)
  let $expertises := xpr.models.statistics:getExpertisesStatistics($expertises, $experts)
  return map{
    "expertises" : $expertises,
    "experts" : $experts
  }
};

(:~
 : This resource function produces stats
 : @return a list of stats on expertises and experts in json
 :)

(:~
 : This resource function produces stats
 : @return a list of stats on expertises and experts in json
 :)
declare
  %rest:path("/xpr/statistics/{$year}")
  %rest:produces('application/json')
  %output:media-type('application/json')
  %output:method('json')
function getStatisticsByYear($year) {
  let $listExpertises := getExpertises()/expertise[sourceDesc/unitdate[fn:normalize-space(.) = $year]]
  let $listExperts := xpr.models.networks:getExpertsByYear(map{"year":$year})//*:eac
  let $experts := xpr.models.networks:getFormatedExpertsData(
    map{
      "year" : $year,
      "format" : "xml"
    },
    map{
      "experts" : $listExperts
    },
    map{

    }
  )
  (:let $years := fn:distinct-values($db/xpr/expertises/expertise/description/sessions/date[1][@when castable as xs:date][fn:ends-with(fn:string(fn:year-from-date(@when)), '6')]/fn:year-from-date(@when)):)
  (:let $expertises := map {
    "corpus" : getExpertisesStatistics(""),
    "expertisesByYear" : array{
      for $year in $years
      return map {
        $year : getExpertisesStatistics($year)
      }
    }
  }:)
  let $expertises := xpr.models.statistics:getExpertisesStatistics($listExpertises, $experts)
  let $experts := xpr.models.statistics:getExpertsStatistics($experts, $listExpertises)
  return map{
    "corpus" : $year,
    "expertises" : $expertises,
    "experts" : $experts
  }
};

(:~
 : this function queries term in xpr database
 : @param $term
 : @todo use XQFT
 : @todo use mapping
 :)
declare
%rest:path('/xpr/query/{$term}')
%rest:produces('application/html')
%output:method("html")
%output:html-version('5.0')
function xpr.xpr:query($term) {
  let $data := xpr.xpr:queryData($term)
  let $expertises := fn:count($data//expertise)
  let $diacritics := 'ÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÑÒÓÔÕÖÙÚÛÜÝàáâãäåçèéêëìíîïñòóôõöùúûüýÿ'
  let $noAccent := 'AAAAAACEEEEIIIINOOOOOUUUUYaaaaaaceeeeiiiinooooouuuuyy'
  return
    <html>
      <head>
        {$xpr.xpr:style}
        <!--<link href="/xpr/files/css/normalize.css" rel="stylesheet" />
        <link href="/xpr/files/css/main.css" rel="stylesheet" />-->
      </head>
      <body>
        <nav></nav>
        <main>
          <h1>Expertises mentionnant « {$term} »</h1>
          <p>Nombre d’expertises : {$expertises}</p>
          <div>
            <table>
              <thead>
                <tr>
                  <td><span>Année</span></td>
                  {
                  for $cat in fn:distinct-values($data//categories/fn:string-join(category, ' - '))
                  order by $cat
                  return
                  <td><span>{$cat}</span></td>
                  }
                  <td><span>nb expertises</span></td>
                  <td><span>total année</span></td>
                  <td><span>pourcentage</span></td>
                </tr>
              </thead>
              <tbody>
              {
              for $year in fn:distinct-values($data//year)
              let $expertiseCount := fn:count($data//expertise[year = $year])
              let $expertiseYear := fn:count(getExpertises()//expertise[descendant::sessions/date[1]/fn:substring(@when, '1', '4') = $year])
              let $pourcentage := fn:format-number($expertiseCount div $expertiseYear, '0%')
              order by $year
              return (
              <tr>
                <td>{$year}</td>
                {
                for $cat in fn:distinct-values($data//categories/fn:string-join(category, ' - '))
                order by $cat
                return(
                  <td>
                    {
                    let $num := fn:count($data//expertise[year = $year][fn:string-join(categories/category, ' - ') = $cat])
                    return
                    if ($num != 0) then $num
                    else ''
                    }
                  </td>
                )
                }
                <td>{$expertiseCount}</td>
                <td>{$expertiseYear}</td>
                <td>{$pourcentage}</td>
              </tr>
              )
              }
              </tbody>
            </table>
          </div>
          <div class="detail">
            <table>
              <thead>
                <tr>
                  <td>ID</td>
                  <td>Catégories d’expertise</td>
                  <td>Désignation</td>
                  <td>Causes</td>
                  <td>Conclusions</td>
                  <td>Keywords</td>
                </tr>
              </thead>
              <tbody>
              {
                let $listExpertises := getExpertises()//expertise[fn:matches(fn:translate(fn:normalize-space(.), $diacritics, $noAccent), fn:translate($term, $diacritics, $noAccent), 'i')]
                for $expertise in $listExpertises
                order by $expertise/@xml:id
                return
                <tr>
                  <td>
                  {
                  let $unitid := fn:normalize-space($expertise/@xml:id)
                  let $path := '/xpr/expertises/' || $unitid || '/view'
                  return <a href="{$path}">{$unitid}</a>
                  }
                  </td>
                  <td>
                    <ul>
                    {
                      for $cat in $expertise/description/categories/category
                      return <li>{fn:normalize-space($cat)}</li>
                    }
                    </ul>
                  </td>
                  <td>
                  {
                    if($expertise//designation[fn:matches(fn:translate(fn:normalize-space(.), $diacritics, $noAccent), fn:translate($term, $diacritics, $noAccent), 'i')])
                    then 'X'
                    else ''
                  }
                  </td>
                  <td>
                  {
                    if($expertise//case[fn:matches(fn:translate(fn:normalize-space(.), $diacritics, $noAccent), fn:translate($term, $diacritics, $noAccent), 'i')])
                    then 'X'
                    else ''
                  }
                  </td>
                  <td>
                  {
                    if($expertise//opinion[fn:matches(fn:translate(fn:normalize-space(.), $diacritics, $noAccent), fn:translate($term, $diacritics, $noAccent), 'i')])
                    then 'X'
                    else ''
                  }
                  </td>
                  <td>
                  {
                    if($expertise//keywords[fn:matches(fn:translate(fn:normalize-space(.), $diacritics, $noAccent), fn:translate($term, $diacritics, $noAccent), 'i')])
                    then 'X'
                    else ''
                  }
                  </td>
                </tr>
              }
              </tbody>
            </table>
          </div>
        </main>
      </body>
    </html>
};

declare function xpr.xpr:queryData($term) {
let $diacritics := 'ÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÑÒÓÔÕÖÙÚÛÜÝàáâãäåçèéêëìíîïñòóôõöùúûüýÿ'
let $noAccent := 'AAAAAACEEEEIIIINOOOOOUUUUYaaaaaaceeeeiiiinooooouuuuyy'
return (
    <expertises>
        {
            for $expertise in getExpertises()//expertise[fn:matches(fn:translate(fn:normalize-space(.), $diacritics, $noAccent), fn:translate($term, $diacritics, $noAccent), 'i')]
            (:where $expertise//text() contains text "réparation":)
            return
            (
            <expertise>
                <unitid>{$expertise//idno[@type='unitid']}</unitid>
                <item>{$expertise//idno[@type='item']}</item>
                <categories>{
                    if($expertise//categories/category) then
                    for $category in $expertise//categories/category
                    order by $category/fn:normalize-space(@type)
                    return (
                      <category>{
                      switch ($category/fn:normalize-space(@type))
                      case 'acceptation' return 'Recevoir et évaluer le travail réalisé'
                      case 'registration' return 'Enregistrer'
                      case 'settlement' return 'Départager'
                      case 'assessment' return 'Décrire et évaluer les travaux à venir'
                      case 'estimation' return 'Estimer la valeur des biens'
                      default return ""
                      }</category>
                    )
                    else <category>Pas de catégorie</category>
                }</categories>
                <year>{$expertise//sessions/date[1]/fn:substring(@when, '1', '4')}</year>
            </expertise>
            )
        }
    </expertises>
)
};