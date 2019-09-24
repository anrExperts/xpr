xquery version "3.0";

(:~
 : Script de reprise de la base de données
 : @author sardinecan
 : @since 2019-09-24
 : @howto just run the script !
 :)

declare default function namespace 'local' ;
declare default element namespace "xpr";


(:~
 :This function adds new element <xpr/> in the bdd 
 :)

declare function insert()
{
  copy $content := db:open('xpr')
  modify (
    insert node <xpr xmlns="xpr"><bio/><posthumousInventories/><sources/></xpr> as last into $content
  )
  return $content
};


(:~
 :This function puts expertises node into new element <xpr/> 
 : 
 :)
declare function clean() {
  copy $content := insert()
  modify (
    let $expertises := $content/expertises
    return insert node $expertises as first into $content/xpr,
    delete node $content/expertises
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
  if ( db:open('xpr')/expertises) then (
    file:write(file:base-dir() || 'sauvegarde' || '.xml', $content),
    db:drop('xpr'),
    db:create( "xpr", $content, "z1j.xml", map {"chop" : fn:false()} )
  )
  else ()
};

renew()

