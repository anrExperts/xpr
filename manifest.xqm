xquery version "3.1";
module namespace xpr.manifest = "xpr.manifest";
(:~
 : This xquery module is an application for xpr
 :
 : @author sardinecan & emchateau (ANR Experts)
 : @since 2022-12
 : @licence GNU http://www.gnu.org/licenses
 : @version 0.2
 :
 : xpr is free software: you can redistribute it and/or modify
 : it under the terms of the GNU General Public License as published by
 : the Free Software Foundation, either version 3 of the License, or
 : (at your option) any later version.
 :
 :)

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
 declare namespace json = "http://basex.org/modules/json" ;

 declare namespace xpr = "xpr" ;
 declare default function namespace "xpr.manifest" ;

 declare default collation "http://basex.org/collation?lang=fr" ;

(:~
 : This resource function defines a manifest.json for xpr unitid files
 :)

declare
  %rest:path("xpr/manifests")
  %rest:produces('application/html')
  %output:method("html")
function getManifest() {
  <html>
    <head></head>
    <body>
      <form action="/xpr/manifests/write" method="post">
          <label for="apikey">API-KEY</label>
          <input type="apikey" name="apikey" id="apikey"/>
          <input type="submit" value="Envoyer"/>
      </form>
    </body>
  </html>
};

declare function getUserDatas($apikey) {
  let $apikey := $apikey
  return
    http:send-request(
      <http:request method="post">
        <http:header name="X-API-KEY" value="{$apikey}"/>
      </http:request>,
      'https://api.nakala.fr/users/datas/owned'
  )/*:json
};

declare function createManifests($apikey) {
  let $apikey := $apikey
  let $datas := getUserDatas($apikey)
  for $data in $datas/data/_
    let $unitid := $data/metas/_[propertyUri = "http://nakala.fr/terms#title"]/value => fn:normalize-space()
    let $nakaIdentifier := $data/identifier => fn:normalize-space()
    let $data := http:send-request(<http:request method='get' href='https://api.nakala.fr/datas/{$nakaIdentifier}' />)/*:json
  return
    array{
      $unitid,
      map {
        "@context" : "http://iiif.io/api/presentation/3/context.json",
        (:@todo récupérer l'adresse ?:)
        "id" : "/xpr/iiif/"|| $unitid ||"/manifest.json",
        "type": "Manifest",
        "label": map {
          "fr" : array {
            $data/*:metas/*[*:propertyUri = "http://nakala.fr/terms#title"]/*:value => fn:normalize-space()
          }
        },
        "behavior" : array {
          "paged"
        },
        "items" : array {
          for $f at $i in $data/*:files/*
          let $nakaFileIdentifier := $f/*:sha1 => fn:normalize-space()
          let $info := http:send-request(<http:request method='get' href="https://api.nakala.fr/iiif/{$nakaIdentifier}/{$nakaFileIdentifier}/info.json" />)/*:json
          return map {
            "id" : "https://xpr/iiif/" || $unitid || "/canvas/p" || fn:format-number($i, "0000"),
            "type" : "Canvas",
            "label" : map {
              "fr" : array {
                $f/*:name => fn:normalize-space()
              }
            },
            "width" : fn:number($info/*:width => fn:normalize-space()),
            "height" : fn:number($info/*:height => fn:normalize-space()),
            "items" : array {
              map {
                "id" : "https://xpr/iiif/" || $unitid || "/page/p" || fn:format-number($i, "0000") || "/1",
                "type" : "AnnotationPage",
                "items" : array {
                  map {
                    "id" : "https://xpr/iiif/" || $unitid || "/annotation/p" || fn:format-number($i, "0000") || "-image",
                    "type" : "Annotation",
                    "motivation" : "painting",
                    "body" : map {
                      "id" : "https://api.nakala.fr/iiif/" || fn:normalize-space($data/*:identifier) || "/" || $nakaFileIdentifier || "/full/max/0/default.jpg",
                      "type" : "Image",
                      "format" : "image/jpeg",
                      "width" : fn:number($info/*:width => fn:normalize-space()),
                      "height" : fn:number($info/*:height => fn:normalize-space()),
                      "service" : array {
                        map {
                          "id": "https://api.nakala.fr/iiif/" || fn:normalize-space($data/*:identifier) || "/" || $nakaFileIdentifier || "/info.json",
                          "type": "ImageService3",
                          "profile": "level2"
                        }
                      }
                    },
                    "target" : "https://xpr/iiif/" || $unitid || "/canvas/p" || fn:format-number($i, "0000")
                  }
                }
              }
            }
          }
        }
      }
    }
};

declare
  %rest:path("xpr/manifests/write")
  %rest:produces('application/html')
  %output:method("html")
  %rest:query-param('apikey', '{$apikey}', 'test')
 function writeManifest($apikey) {
  let $manifests := createManifests($apikey)
  return (
    "Fichiers ajoutés:",
    for $manifest in $manifests
    return (
      file:write(file:base-dir() || "files/manifest/"||$manifest(1)||".manifest.json", json:serialize($manifest(2))),
      $manifest(1)||".manifest.json"
    )
  )
};