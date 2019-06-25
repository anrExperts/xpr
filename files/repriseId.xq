xquery version "3.0";

(:~
 : Script de mise à jour des @xml:id, utitid, item, des expertises
 : @author sardinecan
 : @rev emchateau
 : @since 2019-06-25
 : @howto just run the script !
 :)

declare default function namespace 'local' ;
declare default element namespace "xpr";


declare function newId() {
  copy $db := db:open('xpr')
  modify (
    for $expertise in $db//expertise
    
    let $expertiseId := $expertise/@xml:id
    let $newId := fn:replace(fn:replace(fn:upper-case($expertise/sourceDesc/idno[@type="unitid"]), '/', '-'),' ','') || 'd' || fn:format-integer($expertise/sourceDesc/idno[@type="item"], '000')
    
    let $unitid := $expertise/sourceDesc/idno[@type="unitid"]
    let $newUnitid := fn:replace(fn:replace(fn:upper-case($expertise/sourceDesc/idno[@type="unitid"]), '/', '-'),' ','')
    
    let $item := $expertise/sourceDesc/idno[@type="item"]
    let $newItem := fn:format-integer($expertise/sourceDesc/idno[@type="item"], '000')
    
    return (
      replace value of node $expertiseId with $newId,
      replace value of node $unitid with $newUnitid,
      replace value of node $item with $newItem
    )
  )
  return $db
};


(:~
 : This function replace the xpr database 
 : @return the db with updated @xml:id for the expertise nodes and 
 : @correct the value of unitid (upper-case with no whitespace)
 : @correct the value of item (format-integer '000')
 :)
declare 
  %updating 
function replaceid() {
  let $content := newId()
  return 
  if ( db:open('xpr')/expertises/expertise/@xml:id ) then (
    file:write(file:base-dir() || 'sauvegarde' || '.xml', $content),
    db:drop('xpr'),
    db:create( "xpr", $content, "z1j.xml", map {"chop" : fn:false()} )
  )
  else ()
};

replaceid()
