xquery version "3.0";
module namespace xpr = "xpr";
(:~
 : This xquery module is an application for the Z1J expertises called xpr
 :
 : @author emchateau et sardinecan (ANR Experts)
 : @since 2019-01
 : @licence GNU http://www.gnu.org/licenses
 :
 : xpr is free software: you can redistribute it and/or modify
 : it under the terms of the GNU General Public License as published by
 : the Free Software Foundation, either version 3 of the License, or
 : (at your option) any later version.
 :
 :)

declare namespace rest = "http://exquery.org/ns/restxq";
declare namespace file = "http://expath.org/ns/file";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace web = "http://basex.org/modules/web";
declare namespace update = "http://basex.org/modules/update";
declare namespace db = "http://basex.org/modules/db";

declare default element namespace "xpr";
declare default function namespace "xpr";

declare variable $xpr:xslt := file:base-dir();

(:~
 : This resource function defines the application root
 : @return redirect to the home page or to the install
 :)
declare 
  %rest:path("/xpr")
  %output:method("xml")
function index() {
  if (db:exists("xpr"))
    then web:redirect("/xpr/home") 
    else web:redirect("/xpr/install") 
};

(:~
 : This resource function install
 : @return create the db
 :)
declare 
  %rest:path("/xpr/install")
  %output:method("xml")
  %updating
function install() {
  if (db:exists("xpr")) 
    then (
      update:output("La base xpr existe déjà, voulez-vous l’écraser ?")
     )
    else (
      update:output("La base a été créée"),
      db:create( "xpr", <expertises/>, "z1j.xml", map {"chop" : fn:false()} )
      )
};

(:~
 : This resource function defines the application home
 : @return redirect to the expertises list
 :)
declare 
  %rest:path("/xpr/home")
  %output:method("xml")
function home() {
  web:redirect("/xpr/expertises") 
};

(:~
 : This resource function lists all the expertises
 : @return an ordered list of expertises
 :)
declare 
%rest:path("xpr/expertises")
%output:method("html")
function listExpertises() {
  let $expertises := db:open("xpr")//*:expertise
  let $content := for $expertise in $expertises return <p><a href="{$expertise/xml:id}">{$expertise}</a></p>
  return 
    <html>
      <head>
        <title>Expertises</title>
      </head>
      <body>
        <h1>Liste des expertises</h1>
        <ul>{
          for $expertise in $expertises 
          let $cote := $expertise/sourceDesc/idno[@type="unitid"]
          let $dossier := $expertise/sourceDesc/idno[@type="item"]
          let $date := $expertise/description/sessions/date[1]/@when
          return 
            <li>
              <span>{$cote || ' n° ' || $dossier}</span>
              <span>{fn:string($date)}</span>
              <button onclick="location.href='/xpr/expertises/{$cote}'">Nouveau</button>
            </li>
        }</ul>
        <button onclick="location.href='/xpr/expertises/new'">Nouveau</button>
      </body>
    </html>
};

(:~
 : This resource function lists all the expertises
 : @return an ordered list of expertises
 :)
declare 
%rest:path("xpr/expertises/{$id}")
%output:method("xml")
function modifyExpertise($id) {
  let $expertises := db:open("xpr")//*:expertise
  let $xsltformsPath := "/xpr/files/xsltforms/xsltforms/xsltforms.xsl"
  let $xprFormPath := file:base-dir() || "files/xprForm.xml"
  return
    (processing-instruction xml-stylesheet { fn:concat("href='", $xsltformsPath, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    fn:doc($xprFormPath)
    )
};

(:~
 : This resource function edits an exertise
 : @param an expertise id
 : @return an xforms for the expertise
 : @bug namespace xf:instance
:)
declare
%rest:path("xpr/expertises/new")
%output:method("xml")
function xform() {
  let $xsltformsPath := "/xpr/files/xsltforms/xsltforms/xsltforms.xsl"
  let $xprFormPath := file:base-dir() || "files/xprForm.xml"
  return
    (processing-instruction xml-stylesheet { fn:concat("href='", $xsltformsPath, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    fn:doc($xprFormPath)
    )
};

(:~
 : This function consumes new expertises 
 : @param $param content
 : @bug solve the xml namespace in xforms
 :)
declare
%rest:path("xpr/expertises/put")
%output:method("xml")
%rest:PUT("{$param}")
%updating
function xformResult($param) {
  let $id := $param/*/*:sourceDesc/*:idno[@type="unitid"]/text()
  let $db := db:open("xpr")
  let $param := 
    copy $d := $param
    modify insert node attribute xml:id {$id} into $d/*
    return $d
  return insert node $param into $db
};

declare
%rest:path("xpr/expertises/post")
%output:method("xml")
%rest:POST("{$param}")
%updating
function updateExpertise($param) {
  let $id := $param/text()
  let $db := db:open("xpr")
  return (
    (: insert node (attribute xml:id {$id} ) into $param/*:expertise, :)
    insert node $param into $db/expertises
  )
};

declare
%rest:path("xpr/test")
%output:method("xml")
function formTest() {
  (
    processing-instruction xml-stylesheet {'href="files/xsltforms/xsltforms/xsltforms.xsl"', 'type="text/xsl"'},
    <?css-conversion no?>,
     <html
        xmlns="http://www.w3.org/1999/xhtml"
        xmlns:ev="http://www.w3.org/2001/xml-events"
        xmlns:xf="http://www.w3.org/2002/xforms">
        <head>
          <title>test</title>
          <xf:model>
            <xf:instance xmlns="">
               <expertise>
                 <item>test</item>
               </expertise>
            </xf:instance>
            <xf:submission id="submit" method="post" resource="/xpr/edit/post" replace="none"  />
          </xf:model>
        </head>
        <body>
        <h1>test</h1>
          <form>
            <xf:input ref="item" incremental="true">
              <xf:label>Text</xf:label>
              <xf:hint>hint</xf:hint>
            </xf:input>
            <xf:submit submission="submit">
              <xf:label>Envoyer</xf:label>
            </xf:submit>
          </form>
        </body>
      </html>
    )
};


(:
  Cette fonction renvoie le contenu d’un champ avec la méthode GET
  @bug ne permet pas de relancer le formulaire, affiche le résultat comme output
:)
declare
%rest:path("/form03")
%output:method("xml")
%rest:GET
%rest:query-param("reference", "{$reference}")
function form03($reference) {
    (
    processing-instruction xml-stylesheet {'href="files/xsltforms/xsltforms/xsltforms.xsl"', 'type="text/xsl"'},
    <?css-conversion no?>,
    <html
        xmlns="http://www.w3.org/1999/xhtml"
        xmlns:ev="http://www.w3.org/2001/xml-events"
        xmlns:xf="http://www.w3.org/2002/xforms">
        <head>
            <title>BaseX XForms Demo</title>
            <link
                href="https://fonts.googleapis.com/css?family=IBM+Plex+Mono:400,400i|IBM+Plex+Sans+Condensed:400,400i|IBM+Plex+Sans:100,100i,400,400i,700,700i|IBM+Plex+Serif:400,400i"
                rel="stylesheet"/>
            <link
                href="files/css/normalize.css"
                rel="stylesheet"/>
            <link
                href="files/css/main.css"
                rel="stylesheet"/>
            <!-- <link href="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.4.1/semantic.css" rel="stylesheet"/> -->
            <!-- XForms data models -->
            <xf:model>
                <xf:instance>
                    <expertise
                        xmlns="">
                        <references>
                            <cote></cote>
                            <facsimile
                                url=""></facsimile>
                        </references>
                        <vacations>
                            <vacation
                                when=""
                                type=""></vacation>
                        </vacations>
                        <physDesc>
                            <extent>
                                <measure></measure>
                                <appendices
                                    n="">
                                    <appendice
                                        n=""
                                        type="">
                                        <type></type>
                                        <todo></todo>
                                    </appendice>
                                </appendices>
                            </extent>
                        </physDesc>
                    </expertise>
                </xf:instance>
                <xf:bind
                    nodeset="references/cote"
                    required="true()"/>
                <xf:bind
                    nodeset="vacations/vacation/@when"
                    type="xsd:date"/>
                <xf:bind
                    nodeset="physDesc/extent/appendices/@n"
                    type="xf:integer"/>
                <xf:bind
                    nodeset="physDesc/extent/appendices/appendice/@n"
                    type="xf:integer"/>
                <xf:bind
                    nodeset="physDesc/extent/appendices/appendice/todo"
                    relevant="../type='other"/>
                <xf:submission
                    id="submit"
                    resource="form03"
                    method="get"
                    replace="instance"/>
            </xf:model>
        </head>
        <body>
            <header>
                <h1>Form00</h1>
            </header>
            <main>
                <div
                    class="ui inverted segment">
                    <h1
                        class="ui grey inverted header">Formulaire de dépouillement Z1j</h1>
                </div>
                <div
                    class="ui container">
                    <div
                        class="ui grid">
                        <div
                            class="ten wide column">
                            <!--Début formulaire-->
                            <div
                                class="row">
                                <h2>Références</h2>
                                <div
                                    class="ui clearing divider"/>
                                <xf:input
                                    ref="references/cote"
                                    incremental="true">
                                    <xf:label>Cote Z1j : </xf:label>
                                    <xf:alert>Ce champ est requis</xf:alert>
                                </xf:input>
                                <br/>
                                <xf:textarea
                                    ref="references/facsimile/@url">
                                    <xf:label>facsimile : </xf:label>
                                </xf:textarea>
                                <xf:input
                                    class="date"
                                    ref="vacations/vacation/@when"
                                    incremental="true">
                                    <xf:label>Date de la vacation : </xf:label>
                                    <xf:alert>erreur</xf:alert>
                                </xf:input>
                            </div>
                            <!-- 
 <div class="ui hidden divider"></div>
            <div class="row">
                <h2>Dates de l‘expertise</h2>
                <div class="ui clearing divider"></div>
                <xf:repeat id="repeatVacations" nodeset="vacations/vacation">
                    <xf:input ref="@when" incremental="true">
                        <xf:label>Date de la vacation : </xf:label>
                        <xf:alert>erreur</xf:alert>
                    </xf:input>
                    <xf:select1 ref="@type">
                        <xf:label>Lieu de la vacation : </xf:label>
                        <xf:item>
                            <xf:label>Paris et faubourgs</xf:label>
                            <xf:value>paris</xf:value>
                        </xf:item>
                        <xf:item>
                            <xf:label>Banlieue</xf:label>
                            <xf:value>banlieue</xf:value>
                        </xf:item>
                        <xf:item>
                            <xf:label>Campagne</xf:label>
                            <xf:value>campagne</xf:value>
                        </xf:item>
                    </xf:select1>
                    <xf:trigger>
                        <xf:label>&#10007;</xf:label>
                        <xf:delete nodeset="." at="1" ev:event="DOMActivate" if="count(//vacation) > 1"/>
                    </xf:trigger>
                </xf:repeat>
                <xf:trigger>
                    <xf:label>Ajouter une vacation</xf:label>
                    <xf:insert nodeset="vacations/vacation" at="index('repeatVacations')" position="after" ev:event="DOMActivate" content="empty"/>
                </xf:trigger>
            </div>
            <div class="ui hidden divider"></div>
            <div class="row">
                <h2>Description physique du procès-verbal et des pièces annexes</h2>
                <div class="ui clearing divider"></div>
                <xf:input ref="physDesc/extent/measure" incremental="true">
                  <xf:label>Nombre de cahiers et de feuillets :
                  </xf:label>
                </xf:input>
                <br/>
                <xf:input ref="physDesc/extent/appendices/@n">
                  <xf:label>Nombre de pièces annexes :
                  </xf:label>
                  <xf:alert>Nombre requis.</xf:alert>
                </xf:input>

                <h3>Description des pièces annexes</h3>
                <div class="ui clearing divider"></div>
                <xf:repeat id="repeatAppendices" nodeset="physDesc/extent/appendices/appendice" appearance="full">
                    <xf:input ref="@n">
                        <xf:label>N° de la pièce annexe : </xf:label>
                        <xf:alert>Nombre requis.</xf:alert>
                    </xf:input>
                    <br/>
                    <xf:select1 ref="type" appearance="full">
                        <xf:label>Type de pièce annexe : </xf:label>
                        <xf:item>
                            <xf:label>Dessin</xf:label>
                            <xf:value>dessin</xf:value>
                        </xf:item>
                        <xf:item>
                            <xf:label>Plan</xf:label>
                            <xf:value>plan</xf:value>
                        </xf:item>
                        <xf:item>
                            <xf:label>Croquis</xf:label>
                            <xf:value>croquis</xf:value>
                        </xf:item>
                        <xf:item>
                            <xf:label>Brouillon</xf:label>
                            <xf:value>brouillon</xf:value>
                        </xf:item>
                        <xf:item>
                            <xf:label>Pouvoir</xf:label>
                            <xf:value>pouvoir</xf:value>
                        </xf:item>
                        <xf:item>
                            <xf:label>Requête</xf:label>
                            <xf:value>requête</xf:value>
                        </xf:item>
                        <xf:item>
                            <xf:label>autre, à préciser</xf:label>
                            <xf:value>other</xf:value>
                        </xf:item>
                    </xf:select1>
                    <xf:input ref="todo">
                        <xf:label>Préciser le type de pièce : </xf:label>
                    </xf:input>
                    <xf:trigger>
                        <xf:label>Supprimer une annexe</xf:label>
                        <xf:delete nodeset="." at="1" ev:event="DOMActivate" if="count(//appendice) > 1"/>
                    </xf:trigger>
                </xf:repeat>
                <xf:trigger>
                    <xf:label>Ajouter une pièce annexe</xf:label>
                    <xf:insert nodeset="physDesc/extent/appendices/appendice" at="index('repeatAppendices')" position="after" ev:event="DOMActivate"/>
                </xf:trigger>
            </div>
        </div><!-\- fin formulaire -\->
        <div class="six wide column">
          <div>
            <h2>Résultat XML</h2>
            <pre>
                <xf:output value="serialize(., 'yes')"/>
            </pre>
          </div>  -->
                        </div>
                    </div>
                </div>
                <div
                    class="ui container">
                    <xf:submit
                        submission="form03">
                        <xf:label>Envoyer</xf:label>
                    </xf:submit>
                    <xf:trigger>
                        <xf:label>Reset</xf:label>
                        <xf:reset
                            ev:event="DOMActivate"/>
                    </xf:trigger>
                </div>
            </main>
            <footer>
                <p>eXperts</p>
            </footer>
        </body>
        <script
            src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.js"></script>
        <script
            src="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.4.1/semantic.js"></script>
    </html>
    )
};

(:~ 
 : Cette Fonction est une version de la Démo de BaseX pour RESTXQ
 :)
declare
%rest:path("/basexForm")
%output:method("xml")
%rest:GET
function old() {
    (
    processing-instruction xml-stylesheet {'href="files/xsltforms/xsltforms/xsltforms.xsl"', 'type="text/xsl"'},
    <html
        xmlns="http://www.w3.org/1999/xhtml"
        xmlns:xf="http://www.w3.org/2002/xforms">
        <head>
            <title>BaseX XForms Demo</title>
            <xf:model>
                <xf:instance>
                    <track
                        xmlns="">
                        <metadata>
                            <title>Like A Rolling Stone</title>
                            <artist>Bob Dylan</artist>
                            <date>1965-06-21</date>
                            <genre>Folk</genre>
                        </metadata>
                    </track>
                </xf:instance>
                <xf:bind
                    id="_date"
                    nodeset="//date"
                    type="xs:date"/>
            </xf:model>
        </head>
        
        <body>
            <div
                class="right">
                <img
                    src="files/basex.svg"
                    width="96"/>
            </div>
            <h2>BaseX XForms Demo</h2>
            <ul>
                <li> In this example, the XForms model is defined in the <code>head</code> section of the XML document.</li>
                <li> The XForms model consists of an <b>instance</b> and a <b>binding</b>.</li>
                <li> The instance contains the data, and the binding specifies the type of elements (in this case the <code>date</code> element).</li>
            </ul>
            
            <h3>XForm Widgets <small> – coupled to and synchronized with XML Data Model</small></h3>
            <ul>
                <li> Whenever you modify data in the edit components, the XML data model will
                    be updated, and all other output and input components will reflect the changes.</li>
                <li> XForms also cares about type conversion: as the <code>date</code>
                    element is of type <code>xs:date</code>: a date picker is offered.</li>
            </ul>
            
            <div>Below, three different views on the XForms model are supplied. Please open the source
                view of this HTML document to see how the input and output fields are specified.</div>
            <table
                width='100%'>
                <tr>
                    <td
                        width='30%'>
                        <h4>Input Form</h4>
                        <table>
                            <tr>
                                <td>Title:</td>
                                <td><xf:input
                                        class="input-medium"
                                        ref="/track/metadata/title"
                                        incremental="true"/></td>
                            </tr>
                            <tr>
                                <td>Artist:</td>
                                <td><xf:input
                                        class="input-medium"
                                        ref="//artist"
                                        incremental="true"/></td>
                            </tr>
                            <tr>
                                <td>Date:</td>
                                <td><xf:input
                                        bind="_date"/></td>
                            </tr>
                            <tr>
                                <td>Genre:</td>
                                <td>
                                    <xf:select1
                                        ref="//genre"
                                        appearance="minimal"
                                        incremental="true">
                                        <xf:item>
                                            <xf:label>Classic Rock</xf:label>
                                            <xf:value>Classic Rock</xf:value>
                                        </xf:item>
                                        <xf:item>
                                            <xf:label>Folk</xf:label>
                                            <xf:value>Folk</xf:value>
                                        </xf:item>
                                        <xf:item>
                                            <xf:label>Metal</xf:label>
                                            <xf:value>Metal</xf:value>
                                        </xf:item>
                                        <xf:item>
                                            <xf:label>Gospel</xf:label>
                                            <xf:value>Gospel</xf:value>
                                        </xf:item>
                                        <xf:item>
                                            <xf:label>Instrumental</xf:label>
                                            <xf:value>Instrumental</xf:value>
                                        </xf:item>
                                        <xf:item>
                                            <xf:label>Soul</xf:label>
                                            <xf:value>Soul</xf:value>
                                        </xf:item>
                                        <xf:item>
                                            <xf:label>Pop</xf:label>
                                            <xf:value>Pop</xf:value>
                                        </xf:item>
                                    </xf:select1>
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td
                        width='30%'>
                        <h4>Output Form</h4>
                        <table>
                            <tr>
                                <td>Artist:</td>
                                <td><xf:output
                                        ref="//artist"/></td>
                            </tr>
                            <tr>
                                <td>Title:</td>
                                <td><xf:output
                                        ref="//title"/></td>
                            </tr>
                            <tr>
                                <td>Date:</td>
                                <td><xf:output
                                        ref="//date"/></td>
                            </tr>
                            <tr>
                                <td>Genre:</td>
                                <td><xf:output
                                        ref="//genre"/></td>
                            </tr>
                        </table>
                    </td>
                    <td
                        width='40%'>
                        <h4>XML Data Model</h4>
                        <pre>
                            <xf:output
                                value="serialize(., 'yes')"/>
                        </pre>
                    </td>
                </tr>
            </table>
        </body>
    </html>
    )
};



(:~
 : this function defines a static files directory for the app
 :
 : @param $file file or unknown path
 : @return binary file
 :)
declare
%rest:path('xpr/files/{$file=.+}')
function xpr:file($file as xs:string) as item()+ {
    let $path := file:base-dir() || 'files/' || $file
    return
        (
        web:response-header( map {'media-type' : web:content-type($path)}),
        file:read-binary($path)
        )
};

(:~
 : this function return a mime-type for a specified file
 :
 : @param  $name  file name
 : @return a mime type for the specified file
 :)
declare function xpr:mime-type(
$name as xs:string
) as xs:string {
    fetch:content-type($name)
};

(:~
 : this function 
 :
 : @param $data the result of the query
 : @return an updated document and instantiate pattern
 :)
declare function wrapper($content as map(*), $outputParams as map(*)) as node()* {
  let $layout := file:base-dir() || "files/" || map:get($outputParams, 'layout')
  let $wrap := fn:doc($layout)
  let $regex := '\{(.+?)\}'
  return
    $wrap/* update (
      for $node in .//*[fn:matches(text(), $regex)] | .//@*[fn:matches(., $regex)]
      return associate($content, $outputParams, $node)
      )
};

(:~
 : this function dispatch the content with the data
 :
 : @param $data the result of the query to dispacth (meta or content)
 : @param $outputParams the serialization params
 : @return an updated node with the data
 :) 
declare %updating function associate($data as map(*), $outputParams as map(*), $node as node()) {
  let $regex := '\{(.+?)\}'
  let $data := $data
  let $keys := fn:analyze-string($node, $regex)//fn:group/text()
  let $values := map:get($data, $keys)
    return typeswitch ($values)
    case document-node() return replace node $node with $values
    case empty-sequence() return ()
    case text() return replace value of node $node with $values
    case xs:string return replace value of node $node with $values
    case xs:string+ return 
      if ($node instance of attribute()) (: when key is an attribute value :)
      then 
        replace node $node/parent::* with 
          element {fn:name($node/parent::*)} {
          for $att in $node/parent::*/(@* except $node) return $att, 
          attribute {fn:name($node)} {fn:string-join($values, ' ')},
          $node/parent::*/text()
          }
    else
      replace node $node with 
      for $value in $values 
      return element {fn:name($node)} { 
        for $att in $node/@* return $att,
        $value
      } 
    case xs:integer return replace value of node $node with xs:string($values)
    case element()+ return replace node $node with 
      for $value in $values 
      return element {fn:name($node)} { 
        for $att in $node/@* return $att, "todo"
      }
    default return replace value of node $node with 'default'
};

(:~
 : This resource function lists all the expertises
 : @return an ordered list of expertises
 :)
declare 
%rest:path("xpr/test/{$id}")
%output:method("xml")
function test($id) {
  let $expertises := db:open("xpr")//*:expertise
  let $xsltformsPath := "/xpr/files/xsltforms/xsltforms/xsltforms.xsl"
  let $content := map {
    'model' : fn:doc(file:base-dir() || "files/" || "xprExpertiseModel.xml"),
    'trigger' : fn:doc(file:base-dir() || "files/" || "xprExpertiseTrigger.xml"),
    'form' : fn:doc(file:base-dir() || "files/" || "xprExpertiseForm.xml")
  }
  let $outputParam := map {
    'layout' : "template.xml"
  }
  return
    (processing-instruction xml-stylesheet { fn:concat("href='", $xsltformsPath, "'"), "type='text/xsl'"},
    <?css-conversion no?>,
    wrapper($content, $outputParam)
    )
};