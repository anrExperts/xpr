xquery version "3.1";

declare namespace xpr = "xpr" ;
declare default element namespace "xpr" ;

declare function local:cleanDates() {
    copy $d := db:open('gip')
    modify (
      for $sentence in $d//sentence[date[not(@when = '')][not(@when castable as xs:date)]]
      return (
        for $date in $sentence/date/fn:analyze-string(@when, '(\d{4}-\d{2}-\d{2})')/fn:match/fn:group
            return insert node <date when="{$date}"/> into $sentence,
        delete node $sentence/date[not(@when = '')][not(@when castable as xs:date)]
       )
     )
    return $d
};

declare function local:cleanKey() {
    copy $d := local:cleanDates()
    modify (
      for $key in $d//key[key]
      return replace value of node $key with $key/key
     )
    return $d
};

declare
%updating
function local:replaceDb() {
    let $gip := local:cleanKey()
    let $dbName := 'gip.old'
    return (
        file:write(file:base-dir() || 'gip' || '.old' || '.xml', $gip),
        db:copy('gip', $dbName),
        db:drop('gip'),
        db:create("gip", $gip, "gip.xml", map {"chop": fn:false()})
    )
};

local:replaceDb()