xquery version "3.0";
module namespace xpr.models.networks = "xpr.models.networks";
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
declare namespace gexf = "http://www.gexf.net/1.2draft";
declare default function namespace "xpr.models.networks" ;

declare default collation "http://basex.org/collation?lang=fr" ;

(:~
 : Pairs combinations
 : @param $seq a sequence to process
 : @return combinations pairs in a sequence
 :)
declare function pairsCombinations($seq) {
  if (fn:count($seq) = 1) then
    map{
      'source' : $seq
    }
  else for $i at $pos in $seq
    for $j in fn:subsequence($seq, $pos+1, fn:count($seq))
    return map{
      'source' : $i,
      'target' : $j
    }
};
    
(:~
 : Experts collaboration
 : @return a gexf network of collaborations
 : @todo select experts by year
 :)
declare function getExpertsCollaborations($queryParam as map(*)) as element() {
let $db := db:open('xpr')
let $year := $queryParam?year
let $nodes := $db//*:eac-cpf[*:cpfDescription/*:identity[@localType = 'expert']]
let $edges :=
    if ($year) then
      for $affaires in db:open('xpr')//xpr:expertise[xpr:description/xpr:sessions/xpr:date[1][fn:not(@when = '')][fn:year-from-date(@when) = xs:integer($year)]]
      let $participants := $affaires/xpr:description/xpr:participants/xpr:experts[fn:count(xpr:expert)>=2]
      return pairsCombinations($participants/xpr:expert/@ref ! fn:data())
    else
      for $affaires in db:open('xpr')//xpr:expertise
      let $participants := $affaires/xpr:description/xpr:participants/xpr:experts[fn:count(xpr:expert)>=2]
      return pairsCombinations($participants/xpr:expert/@ref ! fn:data())
let $description := "Associations d’experts"
return
  <gexf xmlns="http://www.gexf.net/1.2draft" version="1.2">
    <meta lastmodifieddate="{fn:current-date()}">
      <creator>ANR Experts</creator>
      <description>{$description}</description>
    </meta>
    <graph mode="static" defaultedgetype="undirected">
      <attributes class="node">
        <attribute id="0" title="category" type="string"/>
      </attributes>
      <nodes>{
        for $node in $nodes
        let $label := $node//*:cpfDescription/*:identity/*:nameEntry[*:authorizedForm]/*:part
        let $functions := $node//*:functions
        let $function :=
          switch ($functions)
          case ($functions[fn:count(*:function) = 1][*:function/*:term = 'Expert bourgeois']) return 'architecte'
            case ($functions[fn:count(*:function) = 1][*:function/*:term = 'Expert entrepreneur']) return 'entrepreneur'
            case ($functions[fn:count(*:function) = 1][*:function/*:term = 'Arpenteur']) return 'arpenteur'
            case ($functions[fn:count(*:function) >= 2][*:function/*:term = 'Expert entrepreneur' and *:function/*:term = 'Expert bourgeois']) return 'transfuge'
            case ($functions[fn:count(*:function) >= 2][*:function/*:term = 'Expert entrepreneur'][fn:not(*:function/*:term = 'Expert bourgeois')]) return 'entrepreneur'
            case ($functions[fn:count(*:function) >= 2][*:function/*:term = 'Expert bourgeois'][fn:not(*:function/*:term = 'Expert entrepreneur')]) return 'architecte'
            default return 'unknown'
          return
            <node id="{$node/@xml:id}" label="{$label}">
              <attvalues>
                <attvalue for="0" value="{$function}"/>
                  </attvalues>
                </node>
      }</nodes>
      <edges>{
        for $edge at $i in $edges
        return <edge id="{random:uuid()}" source="{$edge?source}" target="{$edge?target}"/>
      }</edges>
    </graph>
  </gexf>
};


(:~
 : Experts collaboration
 : @return a gexf network of collaborations
 :)
declare function getExpertsCollaborationsGraphML($queryParam as map(*)) as element() {
  let $db := db:open('xpr')
  let $year := $queryParam?year
  let $nodes := $db//*:eac-cpf[*:cpfDescription/*:identity[@localType = 'expert']]
  let $edges := if ($year)
    then
      for $affaires in db:open('xpr')//xpr:expertise[xpr:description/xpr:sessions/xpr:date[1][fn:not(@when = '')][fn:year-from-date(@when) = xs:integer($year)]]
      let $participants := $affaires/xpr:description/xpr:participants/xpr:experts[fn:count(xpr:expert)>=2]
      return pairsCombinations($participants/xpr:expert/@ref ! fn:data())
    else
      for $affaires in db:open('xpr')//xpr:expertise
      let $participants := $affaires/xpr:description/xpr:participants/xpr:experts[fn:count(xpr:expert)>=2]
      return pairsCombinations($participants/xpr:expert/@ref ! fn:data())
  let $description := "Associations d’experts"
  return
  <graphml
    xmlns="http://graphml.graphdrawing.org/xmlns"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns http://graphml.graphdrawing.org/xmlns/1.1/graphml.xsd">
    <key id="d0" for="node" attr.name="category" attr.type="string"/>
    <key id="d1" for="node" attr.name="name" attr.type="string"/>
    <graph id="G" edgedefault="undirected">
      {
        for $node in $nodes
        let $label := $node//*:cpfDescription/*:identity/*:nameEntry[*:authorizedForm]/*:part
        let $functions := $node//*:functions
        let $function :=
        switch ($functions)
          case ($functions[fn:count(*:function) = 1][*:function/*:term = 'Expert bourgeois']) return 'architecte'
          case ($functions[fn:count(*:function) = 1][*:function/*:term = 'Expert entrepreneur']) return 'entrepreneur'
          case ($functions[fn:count(*:function) = 1][*:function/*:term = 'Arpenteur']) return 'arpenteur'
          case ($functions[fn:count(*:function) >= 2][*:function/*:term = 'Expert entrepreneur' and *:function/*:term = 'Expert bourgeois']) return 'transfuge'
          case ($functions[fn:count(*:function) >= 2][*:function/*:term = 'Expert entrepreneur'][fn:not(*:function/*:term = 'Expert bourgeois')]) return 'entrepreneur'
          case ($functions[fn:count(*:function) >= 2][*:function/*:term = 'Expert bourgeois'][fn:not(*:function/*:term = 'Expert entrepreneur')]) return 'architecte'
          default return 'unknown'
        return
          <node id="{$node/@xml:id}">
            <data key="d0">{$function}</data>
            <data key="d1">{$label/text()}</data>
          </node>
      }
      {
        for $edge at $i in $edges
        return <edge id="{random:uuid()}" source="{$edge?source}" target="{$edge?target}"/>
      }
    </graph>
  </graphml>
};