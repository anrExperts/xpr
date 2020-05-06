xquery version "3.0";
module namespace xpr.mappings.html = "xpr.mappings.html";
(:~
 : This xquery module is an application for xpr
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

import module namespace G = 'xpr.globals' at './globals.xqm' ;

declare namespace db = "http://basex.org/modules/db" ;
declare namespace file = "http://expath.org/ns/file" ;
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization" ;
declare namespace perm = "http://basex.org/modules/perm" ;
declare namespace web = "http://basex.org/modules/web" ;
declare namespace user = "http://basex.org/modules/user" ;

declare namespace ev = "http://www.w3.org/2001/xml-events" ;
declare namespace eac = "eac" ;

declare namespace map = "http://www.w3.org/2005/xpath-functions/map" ;
declare namespace xf = "http://www.w3.org/2002/xforms" ;
declare namespace xlink = "http://www.w3.org/1999/xlink" ;

declare namespace xpr = "xpr" ;
declare default function namespace "xpr.mappings.html" ;

declare default collation "http://basex.org/collation?lang=fr" ;

(:~
 : this function get the interface message
 :)
declare function getMessage($id, $lang) {
  let $message := $G:interface/xpr:interface/xpr:prosopo/xpr:element[@xml:id=$id]/xpr:message[@xml:lang]/node()
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
    case element(eac:function) return xpr.mappings.html:function($node, $options)
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

declare function xpr.mappings.html:function($node, $options){
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

(:~
 : this function serialise an expertises list
 : @return an html list of expertises
 :)
declare function listXpr2html($content, $options) {
  for $expertise in $content/xpr:expertise
  let $id := $expertise/@xml:id => fn:string()
  let $cote := ($expertise/xpr:sourceDesc/xpr:idno[@type='unitid'] || '/' || $expertise/xpr:sourceDesc/xpr:idno[@type='item']) => fn:normalize-space()
  let $addresses := for $place in $expertise/xpr:description/xpr:places
    return fn:normalize-space($place)
    => fn:string-join(' ; ')
  let $dates := $expertise//xpr:sessions/xpr:date/@when => fn:string-join(' ; ')
  return (
    <li>
      <h3 class="cote">{$cote}</h3>
      <p class="date">{$dates}</p>
      <p>{$addresses}</p>
      <p><a href="{'/xpr/expertises/' || $id || '/view'}">Voir</a> | <a href="{'/xpr/expertises/' || $id || '/modify'}">Modifier</a></p>
    </li>
  )
};

(:~
 : this function serialise an expertises list
 : @return an html list of expertises
 :)
declare function listEac2html($content, $options) {
  for $expertise in $content/xpr:expertise
  let $id := $expertise/@xml:id => fn:string()
  let $cote := ($expertise/xpr:sourceDesc/xpr:idno[@type='unitid'] || '/' || $expertise/xpr:sourceDesc/xpr:idno[@type='item']) => fn:normalize-space()
  let $addresses := for $place in $expertise/xpr:description/xpr:places
    return fn:normalize-space($place)
    => fn:string-join(' ; ')
  let $dates := $expertise//xpr:sessions/xpr:date/@when => fn:string-join(' ; ')
  return (
    <li>
      <h3 class="cote">{$cote}</h3>
      <p class="date">{$dates}</p>
      <p>{$addresses}</p>
      <p><a href="{'/xpr/expertises/' || $id || '/view'}">Voir</a> | <a href="{'/xpr/expertises/' || $id || '/modify'}">Modifier</a></p>
    </li>
  )
};