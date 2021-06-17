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
declare default function namespace "xpr.autosave" ;

declare default collation "http://basex.org/collation?lang=fr" ;


(:~
 : This function creates new expertises
 : @param $param content to insert in the database
 : @param $refere the callback url
 : @return update the database with an updated content and an 200 http
 : @bug change of cote and dossier doesn’t work
 :)
declare
  %rest:path("xpr/autosave/expertises/put")
  %output:method("xml")
  %rest:header-param("Referer", "{$referer}", "none")
  %rest:PUT("{$param}")
  %perm:allow("expertises", "write")
  %updating
function putExpertiseAutosave($param, $referer) {
  let $db := db:open("xprAutosave")
  return(
    if($db/xpr/expertises/expertise[descendant::idno[@type='unitid']=$param//idno[@type='unitid'] and descendant::idno[@type='item']=$param//idno[@type='item']]) then
      let $oldSave := $db/xpr/expertises/expertise[descendant::idno[@type='unitid']=$param//idno[@type='unitid'] and descendant::idno[@type='item']=$param//idno[@type='item']]
      return replace node $oldSave with $param
    else insert node $param as first into $db/xpr/expertises
  )
};