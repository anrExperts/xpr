xquery version '3.0' ;
module namespace xpr = 'xpr' ;

declare default element namespace 'xpr' ;
declare default function namespace 'xpr' ;


(:
  Cette fonction renvoie le contenu d’un champ avec la méthode GET
  @bug ne permet pas de relancer le formulaire, affiche le résultat comme output
:)
declare
  %rest:path("/form00")
  %output:method("xml")
  %rest:GET
  %rest:query-param('reference', "{$reference}")
function form00($reference) {
  (
    processing-instruction xml-stylesheet { 'href="files/xsltforms/xsltforms/xsltforms.xsl"', 'type="text/xsl"'},
    <?css-conversion no?>,
    <html xmlns="http://www.w3.org/1999/xhtml" xmlns:xf="http://www.w3.org/2002/xforms">
      <head>
        <title>BaseX XForms Demo</title>
        <link href="https://fonts.googleapis.com/css?family=IBM+Plex+Mono:400,400i|IBM+Plex+Sans+Condensed:400,400i|IBM+Plex+Sans:100,100i,400,400i,700,700i|IBM+Plex+Serif:400,400i" rel="stylesheet"/>
        <link href="files/css/normalize.css" rel="stylesheet"/>
        <link href="files/css/main.css" rel="stylesheet"/>
        <!-- XForms data models -->
        <xf:model>
          <xf:instance>
          <expertise xmlns="">
            <reference id='reference' />
          </expertise>
          </xf:instance>
          <xf:submission id="submit" resource="form00" method="get" replace="instance"/>

        </xf:model>
      </head>
      <body>
        <header>
          <h1>Form00</h1>
        </header>
        <main>
          <section>
            <h2>Form</h2>
            <xf:input ref="/expertise/reference" incremental="true">
              <xf:label>Input</xf:label>
            </xf:input>
            <xf:submit submission="submit">
              <xf:label>Envoyer</xf:label>
            </xf:submit>
          </section>
          <section>
            <h2>Output</h2>
            <xf:output value="/expertise/reference" />
          </section>
          <section>
            <h2>XML</h2>
            <pre>
              <xf:output value="serialize(., 'yes')"/>
            </pre>
          </section>
          <section>
            <h2>Params</h2>
            <p>{$reference}</p>
          </section>
        </main>
        <footer>
          <p>eXperts</p>
        </footer>
      </body>
    </html>
  )
};


(:
  Cette fonction renvoie le contenu d’un champ avec la méthode POST
  @bug ne permet pas de relancer le formulaire, affiche le résultat comme output
:)
declare
  %rest:path("/form01")
  %output:method("xml")
  %rest:GET
  %rest:query-param('reference', "{$reference}")
function form01($reference) {
  (
    processing-instruction xml-stylesheet { 'href="files/xsltforms/xsltforms/xsltforms.xsl"', 'type="text/xsl"'},
    <?css-conversion no?>,
    <html xmlns="http://www.w3.org/1999/xhtml" xmlns:xf="http://www.w3.org/2002/xforms">
      <head>
        <title>BaseX XForms Demo</title>
        <link href="https://fonts.googleapis.com/css?family=IBM+Plex+Mono:400,400i|IBM+Plex+Sans+Condensed:400,400i|IBM+Plex+Sans:100,100i,400,400i,700,700i|IBM+Plex+Serif:400,400i" rel="stylesheet"/>
        <link href="files/css/normalize.css" rel="stylesheet"/>
        <link href="files/css/main.css" rel="stylesheet"/>
        <!-- XForms data models -->
        <xf:model>
          <xf:instance>
          <expertise xmlns="">
            <reference id='reference' />
          </expertise>
          </xf:instance>
          <xf:submission id="submit" resource="form01Result" method="post" replace="instance"/>

        </xf:model>
      </head>
      <body>
        <header>
          <h1>Form00</h1>
        </header>
        <main>
          <section>
            <h2>Form</h2>
            <xf:input ref="/expertise/reference" incremental="true">
              <xf:label>Input</xf:label>
            </xf:input>
            <xf:submit submission="submit">
              <xf:label>Envoyer</xf:label>
            </xf:submit>
          </section>
          <section>
            <h2>Output</h2>
            <xf:output value="/expertise/reference" />
          </section>
          <section>
            <h2>XML</h2>
            <pre>
              <xf:output value="serialize(., 'yes')"/>
            </pre>
          </section>
          <section>
            <h2>Params</h2>
            <p>{$reference}</p>
          </section>
        </main>
        <footer>
          <p>eXperts</p>
        </footer>
      </body>
    </html>
  )
};

declare
  %rest:path("/form01Result")
  %output:method("xml")
  %rest:POST("{$param}")
function xformResult($param) {
  <div>
    <head>Resultat Form01</head>
    <p>{$param}</p>
  </div>
};


(:
  Cette fonction renvoie le contenu d’un champ avec la méthode GET
  @bug ne permet pas de relancer le formulaire, affiche le résultat comme output
:)
declare
  %rest:path("/form03")
  %output:method("xml")
  %rest:GET
  %rest:query-param('reference', "{$reference}")
function form03($reference) {
  (
    processing-instruction xml-stylesheet { 'href="files/xsltforms/xsltforms/xsltforms.xsl"', 'type="text/xsl"'},
    <?css-conversion no?>,
    <html xmlns="http://www.w3.org/1999/xhtml" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xf="http://www.w3.org/2002/xforms">
      <head>
        <title>BaseX XForms Demo</title>
        <link href="https://fonts.googleapis.com/css?family=IBM+Plex+Mono:400,400i|IBM+Plex+Sans+Condensed:400,400i|IBM+Plex+Sans:100,100i,400,400i,700,700i|IBM+Plex+Serif:400,400i" rel="stylesheet"/>
        <link href="files/css/normalize.css" rel="stylesheet"/>
        <link href="files/css/main.css" rel="stylesheet"/>
        <!-- <link href="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.4.1/semantic.css" rel="stylesheet"/> -->
        <!-- XForms data models -->
        <xf:model>
      <xf:instance>
        <expertise xmlns="">
          <references>
            <cote></cote>
            <facsimile url=""></facsimile>
          </references>
          <vacations>
            <vacation when="" type=""></vacation>
          </vacations>
          <physDesc>
            <extent>
              <measure></measure>
              <appendices n="">
                <appendice n="" type="">
                  <type></type>
                  <todo></todo>
                </appendice>
              </appendices>
            </extent>
          </physDesc>
        </expertise>
      </xf:instance>
      <xf:bind nodeset="references/cote" required="true()"/>
      <xf:bind nodeset="vacations/vacation/@when" type="xsd:date"/>
      <xf:bind nodeset="physDesc/extent/appendices/@n" type="xf:integer"/>
      <xf:bind nodeset="physDesc/extent/appendices/appendice/@n" type="xf:integer"/>
      <xf:bind nodeset="physDesc/extent/appendices/appendice/todo" relevant="../type='other"/>
      <xf:submission id="submit" resource="form03" method="get" replace="instance"/>
    </xf:model>
      </head>
      <body>
        <header>
          <h1>Form00</h1>
        </header>
        <main>
          <div class="ui inverted segment">
      <h1 class="ui grey inverted header">Formulaire de dépouillement Z1j</h1>
    </div>
    <div class="ui container">
      <div class="ui grid">
        <div class="ten wide column">
            <!--Début formulaire-->
            <div class="row">
                <h2>Références</h2>
                <div class="ui clearing divider"/>
                <xf:input ref="references/cote" incremental="true">
                    <xf:label>Cote Z1j : </xf:label>
                    <xf:alert>Ce champ est requis</xf:alert>
                </xf:input>
                <br/>
                <xf:textarea ref="references/facsimile/@url">
                    <xf:label>facsimile : </xf:label>
                </xf:textarea>
                <xf:input class="date" ref="vacations/vacation/@when" incremental="true">
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
    <div class="ui container">
    <xf:submit submission="form03">
       <xf:label>Envoyer</xf:label>
    </xf:submit>
    <xf:trigger>
        <xf:label>Reset</xf:label>
        <xf:reset ev:event="DOMActivate"/>
      </xf:trigger>
    </div>    
        </main>
        <footer>
          <p>eXperts</p>
        </footer>
      </body>
      <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.js"></script>
      <script src="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.4.1/semantic.js"></script>
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
    <html xmlns="http://www.w3.org/1999/xhtml" xmlns:xf="http://www.w3.org/2002/xforms">
      <head>
        <title>BaseX XForms Demo</title>
        <xf:model>
          <xf:instance>
            <track xmlns="">
              <metadata>
              <title>Like A Rolling Stone</title>
              <artist>Bob Dylan</artist>
            <date>1965-06-21</date>
            <genre>Folk</genre>
          </metadata>
        </track>
      </xf:instance>
      <xf:bind id="_date" nodeset="//date" type="xs:date"/>
    </xf:model>
  </head>

  <body>
    <div class="right">
      <img src="files/basex.svg" width="96" />
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
    <table width='100%'>
      <tr>
        <td width='30%'>
          <h4>Input Form</h4>
          <table>
            <tr>
              <td>Title:</td>
              <td><xf:input class="input-medium" ref="/track/metadata/title" incremental="true"/></td>
            </tr>
            <tr>
              <td>Artist:</td>
              <td><xf:input class="input-medium" ref="//artist" incremental="true"/></td>
            </tr>
            <tr>
              <td>Date:</td>
              <td><xf:input bind="_date"/></td>
            </tr>
            <tr>
              <td>Genre:</td>
              <td>
                <xf:select1 ref="//genre" appearance="minimal" incremental="true">
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
        <td width='30%'>
          <h4>Output Form</h4>
          <table>
            <tr>
              <td>Artist:</td>
              <td><xf:output ref="//artist"/></td>
            </tr>
            <tr>
              <td>Title:</td>
              <td><xf:output ref="//title"/></td>
            </tr>
            <tr>
              <td>Date:</td>
              <td><xf:output ref="//date"/></td>
            </tr>
            <tr>
              <td>Genre:</td>
              <td><xf:output ref="//genre"/></td>
            </tr>
          </table>
        </td>
        <td width='40%'>
          <h4>XML Data Model</h4>
          <pre>
            <xf:output value="serialize(., 'yes')"/>
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
%rest:path('/files/{$file=.+}')
function xpr:file($file as xs:string) as item()+ {
  let $path := file:base-dir() || 'files/' || $file
  return (
    web:response-header(map { 'media-type': web:content-type($path)}),
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
  $name  as xs:string
) as xs:string {
  fetch:content-type($name)
};