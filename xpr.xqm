xquery version "3.0";
module namespace xpr = "xpr";
(:~
 : This xquery module is an application for the Z1J expertises called xpr
 :
 : @author emchateau & sardinecan (ANR Experts)
 : @since 2019-01
 : @licence GNU http://www.gnu.org/licenses
 :
 : xpr is free software: you can redistribute it and/or modify
 : it under the terms of the GNU General Public License as published by
 : the Free Software Foundation, either version 3 of the License, or
 : (at your option) any later version.
 :
 :)

declare namespace rest = "http://exquery.org/ns/restxq" ;
declare namespace file = "http://expath.org/ns/file" ;
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization" ;
declare namespace db = "http://basex.org/modules/db" ;
declare namespace web = "http://basex.org/modules/web" ;
declare namespace update = "http://basex.org/modules/update" ;
declare namespace perm = "http://basex.org/modules/perm" ;
declare namespace user = "http://basex.org/modules/user" ;
declare namespace http = "http://expath.org/ns/http-client" ;
declare namespace map = "http://www.w3.org/2005/xpath-functions/map" ;

declare namespace xlink = "http://www.w3.org/1999/xlink" ;
declare namespace ev = "http://www.w3.org/2001/xml-events" ;
declare namespace xf = "http://www.w3.org/2002/xforms" ;
declare namespace eac = "eac" ;

declare default element namespace "xpr" ;
declare default function namespace "xpr" ;

declare default collation "http://basex.org/collation?lang=fr" ;

declare variable $xpr:xsltFormsPath := "/xpr/files/xsltforms/xsltforms/xsltforms.xsl" ;
declare variable $xpr:home := file:base-dir() ;
declare variable $xpr:interface := fn:doc($xpr:home || "files/interface.xml") ;

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
 : @return an ordered list of expertises
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
 : @return an ordered list of expertises
 :)
declare 
  %rest:path("/xpr/expertises/list")
  %rest:produces('text/html')
  %output:method("xml")
function listHtml() {
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
    (processing-instruction xml-stylesheet { fn:concat("href='", $xpr:xsltFormsPath, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    wrapper($content, $outputParam)
    )
};

(:~
 : This resource function lists all the expertises
 : @return an ordered list of expertises
 :)
declare 
  %rest:path("/xpr/expertises/list/json")
  %rest:produces('application/json')
  %output:media-type('application/json')
  %output:method('json')
function jsonExpertises() {
  let $content := db:open('xpr')//expertise
  return map{'test' : 1}
};

(:~
 : This resource function lists all the expertises
 : @return an ordered list of expertises
 :)
declare 
  %rest:path("/xpr/expertises/view")
  %rest:produces('application/html')
  %output:method("html")
function viewExpertises() {
  let $content := map {
    'data' : db:open('xpr')//expertise,
    'trigger' : '',
    'form' : ''
  }
  let $outputParam := map {
    'layout' : "listeExpertise.xml"
  }
  return wrapper($content, $outputParam)
};

(:~
 : @return an xml representation of an expertise item
 : @return an xml representation of an expertise
 :)
declare 
  %rest:path("xpr/expertises/{$id}")
  %output:method("xml")
function getExpertise($id) {
  db:open('xpr')//expertise[@xml:id=$id]
};

(:~
 : This resource function shows an expertise item
 : @return an html representation of an expertise
 :)
declare 
  %rest:path("xpr/expertises/{$id}/view")
  %rest:produces('application/html')
  %output:method("html")
function viewExpertise($id) {
  let $content := map {
    'data' : db:open('xpr')//expertise[@xml:id=$id],
    'trigger' : '',
    'form' : ''
  }
  let $outputParam := map {
    'layout' : "ficheExpertise.xml"
  }
  return wrapper($content, $outputParam)
};

(:~
 : This resource function shows an expertise item
 : @return an json representation of an expertise
 :)
declare 
  %rest:path("xpr/expertises/json/{$id}")
  %rest:produces('application/json')
  %output:media-type('application/json')
  %output:method('json')
function jsonExpertise($id) {
  let $expertise := db:open('xpr')//expertise[@xml:id=$id]
  return array{
    map{
    'type' : $expertise/sourceDesc/idno[@type='unitid'] => fn:string(),
    'date' : $expertise/description/sessions/date/@when => fn:string()
    }
  }
};

(:~
 : This resource function creates a new exertise
 : @return an xforms for the expertise
:)
declare
  %rest:path("xpr/expertises/new")
  %output:method("xml")
function new() {
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
    (processing-instruction xml-stylesheet { fn:concat("href='", $xpr:xsltFormsPath, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    wrapper($content, $outputParam)
    )
};

(:~
 : This resource function modify an expertise item
 : @param $id an expertise id
 : @return the expertise item in xforms
 :)
declare 
  %rest:path("xpr/expertises/{$id}/modify")
  %output:method("xml")
function modify($id) {
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
    (processing-instruction xml-stylesheet { fn:concat("href='", $xpr:xsltFormsPath, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    wrapper($content, $outputParam)
    )
};

(:~
 : This function consumes new expertises 
 : @param $param content
 : @bug change of cote and dossier doesn’t work
 :)
declare
  %rest:path("xpr/expertises/put")
  %output:method("xml")
  %rest:header-param("Referer", "{$referer}", "none")
  %rest:PUT("{$param}")
  %updating
function xformResult($param, $referer) {
  let $db := db:open("xpr")
  return 
    if (fn:ends-with($referer, 'modify'))
    then 
      let $location := fn:analyze-string($referer, 'xpr/expertises/(.+?)/modify')//fn:group[@nr='1']
      let $id := fn:replace(fn:lower-case($param/expertise/sourceDesc/idno[@type="unitid"]), '/', '-') || 'd' || fn:format-integer($param/expertise/sourceDesc/idno[@type="item"], '000')
      (: let $param := 
        copy $d := $param
        modify replace value of node $d/@xml:id with $id
        return $d :)
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
          for $place at $i in $d/expertise/description/places/place
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
 : This function export the z1j database into the base-dir
 : @return redirect to the expertises list
 :
 : @todo change the export path 
 :)
declare 
  %rest:path("/xpr/expertises/export")
function z1jExport(){
  db:export("xpr", file:base-dir(), map { 'method': 'xml' }),
  web:redirect("/xpr/expertises/view")
};

(:~
 : This resource function lists all the biographies
 : @return an xml list of persons/corporate bodies
 :)
declare 
  %rest:path("/xpr/biographies")
  %rest:produces('application/xml')
  %output:method("xml")
function biographies() {
  db:open('xpr')/xpr/bio
};

(:~
 : This resource function lists all the biographies
 : @return an html list of persons/corporate bodies
 :)
declare 
  %rest:path("/xpr/biographies/list")
  %rest:produces('text/html')
  %output:method("html")
function listBio() {
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
  %rest:path("/xpr/biographies/view")
  %rest:produces('application/html')
  %output:method("html")
function viexEntities() {
  let $content := map {
    'data' : db:open('xpr')//bio,
    'trigger' : '',
    'form' : ''
  }
  let $outputParam := map {
    'layout' : "listeProsopo.xml"
  }
  return wrapper($content, $outputParam)
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
  %rest:path("/xpr/biographies/{$id}/view")
  %rest:produces('application/html')
  %output:method("html")
function viewBiography($id) {
  let $content := map {
    'data' : db:open('xpr')//eac:eac-cpf[eac:cpfDescription/eac:identity/eac:entityId=$id],
    'trigger' : '',
    'form' : ''
  }
  let $outputParam := map {
    'layout' : "ficheProsopo.xml"
  }
  return wrapper($content, $outputParam)
};

(:~
 : This resource function show an entity
 : @return an html view of an entity with xquery templating
 :)
declare 
  %rest:path("/xpr/biographies/{$id}/view2")
  %rest:produces('application/html')
  %output:method("html")
function viewBiography2($id) {
  let $content := map {
    'title' : 'Fiche de ' || $id,
    'data' : getBiography($id),
    'trigger' : '',
    'form' : ''
  }
  let $outputParam := map {
    'layout' : "ficheProsopo2.xml",
    'mapping' : eac2html(map:get($content, 'data'), map{})
  }
  return wrapper($content, $outputParam)
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
    (processing-instruction xml-stylesheet { fn:concat("href='", $xpr:xsltFormsPath, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    wrapper($content, $outputParam)
    )
};

(:~
 : This resource function creates an new entity
 : @return an xforms for the entity
:)
declare
  %rest:path("xpr/biographies/new")
  %output:method("xml")
function newBio() {
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
    (processing-instruction xml-stylesheet { fn:concat("href='", $xpr:xsltFormsPath, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    wrapper($content, $outputParam)
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
function xformBioResult($param, $referer) {
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
function entities() {
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
function inventories() {
  db:open('xpr')/xpr/posthumousInventories
};

(:~
 : This resource function lists all the inventories
 : @return an ordered list of posthumous inventories
 :)
declare 
%rest:path("/xpr/inventories/list")
%rest:produces('text/html')
%output:method("html")
function listInventories() {
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
    (processing-instruction xml-stylesheet { fn:concat("href='", $xpr:xsltFormsPath, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    wrapper($content, $outputParam)
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
function xformInventoryResult($param, $referer) {
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
function xformRelationResult($param, $referer) {
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
function sources() {
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
  %rest:path("/xpr/sources/list")
  %rest:produces('text/html')
  %output:method("html")
function listSources() {
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
    (processing-instruction xml-stylesheet { fn:concat("href='", $xpr:xsltFormsPath, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    wrapper($content, $outputParam)
    )
};

(:~
 : This resource function lists all the sources
 : @return an ordered list of sources
 :)
declare 
  %rest:path("xpr/sources/{$id}")
  %output:method("xml")
function showSource($id) {
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
    (processing-instruction xml-stylesheet { fn:concat("href='", $xpr:xsltFormsPath, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    wrapper($content, $outputParam)
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
function xformSourcesResult($param, $referer) {
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

(: ****************************GIP****************************** :)

(:~
 : This resource function lists all the gip expertises
 : @return an ordered list of gip expertises
 :)
declare
  %rest:path("/xpr/gip")
  %rest:produces('application/xml')
  %output:method("xml")
function getGipExpertises() {
  db:open('gip')/xpr/expertises
};



(:~
 : This resource function lists all the gip expertises
 : @return an ordered list of gip expertises
 :)
declare
  %rest:path("/xpr/gip/view")
  %rest:produces('application/html')
  %output:method("html")
function gipView() {
 let $content := map {
    'title' : 'Liste des expertises du GIP',
    'data' : getGipExpertises(),
    'trigger' : '',
    'form' : ''
  }
  let $outputParam := map {
    'layout' : "listGip.xml",
    'mapping' : eac2html(map:get($content, 'data'), map{})
  }
  return wrapper($content, $outputParam)
};


(:~
 : @return an xml representation of a gip expertise item
 : @return an xml representation of a gip expertise
 :)
declare
  %rest:path("xpr/gip/{$id}")
  %output:method("xml")
function getGipExpertise($id) {
  db:open('gip')//expertise[@xml:id=$id]
};

(:~
 : This resource function shows a gip expertise item
 : @return an html representation of a gip expertise
 :)
declare
  %rest:path("xpr/gip/{$id}/view")
  %rest:produces('application/html')
  %output:method("html")
function viewGipExpertise($id) {
  let $content := map {
    'data' : db:open('gip')//expertise[@xml:id=$id],
    'trigger' : '',
    'form' : ''
  }
  let $outputParam := map {
    'layout' : "ficheExpertise.xml"
  }
  return wrapper($content, $outputParam)
};

(:~
 : This resource function modify an expertise item
 : @param $id an expertise id
 : @return the expertise item in xforms
 :)
declare
  %rest:path("xpr/gip/{$id}/modify")
  %output:method("xml")
function modifyGip($id) {
  let $content := map {
    'instance' : $id,
    'path' : 'gip',
    'model' : 'xprExpertiseModel.xml',
    'trigger' : 'xprExpertiseTrigger.xml',
    'form' : 'xprGipExpertiseForm.xml'
  }
  let $outputParam := map {
    'layout' : "template.xml"
  }
  return
    (processing-instruction xml-stylesheet { fn:concat("href='", $xpr:xsltFormsPath, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    wrapper($content, $outputParam)
    )
};

(:~
 : This function consumes new expertises
 : @param $param content
 : @bug change of cote and dossier doesn’t work
 :)
declare
  %rest:path("xpr/gip/put")
  %output:method("xml")
  %rest:header-param("Referer", "{$referer}", "none")
  %rest:PUT("{$param}")
  %updating
function xformGipResult($param, $referer) {
  let $db := db:open('gip')
  return
    if (fn:ends-with($referer, 'modify'))
    then
      let $location := fn:analyze-string($referer, 'xpr/gip/(.+?)/modify')//fn:group[@nr='1']
      let $id := fn:replace(fn:lower-case($param/expertise/sourceDesc/idno[@type="unitid"]), '/', '-') || 'd' || fn:format-integer($param/expertise/sourceDesc/idno[@type="item"], '000')
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
        modify insert node attribute xml:id {$id} into $d/*
        return $d
      return (
        insert node $param into $db/xpr/gip,
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
function networks($year) {
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
function networkViz($year) {
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
function xpr:file($file as xs:string) as item()+ {
  let $path := file:base-dir() || 'files/' || $file
  return
    (
      web:response-header( map {'media-type' : web:content-type($path)}),
      file:read-binary($path)
    )
};

(:~
 : this function return a mime-type for a specified file
 :
 : @param  $name  file name
 : @return a mime type for the specified file
 :)
declare function xpr:mime-type($name as xs:string) as xs:string {
    fetch:content-type($name)
};

(:~
 : this function call a wrapper
 :
 : @param $content the content to serialize
 : @param $outputParams the output params
 : @return an updated document and instantiated pattern
 :)
declare function wrapper($content as map(*), $outputParams as map(*)) as node()* {
  let $layout := file:base-dir() || "files/" || map:get($outputParams, 'layout')
  let $mapping := map:get($content, 'mapping')
  let $wrap := fn:doc($layout)
  let $regex := '\{(.+?)\}'
  return
    $wrap/* update (
      for $node in .//*[fn:matches(text(), $regex)] | .//@*[fn:matches(., $regex)]
      let $key := fn:analyze-string($node, $regex)//fn:group/text()
      return switch ($key)
        case 'model' return replace node $node with getModels($content)
        case 'trigger' return replace node $node with getTriggers($content)
        case 'form' return replace node $node with getForms($content)
        case 'data' return replace node $node with $content?data
        case 'content' return replace node $node with $outputParams?mapping
        default return associate($content, $outputParams, $node)
      )
};

(:~
 : this function get the models
 :
 : @param $content the content params
 : @return the default models or its instance version
 : @bug not generic enough
 :)
declare function getModels($content as map(*)){
  let $instances := map:get($content, 'instance')
  let $path := map:get($content, 'path')
  let $models := map:get($content, 'model')
  for $model at $i in $models return
    if ($instances[$i])
    then (
      copy $doc := fn:doc(file:base-dir() || "files/" || $model)
      modify replace value of node $doc/xf:model/xf:instance[@id=fn:substring-before($model, 'Model.xml')]/@src with '/xpr/' || $path || '/' || $instances[$i]
      return $doc
    )
    else
    fn:doc(file:base-dir() || "files/" || $model)
};

(:~
 : this function get the models
 :
 : @param $content the content params
 : @return the default models or its instance version
 : @bug not generic enough
 :)
declare function getTriggers($content as map(*)){
  let $instance := map:get($content, 'instance')
  let $path := map:get($content, 'path')
  let $triggers := map:get($content, 'trigger')
  return if ($triggers) then fn:doc(file:base-dir() || "files/" || $triggers) else ()
};

(:~
 : this function get the forms
 :
 : @param $content the content params
 : @return the default forms or its instance version
 : @bug not generic enough
 :)
declare function getForms($content as map(*)){
  let $instance := map:get($content, 'instance')
  let $path := map:get($content, 'path')
  let $forms := map:get($content, 'form')
  return if ($forms) then fn:doc(file:base-dir() || "files/" || $forms) else ()
};

(:~
 : this function dispatch the content with the data
 :
 : @param $content the content to serialize
 : @param $outputParams the serialization params
 : @return an updated node with the data
 : @bug the behavior is not complete
 :) 
declare 
  %updating 
function associate($content as map(*), $outputParams as map(*), $node as node()) {
  let $regex := '\{(.+?)\}'
  let $keys := fn:analyze-string($node, $regex)//fn:group/text()
  let $values := map:get($content, $keys)
    return typeswitch ($values)
    case document-node() return replace node $node with $values
    case empty-sequence() return ()
    case text() return replace value of node $node with $values
    case xs:string return replace value of node $node with $values
    case xs:string+ return 
      if ($node instance of attribute()) (: when key is an attribute value :)
      then 
        replace node $node/parent::* with 
          element {fn:name($node/parent::*)} {
          for $att in $node/parent::*/(@* except $node) return $att, 
          attribute {fn:name($node)} {fn:string-join($values, ' ')},
          $node/parent::*/text()
          }
    else
      replace node $node with 
      for $value in $values 
      return element {fn:name($node)} { 
        for $att in $node/@* return $att,
        $value
      } 
    case xs:integer return replace value of node $node with xs:string($values)
    case element()+ return replace node $node with 
      for $value in $values 
      return element {fn:name($node)} { 
        for $att in $node/@* return $att, "todo"
      }
    default return replace value of node $node with 'default'
};

(:~
 : this function 
 :)
(: declare 
  %output:indent('no') 
function entry($node as node()*, $options as map(*)) as item()* {
  for $i in $node return dispatch($i, $options)
}; :)

(:~
 : this function get the interface message
 :)
declare function getMessage($id, $lang) {
  let $message := $xpr:interface/xpr:interface/xpr:prosopo/xpr:element[@xml:id=$id]/xpr:message[@xml:lang]/node()
  return if ($message[fn:normalize-space(.)!=''])
    then $message
    else <message>todo</message>
};

(:~
 : this function dispatches the treatment of the XML document
 :)
declare 
  %output:indent('no')
function eac2html($node as node()*, $options as map(*)) as item()* {
  typeswitch($node)
    case text() return $node[fn:normalize-space(.)!='']
    case element(eac:eac-cpf) return eac-cpf($node, $options)
    case element(eac:cpfDescription) return cpfDescription($node, $options)
    case element(eac:identity) return identity($node, $options)
    case element(eac:description) return description($node, $options)
    case element(eac:existDates) return existDates($node, $options)
    case element(eac:localDescription) return sex($node, $options)
    case element(eac:functions) return functions($node, $options)
    case element(eac:function) return xpr:function($node, $options)
    case element(eac:biogHist) return biogHist($node, $options)
    case element(eac:chronList) return chronList($node, $options)
    case element(eac:control) return ()
    default return passthru($node, $options)
};

(:~
 : This function pass through child nodes (xsl:apply-templates
 :)
declare 
  %output:indent('no') 
function passthru($nodes as node(), $options as map(*)) as item()* {
  for $node in $nodes/node()
  return eac2html($node, $options)
};

declare function eac-cpf($node, $options){
  <article>{passthru($node, $options)}</article>
};

declare function cpfDescription($node, $options){
  <div>{passthru($node, $options)}</div>
};

declare function identity($node, $options){
  <header>{(
    entityType($node/eac:entityType, $options),
    nameEntry($node/eac:nameEntry[eac:authorizedForm], $options),
    entityId($node/eac:entityId, $options),
    for $nameEntry in$ node/eac:nameEntry[fn:not(eac:authorizedForm)] return nameEntry($nameEntry, $options)
)}</header>
};

declare function entityId($node, $options){
  <span class="id">{passthru($node, $options)}</span>
};
declare function entityType($node, $options){
  (:<h3>{
    switch ($node)
    case $node[parent::eac:identity[@localType='expert']] return 'Fiche prosopographique d’expert'
    case $node[parent::eac:identity[@localType='masson']] return 'Fiche prosopographique de maçon'
    default return 'Fiche prosopographique'
  }</h3>:)
  let $type := $node/parent::eac:identity/@localType
  return <h3>{getMessage($type,'fr')}</h3>
  (: @todo add other entry types :)
};

declare function nameEntry($node, $options){
  if ($node/eac:authorizedForm) 
  then <h2>{passthru($node/eac:part, $options)}</h2>
  else for $nameEntry in $node return <div>
    <h4>{getMessage('nameEntry', 'fr')}</h4>
    <ul>{part($node/eac:part, $options)}</ul>
  </div>
};

declare function part($node, $options){
    for $key in ('surname', 'forename', 'particle', 'common', 'formal', 'academic', 'religious', 'nobiliary')
    let $message := getMessage($key, 'fr')
    let $part := $node[@localType=$key]
    where $part[fn:normalize-space(.)!='']
    return <li>{$message || ' : ' || eac2html($part, $options)}</li>
};

declare function description($node, $options){
  <div>
    <h4>{getMessage('description', 'fr')}</h4>
    <ul>{
      eac2html($node/eac:existDates, $options),
      eac2html($node/eac:localDescription[@localType="sex"], $options)
    }</ul>
  </div>,
  eac2html($node/eac:functions, $options),
  eac2html($node/eac:biogHist, $options)
};

declare function existDates($node, $options){
  <li>{getMessage('existance', 'fr') || ' : ' || getDate($node/eac:dateRange, $options)}</li>
};

declare function functions($node, $options){
  <div class="function">
    <h4>{getMessage($node/fn:name(), 'fr')}</h4>
    {passthru($node, $options)}
  </div>
};

declare function xpr:function($node, $options){
  <div>
    <p>{$node/eac:term}, de {getDate($node/eac:dateRange, $options)}</p>
  </div>
  (: @todo prévoir cas où date fixe :)
};

declare function biogHist($node, $options){
  <div class="biogHist">
    <h4>{getMessage($node/fn:name(), 'fr')}</h4>
    {passthru($node, $options)}
  </div>
};

declare function chronList($node, $options){
  for $chronItem in $node/eac:chronItem
  return
    <div>
      <h5>{$node/eac:event}</h5>
      <p>{getMessage($chronItem/eac:date/fn:name(),'fr')} : {getDate($chronItem/eac:date, $options)}</p>
      <p>Participant : {$chronItem/eac:participant}</p>
      <p>{'Involve :' || $chronItem/eac:involve}</p>
      <p>Source : {$chronItem/eac:source}</p>
      <p>Coût : {$chronItem/eac:cost}</p>
    </div>
};

declare function getDate($node, $options) as xs:string {
  switch($node)
  case $node[self::eac:dateRange] return fn:string-join(
    ($node/eac:fromDate, $node/eac:toDate) ! getPrecision(., $options),
    ' à ')
  default return getPrecision($node/*, $options)
  (: @todo mettre valeur vide en cas d’abs :)
};

declare function getPrecision($node, $options) as xs:string* {
  switch ($node)
  case $node[@notAfter] return ($node/@notAfter || ' ]')
  case $node[@notBefore] return ('[ ', $node/@notBefore)
  case $node[@standardDate] return ($node/@standardDate)
  default return $node/@*
};

declare function sex($node, $options){
  <li>{getMessage($node, 'fr')}</li>
  (: @todo restreindre l’appel au sex :)
};