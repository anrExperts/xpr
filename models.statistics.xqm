xquery version "3.0";
module namespace xpr.models.statistics = "xpr.models.statistics";
(:~
 : This xquery module is an application for xpr
 :
 : @author emchateau & sardinecan (ANR Experts)
 : @since 2019-01
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
import module namespace xpr.xpr = "xpr.xpr" at './xpr.xqm' ;
import module namespace xpr.mappings.html = 'xpr.mappings.html' at './mappings.html.xqm' ;

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
declare namespace ev = "http://www.w3.org/2001/xml-events" ;
declare namespace eac = "https://archivists.org/ns/eac/v2" ;
declare namespace rico = "rico" ;

declare namespace map = "http://www.w3.org/2005/xpath-functions/map" ;
declare namespace xf = "http://www.w3.org/2002/xforms" ;
declare namespace xlink = "http://www.w3.org/1999/xlink" ;

declare default element namespace "xpr" ;
declare default function namespace "xpr.models.statistics" ;

declare default collation "http://basex.org/collation?lang=fr" ;

declare function getExpertisesStatistics($expertises, $experts) {
  let $expertises := $expertises[description/categories[fn:count(category) = 1]]
  let $sessionPlaces :=
    for $place in fn:distinct-values(xpr.xpr:getExpertises()/expertise/description/sessions/date[fn:normalize-space(@type)!=""]/@type)
    let $label := switch ($place)
      case 'paris' return 'Paris'
      case 'suburbs' return 'Banlieue'
      case 'province' return 'Province'
      default return 'Indéterminé'
    return [$place, $label]
  let $duration :=
    for $expertise in $expertises/description/sessions
    let $dates :=
      for $session in $expertise/date[@when castable as xs:date]
      order by $session/@when
      return xs:date($session/@when)
    let $duration := $dates[fn:last()] - $dates[1]
    return fn:days-from-duration($duration)
  let $places :=
    (:let $listPlace := fn:distinct-values(db:open('xpr')//*:expertise//*:places/*:place/@type):)
    let $listPlace := fn:distinct-values(xpr.xpr:getExpertises()/expertise/description/sessions/date[fn:normalize-space(@type)!=""]/@type)
    let $seq := ('paris', 'suburbs', 'province')
    let $pairs :=
      for $i at $pos in $seq
      for $j in fn:subsequence($seq, $pos+1, fn:count($seq))
      return [$i, $j]
    return ($listPlace, $pairs, ['paris', 'suburbs', 'province'])
  let $objects :=
    let $types := fn:distinct-values(xpr.xpr:getExpertises()/expertise/description/procedure/objects/object/@type)
    for $type in $types
      let $label := (xpr.xpr:getExpertises()/expertise/description/procedure/objects/object[@type = $type])[1] => fn:normalize-space()
    return [$type, $label]
  let $extent := for $expertise in $expertises return fn:number($expertise/sourceDesc/physDesc/extent[fn:normalize-space(.)!=''])
  let $appendiceTypes :=
    for $type in fn:distinct-values($expertises//sourceDesc/physDesc/appendices/appendice/type/@type[fn:normalize-space(.)!=''])
      let $label := if($type!='other') then ($expertises//type[@type=$type])[1] => fn:normalize-space() else 'Autre'
    return [$type, $label]

  let $frameworks :=
    let $types := fn:distinct-values($expertises/description/procedure/framework/@type[fn:normalize-space(.)!=''])
    for $type in $types
      let $label := ($expertises/description/procedure/framework[fn:normalize-space(@type)=$type])[1] => fn:normalize-space()
    return [$type, $label]

  let $categories :=
    let $types := fn:distinct-values($expertises/description/categories/category/@type[fn:normalize-space(.)!=''])
    for $type in $types
      let $label := ($expertises/description/categories/category[fn:normalize-space(@type)=$type])[1] => fn:normalize-space()
    return [$type, $label]

  let $categories :=
    let $types := fn:distinct-values($expertises/description/categories/category/@type[fn:normalize-space(.)!=''])
    for $type in $types
      let $label := ($expertises/description/categories/category[fn:normalize-space(@type)=$type])[1] => fn:normalize-space()
    return [$type, $label]

  let $agreements :=
    let $types := fn:distinct-values($expertises/description/conclusions/agreement/@type[fn:normalize-space(.)!=''])
    for $type in $types
      let $label := ($expertises/description/conclusions/agreement[fn:normalize-space(@type)=$type])[1] => fn:normalize-space()
    return [$type, $label]

  let $fees := for $fee in $expertises/description/conclusions/fees/total return $fee/@l => fn:normalize-space()

  let $content := map{
    "total" : fn:count($expertises),
    "thirdParty" : map{
      "total" : fn:count($expertises[description/participants/experts/expert[@context='third-party']]),
      "architectes" : fn:count($expertises[description/participants/experts/expert[@context='third-party'][fn:substring-after(@ref, '#') = $experts/expert[column='architecte']/id]]),
      "entrepreneurs" : fn:count($expertises[description/participants/experts/expert[@context='third-party'][fn:substring-after(@ref, '#') = $experts/expert[column='entrepreneur']/id]])
    },
    "extent" : map{
      "total" : fn:sum($expertises/sourceDesc/physDesc/extent[fn:normalize-space(.)!='']),
      "averageByExpertise" : fn:round(fn:sum($expertises/sourceDesc/physDesc/extent[fn:normalize-space(.)!='']) div fn:count($expertises), 2),
      "extentDistribution" : array{getDistribution($extent, 5, 20)}
    },
    "sketches" : map{
      "expertisesWithSketch" : fn:count($expertises[descendant::extent[@sketch = 'true']]),
      "expertisesWithoutSketch" : fn:count($expertises[descendant::extent[@sketch != 'true']])
    },
    "appendices" : map{
      "total" : fn:count($expertises/sourceDesc/physDesc/appendices/appendice[fn:normalize-space(.)!='']),
      "expertisesWithAppendices" : fn:count($expertises[sourceDesc/physDesc/appendices[fn:normalize-space(.)!='']]),
      "expertisesWithoutAppendices" : fn:count($expertises[fn:not(sourceDesc/physDesc/appendices[fn:normalize-space(.)!=''])]),
      "types" : array{ for $type in $appendiceTypes return  map{
        "type" : array:get($type, 1),
        "label" : array:get($type, 2),
        "total" : fn:count($expertises//appendice[type/@type=array:get($type, 1)]),
        "expertises" : fn:count($expertises[sourceDesc/physDesc/appendices/appendice/type/@type=$type])
        (:"extent" : fn:sum($expertises/sourceDesc/physDesc/appendices/appendice/extent[fn:normalize-space(.)!='']),:)
      }}
    },
    "sessions" : map{
      "total" : fn:count($expertises//sessions/date[fn:normalize-space(@when)!='']),
      "averageByExpertise" : fn:round(fn:count($expertises//sessions/date[fn:normalize-space(@when)!='']) div fn:count($expertises), 2),
      "places" : array{ for $place in $sessionPlaces return map{
        "place" : array:get($place, 1),
        "label" : array:get($place, 2),
        "total" : fn:count($expertises/description/sessions/date[@type=array:get($place, 1)])
      }}
    },
    "duration" : map{
      "days" : map{
        "total" : fn:sum($duration),
        "averageByExpertise" : fn:sum($duration) div fn:count($expertises),
        "distributionByDays" : array{getDistribution($duration, 5, 20)}
      },
      "sessions" : map{
        "total" : fn:count($expertises/description/sessions/date[fn:normalize-space(@when)!='']),
        "averageByExpertise" : fn:round((fn:count($expertises/description/sessions/date[fn:normalize-space(@when)!='']) div fn:count($expertises)) div 2, 2)
      }
    },
    (:@todo revoir avec EC le fonctionnement + fonction:)
    "places" : array{
      for $place in $places
      return map{
        "place" : array{
          $place
        },
        "total" : countExpertisesByPlaces($expertises, $place)
      }
    },
    "categories" : array{
      for $category in $categories
      let $cases := $expertises[description/categories[fn:count(category) = 1][category[@type = $category]]]
      return map{
        "category" : $category,
        "label" : ($expertises/description/categories/category[@type=$category])[1] => fn:normalize-space(),
        "total" : fn:count($cases),
        "frameworks" : array{
          for $framework in fn:distinct-values($expertises/description/procedure/framework/@type)
          return map{
            "framework" : $framework,
            "total" : fn:count($cases[description/procedure/framework[@type=$framework]]),
            "places" : array{
              for $place in $places
              return map{
                "place" : array{$place},
                "total" : countExpertisesByPlaces($cases[description/procedure/framework[@type=$framework]], $place),
                "objects" : array{
                  for $object in $objects
                  return map{
                    "object" : array:get($object, 1),
                    "label" : array:get($object, 2),
                    "total" : countExpertisesByPlaces($cases[description/procedure[framework[@type=$framework]][objects[object/@type=array:get($object, 1)]]], $place)
                  }
                }
              }
            }
          }
        }
      }
    },
    "experts" : array{
      let $maxExperts := for $expertise in $expertises return fn:count($expertise/description/participants/experts/expert)
      for $numExperts in fn:sort(fn:distinct-values($maxExperts))
        let $affaires := $expertises[description/participants/experts[fn:not(expert[@context='third-party'])][fn:count(expert) = $numExperts]]
        let $distrib :=
          for $expertise in $affaires
          return
          <expertise>{
            for $expert in $expertise/description/participants/experts/expert
                      return <expert>{$experts/expert[id = $expert/fn:substring-after(@ref, '#')]/column => fn:normalize-space()}</expert>
          }</expertise>
      return map{
        "totalExperts" :  $numExperts,
        "totalExpertises" : fn:count($affaires),
        "distribution" : array{
          if ($numExperts = 1) then for $column in ('architecte', 'entrepreneur') return map{
            "label" : $column,
            "total" : fn:count($distrib[expert = $column])
          }
          else if ($numExperts = 2) then for $collab in (['architecte', 'architecte'], ['entrepreneur', 'architecte'], ['entrepreneur', 'entrepreneur']) return map{
            "label" : fn:string-join($collab, ' - '),
            "total" : if(array:get($collab, 1) = array:get($collab, 2)) then fn:count($distrib[expert[1] = array:get($collab, 1)][expert[2] = array:get($collab, 2)])
                      else fn:count($distrib[expert[1] = array:get($collab, 1)][expert[2] = array:get($collab, 2)]) + fn:count($distrib[expert[1] = array:get($collab, 2)][expert[2] = array:get($collab, 1)])
          }
        }
      }
    },
    "frameworks" : array{
      for $framework in $frameworks
      return map{
        "framework" : array:get($framework, 1),
        "label" : array:get($framework, 2),
        "total" : fn:count($expertises[description/procedure[framework[@type = $framework]]])
      }
    },
    "origination" : array{
      for $origination in fn:distinct-values($expertises/description/procedure/origination/@type[fn:normalize-space(.)!=''])
      let $e := $expertises[description/procedure/origination/fn:normalize-space(@type) = $origination]
      return map {
        "origination" : $origination,
        "label" : ($expertises/description/procedure/origination[@type=$origination])[1] => fn:normalize-space(),
        "total" : fn:count($e),
        "distribution" : map{
          "categories" : array{
            for $cat in $categories
            let $e := $e[description/categories/category/fn:normalize-space(@type) = $cat]
            return map{
              "category" : array:get($cat, 1),
              "label" : array:get($cat, 2),
              "total" : fn:count($e)
            }
          },
          "frameworks" : array{
            for $framework in $frameworks
            let $e := $e[description/procedure/framework[fn:normalize-space(@type)=$framework]]
            return map {
              "framework" : array:get($framework, 1),
              "label" : array:get($framework, 2),
              "total" : fn:count($e)
            }
          }
        }
      }
    },
    "sentences" : map{
      "total" : fn:count($expertises[description/procedure[fn:normalize-space(sentences)!='']])
    },
    "objects" : array{
      for $object in $objects
      return map{
        "object" : array:get($object, 1),
        "label" : array:get($object, 2),
        "total" : fn:count($expertises[description/procedure/objects/object[fn:normalize-space(@type)=array:get($object, 1)]])
      }
    },
    "conclusion" : array{
      for $agreement in $agreements
      return map{
        "agreement" : array:get($agreement, 1),
        "label" : array:get($agreement, 2),
        "total" : fn:count($expertises[description/conclusions/agreement/@type=array:get($agreement, 1)])
      }
    },
    "fees" : array{
      map{"10" : fn:count($fees[fn:number(.) <= 10])},
      map{"20" : fn:count($fees[fn:number(.) <= 20 and fn:number(.) > 10])},
      map{"30" : fn:count($fees[fn:number(.) <= 30 and fn:number(.) > 20])},
      map{"40" : fn:count($fees[fn:number(.) <= 40 and fn:number(.) > 30])},
      map{"50" : fn:count($fees[fn:number(.) <= 50 and fn:number(.) > 40])},
      map{"100" : fn:count($fees[fn:number(.) <= 100 and fn:number(.)>50])},
      map{"200" : fn:count($fees[fn:number(.) <= 200 and fn:number(.) > 100])},
      map{"300" : fn:count($fees[fn:number(.) <= 300 and fn:number(.) > 200])},
      map{"400" : fn:count($fees[fn:number(.) <= 400 and fn:number(.) > 300])},
      map{"500" : fn:count($fees[fn:number(.) <= 500 and fn:number(.) > 400])},
      map{"750" : fn:count($fees[fn:number(.) <= 750 and fn:number(.) > 500])},
      map{"1000" : fn:count($fees[fn:number(.) <= 1000 and fn:number(.)>750])},
      map{"1250" : fn:count($fees[fn:number(.) <= 1250 and fn:number(.) > 1000])},
      map{"1500" : fn:count($fees[fn:number(.) <= 1500 and fn:number(.) > 1250])},
      map{"1750" : fn:count($fees[fn:number(.) <= 1750 and fn:number(.) > 1500])},
      map{"2000" : fn:count($fees[fn:number(.) <= 2000 and fn:number(.) > 1750])},
      map{"3000" : fn:count($fees[fn:number(.) <= 3000 and fn:number(.) > 2000])},
      map{"4000" : fn:count($fees[fn:number(.) <= 4000 and fn:number(.) > 3000])},
      map{"5000" : fn:count($fees[fn:number(.) <= 5000 and fn:number(.) > 4000])},
      map{"+5000" : fn:count(fn:number(.) >= 5000)}
    }

  }
  return $content
};

declare function getExpertsStatistics($experts, $expertises) {
  let $experts := $experts
  let $content := map{
    "total" : fn:count($experts/expert),
    "architects" : fn:count($experts/expert[column = 'architecte']),
    "entrepreneur" : fn:count($experts/expert[column = 'entrepreneur']),
    "surveyor" : fn:count($experts/expert[column = 'arpenteur']),
    "list" : array{
      for $expert in $experts/expert
      let $affaires := $expertises[description/participants/experts[expert[fn:substring-after(@ref, '#') = fn:normalize-space($expert/id)]]]
      let $collaborations := $affaires[description/participants/experts[fn:count(expert) > 1]]
      return map{
        "id" : $expert/id => fn:normalize-space(),
        "name" : $expert/name => fn:normalize-space(),
        "surname" : $expert/surname => fn:normalize-space(),
        "birth" : $expert/birth => fn:normalize-space(),
        "death" : $expert/death => fn:normalize-space(),
        "age" : $expert/age => fn:normalize-space(),
        "column" : $expert/column => fn:normalize-space(),
        "expertises" : map{
          "total" : fn:count($affaires),
          "thirParty" : fn:count($affaires[description/participants/experts[expert[@context = 'third-party'][fn:substring-after(@ref, '#') = fn:normalize-space($expert/id)]]]),
          "collab" : map{
            "total" : fn:count($collaborations),
            "experts" : array{
              for $collab in fn:distinct-values($collaborations/description/participants/experts/expert[fn:substring-after(@ref, '#') != fn:normalize-space($expert/id)]/@ref)
              let $id := fn:substring-after($collab, '#')
              let $expertData := $experts/expert[id = $id]
              let $totalCollab := $collaborations[description/participants/experts[expert[fn:substring-after(@ref, '#') != fn:normalize-space($expert/id)]][expert[@ref = $collab]]]
              order by fn:count($totalCollab)
              return map{
                "id" : $id,
                "name" : $expertData/name => fn:normalize-space(),
                "column" : $expertData/column => fn:normalize-space(),
                "age" : $expertData/age => fn:normalize-space(),
                "totalCollab" : fn:count($totalCollab)
              }
            }
          },
          "categories" : array{
            for $category in fn:distinct-values($expertises/description/categories/category/@type)
            let $cases := $affaires[description/categories[fn:count(category) = 1][category[@type = $category]]]
            return map{
              "category" : $category,
              "label" : ($expertises/description/categories/category[@type=$category])[1] => fn:normalize-space(),
              "total" : fn:count($cases)
              }
          }
        }
      }
    }
  }
  return $content
};

(:declare function countExpertisesByPlaces($expertises, $place) {
  if($place castable as xs:string) then fn:count($expertises//places[place[@type = $place]][fn:not(place[@type != $place])])
  else if(array:size($place) = 2) then fn:count($expertises//places[place[@type = array:get($place, 1)] and place[@type = array:get($place, 2)]][fn:not(place[@type != array:get($place, 1) and @type != array:get($place, 2)])])
  else if(array:size($place) = 3) then fn:count($expertises//places[place[@type = 'paris'] and place[@type = 'suburbs'] and place[@type = 'province']])
};:)

declare function countExpertisesByPlaces($expertises, $place) {
  if($place castable as xs:string) then fn:count($expertises//sessions[date[@type = $place]][fn:not(date[@type != $place])])
  else if(array:size($place) = 2) then fn:count($expertises//sessions[date[@type = array:get($place, 1)] and date[@type = array:get($place, 2)]][fn:not(date[@type != array:get($place, 1) and @type != array:get($place, 2)])])
  else if(array:size($place) = 3) then fn:count($expertises//sessions[date[@type = 'paris'] and date[@type = 'suburbs'] and date[@type = 'province']])
};



declare function getDistribution($seq, $step, $max) {
  for $n in 1 to $max
  let $multiplier := $step
  let $step := $n * $multiplier
  return (
    if($n = 20) then map{
        $step : fn:count($seq[fn:number(.) >= $step])
    }
    else if ($n = 1) then map {
      $step : fn:count($seq[fn:number(.) <= $step and fn:number(.) >= $step - $multiplier])
    }
    else map{
      $step : fn:count($seq[fn:number(.) <= $step and fn:number(.) > $step - $multiplier])
    }
  )
};