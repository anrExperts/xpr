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
declare default element namespace "xpr" ;
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
 : @return the asked format network of collaboration
 :)
declare function getExpertsCollaborations($queryParam as map(*)) as element() {
  if ($queryParam?format = 'graphml')
  then getExpertsCollaborationsGraphML($queryParam)
  else getExpertsCollaborationsGexf($queryParam)
};

(:~
 : List of Experts by year
 : @return a xml file
 : @todo select experts by year
 :)
declare function getExpertsByYear($queryParam as map(*)) as element() {
let $almanakDb := db:open('almanak')
let $year := $queryParam?year
let $expertises := xpr.models.networks:getExpertisesByYear($queryParam)
let $prosopo := db:open('xpr')/xpr/bio

let $almanak := $almanakDb//*:TEI[fn:matches(descendant::*:titleStmt/*:title, $year) or fn:matches(descendant::*:titleStmt/*:title, fn:string(fn:number($year) + 1))]
let $almanakExperts := $almanak//*:item/*:persName[fn:normalize-space(@ref) != '']/@ref
let $z1jExperts := $expertises//*:expertise[descendant::*:sessions/*:date[fn:substring(@when, 1, 4) = $year]]//*:experts/*:expert[fn:normalize-space(@ref)!='']/@ref
let $listExpert :=
    for $expert in fn:distinct-values(($z1jExperts | $almanakExperts))
    let $expertId := fn:substring-after($expert, '#')
    (:let $expertName := $xprDb//*:eac-cpf[@xml:id=$expertId]//*:nameEntry[*:authorizedForm]/*:part => fn:normalize-space()
    let $expertFunction := $xprDb//*:eac-cpf[@xml:id=$expertId]//*:function[$year >= *:dateRange/*:fromDate/@standardDate and $year <= *:dateRange/*:toDate/@standardDate] => fn:normalize-space():)
    return $prosopo//*:eac-cpf[@xml:id=$expertId]
    (: <expert><id>{$expertId}</id><name>{$expertName}</name><function>{$expertFunction}</function></expert>:)

let $comment :=
    let $countAlmanakExperts := fn:count(fn:distinct-values($almanakExperts))
    let $countZ1jExperts := fn:count(fn:distinct-values($z1jExperts))
    return
        <comment>{
            'Total experts almanak : ' || $countAlmanakExperts || ' ; total experts Z1J : ' || $countZ1jExperts || ' ; experts absents de l’almanak :',
            for $expert in fn:distinct-values($z1jExperts)
            return
                if($almanak//*:persName[@ref = $expert]) then ()
                else $expert
        }</comment>
return
  <experts xmlns="xpr">{
    $comment,
    $listExpert
  }</experts>
};

(:~
 : List of expertises by year (with only 1 category)
 : @return a xml file
 : @todo select expertises by year
 : @todo multiple categories
 :)
declare function getExpertisesByYear($queryParam as map(*)) as element() {
let $db := db:open('xpr')
let $year := $queryParam?year
let $expertises := $db//expertise[descendant::sessions/date[fn:substring(@when, 1, 4) = $year]][fn:count(descendant::categories/category) = 1]
return <expertises xmlns="xpr">{$expertises}</expertises>
};

(:~
 : categories - experts network for a year
 : @return a xml file
 :)
declare function getFormatedCategoriesNetwork($queryParam as map(*), $content as map(*), $outputParam as map(*)) as element() {
if ($queryParam?format = 'graphml')
  then getCategoriesNetworkGraphML($queryParam, $content)
  else if(($queryParam?format = 'csv')) then getCategoriesNetworkCSV($queryParam, $content)
  else getCategoriesNetworkGexf($queryParam, $content)
};
declare function getCategoriesNetworkGexf($queryParam as map(*), $content as map(*)) as element() {
<toto/>
};

(:

:)
declare function getCategoriesNetworkGraphML($queryParam as map(*), $content as map(*)) as element() {
let $expertises := $content?expertises
let $experts := $content?experts
let $categories :=
  let $labels := fn:distinct-values($expertises//*:category)
  return
    <categories>{
      for $cat at $i in $labels
      (:@todo faire beaucoup plus propre pour les @type:)
      return <category xml:id="{fn:concat('cat', $i)}" type="{fn:distinct-values($expertises//*:category[fn:normalize-space(.) = $cat]/@type)}">{$cat}</category>
    }</categories>

return
  <graphml
    xmlns="http://graphml.graphdrawing.org/xmlns"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns http://graphml.graphdrawing.org/xmlns/1.1/graphml.xsd">
    <key id="d0" for="node" attr.name="nodeType" attr.type="string"/>
    <key id="d1" for="node" attr.name="name" attr.type="string"/>
    <key id="d2" for="node" attr.name="function" attr.type="string"/>
    <key id="e1" for="edge" attr.name="weight" attr.type="int"/>
    <graph edgedefault="undirected">{
      for $expert in $experts/*:eac-cpf
        let $label := $expert//*:cpfDescription/*:identity/*:nameEntry[*:authorizedForm]/*:part
        let $functions := $expert//*:functions
        let $function :=
        switch ($functions)
          case ($functions[fn:count(*:function) = 1][*:function/*:term = 'Expert bourgeois']) return 'architecte'
          case ($functions[fn:count(*:function) = 1][*:function/*:term = 'Expert entrepreneur']) return 'entrepreneur'
          case ($functions[fn:count(*:function) = 1][*:function/*:term = 'Arpenteur']) return 'arpenteur'
          case ($functions[fn:count(*:function) >= 2][*:function/*:term = 'Expert entrepreneur' and *:function/*:term = 'Expert bourgeois']) return 'transfuge'
          case ($functions[fn:count(*:function) >= 2][*:function/*:term = 'Expert entrepreneur'][fn:not(*:function/*:term = 'Expert bourgeois')]) return 'entrepreneur'
          case ($functions[fn:count(*:function) >= 2][*:function/*:term = 'Expert bourgeois'][fn:not(*:function/*:term = 'Expert entrepreneur')]) return 'architecte'
          default return 'unknown'
      return(
        <node id="{$expert/@xml:id}">
          <data key="d0">expert</data>
          <data key="d1">{$label/text()}</data>
          <data key="d2">{$function}</data>
        </node>),
      for $category in $categories/*:category
      return
        <node id="{$category/@xml:id}">
          <data key="d0">category</data>
          <data key="d1">{$category => fn:normalize-space()}</data>
        </node>
    }
    {
      for $edge at $i in fn:distinct-values($expertises//*:experts/*:expert/@ref[fn:normalize-space(.)!=''])
      let $expert := $edge => fn:substring-after('#')
        return (
          for $category in $categories/*:category
          let $path := $expertises//*:expertise[*:description/*:participants/*:experts/*:expert/@ref=$edge][descendant::*:category/@type = $category/@type]
          where $path
          let $count := fn:count($path)
          return
            <edge id="{random:uuid()}" source="{$expert}" target="{$category/@xml:id}">
              <data key="e1">{$count}</data>
            </edge>
        )
    }
        </graph>
      </graphml>
};

declare function getCategoriesNetworkCSV($queryParam as map(*), $content as map(*)) as element() {
let $expertises := $content?expertises
let $experts := $content?experts
let $categories :=
  let $labels := fn:distinct-values($expertises//*:category)
  return
    <categories>{
      for $cat at $i in $labels
      (:@todo faire beaucoup plus propre pour les @type:)
      return <category xml:id="{fn:concat('cat', $i)}" type="{fn:distinct-values($expertises//*:category[fn:normalize-space(.) = $cat]/@type)}">{$cat}</category>
    }</categories>

return
  <csv>
    <record>
      <cell>id</cell>
      {for $category in $categories/*:category/@type return <cell>{fn:normalize-space($category)}</cell> }
    </record>{
    for $expert in $experts/*:eac-cpf
    order by $expert/@xml:id
    return
      <record>
        <cell>{fn:normalize-space($expert/@xml:id)}</cell>{
        for $category in $categories/*:category/@type
        return
          <cell>{
            let $countExpertises := fn:count($expertises//*:expertise[descendant::*:experts/*:expert/@ref = "#" || $expert/@xml:id][descendant::*:category/@type=$category])
            return if($countExpertises)then $countExpertises else "0"
          }</cell>
        }
      </record>
    }
  </csv>
};

(:~
 : categories - experts network for a year
 : @return a xml file
 :)
declare function getFormatedExpertisesNetwork($queryParam as map(*), $content as map(*), $outputParam as map(*)) as element() {
if ($queryParam?format = 'graphml')
  then getExpertisesNetworkGraphML($queryParam, $content)
  else if(($queryParam?format = 'csv')) then getExpertisesNetworkCSV($queryParam, $content)
};

declare function getExpertisesNetworkGraphML($queryParam as map(*), $content as map(*)) as element() {
<toto/>
};

declare function getExpertisesNetworkCSV($queryParam as map(*), $content as map(*)) as element() {
let $expertises := $content?expertises
let $experts := $content?experts
return
  <csv>
    <record>
      <cell>id</cell>
      {for $expertise in fn:sort($expertises/*:expertise/@xml:id) return <cell>{$expertise => fn:normalize-space()}</cell>}
    </record>{
    for $expert in fn:sort($experts/*:eac-cpf/@xml:id)
    return
      <record>
        <cell>{fn:normalize-space($expert)}</cell>{
        for $expertise in $expertises/*:expertise
        order by $expertise/@xml:id
        return
          if($expertise[descendant::*:experts/*:expert[@ref = "#"||$expert]]) then <cell>1</cell>
          else <cell>0</cell>
        }
      </record>
    }
  </csv>
};

declare function getFormatedClerksNetwork($queryParam as map(*), $content as map(*), $outputParam as map(*)) as element() {
if ($queryParam?format = 'graphml')
  then getClerksNetworkGraphML($queryParam, $content)
  else if(($queryParam?format = 'csv')) then getClerksNetworkCSV($queryParam, $content)
};

declare function getClerksNetworkGraphML($queryParam as map(*), $content as map(*)) as element() {
<toto/>
};

declare function getClerksNetworkCSV($queryParam as map(*), $content as map(*)) as element() {
let $expertises := $content?expertises
let $experts := $content?experts
let $clerks :=
  <list xmlns="xpr">
    <clerk xml:id="xprClerk001">
      <persName>De Varenne</persName>
      <status>Doyen</status>
      <address>rue S. Bont.</address>
      <forms/>
    </clerk>
    <clerk xml:id="xprClerk002">
      <persName>Février</persName>
      <status/>
      <address>rue des vieilles Étuves S. Martin.</address>
      <forms/>
    </clerk>
    <clerk xml:id="xprClerk003">
      <persName>Belot</persName>
      <status/>
      <address>rue de la Verrerie.</address>
      <forms/>
    </clerk>
    <clerk xml:id="xprClerk004">
      <persName>Quirot L.</persName>
      <status/>
      <address>rue Jean pain mollet.</address>
      <forms/>
    </clerk>
    <clerk xml:id="xprClerk005">
      <persName>Le Févre</persName>
      <status/>
      <address>rue des Maturins.</address>
      <forms/>
    </clerk>
    <clerk xml:id="xprClerk006">
      <persName>Meley</persName>
      <status/>
      <address>rue de la Tisseranderie</address>
      <forms>
        <form>Meley, François</form>
        <form>Melley, François</form>
        <form>Nelet, François</form>
        <form>Neley, François</form>
      </forms>
    </clerk>
    <clerk xml:id="xprClerk007">
      <persName>Boussart</persName>
      <status/>
      <address>rue de la Mortellerie</address>
      <forms/>
    </clerk>
    <clerk xml:id="xprClerk008">
      <persName>Quirot J</persName>
      <status/>
      <address>rue de la Verrerie, près le Cémetière S. Jean</address>
      <forms/>
    </clerk>
    <clerk xml:id="xprClerk009">
      <persName>Chastriot</persName>
      <status/>
      <address>rue des deux Écus</address>
      <forms/>
    </clerk>
    <clerk xml:id="xprClerk010">
      <persName>Dupré</persName>
      <status/>
      <address>rue Patourelle.</address>
      <forms/>
    </clerk>
    <clerk xml:id="xprClerk011">
      <persName>Le Couvreux</persName>
      <status/>
      <address>cul-de-sac de Guéméné</address>
      <forms/>
    </clerk>
    <clerk xml:id="xprClerk012">
      <persName>Callou</persName>
      <status/>
      <address>rue de la Poterie</address>
      <forms>
        <form>Callon, Antoine Charles</form>
        <form>Callot, Antoine Charles</form>
        <form>Callou, Antoine</form>
        <form>Callou, Antoine Charles</form>
        <form>Callou, Antoine-Charles</form>
        <form>Callou, Charles Antoine</form>
        <form>Cassou, Antoine Charles</form>
        <form>Collot, Antoine Charles</form>
        <form>Collou, Antoine Charles</form>
      </forms>
    </clerk>
    <clerk xml:id="xprClerk013">
      <persName>Baudouin</persName>
      <status/>
      <address>Quay de Gesvres</address>
      <forms>
        <form>Baudoin, Antoine</form>
        <form>Baudouin, Antoine</form>
        <form>Baudouin, Etienne</form>
        <form>Daudouin, Antoine</form>
        <form>Haudoin, Antoine</form>
      </forms>
    </clerk>
    <clerk xml:id="xprClerk014">
      <persName>Tancart</persName>
      <status/>
      <address>rue Ste Croix de la Bretonnerie</address>
      <forms>
        <form>Tancart, Toussaint</form>
        <form>Tancart, Toussaint ; Callou (deuxième vacation)</form>
        <form>Tansart, Toussaint</form>
        <form>Taucart, Toussaint</form>
        <form>Toucard, Toussaint</form>
        <form>Toucart, Toussaint</form>
      </forms>
    </clerk>
    <clerk xml:id="xprClerk015">
      <persName>Danjau</persName>
      <status/>
      <address>Montagne Ste Géneviéve</address>
      <forms>
        <form>Dangin, Pierre Paul</form>
        <form>Danjan, Pierre Paul</form>
        <form>Danjan, Pierre-Paul</form>
        <form>Danjean, Pierre Paul</form>
        <form>Danjon, Pierre-Paul</form>
        <form>Dauhan, Pierre Paul</form>
        <form>Daujan, Pierre Paul</form>
      </forms>
    </clerk>
    <clerk xml:id="xprClerk016">
      <persName>Mayer</persName>
      <status/>
      <address>rue de la Verrerie</address>
      <forms/>
    </clerk>
    <clerk xml:id="xprClerk017">
      <persName>Cochois, Jacques Richard</persName>
      <status/>
      <address/>
      <forms>
        <form>Cochois, Jacques Richard</form>
        <form>Cochois, Jacques-Richard</form>
        <form>Cochois, Richard</form>
        <form>Richard, Jacques</form>
      </forms>
    </clerk>
    <clerk xml:id="xprClerk019">
      <persName>Le Brun, Jacques Charles</persName>
      <status/>
      <address/>
      <forms>
        <form>Le Brun, Jacques Charles</form>
      </forms>
    </clerk>
    <clerk xml:id="xprClerk020">
      <persName>Quirot, Estienne François</persName>
      <status/>
      <address/>
      <forms>
        <form>François, Etienne</form>
        <form>Quirot, Estienne François</form>
        <form>Quirot, Etienne</form>
        <form>Quirot, Etienne François</form>
        <form>Quirot, François Estienne</form>
      </forms>
    </clerk>
    <clerk xml:id="xprClerk021">
      <persName>Quirot, Jacques</persName>
      <status/>
      <address/>
      <forms>
        <form>Quirot, Jacques</form>
        <form>Quiriot, Jacques</form>
        <form>Quirot, [Jacques]</form>
      </forms>
    </clerk>
    <clerk xml:id="xprClerk022">
      <persName>Quirot, Jean</persName>
      <status/>
      <address/>
      <forms>
        <form>Quirot, Jean</form>
      </forms>
    </clerk>
    <clerk xml:id="xprClerk023">
      <persName>Quirot, Pierre</persName>
      <status/>
      <address/>
      <forms>
        <form>Quirot, Pierre</form>
      </forms>
    </clerk>
    <clerk xml:id="xprClerk018">
      <persName>Quirot</persName>
      <status/>
      <address/>
      <forms>
        <form>Quirot,</form>
      </forms>
    </clerk>
  </list>
return
  <csv>
    <record>
      <cell>id</cell>
      {for $clerk in fn:sort($clerks/*:clerk/@xml:id) return <cell>{$clerk => fn:normalize-space()}</cell>}
    </record>{
    for $expert in fn:sort($experts/*:eac-cpf/@xml:id)
    return
      <record>
        <cell>{fn:normalize-space($expert)}</cell>{
        for $clerk in fn:sort($clerks/*:clerk/@xml:id)
        return
          if($expertises//*:expertise[descendant::*:clerk/*:persName[fn:string-join(*, ', ') = $clerks/*:clerk[@xml:id=$clerk]/*:forms/*:form]][descendant::*:experts/*:expert[@ref = "#"||$expert]])
          then <cell>{fn:count($expertises//*:expertise[descendant::*:clerk/*:persName[fn:string-join(*, ', ') = $clerks/*:clerk[@xml:id=$clerk]/*:forms/*:form]][descendant::*:experts/*:expert[@ref = "#"||$expert]])}</cell>
          else <cell>0</cell>
        }
      </record>
    }
  </csv>
};

(:~
 : experts data for a year
 : @return a xml file
 :)
declare function getFormatedExpertsData($queryParam as map(*), $content as map(*), $outputParam as map(*)) as element() {
if ($queryParam?format = 'xml')
  then getExpertsDataXML($queryParam, $content)
  else if(($queryParam?format = 'csv')) then getExpertsDataCSV($queryParam, $content)
};

declare function getExpertsDataXML($queryParam as map(*), $content as map(*)) as element() {
    $content?experts
};

declare function getExpertsDataCSV($queryParam as map(*), $content as map(*)) as element() {
let $experts := $content?experts
return
  <csv>
    <record>
      <cell>id</cell>
      <cell>name</cell>
      <cell>surname</cell>
      <cell>column</cell>
      <cell>birth</cell>
      <cell>death</cell>
      <cell>almanach</cell>
    </record>{
    for $expert in $experts/*:eac-cpf
        order by $expert/@xml:id
        let $name := $expert//*:cpfDescription/*:identity/*:nameEntry[*:authorizedForm]/*:part => fn:normalize-space()
        let $surname := $expert//*:cpfDescription/*:identity/*:nameEntry[*:alternativeForm][1]/*:part[@localType='surname'] => fn:normalize-space()
        let $birth := $expert//*:existDates/*:dateRange/*:fromDate/@* => fn:normalize-space()
        let $death := $expert//*:existDates/*:dateRange/*:toDate/@* => fn:normalize-space()
        let $functions := $expert//*:functions
        let $column :=
              switch ($functions)
                case ($functions[fn:count(*:function) = 1][*:function/*:term = 'Expert bourgeois']) return 'architecte'
                case ($functions[fn:count(*:function) = 1][*:function/*:term = 'Expert entrepreneur']) return 'entrepreneur'
                case ($functions[fn:count(*:function) = 1][*:function/*:term = 'Arpenteur']) return 'arpenteur'
                case ($functions[fn:count(*:function) >= 2][*:function/*:term = 'Expert entrepreneur' and *:function/*:term = 'Expert bourgeois']) return 'transfuge'
                case ($functions[fn:count(*:function) >= 2][*:function/*:term = 'Expert entrepreneur'][fn:not(*:function/*:term = 'Expert bourgeois')]) return 'entrepreneur'
                case ($functions[fn:count(*:function) >= 2][*:function/*:term = 'Expert bourgeois'][fn:not(*:function/*:term = 'Expert entrepreneur')]) return 'architecte'
                default return 'unknown'
    return
    <record>
        <cell>{$expert/@xml:id => fn:normalize-space()}</cell>
        <cell>{$name}</cell>
        <cell>{$surname}</cell>
        <cell>{$column}</cell>
        <cell>{$birth}</cell>
        <cell>{$death}</cell>
        <cell>almanach</cell>
    </record>
    }
  </csv>
};

(:~
 : experts data for a year
 : @return a xml file
 :)
declare function getFormatedExpertisesData($queryParam as map(*), $content as map(*), $outputParam as map(*)) as element() {
if ($queryParam?format = 'xml')
  then getExpertisesDataXML($queryParam, $content)
  else if(($queryParam?format = 'csv')) then getExpertisesDataCSV($queryParam, $content)
};

declare function getExpertisesDataXML($queryParam as map(*), $content as map(*)) as element() {
    $content?expertises
};

declare function getExpertisesDataCSV($queryParam as map(*), $content as map(*)) as element() {
let $expertises := $content?expertises
let $experts := $content?experts
return
  <csv>
    <record>
      <cell>id</cell>
      <cell>third-party</cell>
      <!--<cell>origination</cell>-->
      <cell>framework</cell>
      <cell>categories</cell>
      <cell>designation</cell>
      <cell>nbExperts</cell>
      <cell>columns</cell>
    </record>{
    for $expertise in $expertises/*:expertise
    order by $expertise/@xml:id
    let $id := $expertise/@xml:id => fn:normalize-space()
    let $thirdParty := fn:boolean($expertise/descendant::*:experts/*:expert[@context='third-party'])
    (:let $origination := fn:translate($expertise/descendant::*:origination, ' ', ' ') => fn:normalize-space()):)
    let $framework := $expertise/descendant::*:framework/@type => fn:normalize-space()
    let $categories := fn:string-join($expertise/descendant::*:categories/*:category/@type, ', ') => fn:normalize-space()
    let $designation := $expertise/descendant::*:categories/*:designation => fn:normalize-space()
    let $expertsId := $expertise//*:experts/*:expert[fn:normalize-space(@xml:id)!='']/fn:substring-after(@ref, '#')
    let $functions :=
      for $expertId in $expertsId
      return
        switch ($experts//*:eac-cpf[@xml:id=$expertId]//*:functions)
        case ($experts//*:eac-cpf[@xml:id=$expertId]//*:functions[fn:count(*:function) = 1][*:function/*:term = 'Expert bourgeois']) return 'architecte'
        case ($experts//*:eac-cpf[@xml:id=$expertId]//*:functions[fn:count(*:function) = 1][*:function/*:term = 'Expert entrepreneur']) return 'entrepreneur'
        case ($experts//*:eac-cpf[@xml:id=$expertId]//*:functions[fn:count(*:function) = 1][*:function/*:term = 'Arpenteur']) return 'arpenteur'
        case ($experts//*:eac-cpf[@xml:id=$expertId]//*:functions[fn:count(*:function) >= 2][*:function/*:term = 'Expert entrepreneur' and *:function/*:term = 'Expert bourgeois']) return 'transfuge'
        case ($experts//*:eac-cpf[@xml:id=$expertId]//*:functions[fn:count(*:function) >= 2][*:function/*:term = 'Expert entrepreneur'][fn:not(*:function/*:term = 'Expert bourgeois')]) return 'entrepreneur'
        case ($experts//*:eac-cpf[@xml:id=$expertId]//*:functions[fn:count(*:function) >= 2][*:function/*:term = 'Expert bourgeois'][fn:not(*:function/*:term = 'Expert entrepreneur')]) return 'architecte'
        default return 'unknown'

    return
    <record>
      <cell>{$id}</cell>
      <cell>{$thirdParty}</cell>
      <!--<cell>{$origination}</cell>-->
      <cell>{$framework}</cell>
      <cell>{$categories}</cell>
      <cell>{$designation}</cell>
      <cell>{fn:count($expertsId)}</cell>
      <cell>{for $function in fn:distinct-values($functions) order by $function return $function}</cell>
    </record>}
  </csv>
};

(:~
 : Experts collaboration
 : @return a gexf network of collaborations
 : @todo select experts by year
 :)
declare function getExpertsCollaborationsGexf($queryParam as map(*)) as element() {
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
 : @todo resolve issue with the cases dates (for now we take the first date)
 :)
declare function getExpertsCollaborationsGraphML($queryParam as map(*)) as element() {
  let $db := db:open('xpr')
  let $year := $queryParam?year
  let $cases := db:open('xpr')//xpr:expertise[xpr:description/xpr:sessions/xpr:date[1][fn:not(@when = '')][fn:year-from-date(@when) = xs:integer($year)]]
  let $nodes := $db//*:eac-cpf[@xml:id = $cases//xpr:experts/xpr:expert/@ref][*:cpfDescription/*:identity[@localType = 'expert']]
  let $edges := if ($year)
    then
      for $case in $cases
      let $participants := $case/xpr:description/xpr:participants/xpr:experts[fn:count(xpr:expert)>=2]
      return pairsCombinations($participants/xpr:expert/@ref ! fn:data())
    else
      for $case in db:open('xpr')//xpr:expertise
      let $participants := $case/xpr:description/xpr:participants/xpr:experts[fn:count(xpr:expert)>=2]
      return pairsCombinations($participants/xpr:expert/@ref ! fn:data())
  let $description := "Associations d’experts"
  return
  <graphml
    xmlns="http://graphml.graphdrawing.org/xmlns"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns http://graphml.graphdrawing.org/xmlns/1.1/graphml.xsd">
    <key id="d0" for="node" attr.name="category" attr.type="string"/>
    <key id="d1" for="node" attr.name="name" attr.type="string"/>
    <graph edgedefault="undirected">
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