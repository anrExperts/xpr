xquery version "3.0";
module namespace xpr.autosave = "xpr.autosave";
(:~
 : This xquery module is an application for xpr
 :
 : @author emchateau & sardinecan (ANR Experts)
 : @since 2021-06
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
declare namespace eac = "eac" ;

declare namespace map = "http://www.w3.org/2005/xpath-functions/map" ;
declare namespace xf = "http://www.w3.org/2002/xforms" ;
declare namespace xlink = "http://www.w3.org/1999/xlink" ;

declare namespace xpr = "xpr" ;
declare default element namespace "xpr" ;
declare default function namespace "xpr.autosave" ;

declare default collation "http://basex.org/collation?lang=fr" ;


(:~
 : This function insert autosaved expertises in xprAutosave db
 : @param $param content to insert in the database
 : @param $refere the callback url
 : @return update the database with an updated content
 :)
declare
  %rest:path("xpr/expertises/autosave/put")
  %output:method("xml")
  %rest:header-param("Referer", "{$referer}", "none")
  %rest:PUT("{$param}")
  %perm:allow("expertises", "write")
  %updating
function putExpertiseAutosave($param, $referer) {
  let $db := db:open("xprAutosave")
  let $unitid := $param//idno[@type='unitid']
  let $item := $param//idno[@type='item']
  let $user := fn:normalize-space(user:list-details(Session:get('id'))/@name)
  let $fileId := fn:generate-id($param)
  return (
      let $id := fn:replace(fn:lower-case($param/expertise/sourceDesc/idno[@type="unitid"]), '/', '-') || 'd' || fn:format-integer($param/expertise/sourceDesc/idno[@type="item"], '000') || $param/expertise/sourceDesc/idno[@type="supplement"]
      let $param :=
        copy $d := $param
        modify(
          insert node attribute xml:id {$id} into $d/*,
          replace value of node $d/expertise/control/maintenanceHistory/maintenanceEvent[1]/agent with $user,
          for $place at $i in $d/expertise/description[categories/category[@type="estimation"]]/places/place
          let $idPlace := fn:generate-id($place)
          return(
            insert node attribute xml:id {$idPlace} into $place,
            insert node attribute ref {fn:concat('#', $idPlace)} into $d/expertise/description/conclusions/estimates/place[$i]
          )
        )
        return $d
      return (
        db:add('xprAutosave', $param, 'xpr/expertises/'|| $fileId ||'.xml'),
        deleteExpertiseAutosave()
      )

  )
};

declare %updating function deleteExpertiseAutosave() {
    if(fn:count(db:open("xprAutosave", 'xpr/expertises')/*:expertise) > 100) then (
        let $file2delete := db:list("xprAutosave", 'xpr/expertises')[1]
        return db:delete("xprAutosave", $file2delete)
    )
};

(:~
 : This function returns xprAutosave db
 :)
(:
declare
  %rest:path("xpr/autosave")
  %output:method("xml")
function getAutosave() {
  let $db := db:open("xprAutosave")
  return $db
};:)
