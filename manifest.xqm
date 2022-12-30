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
  %rest:path("xpr/iiif/{$file}/manifest.json")
  %rest:produces('application/json')
  %output:media-type('application/json')
  %output:method('json')
function getManifest($file) {
  let $nakaIdentifier := db:open('xprImages')//*:unitid[*:idno=$file]/*:nakalaId => fn:normalize-space()

  let $data := http:send-request(<http:request method='get' href='https://api.nakala.fr/datas/{$nakaIdentifier}' />)/*:json
  return (
    map {
      "@context" : "http://iiif.io/api/presentation/3/context.json",
      (:@todo récupérer l'adresse ?:)
      "id" : "http://localhost:8984/xpr/iiif/"|| $file ||"/manifest.json",
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
          "id" : "https://xpr/iiif/" || $file || "/canvas/p" || fn:format-number($i, "0000"),
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
              "id" : "https://xpr/iiif/" || $file || "/page/p" || fn:format-number($i, "0000") || "/1",
              "type" : "AnnotationPage",
              "items" : array {
                map {
                  "id" : "https://xpr/iiif/" || $file || "/annotation/p" || fn:format-number($i, "0000") || "-image",
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
                  "target" : "https://xpr/iiif/" || $file || "/canvas/p" || fn:format-number($i, "0000")
                }
              }
            }
          }
        }
      }
    }
  )
};