xquery version '3.0' ;
module namespace xpr = 'xpr' ;

declare default element namespace 'xpr' ;
declare default function namespace 'xpr' ;


(:
  This function
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

:)
declare
  %rest:path("/xformsResults")
  %output:method("xml")
  %rest:POST("{$param}")
  %updating
function xformResult($param) {
  for $expertises in db:open("xforms")/expertises
  return insert node $param into $expertises
};

(:
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