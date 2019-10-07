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

declare default element namespace "xpr";
declare default function namespace "xpr";

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
      return replace node $db/xpr/expertises/expertise[@xml:id = $location] with $param
    else
      let $id := fn:replace(fn:lower-case($param/expertise/sourceDesc/idno[@type="unitid"]), '/', '-') || 'd' || fn:format-integer($param/expertise/sourceDesc/idno[@type="item"], '000')
      let $param := 
        copy $d := $param
        modify insert node attribute xml:id {$id} into $d/*
        return $d
      return insert node $param into $db/xpr/expertises
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
    </body>
  </html>
};

(:~
 : This resource function edits an prosopo
 : @return an xforms for the expertise
:)
declare
  %rest:path("xpr/biographies/new")
  %output:method("xml")
function newBio() {
  let $content := map {
    'instance' : '',
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
 : This function consumes new prosopo 
 : @param $param content
 : @todo modify
 :)
declare
%rest:path("xpr/biographies/put")
%output:method("xml")
%rest:header-param("Referer", "{$referer}", "none")
%rest:PUT("{$param}")
%updating
function xformBioResult($param, $referer) {
  let $db := db:open("xpr")
  return insert node $param into $db/xpr/bio
};


(:~
 : This resource function lists all the posthumous inventories
 : @return a xml ressource of all the posthumous inventories
 :)
declare 
%rest:path("/xpr/inventories")
%rest:produces('application/xml')
%output:method("xml")
function inventories() {
  db:open('xpr')/xpr/posthumousInventories
};

(:~
 : This resource function lists all the posthumous inventories
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
 : This resource function edits 
 : @return an xforms for the expertise
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
 : This function consumes new prosopo 
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
  return insert node $param into $db/xpr/expertises
};

(:~
 : This resource function lists all the posthumous inventories
 : @return a xml ressource of all the posthumous inventories
 :)
declare 
%rest:path("/xpr/sources")
%rest:produces('application/xml')
%output:method("xml")
function sources() {
  db:open('xpr')/xpr/sources
};

(:~
 : This resource function lists all the posthumous inventories
 : @return an ordered list of posthumous inventories
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
    </body>
  </html>
};

(:~
 : This resource function edits 
 : @return an xforms for the expertise
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
 : This function consumes new prosopo 
 : @param $param content
 : @todo modify
 :)
declare
%rest:path("xpr/sources/put")
%output:method("xml")
%rest:header-param("Referer", "{$referer}", "none")
%rest:PUT("{$param}")
%updating
function xformSourcesResult($param, $referer) {
  let $db := db:open("xpr")
  return insert node $param into $db/xpr/sources
};


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
  let $model := map:get($content, 'model')
  return if ($instance) then
    copy $doc := fn:doc(file:base-dir() || "files/" || $model)
    modify replace value of node $doc/xf:model/xf:instance[@id='xprModel']/@src with '/xpr/expertises/' || $instance
    return $doc
    else fn:doc(file:base-dir() || "files/" || $model)
};