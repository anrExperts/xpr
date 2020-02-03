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

declare namespace rest = "http://exquery.org/ns/restxq";
declare namespace file = "http://expath.org/ns/file";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace web = "http://basex.org/modules/web";
declare namespace update = "http://basex.org/modules/update";
declare namespace db = "http://basex.org/modules/db";

declare namespace xf = "http://www.w3.org/2002/xforms";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace eac = "eac";

declare default element namespace "xpr";
declare default function namespace "xpr";

declare default collation "http://basex.org/collation?lang=fr";

declare variable $xpr:xsltFormsPath := "/xpr/files/xsltforms/xsltforms/xsltforms.xsl";

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
  web:redirect("/xpr/expertises/list") 
};

(:~
 : This resource function lists all the expertises
 : @return an ordered list of expertises
 :)
declare 
%rest:path("/xpr/expertises")
%rest:produces('application/xml')
%output:method("xml")
function list() {
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
    'form' : fn:doc(file:base-dir() || "files/" || "xprList.xml")
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
(: declare 
%rest:path("xpr/expertises")
%output:method("xml")
function listExpertises() {
  <xml xmlns="xpr">
  {db:open('xpr')//*:expertise}</xml>
  (: let $expertises := db:open("xpr")//*:expertise
  let $content := for $expertise in $expertises return <p><a href="{$expertise/xml:id}">{$expertise}</a></p>
  return 
    <html>
      <head>
        <title>Expertises</title>
      </head>
      <body>
        <h1>Liste des expertises</h1>
        <ul>{
          for $expertise in $expertises 
          let $cote := $expertise/sourceDesc/idno[@type="unitid"]
          let $dossier := $expertise/sourceDesc/idno[@type="item"]
          let $date := $expertise/description/sessions/date[1]/@when
          let $id := $expertise/@xml:id
          return 
            <li>
              <span>{$cote || ' n° ' || $dossier}</span>
              <span>{fn:string($date)}</span>
              <button onclick="location.href='/xpr/expertises/{$id}'">voir</button>
              <button onclick="location.href='/xpr/expertises/{$id}/modify'">Modifier</button>
            </li>
        }</ul>
        <button onclick="location.href='/xpr/expertises/new'">Ajouter une expertise</button>
      </body>
    </html> :)
}; :)

(:~
 : This resource function lists all the expertises
 : @return an ordered list of expertises
 :)
declare 
%rest:path("xpr/expertises/{$id}")
%output:method("xml")
function showExpertise($id) {
  db:open('xpr')//expertise[@xml:id=$id]
};


(:~
 : This resource function edits an exertise
 : @param an expertise id
 : @return an xforms for the expertise
:)
declare
  %rest:path("xpr/expertises/new")
  %output:method("xml")
function new() {
  let $content := map {
    'instance' : '',
    'model' : 'xprExpertiseModel.xml',
    'trigger' : fn:doc(file:base-dir() || "files/" || "xprExpertiseTrigger.xml"),
    'form' : fn:doc(file:base-dir() || "files/" || "xprExpertiseForm.xml")
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
%rest:path("xpr/expertises/{$id}/modify")
%output:method("xml")
function modify($id) {
  let $content := map {
    'instance' : $id,
    'path' : 'expertises',
    'model' : 'xprExpertiseModel.xml',
    'trigger' : fn:doc(file:base-dir() || "files/" || "xprExpertiseTrigger.xml"),
    'form' : fn:doc(file:base-dir() || "files/" || "xprExpertiseForm.xml")
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
        modify insert node attribute xml:id {$id} into $d/*
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
    web:redirect("/xpr/expertises/list")
};

(:~
 : This resource function lists all the biographies
 : @return an ordered list of persons/corporate bodies
 :)
declare 
%rest:path("/xpr/biographies")
%rest:produces('application/xml')
%output:method("xml")
function biographies() {
  db:open('xpr')/xpr/bio
};

(:~
 : This resource function lists all the expertises
 : @return an ordered list of expertises
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
%rest:path("xpr/biographies/{$id}")
%output:method("xml")
function showBiographie($id) {
  db:open('xpr')//eac:eac-cpf[eac:cpfDescription/eac:identity/eac:entityId=$id]
};

(:~
 : This resource function lists all entities
 : @return an ordered list of entities
 :)
declare 
%rest:path("xpr/biographies/{$id}/modify")
%output:method("xml")
function modifyEntity($id) {
  let $content := map {
    'instance' : $id,
    'path' : 'biographies',
    'model' : 'xprProsopoModel.xml',
    'trigger' : fn:doc(file:base-dir() || "files/" || "xprProsopoTrigger.xml"),
    'form' : fn:doc(file:base-dir() || "files/" || "xprProsopoForm.xml")
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
 : This resource function edits an entity
 : @return an xforms for the entity
:)
declare
  %rest:path("xpr/biographies/new")
  %output:method("xml")
function newBio() {
  let $content := map {
    'instance' : '',
    'model' : ('xprProsopoModel.xml', 'xprNewEntityModel.xml'),
    'trigger' : fn:doc(file:base-dir() || "files/" || "xprProsopoTrigger.xml"),
    'form' : fn:doc(file:base-dir() || "files/" || "xprProsopoForm.xml")
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
 : @todo modify
 :)
(: declare
%rest:path("xpr/biographies/put")
%output:method("xml")
%rest:header-param("Referer", "{$referer}", "none")
%rest:PUT("{$param}")
%updating
function xformBioResult($param, $referer) {
  let $db := db:open("xpr")
  return insert node $param into $db/xpr/bio
}; :)

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
      return <entity xml:id="{$id}" type="{$entity//eac:identity/@localType}">{$entity//eac:nameEntry[child::eac:authorizedForm]/eac:part/text()}</entity>
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
    'model' : 'xprInventoryModel.xml',
    'trigger' : fn:doc(file:base-dir() || "files/" || "xprInventoryTrigger.xml"),
    'form' : fn:doc(file:base-dir() || "files/" || "xprInventoryForm.xml")
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
  let $expert := $param/*:relations/@ref
  for $relation in $param/*:relations/*:cpfRelation
  return insert node $relation into $db//*:eac-cpf[@xml:id = $expert]//*:relations
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
    'trigger' : fn:doc(file:base-dir() || "files/" || "xprSourceTrigger.xml"),
    'form' : fn:doc(file:base-dir() || "files/" || "xprSourceForm.xml")
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
    'trigger' : fn:doc(file:base-dir() || "files/" || "xprSourceTrigger.xml"),
    'form' : fn:doc(file:base-dir() || "files/" || "xprSourceForm.xml")
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
      insert node $param into $db/xpr/sources
};

(: 
return switch ($type)
 :)


(: declare
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
      
      return replace node $db/xpr/expertises/expertise[@xml:id = $location] with $param
    else
      let $id := fn:replace(fn:lower-case($param/expertise/sourceDesc/idno[@type="unitid"]), '/', '-') || 'd' || fn:format-integer($param/expertise/sourceDesc/idno[@type="item"], '000')
      let $param := 
        copy $d := $param
        modify insert node attribute xml:id {$id} into $d/*
        return $d
      return insert node $param into $db/xpr/expertises
}; :)


(:~
 : Utilities 
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
declare function xpr:mime-type(
$name as xs:string
) as xs:string {
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
  let $wrap := fn:doc($layout)
  let $regex := '\{(.+?)\}'
  return
    $wrap/* update (
      for $node in .//*[fn:matches(text(), $regex)] | .//@*[fn:matches(., $regex)]
      let $key := fn:analyze-string($node, $regex)//fn:group/text()
      return if ($key = 'model') 
        then replace node $node with getModel($content)
        else associate($content, $outputParams, $node)
      )
};

(:~
 : this function dispatch the content with the data
 :
 : @param $content the content to serialize
 : @param $outputParams the serialization params
 : @return an updated node with the data
 : @bug the behavior is not complete
 :) 
declare %updating function associate($content as map(*), $outputParams as map(*), $node as node()) {
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
 : this function get the model
 :
 : @param $content the content params
 : @return the default model or its instance version
 : @bug not generic enough
 :)
declare function getModel($content as map(*)){
  let $instance := map:get($content, 'instance')
  let $path := map:get($content, 'path')
  let $model := map:get($content, 'model')
  return
    if ($instance) then
      for $model at $i in $model
      return
        (
          copy $doc := fn:doc(file:base-dir() || "files/" || $model[$i])
          modify replace value of node $doc/xf:model/xf:instance[@id=fn:substring-before($model[$i], 'Model.xml')]/@src with '/xpr/' || $path || '/' || $instance
          return $doc
        )
    else 
      for $model in $model
        return fn:doc(file:base-dir() || "files/" || $model)
};