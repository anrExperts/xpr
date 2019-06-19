xquery version "3.0";

(:~
 : Script de reprise de la base de données
 : @author emchateau
 : @since 2019-06-18
 : @howto just run the script !
 :)

declare default function namespace 'local' ;
declare default element namespace "xpr";

declare function clean() {
  copy $content := db:open('xpr')
  modify (
    let $expertises := $content/expertise
    return insert node $expertises into $content/expertises,
    delete node $content/expertise
  ) 
  return $content
};

(:~
 : This function replace the xpr database 
 : @return a clean hiearchical db and an export when expertise are outside the root element expertises
 :)
declare 
  %updating 
function renew() {
  let $content := clean()
  return 
  if ( db:open('xpr')/expertise ) then (
    file:write(file:base-dir() || 'sauvegarde' || '.xml', $content),
    db:drop('xpr'),
    db:create( "xpr", $content, "z1j.xml", map {"chop" : fn:false()} )
  )
  else ()
};

renew()