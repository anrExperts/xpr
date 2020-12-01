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

declare namespace ev = "http://www.w3.org/2001/xml-events" ;
declare namespace eac = "eac" ;

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
 : This resource function install
 : @return create the db
 :
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
  %rest:path("/xpr/expertises/export")
function z1jExport(){
  db:export("xpr", file:base-dir(), map { 'method': 'xml' }),
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
 : This resource function lists all the expertises
 : @return an ordered list of expertises in xml
 :)
declare 
  %rest:path("/xpr/expertises")
  %rest:produces('application/xml')
  %output:method("xml")
function getExpertises() {
  db:open('xpr')/xpr/expertises
};

(:~
 : This resource function lists all the expertises
 : @return an ordered list of expertises in html
 :)
declare
  %rest:path("/xpr/expertises/view")
  %rest:produces('application/html')
  %output:method("html")
  %output:html-version('5.0')
function getExpertisesHtml() {
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
  return
    (processing-instruction xml-stylesheet { fn:concat("href='", $G:xsltFormsPath, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    xpr.models.xpr:wrapper($content, $outputParam)
    )
};

(:~
 : This resource function lists all the expertises
 : @return an ordered list of expertises in json
 : @todo to develop
 :)
declare 
  %rest:path("/xpr/expertises/json")
  %rest:produces('application/json')
  %output:media-type('application/json')
  %output:method('json')
function getExpertisesJson() {
  let $content := db:open('xpr')//expertise
  return map{'test' : 1}
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
    'data' : db:open('xpr')//expertise,
    'trigger' : '',
    'form' : ''
  }
  let $outputParam := map {
    'layout' : "listeExpertiseSaxon.xml"
  }
  return xpr.models.xpr:wrapper($content, $outputParam)
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
  db:open('xpr')//expertise[@xml:id=$id]
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
 : @return an expertise item in html
 :)
declare 
  %rest:path("xpr/expertises/{$id}/saxon")
  %rest:produces('application/html')
  %output:method("html")
function getExpertiseSaxon($id) {
  let $content := map {
    'data' : db:open('xpr')//expertise[@xml:id=$id],
    'trigger' : '',
    'form' : ''
  }
  let $outputParam := map {
    'layout' : "ficheExpertiseSaxon.xml"
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
  let $expertise := db:open('xpr')//expertise[@xml:id=$id]
  return array{
    map{
    'type' : $expertise/sourceDesc/idno[@type='unitid'] => fn:string(),
    'date' : $expertise/description/sessions/date/@when => fn:string()
    }
  }
};

(:~
 : This resource function edits a new expertise
 : @return an xforms to edit an expertise
:)
declare
  %rest:path("xpr/expertises/new")
  %output:method("xml")
function newExpertise() {
  let $content := map {
    'instance' : '',
    'model' : 'xprExpertiseModel.xml',
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
 : This resource function modify an expertise item
 : @param $id the expertise id
 : @return an xforms to edit the expertise
 :)
declare 
  %rest:path("xpr/expertises/{$id}/modify")
  %output:method("xml")
function modifyExpertise($id) {
  let $content := map {
    'instance' : $id,
    'path' : 'expertises',
    'model' : 'xprExpertiseModel.xml',
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
  %updating
function putExpertise($param, $referer) {
  let $db := db:open("xpr")
  return 
    if (fn:ends-with($referer, 'modify'))
    then 
      let $location := fn:analyze-string($referer, 'xpr/expertises/(.+?)/modify')//fn:group[@nr='1']
      let $id := fn:replace(fn:lower-case($param/expertise/sourceDesc/idno[@type="unitid"]), '/', '-') || 'd' || fn:format-integer($param/expertise/sourceDesc/idno[@type="item"], '000')
      let $param :=
        copy $d := $param
        modify (
          replace value of node $d/expertise/@xml:id with $id,
          for $place at $i in $d/expertise/description[categories/category[@type="estimation"]]/places/place
          let $idPlace := fn:generate-id($place)
          where $place[fn:not(@xml:id)]
          return (
            insert node attribute xml:id {$idPlace} into $place,
            insert node attribute ref {fn:concat('#', $idPlace)} into $d/expertise/description/conclusions/estimates/place[$i]
            )
        )
        return $d
      return (
        replace node $db/xpr/expertises/expertise[@xml:id = $location] with $param,
        update:output(
         (
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
         )
        )
      )  
    else
      let $id := fn:replace(fn:lower-case($param/expertise/sourceDesc/idno[@type="unitid"]), '/', '-') || 'd' || fn:format-integer($param/expertise/sourceDesc/idno[@type="item"], '000')
      let $param := 
        copy $d := $param
        modify (
          insert node attribute xml:id {$id} into $d/*,
          for $place at $i in $d/expertise/description[categories/category[@type="estimation"]]/places/place
          let $idPlace := fn:generate-id($place)
          return (
            insert node attribute xml:id {$idPlace} into $place,
            insert node attribute ref {fn:concat('#', $idPlace)} into $d/expertise/description/conclusions/estimates/place[$i]
          )
        )
        return $d
      return (
        insert node $param into $db/xpr/expertises,
        update:output(
         (
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
         )
        )
      )  
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
 : This resource function lists the persons or corporate bodies
 : @return an xml list of persons/corporate bodies
 :)
declare 
  %rest:path("/xpr/biographies")
  %rest:produces('application/xml')
  %output:method("xml")
function getBiographies() {
  db:open('xpr')/xpr/bio
};

(:~
 : This resource function lists all the expertises
 : @return an ordered list of expertises in html
 :)
declare
  %rest:path("/xpr/biographies/view")
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
 : This resource function lists all the biographies
 : @return an html list of persons/corporate bodies
 :)
declare 
  %rest:path("/xpr/biographies/old")
  %rest:produces('text/html')
  %output:method("html")
function getBiographiesOld() {
  <html>
    <head>Expertises</head>
    <body>
      <h1>xpr Biographies</h1>
      <p><a href="/xpr/biographies/new">Nouvelle fiche</a></p>
      <ul>
      {
        for $entity in db:open('xpr')//bio/eac:eac-cpf
        let $id := $entity/eac:cpfDescription//eac:entityId
        let $identity := $entity//eac:nameEntry[child::eac:authorizedForm]/eac:part
        return 
          <li>
            <a href="/xpr/biographies/{$id}">{$identity}</a> 
            <a href="/xpr/biographies/{$id}/modify">Modifier</a>
          </li>
      }
      </ul>
    </body>
  </html>
};

(:~
 : This resource function lists all the entities
 : @return an ordered list of entities
 :)
declare 
  %rest:path("/xpr/biographies/saxon")
  %rest:produces('application/html')
  %output:method("html")
function getEntitiesListSaxon() {
  let $content := map {
    'data' : db:open('xpr')//bio,
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
 : @return an xml representation of an entitu
 :)
declare 
  %rest:path("xpr/biographies/{$id}")
  %output:method("xml")
function getBiography($id) {
  db:open('xpr')//eac:eac-cpf[eac:cpfDescription/eac:identity/eac:entityId=$id]
};

(:~
 : This resource function show an entity
 : @return an html view of an entity
 :)
declare 
  %rest:path("/xpr/biographies/{$id}/saxon")
  %rest:produces('application/html')
  %output:method("html")
function getBiographyXforms($id) {
  let $content := map {
    'data' : db:open('xpr')//eac:eac-cpf[eac:cpfDescription/eac:identity/eac:entityId=$id],
    'trigger' : '',
    'form' : ''
  }
  let $outputParam := map {
    'layout' : "ficheProsopoSaxon.xml"
  }
  return xpr.models.xpr:wrapper($content, $outputParam)
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
    'data' : getBiography($id),
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
 : This resource function modify an entity
 : @return an xforms to modify an entity
 :)
declare 
  %rest:path("xpr/biographies/{$id}/modify")
  %output:method("xml")
function modifyEntity($id) {
  let $content := map {
    'instance' : $id,
    'path' : 'biographies',
    'model' : ('xprProsopoModel.xml', 'xprSourceModel.xml', 'xprInventoryModel.xml'),
    'trigger' : 'xprProsopoTrigger.xml',
    'form' : 'xprProsopoForm.xml'
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
 : This resource function creates an new entity
 : @return an xforms for the entity
:)
declare
  %rest:path("xpr/biographies/new")
  %output:method("xml")
function newBiography() {
  let $content := map {
    'instance' : '',
    'model' : ('xprProsopoModel.xml', 'xprSourceModel.xml', 'xprInventoryModel.xml'),
    'trigger' : 'xprProsopoTrigger.xml',
    'form' : 'xprProsopoForm.xml'
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
 : This function consumes new entity 
 : @param $param content
 :)
declare
  %rest:path("xpr/biographies/put")
  %output:method("xml")
  %rest:header-param("Referer", "{$referer}", "none")
  %rest:PUT("{$param}")
  %updating
function putBiography($param, $referer) {
  let $db := db:open("xpr")
  return 
    if ($param/*/@xml:id)
    then
      let $location := fn:analyze-string($referer, 'xpr/biographies/(.+?)/modify')//fn:group[@nr='1']
      let $id := $param//*:entityId
      (: let $param := 
        copy $d := $param
        modify replace value of node $d/@xml:id with $id
        return $d :)
      return replace node $db/xpr/bio/eac:eac-cpf[@xml:id = $location] with $param  
    else
      let $id :=
        for $type in $param//eac:identity/@localType
        return switch ($type)
          case 'expert' return 'xpr' || fn:format-integer(fn:count($db//eac:eac-cpf[descendant::eac:identity/@localType = 'expert']) + 1, '0000')
          case 'mason' return 'mas' || fn:format-integer(fn:count($db//eac:eac-cpf[descendant::eac:identity/@localType = 'mason']) + 1, '0000')
          case 'person' return 'xprPerson' || fn:format-integer(fn:count($db//eac:eac-cpf[descendant::eac:identity/@localType = 'person']) + 1, '0000')
          case 'office' return 'xprOffice' || fn:format-integer(fn:count($db//eac:eac-cpf[descendant::eac:identity/@localType = 'office']) + 1, '0000')
          case 'notary' return 'xprNotary' || fn:format-integer(fn:count($db//eac:eac-cpf[descendant::eac:identity/@localType = 'notary']) + 1, '0000')
          case 'org' return 'xprOrg' || fn:format-integer(fn:count($db//eac:eac-cpf[descendant::eac:identity/@localType = 'org']) + 1, '0000')
          case 'family' return 'xprFamily' || fn:format-integer(fn:count($db//eac:eac-cpf[descendant::eac:identity/@localType = 'family']) + 1, '0000')
          default return 'xprPerson' || fn:format-integer(fn:count($db//eac:eac-cpf[descendant::eac:identity/@localType = 'person']) + 1, '0000')
      let $param := 
        copy $d := $param
        modify 
        (
          insert node attribute xml:id {$id} into $d/*,
          replace value of node $d//eac:entityId with $id
        )
        return $d
      return (
        insert node $param into $db/xpr/bio,
        update:output(
          (
          <rest:response>
            <http:response status="200" message="">
              <http:header name="Content-Language" value="fr"/>
              <http:header name="Content-Type" value="text/plain; charset=utf-8"/>
            </http:response>
          </rest:response>,
          <result>
            <id>{$id}</id>
            <message>Une nouvelle entité a été ajoutée : {$param//eac:nameEntry[eac:authorizedForm]/eac:part}.</message>
          </result>
          )
        )
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
  <entities xmlns="xpr">
    {
      for $entity in db:open('xpr')/xpr/bio/eac:eac-cpf
      let $id := $entity/@xml:id
      order by fn:lower-case($entity//eac:nameEntry[child::eac:authorizedForm])
      return <entity xml:id="{$id}" type="{$entity//eac:identity/@localType}"><label>{$entity//eac:nameEntry[child::eac:authorizedForm]/eac:part/text()}</label></entity>
    }
  </entities>
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
  db:open('xpr')/xpr/posthumousInventories
};

(:~
 : This resource function lists all the inventories
 : @return an ordered list of posthumous inventories
 :)
declare 
%rest:path("/xpr/inventories/view")
%rest:produces('text/html')
%output:method("html")
function getInventoriesHtml() {
  <html>
    <head>Inventaires après-décès</head>
    <body>
      <h1>xpr Inventaire après-décès</h1>
      <p><a href="/xpr/inventories/new">Nouvelle fiche</a></p>
    </body>
  </html>
};

(:~
 : This resource function edits new inventory
 : @return an xforms for the inventory
:)
declare
  %rest:path("xpr/inventories/new")
  %output:method("xml")
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
  %updating
function putInventory($param, $referer) {
  let $db := db:open("xpr")
  return insert node $param into $db/xpr/posthumousInventories
};


(:~
 : This function consumes new relations 
 : @param $param content
 : @
 :)
declare
  %rest:path("xpr/relations/put")
  %output:method("xml")
  %rest:header-param("Referer", "{$referer}", "none")
  %rest:PUT("{$param}")
  %updating
function putRelation($param, $referer) {
  let $db := db:open("xpr")
  let $expert := $param/inventory/sourceDesc/expert/@ref
  for $relation in $param//eac:relations/eac:cpfRelation
  return 
  if ($db//eac:eac-cpf[@xml:id = $expert]//eac:relations/eac:cpfRelation[@xlink:href = $relation/@xlink:href][@xlink:arcrole = $relation/@xlink:arcrole])
  then
    for $source in $db//eac:eac-cpf[@xml:id = $expert]//eac:relations/eac:cpfRelation[@xlink:href = $relation/@xlink:href][@xlink:arcrole = $relation/@xlink:arcrole]/xpr:source/@xlink:href
    return switch ($source)
      case $relation/xpr:source/@xlink:href return ()
      default return insert node $relation/xpr:source into $db//eac:eac-cpf[@xml:id = $expert]//eac:relations/eac:cpfRelation[@xlink:href = $relation/@xlink:href][@xlink:arcrole = $relation/@xlink:arcrole]
  else
    insert node $relation into $db//eac:eac-cpf[@xml:id = $expert]//eac:relations
};


(:~
 : This resource function lists all the sources
 : @return an ordered xml ressource of all the sources
 : @todo collation for order by (for accent)
 :)
declare 
%rest:path("/xpr/sources")
%rest:produces('application/xml')
%output:method("xml")
function getSources() {
  <sources xmlns="xpr">
    {
      for $source in db:open('xpr')/xpr/sources/source
      order by fn:lower-case($source/text())
      return $source
    }
  </sources>
};

(:~
 : This resource function lists all the sources
 : @return an ordered list of sources
 :)
declare 
  %rest:path("/xpr/sources/view")
  %rest:produces('text/html')
  %output:method("html")
function getSourcesHtml() {
  <html>
    <head>Source</head>
    <body>
      <h1>xpr Source</h1>
      <p><a href="/xpr/sources/new">Nouvelle fiche</a></p>
       <ul>
      {
        for $source in db:open('xpr')/xpr/sources/source
        let $id := fn:replace($source, '[^a-zA-Z0-9]', '-')
        return 
          <li>
            <a href="/xpr/sources/{$id}">{$source}</a> 
            <a href="/xpr/sources/{$id}/modify">Modifier</a>
          </li>
      }
      </ul>
    </body>
  </html>
};

(:~
 : This resource function edits new source
 : @return an xforms for the source
:)
declare
  %rest:path("xpr/sources/new")
  %output:method("xml")
function newSource() {
  let $content := map {
    'instance' : '',
    'model' : 'xprSourceModel.xml',
    'trigger' : 'xprSourceTrigger.xml',
    'form' : 'xprSourceForm.xml'
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
 : This resource function lists all the sources
 : @return an ordered list of sources
 :)
declare 
  %rest:path("xpr/sources/{$id}")
  %output:method("xml")
function getSource($id) {
  db:open('xpr')/xpr/sources/source[fn:replace(., '[^a-zA-Z0-9]', '-') = $id]
};

(:~
 : This resource function lists all the expertises
 : @return an ordered list of expertises
 :)
declare 
  %rest:path("xpr/sources/{$id}/modify")
  %output:method("xml")
function modifySource($id) {
  let $content := map {
    'instance' : $id,
    'model' : 'xprSourceModel.xml',
    'trigger' : 'xprSourceTrigger.xml',
    'form' : 'xprSourceForm.xml'
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
 : This function consumes new source 
 : @param $param content
 : @todo mettre en place une routine pour empêcher l'ajout d'une référence si elle est déjà présente
 :)
declare
  %rest:path("xpr/sources/put")
  %output:method("xml")
  %rest:header-param("Referer", "{$referer}", "none")
  %rest:PUT("{$param}")
  %updating
function putSource($param, $referer) {
  let $db := db:open("xpr")
  let $origin := fn:analyze-string($referer, 'xpr/(.+?)/(.+?)/modify')//fn:group[@nr='1']
  return
    if (fn:ends-with($referer, 'modify'))
    then
      switch ($origin)
      case 'biographies' return insert node $param into $db/xpr/sources
      default return let $location := fn:analyze-string($referer, 'xpr/sources/(.+?)/modify')//fn:group[@nr='1']
      return replace node $db/xpr/sources/source[fn:replace(., '[^a-zA-Z0-9]', '-') = $location] with $param 
    else
      insert node $param into $db/xpr/sources,
      update:output(
        (
        <rest:response>
          <http:response status="200" message="test">
            <http:header name="Content-Language" value="fr"/>
            <http:header name="Content-Type" value="text/plain; charset=utf-8"/>
          </http:response>
        </rest:response>,
        <result>
          <id>{$param/source/text()}</id>
          <message>Une nouvelle source a été ajoutée : {$param/source/text()}.</message>
          <url></url>
        </result>
        )
      )
};

(:~
 : This function consumes 
 : @param $year content
 : 
 :)
(: declare
  %rest:path("xpr/networks/{$year}")
  %output:method("json")
  %rest:produces('application/json')
function networks($year) {
  
  let $expertises := db:open('xpr')//expertise[description/sessions/date[1][fn:starts-with(@when, $year)]][fn:count(.//participants/experts/expert) = 2]
  let $experts := fn:distinct-values(db:open('xpr')//expertise[description/sessions/date[1][fn:starts-with(@when, $year)]]//participants/experts/expert/@ref)
  
  let $nodes := 
    for $expert in $experts
    return map {
      'id' : $expert,
      'label' : $expert,
      'x' : '',
      'y' : '',
      'size' : '2'
    }
  
  let $edges := 
    for $expertise in $expertises
    return map {
      'id' : fn:string($expertise/@xml:id),
      'source' : fn:string($expertise//participants/experts/expert[1]/@ref),
      'target' : fn:string($expertise//participants/experts/expert[2]/@ref)
    }
  
  return 
  map {
    'nodes' : array{$nodes},
    'edges' : array{$edges}
  }
}; :)

(:~
 : This function consumes 
 : @param $year content
 : 
 :)
declare
  %rest:path("xpr/networks/{$year}")
  %output:method("json")
  %rest:produces('application/json')
function getNetworks($year) {
  let $expertises := db:open('xpr')//expertise[description/sessions/date[1][fn:starts-with(@when, $year)]][fn:count(.//participants/experts/expert) = 2]
  let $experts := fn:distinct-values(db:open('xpr')//expertise[description/sessions/date[1][fn:starts-with(@when, $year)]]//participants/experts/expert/@ref)
  
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
 : view doesn't work for now
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
 : This resource function lists all the expertises with 2 or more categories
 : @return an ordered list of expertises in xml
 :)
declare 
  %rest:path("/xpr/dualcat")
  %rest:produces('application/xml')
  %output:method("xml")
function getExpertisesDualCategories() {
  <expertises>{db:open('xpr')/xpr/expertises/expertise[fn:count(descendant::category) > 1]}</expertises>
};

(:~
 : This resource function lists all the expertises
 : @return an ordered list of expertises in html
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
 : This function consumes 
 : @param $year content
 : 
 :)
(: declare
  %rest:path("xpr/networks/{$year}/viz")
  %output:method("html")
function networkViz($year) {
  <html>
    <head>
      <title>Basic sigma.js example</title>
      <style type="text/css">
        <![CDATA[body {
        margin: 0;
      }
    #container {
      position: absolute;
      width: 100%;
      height: 100%;
    }
    ]]>
  </style>
</head>
<body>
  <div id="container"></div>
  <script src="/xpr/files/js/sigma/build/sigma.require.js"></script>
  <script src="/xpr/files/js/sigma/build/plugins/sigma.parsers.json.min.js"></script>
  <script src="/xpr/files/js/sigma/plugins/sigma.layout.forceAtlas2/worker.js"></script>
  <script src="/xpr/files/js/sigma/plugins/sigma.layout.forceAtlas2/supervisor.js"></script>
  <script>
    sigma.parsers.json('/xpr/networks/{$year}', {{
      container: 
        'container',
        settings: {{
          defaultNodeColor: '#ec5148'
        }}
    }});
    sigma.startForceAtlas2({{linLogMode: true, worker: true, barnesHutOptimize: false}});
    sigma.graph.nodes();
    sigma.refresh();
  </script>
</body>
</html>

}; :)


(:~
 : ~:~:~:~:~:~:~:~:~
 : utilities 
 : ~:~:~:~:~:~:~:~:~
 :)

(:~
 : this function defines a static files directory for the app
 :
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
              width : 800px;
              margin: auto;
            }}
            table {{
             display: inline;
             border-collapse:collapse
             }}
            td {{
             border-width:1px;
             border-style:solid;
             border-color:red;
             }}
            .label td {{
              font-weight: bold;
            }}
            tr:not(.label) td {{
            text-align: center;
            }}

            .vertical {{
            writing-mode: vertical-rl;
            text-orientation: sideways;
            min-width: 20px;
            }}
            div {{
            margin-bottom : 50px;
            }}
          </style>;

(:~
 : this function queries term in xpr databes
 : @param $term
 :
 : @todo use XQFT
 : @todo use mapping
 :)
declare
%rest:path('/xpr/query/{$term}')
%rest:produces('application/html')
%output:method("html")
%output:html-version('5.0')
function xpr.xpr:query($term) {
  let $db := db:open('xpr')
  let $data := xpr.xpr:queryData($term)
  let $expertises := fn:count($db//expertise[fn:matches(fn:normalize-space(.), $term, 'i')])
  return
    <html>
        <head>
          {$xpr.xpr:style}
        </head>
        <body>
          <h1>Expertises mentionnant « {$term} »</h1>
          <p>Nombre d’expertises : {$expertises}</p>
          <div>
            <table>
                <tr class="label">
                    <td>Année</td>
                    {
                    for $cat in fn:distinct-values($data//categories/fn:string-join(category, ' - '))
                    return <td class="vertical">{$cat}</td>
                    }
                    <td>nb expertises</td>
                    <td>total année</td>
                    <td>pourcentage</td>
                </tr>
                {
                for $year in fn:distinct-values($data//year)
                let $expertiseCount := fn:count($data//expertise[year = $year])
                let $expertiseYear := fn:count($db//expertise[descendant::sessions/date[1]/fn:substring(@when, '1', '4') = $year])
                let $pourcentage := fn:format-number($expertiseCount div $expertiseYear, '0%')
                order by $year
                return (
                    <tr>
                        <td>{$year}</td>
                        {
                        for $cat in fn:distinct-values($data//categories/fn:string-join(category, ' - '))
                        return(
                            <td>{
                            let $num := fn:count($data//expertise[year = $year][fn:string-join(categories/category, ' - ') = $cat])
                            return
                            if ($num != 0) then $num
                            else ''
                            }</td>
                        )
                        }
                        <td>{$expertiseCount}</td>
                        <td>{$expertiseYear}</td>
                        <td>{$pourcentage}</td>
                    </tr>
                )
                }
            </table>
          </div>
          <div>
            <table>
                <tr class="label">
                    <td>ID</td>
                    <td>Catégories d’expertise</td>
                    <td>Désignation</td>
                    <td>Causes</td>
                    <td>Conclusions</td>
                    <td>Keywords</td>
                </tr>
                {
                for $expertise in $db//expertise[fn:matches(fn:normalize-space(.), $term, 'i')]
                return
                <tr>
                    <td>
                    {
                      let $unitid := fn:normalize-space($expertise/@xml:id)
                      let $path := '/xpr/expertises/' || $unitid || '/modify'
                      return <a href="{$path}">{$unitid}</a>
                    }
                    </td>
                    <td>
                      <ul>{
                        for $cat in $expertise/description/categories/category
                        return <li>{fn:normalize-space($cat)}</li>
                      }</ul>
                    </td>
                    <td>{
                      if($expertise//designation[fn:matches(fn:normalize-space(.), $term, 'i')])
                      then 'X'
                      else ''
                    }</td>
                    <td>{
                      if($expertise//case[fn:matches(fn:normalize-space(.), $term, 'i')])
                      then 'X'
                      else ''
                    }</td>
                    <td>{
                      if($expertise//opinion[fn:matches(fn:normalize-space(.), $term, 'i')])
                      then 'X'
                      else ''
                    }</td>
                    <td>{
                      if($expertise//keywords[fn:matches(fn:normalize-space(.), $term, 'i')])
                      then 'X'
                      else ''
                    }</td>
                </tr>
                }
            </table>
          </div>
        </body>
    </html>
};

declare function xpr.xpr:queryData($term) {
let $db := db:open('xpr')
return (
    <expertises>
        {
            for $expertise in $db//expertise[fn:matches(fn:normalize-space(.), $term, 'i')]
            return
            (
            <expertise>
                <unitid>{$expertise//idno[@type='unitid']}</unitid>
                <item>{$expertise//idno[@type='item']}</item>
                <categories>{
                    for $category in $expertise//categories/category
                    order by $category
                    return $category
                }</categories>
                <year>{$expertise//sessions/date[1]/fn:substring(@when, '1', '4')}</year>
            </expertise>
            )
        }
    </expertises>
)
};

declare function xpr.xpr:expertiseCounter() {
    let $db := db:open('xpr')//expertises
    return(
     <data>
       {
         for $unitid in fn:distinct-values($db/expertise/fn:substring-after(fn:substring-before(@xml:id, 'd'), 'z1j'))
         return (
           <file>
             <unitid>{$unitid}</unitid>
             <count>{fn:format-number(fn:count($db/expertise[fn:substring-after(fn:substring-before(@xml:id, 'd'), 'z1j') = $unitid]), '000')}</count>
             <last>{$db/expertise[fn:substring-after(fn:substring-before(@xml:id, 'd'), 'z1j') = $unitid][fn:last()]/fn:substring-after(@xml:id, 'd')}</last>
           </file>
         )
       }
     </data>
    )
};


(:~
 : this function returns the xpr database status
 : @todo use mapping
 :)
declare
%rest:path('/xpr/status')
%rest:produces('application/html')
%output:method("html")
%output:html-version('5.0')
function xpr.xpr:status() {
    let $db := db:open('xpr')//expertises
    let $expertises := fn:count($db/expertise)
    let $data := xpr.xpr:expertiseCounter()
    return(
      <html>
        <head>
          {$xpr.xpr:style}
        </head>
        <body>
          <div>
            <h1>État des dépouillements</h1>
            <p>Expertises dépouillées : {$expertises}</p>
            <table>
              <tr class="label">
                <td>Unitid</td>
                <td>Nb expertises</td>
                <td>last expertise</td>
              </tr>
              {
                for $unitid in $data/file
                return (
                <tr>
                  <td>{$unitid/unitid}</td>
                  <td>{$unitid/count}</td>
                  <td>{$unitid/last}</td>
                </tr>
                )
              }
              </table>
              <table>
              <tr class="label">
                <td colspan="3">À vérifier</td>
              </tr>
                <tr class="label">
                  <td>Unitid</td>
                  <td>Nb expertises</td>
                  <td>last expertise</td>
                </tr>
                {
                  for $diff in $data//file[count != last]
                  return  (
                  <tr>
                    <td>{$diff/unitid}</td>
                    <td>{$diff/count}</td>
                    <td>{$diff/last}</td>
                  </tr>
                  )
                }
              </table>
          </div>
        </body>
      </html>
    )
};