xquery version '3.0';

declare default function namespace 'xpr';

(: declare 
function importDoc() {
  let $doc := file:read-text('/Volumes/data/github/xpr/listeExperts.csv')
  let $doc := csv:parse($doc, map {'header': fn:true()})

  return (
    copy $docCopy := $doc
    modify (
      for $id in $docCopy/csv/record/idno
      let $idno := fn:concat('xpr', fn:format-number(fn:number(fn:substring-after($id, 'E')),'0000'))
      return (
        replace value of node $id/text() with $idno,
        insert node attribute xml:id {$idno} into $id  
      )
    )
  return file:write('/Volumes/data/github/xpr/experts.xml', $docCopy)
)
}; :)





declare function templateMatch ($node as node()*) as item()* {
  typeswitch($node) 
    case text() return $node
    case element(csv) return csv($node)
    case element(record) return record($node)
    case element(idno) return idno($node)
    case element(surname) return surname($node)
    case element(forename) return forename($node)
    case element(birth) return birth($node)
    case element(death) return death($node)
    case element(provision) return provision($node)
    case element(floruit) return floruit($node)
    (: case element(record) return record($node) :)
    default return passthru($node)
};

declare function passthru ($node) {
  for $n in $node/node()
  return templateMatch($n)
};

declare function csv($node) {
  <experts xmlns="">{passthru($node)}</experts>
};

declare function record($node) {
  <expert>{passthru($node)}</expert>
};

declare function idno($node) {
  let $idno := fn:concat('xpr', fn:format-number(fn:number(fn:substring-after($node, 'E')),'0000'))
  return (<idno>{$idno}</idno>)
};

declare function surname($node) {
  <surname>{passthru($node)}</surname>
};

declare function forename($node) {
  <forename>{passthru($node)}</forename>
};

declare function birth($node) {
  <birth>{passthru($node)}</birth>
};

declare function death($node) {
  <death>{passthru($node)}</death>
};

declare function provision($node) {
  <provision>{passthru($node)}</provision>
};

declare function floruit($node) {
  <floruit>{passthru($node)}</floruit>
};

(: <record>
    <idno xml:id="xpr0001">xpr0001</idno>
    <surname>Adhenet</surname>
    <forename>Thomas</forename>
    <birth>1690-11</birth>
    <death/>
    <provision>1723-01-08</provision>
    <floruit/>
</record> :)
let $doc := file:read-text('/Volumes/data/github/xpr/listeExperts.csv')
let $doc := csv:parse($doc, map {'header': fn:true()})
return templateMatch($doc)

