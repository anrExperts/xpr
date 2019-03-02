xquery version '3.0' ;
module namespace test = 'test' ;

declare default element namespace 'test' ;
declare default function namespace 'test' ;

declare variable $test:xslt := file:base-dir();

(:
:)
declare
  %rest:path("/experts")
  %output:method("xml")
function xform() {
  (processing-instruction xml-stylesheet {'href="static/xsltforms2/xsltforms.xsl"', 'type="text/xsl"'},
  processing-instruction css-conversion {'no'},
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:xf="http://www.w3.org/2002/xforms" xmlns:ev="http://www.w3.org/2001/xml-events">
  <head>
    <meta charset="UTF-8"/>
    <link rel="stylesheet" type="text/css" href="static/semanticUI/semantic.css"/>
    <title>Copy Item</title>
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
      
    </xf:model>
  </head>
  <body>
    <div class="ui inverted segment">
      <h1 class="ui grey inverted header">Formulaire de dépouillement Z1j</h1>
    </div>
    <div class="ui container">
      <div class="ui grid">
        <div class="ten wide column">
            <!--Début formulaire-->
            <div class="row">
                <h2>Références</h2>
                <div class="ui clearing divider"></div>
                <xf:input ref="references/cote" incremental="true">
                    <xf:label>Cote Z1j : </xf:label>
                    <xf:alert>Ce champ est requis</xf:alert>
                </xf:input>
                <br/>
                <xf:input ref="references/facsimile/@url">
                    <xf:label>facsimile : </xf:label>
                </xf:input>
            </div>
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
        </div><!--fin formulaire-->
        <div class="six wide column">
          <div>
            <h2>Résultat XML</h2>
            <pre>
                <xf:output value="serialize(., 'yes')"/>
            </pre>
          </div>
        </div>
      </div>
    </div>
    <div class="ui container">
      
      <xf:submit>
        <xf:label>Envoyer</xf:label>
      </xf:submit>
      <xf:trigger>
        <xf:label>Reset</xf:label>
        <xf:reset ev:event="DOMActivate"/>
      </xf:trigger>
    </div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.js"></script>
    <script src="static/semanticUI/semantic.min.js"></script>
  </body>
</html>
)
};