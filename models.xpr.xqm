xquery version "3.0";
module namespace xpr.models.xpr = "xpr.models.xpr";
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
declare default function namespace "xpr.models.xpr" ;

declare default collation "http://basex.org/collation?lang=fr" ;

(:~
 : this function return a mime-type for a specified file
 :
 : @param  $name  file name
 : @return a mime type for the specified file
 :)
declare function xpr.models.xpr:mime-type($name as xs:string) as xs:string {
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
