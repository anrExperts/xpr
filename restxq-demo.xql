xquery version "3.0";
module namespace demo="restxq/demo";
(: 
 : This module defines the RestXQ endpoints of an adress book
 :)

declare namespace rest = "http://exquery.org/ns/restxq";
declare namespace file = "http://expath.org/ns/file";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace web = "http://basex.org/modules/web";


declare variable $demo:data := "/data/addresses";

(:~
 : This module is an adress list
 : @return a list of all addresses as XML
 :)
declare
    %rest:GET
    %rest:path("/address")
    %rest:produces("application/xml", "text/xml")
function demo:addresses() {
    <addresses>
    {
        for $address in collection("/data/addresses")/address
        return
            $address
    }
    </addresses>
};

(:~
 : Test: list all addresses in JSON format. For this function to be chosen,
 : the client should send an Accept header containing application/json.
 :)
(:declare:)
(:    %rest:GET:)
(:    %rest:path("/address"):)
(:    %rest:produces("application/json"):)
(:    %output:media-type("application/json"):)
(:    %output:method("json"):)
(:function demo:addresses-json() {:)
(:    demo:addresses():)
(:};:)

(:~
 : Retrieve an address identified by uuid.
 :)
declare 
    %rest:GET
    %rest:path("/address/{$id}")
function demo:get-address($id as xs:string*) {
    collection($demo:data)/address[@id = $id]
};

(:~
 : Search addresses using a given field and a (lucene) query string.
 :)
declare 
    %rest:GET
    %rest:path("/search")
    %rest:form-param("query", "{$query}", "")
    %rest:form-param("field", "{$field}", "name")
function demo:search-addresses($query as xs:string*, $field as xs:string*) {
    <addresses>
    {
        if ($query != "") then
            switch ($field)
                case "name" return
                    collection($demo:data)/address[ft:contains(name, $query)]
                case "street" return
                    collection($demo:data)/address[ft:contains(street, $query)]
                case "city" return
                    collection($demo:data)/address[ft:contains(city, $query)]
                default return
                    collection($demo:data)/address[ft:contains(., $query)]
        else
            collection($demo:data)/address
    }
    </addresses>
};

(:~
 : Update an existing address or store a new one. The address XML is read
 : from the request body.
 :)
declare
    %rest:PUT("{$content}")
    %rest:path("/address")
    %updating
function demo:create-or-edit-address($content as node()*) {
    let $id := ($content/address/@id, random:uuid())[1]
    let $data :=
        <address id="{$id}">
        { $content/address/* }
        </address>
    (: let $log := util:log("DEBUG", "Storing data into " || $demo:data) :)
    return
      db:store($demo:data, $id || ".xml", $data),
      update:output(web:redirect('/address'))
};

(:~
 : Delete an address identified by its uuid.
 :)
declare
    %rest:DELETE
    %rest:path("/address/{$id}")
    %updating
function demo:delete-address($id as xs:string*) {
    db:delete($demo:data, $id || ".xml"),
    update:output(web:redirect('/address'))
};