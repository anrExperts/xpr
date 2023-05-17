xquery version "3.0";
module namespace xpr.mappings.html = "xpr.mappings.html";
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
import module namespace functx = "http://www.functx.com";
import module namespace Session = 'http://basex.org/modules/session';

declare namespace db = "http://basex.org/modules/db" ;
declare namespace file = "http://expath.org/ns/file" ;
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization" ;
declare namespace perm = "http://basex.org/modules/perm" ;
declare namespace web = "http://basex.org/modules/web" ;
declare namespace user = "http://basex.org/modules/user" ;

declare namespace ev = "http://www.w3.org/2001/xml-events" ;
declare namespace eac = "https://archivists.org/ns/eac/v2" ;
declare namespace rico = "rico" ;

declare namespace map = "http://www.w3.org/2005/xpath-functions/map" ;
declare namespace xf = "http://www.w3.org/2002/xforms" ;
declare namespace xlink = "http://www.w3.org/1999/xlink" ;

declare namespace xpr = "xpr" ;
declare default function namespace "xpr.mappings.html" ;

declare default collation "http://basex.org/collation?lang=fr" ;

(:~
 : this function get the interface message
 : @todo deals with other cases
 :)
declare function getMessage($id, $lang) {
  let $message := $G:interface/xpr:interface/xpr:prosopo/xpr:element[@xml:id=$id]/xpr:message[@xml:lang]/node()
  return if ($message[fn:normalize-space(.)!=''])
    then $message
    else <message>todo</message>
};

(:~
 : This function dispatches the treatment of the xpr XML document (expertises)
 :)
declare
  %output:indent('no')
function xpr2html($node as node()*, $options as map(*)) as item()* {
  <article>
    <header>
      <h2>{ getReference($node, $options) }</h2>
      <h3>{ fn:string-join(
      for $place in $node/xpr:description/xpr:places/xpr:place return getPlace($place, $options),
      ' | ') }</h3>
      <div class="canvas-container">
        <sequence-panel
          id='sequence'
          manifest-id="/xpr/files/manifest/{$node/xpr:sourceDesc/xpr:idno[@type='unitid']=>fn:normalize-space()}.manifest.json"
          start-canvas="https://xpr/iiif/{$node/xpr:sourceDesc/xpr:idno[@type='unitid']=>fn:normalize-space()}/canvas/p{$node/xpr:sourceDesc/xpr:facsimile/@from => fn:normalize-space()}"
          margin='30'>
        </sequence-panel>
        <button id='prev'>prev</button>
        <button id='next'>next</button>
      </div>
      <ul>{
        <lh>Liste des vacations</lh>,
        for $pair in $node/xpr:description/xpr:sessions/xpr:date ! array{./@type , ./@when}
        return <li>{fn:string-join(
          (
            if (array:head($pair) = 'paris') then 'Paris'
            else if (array:head($pair) = 'suburbs') then 'Banlieue'
            else 'Province',
            if (fn:normalize-space(array:tail($pair)) castable as xs:date) then
            getFormatedDate(<date when="{array:tail($pair)}"/>, $options)
            else 'date non renseignée'
          ),
          ' : ')}</li>
      }</ul>
    </header>
    <div class="meta">
      <div class="procedure">
        <h3>Procédure</h3>
        {if (fn:normalize-space($node/xpr:description/xpr:categories/xpr:designation) != '') then
        <p>{fn:normalize-space($node/xpr:description/xpr:categories/xpr:designation), if($node/xpr:description/xpr:categories/xpr:designation[@rubric='true']) then ' (en rubric)'}</p>}
        <p>{if (fn:count($node/xpr:description/xpr:categories/xpr:category) > 1) then
          'Catégories d’expertise : '
          else 'Catégorie d’expertise : ',
          fn:string-join($node/xpr:description/xpr:categories/xpr:category, ' ; ') => fn:concat( '.')}
        </p>
        <p>Procédure : {fn:concat($node/xpr:description/xpr:procedure/xpr:framework/@type, ' - ', fn:normalize-space($node/xpr:description/xpr:procedure/xpr:framework))}</p>
        <p>Origine de l’expertise : {$node/xpr:description/xpr:procedure/xpr:origination}</p>
        {if (fn:normalize-space($node/xpr:description/xpr:procedure/xpr:sentences) != '') then
        <p>Intervention d’une institution  : {
          (for $sentence in $node/xpr:description/xpr:procedure/xpr:sentences/xpr:sentence
          return fn:concat(
            functx:capitalize-first($sentence/xpr:orgName),
            ' : ',
            (for $date in $sentence/xpr:date return getFormatedDate($date, $options)) => fn:string-join(', ')))
          => fn:string-join(' | ')
        }</p>}
        <p>Cause de l’expertise : {fn:normalize-space($node/xpr:description/xpr:procedure/xpr:case)}</p>
        <p>{
          if(fn:count($node/xpr:description/xpr:procedure/xpr:objects/xpr:object) > 1) then 'Objets de l’expertise : '
          else 'Objet de l’expertise : ',
          fn:string-join($node/xpr:description/xpr:procedure/xpr:objects/xpr:object, ' ; ') => fn:concat('.')
        }</p>
      </div>
      <div class="participants">
        <h3>Participants</h3>
        <div>{
          <h4>{ if(fn:count($node/xpr:description/xpr:participants/xpr:experts/xpr:expert) > 1) then 'Experts' else 'Expert' }</h4>,
          <ul>{
            for $expert in $node/xpr:description/xpr:participants/xpr:experts/xpr:expert
            return <li>{ getExpert($expert, $options) }</li>
          }</ul>
        }</div>
        <div>{
          <h4>{ if(fn:count($node/xpr:description/xpr:participants/xpr:clerks/xpr:clerk) > 1) then 'Greffiers' else 'Greffier' }</h4>,
          <ul>{
            for $clerk in $node/xpr:description/xpr:participants/xpr:clerks/xpr:clerk
            return <li>{ getPersName($clerk/xpr:persName, $options) }</li>
          }</ul>
        }</div>
        {for $party in $node/xpr:description/xpr:participants/xpr:parties/xpr:party[fn:normalize-space(.)!=''] return getParty($party, $options)}
        {if(fn:normalize-space($node/xpr:description/xpr:participants/xpr:craftmen)!='') then
        <div>{
          <h4>Entrepreneurs, architectes ou maîtres d’œuvre</h4>,
          <ul>{
            for $craftman in $node/xpr:description/xpr:participants/xpr:craftmen/xpr:craftman
            return <li>{(
              getPersName($craftman/xpr:persName, $options),
              if(fn:normalize-space($craftman/xpr:occupation)!='') then fn:normalize-space($craftman/xpr:occupation)
              ) => fn:string-join(', ') }</li>
          }</ul>
        }</div>
        }
      </div>
      <div class="conclusions">
        <h3>Conclusions</h3>
        <p>{
          fn:concat(
            'Dispositif de l’expertise : ',
            fn:lower-case(fn:normalize-space($node/xpr:description/xpr:conclusions/xpr:agreement)))
        }</p>
        {for $opinion in $node/xpr:description/xpr:conclusions/xpr:opinion
        return <p>{ getOpinion($opinion, $options) }</p>}
        {if(fn:normalize-space($node/xpr:description/xpr:conclusions/xpr:arrangement)!='') then
          <p>{ 'Accomodement : ' || fn:lower-case(fn:normalize-space($node/xpr:description/xpr:conclusions/xpr:arrangement)) || '.' }</p>}
        {if(fn:normalize-space(fn:string-join($node/xpr:description/xpr:conclusions/xpr:estimate/@*))!='') then
          <p>{'Montant global (pour les estimations) : ' || getValue($node/xpr:description/xpr:conclusions/xpr:estimate, $options)}</p>}
        {if(fn:normalize-space($node/xpr:description/xpr:conclusions/xpr:estimates)!='') then
          <ul>{
            for $place in $node/xpr:description/xpr:conclusions/xpr:estimates/xpr:place
            let $ref := fn:substring-after($place/@ref, '#')
            let $placeName := getAddress($node/xpr:description/xpr:places/xpr:place[@xml:id=$ref], $options)
            return (
              <lh>{ 'Estimation pour', $placeName }</lh>,
              for $appraisal in $place/xpr:appraisal
              return <li>{ fn:normalize-space($appraisal/xpr:desc) || ' : ' || getValue($appraisal, $options) }</li>)
          }</ul>}
        {if(
          fn:normalize-space(
            fn:string-join($node/xpr:description/xpr:conclusions/xpr:fees/(descendant::*/@l, descendant::*/@s, descendant::*/@d)))!='')
        then
          for $fee in $node/xpr:description/xpr:conclusions/xpr:fees/xpr:fee[fn:string-join((@l, @s, @d))!='']
          return <p>{ getFee($fee, $options) }</p>}
        {if(
          fn:normalize-space(
            fn:string-join($node/xpr:description/xpr:conclusions/xpr:fees/xpr:total/(@l, @s, @d)))!='')
        then <p>{ 'Coût total de l’expertise :', getValue($node/xpr:description/xpr:conclusions/xpr:fees/xpr:total, $options) }</p>}
        {if(
          fn:normalize-space(
            fn:string-join($node/xpr:description/xpr:conclusions/xpr:expenses/xpr:expense[@type='expert']/(@l, @s, @d)))!='')
        then <p>{ 'Bourse commune des experts :', getValue($node/xpr:description/xpr:conclusions/xpr:expenses/xpr:expense[@type='expert'], $options) }</p>}
        {if(
          fn:normalize-space(
            fn:string-join($node/xpr:description/xpr:conclusions/xpr:expenses/xpr:expense[@type='clerk']/(@l, @s, @d)))!='')
        then <p>{ 'Bourse commune des greffiers :', getValue($node/xpr:description/xpr:conclusions/xpr:expenses/xpr:expense[@type='clerk'], $options) }</p>}
      </div>
      {if(fn:normalize-space(fn:string-join($node/xpr:description/xpr:keywords[@group]))!='')
      then
        <div class="indexation">{
          <h3>Indexation</h3>,
          for $keywordsGroup in $node/xpr:description/xpr:keywords[@group][fn:normalize-space(.)!='']
          return getKeywords($keywordsGroup, $options)
        }</div>}
      {if(fn:normalize-space($node/xpr:description/xpr:analysis)!='')
      then
        <div class="analysis">{
          <h3>Commentaires et première analyse</h3>,
          fn:normalize-space($node/xpr:description/xpr:analysis)
        }</div>}
      {if(fn:normalize-space($node/xpr:description/xpr:noteworthy)!='')
      then
        <div class="indexation">{
          <h3>Éléments remarquables</h3>,
          fn:normalize-space($node/xpr:description/xpr:noteworthy)
        }</div>}
    </div>
    <div class="control">{
      <h3>Historique des modifications</h3>,
      <ul>{
        for $maintenanceEvent in $node/xpr:control/xpr:maintenanceHistory/xpr:maintenanceEvent
        return <li>{ getMaintenanceEvent($maintenanceEvent, $options) }</li>
      }</ul>
    }</div>
  </article>
};

declare function getMaintenanceEvent($node as node()*, $options as map(*)) as xs:string {
  let $dateTime := $node/xpr:eventDateTime/@standardDateTime
  return (
    $dateTime, fn:normalize-space($node/xpr:eventDescription), 'par', fn:normalize-space($node/xpr:agent)
  ) => fn:string-join(' ')
};

declare function getKeywords($node as node()*, $options as map(*)) as element() {
  let $label :=
  switch ($node/@group)
    case 'estates' return 'Biens expertisés (nature juridique et caractères)'
    case 'procedure' return 'Procédure (questions de)'
    case 'contract' return 'Contrat (type de, concernant le bien expertisé)'
    case 'encumbrance' return 'Servitudes'
    case 'law' return 'Droit (nature et source du)'
    case 'measurement' return 'Mesure'
    case 'repairs' return 'Réparations (hors cas d’expertises portant sur des réparations)'
    case 'guarantees' return 'Sûreté/Garanties'
    case 'responsability' return 'Responsabilité'
    case 'ownership' return 'Propriété (transmission de)'
    case 'value' return 'Valeur'
    case 'neighbourhood' return 'Voisinage'
    case 'disorder' return 'Désordres'
    case 'transformation' return 'Transformation du bâti/Travaux (type de)'
    default return ()
  return
    <p>{
      $label || ' : ',
      for $term in $node/xpr:term
      return
        <a href="/xpr/index/{$term/@value}">{ fn:normalize-space($term) }</a>
    }</p>
};

declare function getFee($node as node()*, $options as map(*)) as xs:string {
  let $prosopo := db:open('xpr')/xpr:xpr/xpr:bio
  let $expertName := fn:normalize-space($prosopo/eac:eac[@xml:id=fn:substring-after($node/@ref, '#')]/eac:cpfDescription/eac:identity/eac:nameEntry[@status='authorized']/eac:part)
  let $type :=
  switch ($node/@type)
    case 'expert'
    return (
      ('Expert',
      if(fn:normalize-space($node/@ref)!='') then
        let $prosopo := db:open('xpr')/xpr:xpr/xpr:bio
        let $expertName := fn:normalize-space($prosopo/eac:eac[@xml:id=fn:substring-after($node/@ref, '#')]/eac:cpfDescription/eac:identity/eac:nameEntry[@status='authorized']/eac:part)
        return '(' || $expertName || ')')) => fn:string-join(' ')
    case 'clerk' return 'Greffier'
    case 'rolls' return 'Rôles'
    case 'papers' return 'Papier et contrôle'
    case 'plans' return 'Plans'
    case 'prosecutors' return 'Procureur(s)'
    case 'help' return 'Aides'
    case 'other' return fn:normalize-space($node/text())
    default return ()
  return text{$type || ' : ' || getValue($node, $options)}
};

declare function getValue($node as node()*, $options as map(*)) as xs:string {
  (for $value in $node/@*[fn:local-name() = 'l' or fn:local-name() = 's' or fn:local-name() = 'd'][fn:normalize-space(.)!='']
  let $money :=
  switch($value/fn:local-name())
    case 'l' return 'livres'
    case 's' return 'sols'
    case 'd' return 'deniers'
    default return ()
  return (fn:normalize-space($value) || ' ' || $money)) => fn:string-join(', ')
};

declare function getOpinion($node as node()*, $options as map(*)) as node()* {
  let $prosopo := db:open('xpr')/xpr:xpr/xpr:bio
  let $expertName := fn:normalize-space($prosopo/eac:eac[@xml:id=fn:substring-after($node/@ref, '#')]/eac:cpfDescription/eac:identity/eac:nameEntry[@status='authorized']/eac:part)
  let $expert := <a href="/xpr/biographies/{fn:normalize-space($node/@ref)}/view">{ $expertName }</a>
  let $opinion := $node/text()
  return (
    text{'Conclusion'},
    if(fn:normalize-space($node/@ref)!='') then (text{' de '}, $expert),
    text{' : ' || $opinion})

};

declare function getParty($node as node()*, $options as map(*)) as element() {
  let $role := switch ($node/@role)
    case 'petitioner' return 'Partie requérante'
    case 'opponent' return 'Partie opposante'
    default return 'Partie'
  let $status := switch ($node/xpr:status)
    case 'builder' return 'entrepreneur'
    case 'owner' return 'propriétaire'
    case 'joint-owner' return 'copropriétaire'
    case 'limited-partner' return 'commanditaire'
    case 'heir' return 'héritier'
    case 'neighbour' return 'voisin'
    case 'tenant' return 'locataire'
    case 'main-tenant' return 'principal locataire'
    case 'creditor' return 'créancier'
    case 'mortgagor' return 'débiteur'
    case 'contractor' return 'fermier judiciaire'
    default return 'qualification indéterminée'
  let $presence := switch ($node/@presence)
    case 'true' return 'présente'
    case 'false' return 'non présente'
    default return ''
  let $intervention := switch ($node/@intervention)
    case 'true' return 'intervenante'
    case 'false' return 'non intervenante'
    default return ''
  let $expertName := fn:normalize-space(db:open('xpr')/xpr:xpr/xpr:bio/eac:eac[@xml:id=fn:substring-after($node/xpr:expert/@ref, '#')]/eac:cpfDescription/eac:identity/eac:nameEntry[@status='authorized']/eac:part)
  let $expert := <a href="/xpr/biographies/{fn:normalize-space($node/xpr:expert/@ref)}/view">{ $expertName }</a>
  return
    <div class="party">{
      <h4>{ $role || ' (' || $status || ')' }</h4>,
      if(fn:normalize-space(fn:concat($presence, $intervention))!='') then
      <p>{
        'Partie ',
        ($presence, $intervention) => fn:string-join(', ')
      }</p>,
      <ul>{
        for $person in $node/xpr:person[fn:normalize-space(.)!='']
        return <li>{ getPersName($person/xpr:persName, $options) }</li>
      }</ul>,
      if($node/xpr:expert[fn:normalize-space(@ref)!='']) then
      <p>{ 'Expert : ', $expert }</p>,
      if($node/xpr:representative[fn:normalize-space(.)!='']) then
      <ul>{
        <lh>{ if(fn:count($node/xpr:representative[fn:normalize-space(.)!='']) > 1) then 'Représentants' else 'Représentant' }</lh>,
        for $representative in $node/xpr:representative
        return <li>{(
          getPersName($representative/xpr:persName, $options),
          if(fn:normalize-space($representative/xpr:occupation)!='') then fn:normalize-space($representative/xpr:occupation)
          ) => fn:string-join(', ')}</li>
      }</ul>,
      if($node/xpr:prosecutor[fn:normalize-space(.)!='']) then
      <ul>{
        <lh>{ if(fn:count($node/xpr:prosecutor[fn:normalize-space(.)!='']) > 1) then 'Procureurs' else 'Procureur' }</lh>,
        for $prosecutor in $node/xpr:prosecutor
        return <li>{ getPersName($prosecutor/xpr:persName, $options) }</li>
      }</ul>
    }</div>
};

declare function getFormatedDate($node as node()*, $options as map(*)) as xs:string {
  (:@todo make it work with string and node:)
  switch ($node)
    case $node[(@when | @notAfter | @notBefore | @standardDate) castable as xs:date] return fn:format-date(xs:date($node/(@when | @notAfter | @notBefore | @standardDate)), '[D01] [Mn] [Y0001]', 'fr', (), ())
    case $node[(@when | @notAfter | @notBefore | @standardDate) castable as xs:gYearMonth] return fn:format-date(xs:date($node/(@when | @notAfter | @notBefore | @standardDate) || '-01'), '[Mn] [Y0001]', 'fr', (), ())
    case $node[(@when | @notAfter | @notBefore | @standardDate) castable as xs:gYear] return fn:format-date(xs:date($node/(@when | @notAfter | @notBefore | @standardDate) || '-01-01'), '[Y0001]', 'fr', (), ())
    case $node[(@when | @notAfter | @notBefore | @standardDate) = ''] return '..'
    default return $node/@when
};

declare function getPersName($node as node()*, $options as map(*)) as xs:string {
  if(fn:normalize-space($node/xpr:surname)!='' and fn:normalize-space($node/xpr:forename)!='') then
    functx:capitalize-first(fn:normalize-space($node/xpr:surname)) || ', ' || functx:capitalize-first(fn:normalize-space($node/xpr:forename))
  else
    functx:capitalize-first(fn:normalize-space($node))
};

declare function getReference($node as node()*, $options as map(*)) as xs:string {
let $supplement := $node/xpr:sourceDesc/xpr:idno[@type='supplement'][fn:normalize-space(.) != '']
return fn:string-join(
    (
        fn:concat($node/xpr:sourceDesc/xpr:idno[@type='unitid'], ' dossier n° ', $node/xpr:sourceDesc/xpr:idno[@type='item']),
        if ($supplement) then ' ' || $supplement,
        ' (' || getInterval($node/xpr:description/xpr:sessions, $options) || ')'
     )
   )
};

(:~
 : @todo translate dates in french (basex)
 :)
declare function getInterval($node as node()*, $options as map(*)) as xs:string {
  if($node/xpr:date/@when[fn:normalize-space(.) castable as xs:date]) then
    let $interval := (
      for $date in $node/xpr:date[@when!='' and @when castable as xs:date]
      order by $date
      return $date
    )[fn:position() = 1 or fn:position() = fn:last()]
    return fn:string-join(
      $interval ! getFormatedDate(., $options)
      , ' au ')
  else 'date non renseignée'
};

declare function getPlace($node as node()*, $options as map(*)) as xs:string {
  switch ($node/@type)
  case 'paris' return fn:string-join(getAddress($node, $options))
  case 'suburbs' return 'Banlieue : ' || fn:string-join(getAddress($node, $options))
  case 'province' return 'Province : ' || fn:string-join(getAddress($node, $options))
  case 'office' return 'Bureau des experts'
  case 'clerkOffice' return 'Bureau du greffié'
  default return 'Indéterminé : ' || fn:string-join(getAddress($node, $options))
};

declare function getAddress($node as node()*, $options as map(*)) as xs:string* {
  let $buildingNumber := $node/xpr:address/xpr:buildingNumber[fn:normalize-space(.)!='']
  let $street := $node/xpr:address/xpr:street[fn:normalize-space(.)!='']
  let $complement := $node/xpr:complement[fn:normalize-space(.)!='']
  let $parish := $node/xpr:parish[fn:normalize-space(.)!='']
  let $city := $node/xpr:city[fn:normalize-space(.)!='']
  let $district := $node/xpr:district[fn:normalize-space(.)!='']
  let $owner := $node/xpr:owner[fn:normalize-space(.)!='']
  return (
    if ($buildingNumber, $street, $complement) then fn:string-join(
      ($buildingNumber, $street, $complement),
      ', '
    ) || '. ',
    if ($parish, $city, $district) then fn:string-join(
      ($parish, $city, $district),
      ', '
    ) || '. ' else(),
    if ($owner) then '[' || fn:string-join(
      $owner,
      ', '
    ) || ']. '
  )
};

declare function getExpert($node as node()*, $options as map(*)) as node()* {
  let $prosopo := db:open('xpr')/xpr:xpr/xpr:bio
  let $expertName := getEntityName(fn:substring-after($node/@ref, '#'))
  let $expert := <a href="/xpr/biographies/{fn:normalize-space(fn:substring-after($node/@ref, '#'))}/view">{ $expertName }</a>
  let $context :=
    switch ($node/@context[fn:normalize-space(.)!=''])
    case 'primary' return 'nommé en premier lieu'
    case 'third-party' return 'tiers expert'
    case 'unknown' return 'nomination indéterminée'
    default return ()
  let $appointment :=
    (if(fn:not($node/@context='primary') and fn:not($node/@appointment = 'unknown')) then 'nommé ',
    switch ($node/@appointment[fn:normalize-space(.)!=''])
    case 'court-appointed' return 'd’office (par le lieutenant civil)'
    case 'appointed' return 'par les parties'
    case 'experts' return 'par les experts'
    case 'unkwnown' return 'origine de la nomination indéterminée'
    default return ())

  return ($expert, text{', ' || ($node/xpr:title[fn:normalize-space(.)!=''], $context, $appointment) => fn:string-join(', ') || '.'})
};

(:~
 : This function dispatches the treatment of the eac XML document
 :)
declare
  %output:indent('no')
function eac2html($node as node()*, $options as map(*)) as item()* {
  <article>{
    getIdentity($node/eac:cpfDescription/eac:identity, $options),
    getDescription($node/eac:cpfDescription/eac:description, $options),
    getExpertises($node/@xml:id, $options)
  }</article>
};

declare function getIdentity($node as node()*, $options as map(*)) as node()* {
  <header>{(
    getEntityType($node/eac:entityType, $options),
    <h2>{getEntityName($node/eac:identityId)}</h2>,
    <span class="id">{getEntityId($node/eac:identityId, $options)}</span>,
    for $alternativeForm in $node/eac:nameEntry[@preferredForm!='true']
    return
      <div>
        <h4>Forme attestée du nom</h4>
        <ul>{
          for $part in $alternativeForm/eac:part
          return <li>{getPart($part, $options)[1] || ' : ' || getPart($part, $options)[2]}</li>
        }</ul>
        {if($alternativeForm/@sourceReference != '') then
        <ul>
          <lh>{if(fn:tokenize(fn:normalize-space($alternativeForm/@sourceReference))[2]) then 'Sources' else 'Source'}</lh>
          {for $source in getSources($alternativeForm/@sourceReference, $alternativeForm/ancestor::eac:eac/eac:control/eac:sources, $options)
          return
            <li>{$source}</li>}
        </ul>}
      </div>
  )}</header>
};

declare function getEntityName($str as xs:string*) as xs:string {
  let $prosopo := db:open('xpr')/xpr:xpr/xpr:bio
  let $id := $str
  let $entityName := $prosopo/eac:eac[@xml:id=$id]/eac:cpfDescription/eac:identity/eac:nameEntry[@preferredForm='true' and @status='authorized'][1]/eac:part/fn:normalize-space()
  return $entityName
};

(:@todo reprise:)
declare function getEntityType($node as node(), $options as map(*)) as xs:string {
  <h3>{
    switch ($node)
    case $node[parent::eac:identity/eac:otherEntityTypes[eac:otherEntityType/eac:term='expert']] return 'Fiche prosopographique d’expert'
    case $node[parent::eac:identity/eac:otherEntityTypes[eac:otherEntityType/eac:term='clerk']][fn:not(eac:otherEntityType/eac:term='expert')] return 'Fiche prosopographique de greffier'
    case $node[parent::eac:identity/eac:otherEntityTypes[eac:otherEntityType/eac:term='masson']] return 'Fiche prosopographique de maçon'
    default return 'Fiche prosopographique'
  }</h3>
};

declare function getSources($str as xs:string, $sources as node()*, $options as map(*)) as xs:string* {
let $refs := fn:tokenize($str, ' ')
for $ref in $refs
return getSource($ref, $sources, $options)
};

declare function getSource($str as xs:string, $node as node(), $options as map(*)) as xs:string {
let $source := $node/eac:source[@id = fn:substring-after($str, '#')]/eac:reference => fn:normalize-space()
return $source
};

declare function getPart($node as node(), $options as map(*)) as xs:string+ {
  let $value := $node => fn:normalize-space()
  let $key := switch ($node/@localType => fn:normalize-space())
    case 'surname' return 'Nom'
    case 'forename' return 'Prénom'
    case 'particle' return 'Particule'
    case 'common' return 'Titre d’appel'
    case 'formal' return 'Titre institutionnel'
    case 'academic' return 'Titre académique'
    case 'religious' return 'Titre religieux'
    case 'nobiliary' return 'Titre nobiliaire'
    default return 'Partie du nom indéterminée'

  return ($key, $value)
};

declare function getEntityId($node as node(), $options as map(*)) as xs:string {
  let $id := $node => fn:normalize-space()
  return $id
};

declare function getDescription($node as node()*, $options as map(*)) as item()*{
  <div>
    <h4>Description</h4>
    <ul>{
      if($node/eac:existDates) then getExistDates($node/eac:existDates, $options),
      if(fn:normalize-space($node/eac:localDescriptions/eac:localDescription[@localType="sex"]) != '') then
      <li>{getSex($node/eac:localDescriptions/eac:localDescription[@localType="sex"], $options)}</li>
    }</ul>
  </div>,
  if($node/eac:functions) then getFunctions($node/eac:functions, $options),
  if($node/eac:functions) then getBiogHist($node/eac:biogHist, $options)
};

declare function getSex($node as node(), $options as map(*)) as xs:string {
  let $sex :=
    switch (fn:normalize-space($node))
    case 'male' return 'Homme'
    case 'female' return 'Femme'
    default return ()
  return $sex
  (: @todo restreindre l’appel au sex :)
};

declare function getFunctions($node as node(), $options as map(*)) as node(){
  <div class="function">
    <h4>Fonctions</h4>
    {for $function in $node/eac:function
    return getFunction($function, $options)}
  </div>
};

declare function getFunction($node as node(), $options as map(*)) as node() {
  <div>
    <p>{$node/eac:term}, de {if($node/eac:dateRange) then getDate($node/eac:dateRange, $options)}</p>
  </div>
  (: @todo prévoir cas où date fixe :)
};

declare function getBiogHist($node as node()*, $options as map(*)) as node()* {
  <div class="biogHist">
    <h4>Informations biographiques</h4>
    { getChronList($node/eac:chronList, $options) }
  </div>
};

declare function getChronList($node as node(), $options as map(*)) as node()* {
  for $chronItem in $node/eac:chronItem
  return
    <div>
      <h5>{$chronItem/eac:event => fn:normalize-space()}</h5>
      <p>Date : { getDate($chronItem/*[fn:local-name() = 'date' or fn:local-name() = 'dateRange'], $options) }</p>
    </div>
};

declare function getExpertises($node as node(), $options as map(*)) as node(){
  let $db := db:open('xpr')
  let $expertises := $db//*:expertise[descendant::*:experts/*:expert[@ref = fn:concat('#', $node)]]
  return(
    <div>
      <h4>Expertises</h4>
      <ul>{
      for $expertise in $expertises
      order by fn:sort($expertise/descendant::*:sessions/*:date/@when[fn:normalize-space(.)!=''])[1]
      return <li><a href="/xpr/expertises/{fn:normalize-space($expertise/@xml:id)}/view">{getReference($expertise, $options)}</a></li>
      }</ul>
    </div>
  )
};

declare function getExistDates($node as node(), $options as map(*)) as node() {
  <li>{ 'Dates d’existence : ' || getDate($node/eac:dateRange, $options)}</li>
};

declare function getDate($node as node(), $options as map(*)) as xs:string {
  switch($node)
  case $node[self::eac:dateRange] return fn:string-join(
    ($node/eac:fromDate, $node/eac:toDate) ! getPrecision(., $options),
    ' à ')
  case $node[self::eac:date[@*!='']] return getPrecision($node, $options)
  default return 'aucune date mentionnée'
  (: @todo mettre valeur vide en cas d’abs :)
};

declare function getPrecision($node as node(), $options as map(*)) as xs:string* {
  switch ($node)
  case $node[@notAfter] return (getFormatedDate($node, $options) || ' ]')
  case $node[@notBefore] return ('[ ' || getFormatedDate($node, $options))
  case $node[@standardDate] return (getFormatedDate($node, $options))
  default return '..'
};

declare function getEacDates($node as node(), $sources as node(), $option as map(*)) {
  switch($node)
  case $node[self::eac:dateRange] return getEacDateRange($node, $sources, map{})
  case $node[self::eac:dateSet] return getEacDateSet($node, $sources, map{})
  default return getEacDate($node, $sources, map{})
};

declare function getEacDate($node as node(), $sources as node(), $option as map(*)) as map(*) {
  map {
    'precision' : $node/@*[fn:local-name()='standardDate' or fn:local-name()='notBefore' or fn:local-name()='notAfter'][fn:normalize-space(.)!='']/fn:local-name(),
    'date' : $node/@*[fn:local-name()='standardDate' or fn:local-name()='notBefore' or fn:local-name()='notAfter'][fn:normalize-space(.)!=''] => fn:normalize-space(),
    'certainty' : $node/@certainty => fn:normalize-space(),
    'sources' : if($node[fn:normalize-space(@sourceReference)!='']) then getEacSourceReference($node/@sourceReference, $sources)
  }
};

declare function getEacDateRange($node as node(), $sources as node(), $option as map(*)) as map(*) {
  map {
    'from' : getEacDate($node/eac:fromDate, $sources, map{}),
    'to' : getEacDate($node/eac:toDate, $sources, map{})
  }
};

declare function getEacDateSet($node, $sources as node(), $option as map(*)) {
  array {
    for $date in $node/*
    return getEacDates($date, $sources, map{})
  }
};

declare function getEacSourceReference($node, $option) {
  if($node[fn:normalize-space(.)!='']) then array{
    for $source in fn:tokenize($node, ' ')
    return map {
      'source' : $option/eac:source[@id = $source => fn:substring-after('#')] => fn:normalize-space(),
      'id' : ''
    }
  }
};


declare function serializeXpr($node as node()*, $options as map(*)) as item()* {
  typeswitch($node)
    case text() return $node[fn:normalize-unicode(.)!='']
    default return passthruXpr($node, $options)
  };

(:~
 : This function pass through child nodes (xsl:apply-templates)
 :)
declare
  %output:indent('no')
function passthruXpr($nodes as node(), $options as map(*)) as item()* {
  for $node in $nodes/node()
  return serializeXpr($node, $options)
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

(:~
 : This function serialize an expertises list
 : @return an html list of expertises
 :)
declare function listXpr2html($content, $options) {
  <ul id="list">{
    for $expertise in $content/xpr:expertise
    return itemXpr2html($expertise, map{'path' : '/xpr/expertises/'})
  }</ul>
};

(:~
 : This function serialize an expertise item in a list
 : @return an html item of expertises in a list
 :)
declare function itemXpr2html($expertise as node(), $options as map(*)) as node() {
  let $id := $expertise/@xml:id => fn:string()
  let $path := $options?path
  let $status := $expertise/xpr:control/xpr:localControl/xpr:term
  let $cote := ($expertise/xpr:sourceDesc/xpr:idno[@type='unitid'] || '/' || $expertise/xpr:sourceDesc/xpr:idno[@type='item']) => fn:normalize-space()
  let $addresses := for $place in $expertise/xpr:description/xpr:places
    return fn:normalize-space($place) => fn:string-join(' ; ')
  let $dates := $expertise//xpr:sessions/xpr:date/@when => fn:string-join(' ; ')
  let $user := if(Session:get('id') != '') then Session:get('id')
  return
    <li status="{$status}">
      <h3 class="cote">{$cote}</h3>
      <p class="date">{$dates}</p>
      <p>{$addresses}</p>
      <p>
        <a class="view" href="{$path || $id || '/view'}">Voir</a>
        {if ($user and user:list-details($user)/*:info/*:grant/@type = 'expertises' and user:list-details($user)/*:database[@pattern='xpr']/@permission = 'write') then
         (' | ', <a class="modify" href="{$path || $id || '/modify'}">Modifier</a>)
        }
      </p>
    </li>
};

(:~
 : This function serialize a list of entities
 : @param
 :)
declare function listEac2html($node as node()*, $options as map(*)) as item()* {
  <ul id="list">{
    for $entity in $node//eac:eac
    let $id := $entity/@xml:id => fn:normalize-unicode()
    let $name := $entity//eac:nameEntry[@status='authorized'] => fn:normalize-unicode()
    let $type := $entity//eac:identity/@localType => getMessage($options)
    let $dates := $entity/@xml:id => fn:normalize-unicode()
    return
      <li>
        <h3 class="name">{$name}</h3>
        <p class="date">{$dates}</p>
        <p class="type">{$type}</p>
        <p><a class="view" href="{'/xpr/biographies/' || $id || '/view'}">Voir</a> | <a class="modify" href="{'/xpr/biographies/' || $id || '/modify'}">Modifier</a></p>
      </li>
  }</ul>
};

(:~
 : This function serialize a list of IAD
 : @return an html list of IAD
 :)
declare function listIad2html($content as node()*, $options as map(*)) as item()* {
  <ul id="list">{
    for $inventory in $content/xpr:inventory
    return itemIad2Html($inventory, map{'path' : '/xpr/inventories/'})
  }</ul>
};

(:~
 : This function serialise an IAD item in a list
 : @return an html item of iad in a list
 :)
declare function itemIad2Html($inventory as node(), $options as map(*)) as node() {
  let $id := $inventory/@xml:id => fn:string()
  let $path := $options?path
  let $status := $inventory/xpr:control/xpr:localControl/xpr:term
  let $cote := $inventory/xpr:sourceDesc/xpr:idno[@type='unitid'] => fn:normalize-space()
  let $date := $inventory/xpr:sourceDesc/xpr:date/@standardDate
  let $expertId := $inventory/xpr:sourceDesc/xpr:expert/@ref => fn:substring-after('#')
  let $expert := $inventory/ancestor::xpr:xpr/xpr:bio/*:eac[@xml:id=$expertId]/*:cpfDescription/*:identity/*:nameEntry[@status='authorized']/*:part => fn:normalize-space()
  let $user := if(Session:get('id') != '') then Session:get('id')
  return
    <li status="{$status}">
      <h3 class="cote">{$cote}</h3>
      <p class="date">{$date}</p>
      <p>{$expert}</p>
      <p>
        <a class="view" href="{$path || $id || '/view'}">Voir</a>
        {if ($user and user:list-details($user)/*:info/*:grant/@type = 'posthumusInventory') then
         (' | ', <a class="modify" href="{$path || $id || '/modify'}">Modifier</a>)
        }
      </p>
    </li>
};