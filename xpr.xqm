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
      db:create( "xpr", <expertises/>, "z1j.xml", map {"chop" : fn:false()} )
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
  db:open('xpr')
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
(: declare
%rest:path("xpr/expertises/new")
%output:method("xml")
function xform() {
  let $xprFormPath := file:base-dir() || "files/xprForm.xml"
  return
    (processing-instruction xml-stylesheet { fn:concat("href='", $xpr:xsltFormsPath, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    fn:doc($xprFormPath)
    )
}; :)
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
 : @bug solve the xml namespace in xforms
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
    if ( fn:ends-with($referer, 'modify') )
    then insert node <expertise><toto>encore</toto></expertise> into $db/expertises
    else
      let $id := $param/expertise/sourceDesc/idno[@type="unitid"] || '-' || fn:format-integer($param/expertise/sourceDesc/idno[@type="item"], '000')
      let $id := fn:replace($id, '/', '-')
      let $param := 
        copy $d := $param
        modify insert node attribute xml:id {$id} into $d/*
        return $d
    return insert node $param into $db/expertises
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
