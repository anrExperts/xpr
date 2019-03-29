xquery version '3.0';
module namespace xpr = 'xpr';

declare default element namespace 'xpr';
declare default function namespace 'xpr';

declare variable $xpr:xslt := file:base-dir();

(:
 : @bug namespace xf:instance
:)
declare
%rest:path("/formxpr")
%output:method("xml")
function xform() {
    (
    processing-instruction xml-stylesheet {'href="files/xsltforms/xsltforms/xsltforms.xsl"', 'type="text/xsl"'},
    <?css-conversion no?>,
    <html
        xmlns="http://www.w3.org/1999/xhtml"
        xmlns:ev="http://www.w3.org/2001/xml-events"
        xmlns:xf="http://www.w3.org/2002/xforms">
        <head>
            <title>xpr XForms</title>
            <!-- XForms data models -->
            <xf:model>
                <xf:instance
                    id="xprModel"
                    src="files/xml/xprInstance.xml"/>
                
                <xf:instance
                    id="xprAppendices">
                    <appendices
                        xmlns="">
                        <appendice></appendice>
                        <appendice
                            type="drawing">Dessin</appendice>
                        <appendice
                            type="plan">Plan</appendice>
                        <appendice
                            type="sketch">Croquis</appendice>
                        <appentice
                            type="rough">Brouillon</appentice>
                        <appendice
                            type="proxyPA">Pouvoir/procuration (acte sous seing privé)</appendice>
                        <appendice
                            type="proxyNA">Pouvoir/procuration (acte notarié)</appendice>
                        <appendice
                            type="petition">Requête</appendice>
                        <appendice
                            type="other">Autre</appendice>
                    </appendices>
                </xf:instance>
                
                <xf:instance
                    id="xprCategories">
                    <categories
                        xmlns="">
                        <category></category>
                        <category
                            type="estimation">Estimer la valeur des biens</category>
                        <category
                            type="acceptation">Recevoir et évaluer le travail réalisé</category>
                        <category
                            type="registration">Enregistrer</category>
                        <category
                            type="settlement">Départager</category>
                        <category
                            type="assessment">Évaluer les coûts à venir</category>
                    </categories>
                </xf:instance>
                
                <xf:instance
                    id="xprObjects">
                    <objects
                        xmlns="">
                        <object></object>
                        <object
                            type="house">Maison</object>
                        <object
                            type="plot">Terrain</object>
                        <object
                            type="buildings">Ensemble de bâtiments</object>
                        <object
                            type="territory">Domaine, terres, fief</object>
                        <object
                            type="wall">Mur</object>
                        <object
                            type="cesspool">Fosse d'aisance</object>
                        <object
                            type="well">Puits</object>
                        <object
                            type="other">Autre</object>
                    </objects>
                </xf:instance>
                
                <xf:submission
                    id="submit"
                    resource="form03"
                    method="get"
                    replace="instance"/>
                
                <!--**sourceDesc**-->
                <xf:bind
                    id="sourceDesc"
                    nodeset="sourceDesc"/>
                <!--référence-->
                
                <xf:bind
                    id="unitid"
                    nodeset="sourceDesc/idno[@type='unitid']"
                    required="true()"/>
                
                <xf:bind
                    id="item"
                    nodeset="sourceDesc/idno[@type='item']"
                    required="true()"/>
                
                <xf:bind
                    id="facsimileFrom"
                    nodeset="sourceDesc/facsimile/@from"/>
                
                <xf:bind
                    id="facsimileTo"
                    nodeset="sourceDesc/facsimile/@to"/>
                
                <!--physDesc-->
                <xf:bind
                    id="physDesc"
                    nodeset="physDesc"/>
                
                <xf:bind
                    id="extent"
                    nodeset="sourceDesc/physDesc/extent"/>
                
                <xf:bind
                    id="sketch"
                    nodeset="sourceDesc/physDesc/extent/@sketch"/>
                
                <xf:bind
                    id="appendice"
                    nodeset="sourceDesc/physDesc/appendices/appendice"/>
                
                <xf:bind
                    id="appendiceType"
                    nodeset="sourceDesc/physDesc/appendices/appendice/@type"/>
                
                <xf:bind
                    id="appendiceExtent"
                    nodeset="sourceDesc/physDesc/appendices/appendice/extent"/>
                
                <xf:bind
                    id="appendiceDesc"
                    nodeset="sourceDesc/physDesc/appendices/appendice/desc"/>
                
                <xf:bind
                    id="appendiceNote"
                    nodeset="sourceDesc/physDesc/appendices/appendice/note"/>
                
                <!--<xf:bind
                    nodeset="sourceDesc/physDesc/appendices/appendice/@subtype"
                    relevant="./parent::appendice[contains(@type, 'other')]"/>-->
                <!--**description**-->
                <xf:bind
                    id="description"
                    nodeset="description"/>
                
                <!--sessions-->
                <xf:bind
                    id="sessions"
                    nodeset="description/sessions"/>
                
                <xf:bind
                    id="sessionsDate"
                    nodeset="description/sessions/date"/>
                
                <xf:bind
                    id="sessionsWhen"
                    nodeset="description/sessions/session/@when"/>
                
                <xf:bind
                    id="sessionsType"
                    nodeset="description/sessions/date/@type"/>
                
                <!--places-->
                <xf:bind
                    id="places"
                    nodeset="description/places"/>
                
                <xf:bind
                    id="place"
                    nodeset="description/places/place"/>
                
                <xf:bind
                    id="placeAddress"
                    nodeset="description/places/place/address"
                    relevant="../@type='paris' 
                    or ../@type='suburbs' 
                    or ../@type='province' 
                    or ../@type='indeterminate'"/>
                
                <xf:bind
                    id="placeComplement"
                    nodeset="description/places/place/complement"
                    relevant="../@type='paris' 
                    or ../@type='suburbs' 
                    or ../@type='province' 
                    or ../@type='indeterminate'"/>
                
                <xf:bind
                    id="placeParish"
                    nodeset="description/places/place/parish"
                    relevant="../@type='paris'"/>
                
                <xf:bind
                    id="placeCity"
                    nodeset="description/places/place/city"
                    relevant="../@type='suburbs' 
                    or ../@type='province'"/>
                
                <xf:bind
                    id="placeDistrict"
                    nodeset="description/places/place/district"
                    relevant="../@type='suburbs' 
                    or ../@type='province'"/>
                
                <xf:bind
                    id="placeOwner"
                    nodeset="description/places/place/owner"
                    relevant="../@type='paris' 
                    or ../@type='suburbs' 
                    or ../@type='province' 
                    or ../@type='indeterminate'"/>
                
                <!--Categories-->
                
                <xf:bind
                    id="categories"
                    nodeset="description/categories"/>
                
                <xf:bind
                    id="category"
                    nodeset="description/categories/category"/>
                
                <xf:bind
                    id="categoryType"
                    nodeset="description/categories/category/@type"/>
                
                <xf:bind
                    id="designation"
                    nodeset="description/categories/designation"/>
                
                <xf:bind
                    id="designationRubric"
                    nodeset="description/categories/designation/@rubric"/>
                
                <!--procedure encadrant l'expertise-->
                <xf:bind
                    id="procedure"
                    nodeset="description/procedure"/>
                <!--cadre-->
                <xf:bind
                    id="framework"
                    nodeset="description/procedure/framework"/>
                
                <xf:bind
                    id="frameworkType"
                    nodeset="description/procedure/framework/@type"/>
                
                <!--Origine de l'expertise-->
                <xf:bind
                    id="origination"
                    nodeset="description/procedure/origination"/>
                
                <xf:bind
                    id="originationType"
                    nodeset="description/procedure/origination/@type"/>
                
                <!--intervention d'une institution-->
                <xf:bind
                    id="sentences"
                    nodeset="description/procedure/sentences"/>
                
                <xf:bind
                    id="sentence"
                    nodeset="description/procedure/sentences/sentence"/>
                
                <xf:bind
                    id="sentenceOrg"
                    nodeset="description/procedure/sentences/sentence/orgName"/>
                
                <xf:bind
                    id="sentenceDate"
                    nodeset="description/procedure/sentences/sentence/date"/>
                
                <!--Cause de l'expertise-->
                <xf:bind
                    id="case"
                    nodeset="description/procedure/case"/>
                
                <!--Objets de l'expertise-->
                <xf:bind
                    id="objectOther"
                    nodeset="description/procedure/objects/object[@type='other']"
                    relevant="."/>
                
                <!--Acteurs de l'expertise-->
                <xf:bind
                    id="participants"
                    nodeset="description/participants"/>
                
                <!--Les experts-->
                <xf:bind
                    id="experts"
                    nodeset="description/participants/experts"/>
                
                <xf:bind
                    id="expert"
                    nodeset="description/participants/experts/expert"/>
                
                <xf:bind
                    id="expertName"
                    nodeset="description/participants/experts/expert/name"/>
                
                <xf:bind
                    id="expertSurname"
                    nodeset="description/participants/experts/expert/name/surname"/>
                
                <xf:bind
                    id="expertForename"
                    nodeset="description/participants/experts/expert/name/Forename"/>
                
                <xf:bind
                    id="expertTitle"
                    nodeset="description/participants/experts/expert/title"/>
                
                <!--Les greffiers-->
                <xf:bind
                    id="clerks"
                    nodeset="description/participants/clerks"/>
                
                <xf:bind
                    id="clerk"
                    nodeset="description/participants/clerks/clerk"/>
                
                <xf:bind
                    id="clerkName"
                    nodeset="description/participants/clerks/clerk/name"/>
                
                <xf:bind
                    id="clerkSurname"
                    nodeset="description/participants/clerks/clerk/name/surname"/>
                
                <xf:bind
                    id="clerkForename"
                    nodeset="description/participants/clerks/clerk/name/forename"/>
                
                <!--Les parties-->
                <xf:bind
                    id="parties"
                    nodeset="description/participants/parties"/>
                
                <xf:bind
                    id="party"
                    nodeset="description/participants/parties/party"/>
                
                <xf:bind
                    id="person"
                    nodeset="description/participants/parties/party/person"/>
                
                <xf:bind
                    id="personName"
                    nodeset="description/participants/parties/party/person/name"/>
                
                <xf:bind
                    id="personSurname"
                    nodeset="description/participants/parties/party/person/name/surname"/>
                
                <xf:bind
                    id="personForename"
                    nodeset="description/participants/parties/party/person/name/forename"/>
                
                <xf:bind
                    id="personOccupation"
                    nodeset="description/participants/parties/party/person/occupation"/>
                
                <xf:bind
                    id="partyExpert"
                    nodeset="description/participants/parties/party/expert"/>
                
                <xf:bind
                    id="representative"
                    nodeset="description/participants/parties/party/representative"/>
                
                <xf:bind
                    id="representativeName"
                    nodeset="description/participants/parties/party/representative/name"/>
                
                <xf:bind
                    id="representativeSurname"
                    nodeset="description/participants/parties/party/representative/name/surname"/>
                
                <xf:bind
                    id="representativeForename"
                    nodeset="description/participants/parties/party/representative/name/forename"/>
                
                <xf:bind
                    id="representativeOccupation"
                    nodeset="description/participants/parties/party/representative/occupation"/>
                
                <xf:bind
                    id="prosecutor"
                    nodeset="description/participants/parties/party/prosecutor"/>
                
                <xf:bind
                    id="prosecutorName"
                    nodeset="description/participants/parties/party/prosecutor/name"/>
                
                <xf:bind
                    id="prosecutorSurname"
                    nodeset="description/participants/parties/party/prosecutor/name/surname"/>
                
                <xf:bind
                    id="prosecutorForename"
                    nodeset="description/participants/parties/party/prosecutor/name/forename"/>
                
                <!--Entrepreneur, architecte ou maître d’œuvre-->
                
                <xf:bind
                    id="craftmen"
                    nodeset="description/participants/craftmen"/>
                
                <xf:bind
                    id="craftman"
                    nodeset="description/participants/craftmen/craftman"/>
                
                <xf:bind
                    id="craftmanName"
                    nodeset="description/participants/craftmen/craftman/name"/>
                
                <xf:bind
                    id="craftmanSurname"
                    nodeset="description/participants/craftmen/craftman/name/surname"/>
                
                <xf:bind
                    id="craftmanForename"
                    nodeset="description/participants/craftmen/craftman/name/Forename"/>
                
                <xf:bind
                    id="craftmanOccupation"
                    nodeset="description/participants/craftmen/craftman/occupation"/>
                
                <!--Conclusions-->
                <xf:bind
                    id="conclusions"
                    nodeset="description/conclusions"/>
                
                <xf:bind
                    id="agreement"
                    nodeset="description/conclusions/agreement"/>
                
                <xf:bind
                    id="agreementType"
                    nodeset="description/conclusions/agreement/@type"/>
                
                <xf:bind
                    id="opinion"
                    nodeset="description/conclusions/opinion"/>
                
                <xf:bind
                    id="estimation"
                    nodeset="description/conclusions/estimation"/>
            
            
            </xf:model>
        </head>
        <body>
            <h1>Formulaire Z1J</h1>
            <form>
                <xf:trigger>
                    <xf:label>Références</xf:label>
                    <xf:toggle
                        case="references"
                        ev:event="DOMActivate"/>
                </xf:trigger>
                <xf:trigger>
                    <xf:label>Vacations</xf:label>
                    <xf:toggle
                        case="sessions"
                        ev:event="DOMActivate"/>
                </xf:trigger>
                <xf:trigger>
                    <xf:label>Descriptions</xf:label>
                    <xf:toggle
                        case="physDesc"
                        ev:event="DOMActivate"/>
                </xf:trigger>
                <xf:trigger>
                    <xf:label>Lieux de l'expertise</xf:label>
                    <xf:toggle
                        case="places"
                        ev:event="DOMActivate"/>
                </xf:trigger>
                <xf:trigger>
                    <xf:label>Catégories de l'expertise</xf:label>
                    <xf:toggle
                        case="categories"
                        ev:event="DOMActivate"/>
                </xf:trigger>
                <xf:trigger>
                    <xf:label>Procédure et cadre de l'expertise</xf:label>
                    <xf:toggle
                        case="procedure"
                        ev:event="DOMActivate"/>
                </xf:trigger>
                <xf:trigger>
                    <xf:label>Acteurs de l'expertise</xf:label>
                    <xf:toggle
                        case="participants"
                        ev:event="DOMActivate"/>
                </xf:trigger>
                <xf:trigger>
                    <xf:label>Conclusions ou dispositifs de l'expertise</xf:label>
                    <xf:toggle
                        case="conclusions"
                        ev:event="DOMActivate"/>
                </xf:trigger>
                <xf:switch>
                    <xf:case
                        id="references"
                        selected="true">
                        <xf:label>Références</xf:label>
                        <xf:group
                            ref="sourceDesc/idno">
                            <xf:label>Identifiants</xf:label>
                            <xf:input
                                bind="unitid"
                                incremental="true">
                                <xf:label>Cote</xf:label>
                            </xf:input>
                            <xf:input
                                bind="item"
                                incremental="true">
                                <xf:label>Dossier</xf:label>
                            </xf:input>
                        </xf:group>
                        <xf:group
                            ref="sourceDesc/facsimile">
                            <xf:label>Identifiants des vues</xf:label>
                            <xf:input
                                bind="facsimileFrom"
                                incremental="true">
                                <xf:label>Première vue</xf:label>
                            </xf:input>
                            <xf:input
                                bind="facsimileTo"
                                incremental="true">
                                <xf:label>Dernière vue</xf:label>
                            </xf:input>
                        </xf:group>
                        <!--control-->
                        <pre>
                            <xf:output
                                value="serialize(sourceDesc, 'yes')"/>
                        </pre>
                    </xf:case>
                    <xf:case
                        id="sessions"
                        selected="false">
                        <xf:label>Vacations</xf:label>
                        <xf:group
                            ref="description/sessions">
                            <xf:repeat
                                id="repeatSession"
                                bind="sessionsDate">
                                <xf:input
                                    ref="@when"
                                    incremental="true">
                                    <xf:label>Date</xf:label>
                                </xf:input>
                                <xf:select1
                                    ref="@type">
                                    <xf:label>Lieu</xf:label>
                                    <xf:item>
                                        <xf:label>Paris et faubourgs</xf:label>
                                        <xf:value>paris</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Banlieue</xf:label>
                                        <xf:value>suburbs</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Campagne</xf:label>
                                        <xf:value>province</xf:value>
                                    </xf:item>
                                </xf:select1>
                                <xf:trigger>
                                    <xf:label>&#10007;</xf:label>
                                    <xf:delete
                                        nodeset="."
                                        at="1"
                                        ev:event="DOMActivate"
                                        if="count(//description/sessions/date) > 1"/>
                                </xf:trigger>
                            </xf:repeat>
                            <xf:trigger>
                                <xf:label>Ajouter une vacation</xf:label>
                                <xf:action
                                    ev:event="DOMActivate">
                                    <xf:insert
                                        nodeset="date"
                                        at="index('repeatSession')"
                                        position="after"
                                        ev:event="DOMActivate"/>
                                    <xf:setvalue
                                        ref="date[index('repeatSession')]/@when"
                                        value=""/>
                                    <xf:setvalue
                                        ref="date[index('repeatSession')]/@type"
                                        value=""/>
                                </xf:action>
                            </xf:trigger>
                        </xf:group>
                        <pre>
                            <xf:output
                                value="serialize(description/sessions, 'yes')"/>
                        </pre>
                    </xf:case>
                    <xf:case
                        id="physDesc"
                        selected="false">
                        <xf:label>Description physique du procès-verbal et des pièces annexes</xf:label>
                        <xf:group>
                            <xf:input
                                bind="extent"
                                incremental="true">
                                <xf:label>Nombre de cahiers et de feuillets</xf:label>
                            </xf:input>
                            <xf:select1
                                bind="sketch">
                                <xf:label>Croquis sur le procès-verbal</xf:label>
                                <xf:item>
                                    <xf:label>oui</xf:label>
                                    <xf:value>true</xf:value>
                                </xf:item>
                                <xf:item>
                                    <xf:label>non</xf:label>
                                    <xf:value>false</xf:value>
                                </xf:item>
                            </xf:select1>
                        </xf:group>
                        <xf:group
                            ref="sourceDesc/physDesc/appendices">
                            <xf:label>Pièces annexes</xf:label>
                            <!--@rmq Pourra servir au contrôle à partir des informations tirées du récolement. -->
                            <xf:output
                                value="count(//sourceDesc/physDesc/appendices/appendice)"><xf:label>Nombre de pièces annexes</xf:label></xf:output>
                            <xf:repeat
                                id="repeatAppendice"
                                bind="appendice"
                                appearance="full">
                                <xf:select
                                    ref="@type"
                                    appearance="full">
                                    <!--@bug il existe l'attribut selection="open" pour ces cas mais il ne semble pas fonctionner. Il permet de préciser une valeur qui ne serait pas dans la liste.-->
                                    <!-- https://sourceforge.net/p/xsltforms/mailman/message/24465876/ -->
                                    <xf:label>Type de pièce annexe</xf:label>
                                    <xf:item>
                                        <xf:label>Dessin</xf:label>
                                        <xf:value>drawing</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Plan</xf:label>
                                        <xf:value>plan</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Croquis</xf:label>
                                        <xf:value>sketch</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Brouillon</xf:label>
                                        <xf:value>rough</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Pouvoir/procuration (acte sous seing privé)</xf:label>
                                        <xf:value>proxyPA</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Pouvoir/procuration (acte notarié)</xf:label>
                                        <xf:value>proxyNA</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Requête</xf:label>
                                        <xf:value>petition</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Autre</xf:label>
                                        <xf:value>other</xf:value>
                                    </xf:item>
                                </xf:select>
                                <!--@todo appendice autre-->
                                <xf:input
                                    ref="extent"
                                    incremental="true">
                                    <xf:label>Nombre de feuillets</xf:label>
                                </xf:input>
                                <xf:textarea
                                    ref="desc"
                                    incremental="true">
                                    <xf:label>Description physique</xf:label>
                                </xf:textarea>
                                <xf:textarea
                                    ref="note"
                                    incremental="true">
                                    <xf:label>Commentaires</xf:label>
                                </xf:textarea>
                                <xf:trigger>
                                    <xf:label>Supprimer une annexe</xf:label>
                                    <xf:delete
                                        nodeset="."
                                        at="1"
                                        ev:event="DOMActivate"
                                        if="count(//sourceDesc/physDesc/appendices/appendice) > 1"/>
                                </xf:trigger>
                            </xf:repeat>
                            <xf:trigger>
                                <xf:label>Ajouter une pièce annexe</xf:label>
                                <xf:action
                                    ev:event="DOMActivate">
                                    <xf:insert
                                        nodeset="appendice"
                                        at="index('repeatAppendice')"
                                        position="after"
                                        ev:event="DOMActivate"/>
                                    <xf:setvalue
                                        ref="appendice[index('repeatAppendice')]/@type"
                                        value=""/>
                                    <xf:setvalue
                                        ref="appendice[index('repeatAppendice')]/extent"
                                        value=""/>
                                    <xf:setvalue
                                        ref="appendice[index('repeatAppendice')]/desc"
                                        value=""/>
                                    <xf:setvalue
                                        ref="appendice[index('repeatAppendice')]/note"
                                        value=""/>
                                </xf:action>
                            </xf:trigger>
                        </xf:group>
                        <!--control-->
                        <pre>
                            <xf:output
                                value="serialize(sourceDesc/physDesc, 'yes')"/>
                        </pre>
                    </xf:case>
                    <xf:case
                        id="places"
                        selected="false">
                        <xf:label>Lieux de l'expertise</xf:label>
                        <xf:group
                            ref="description/places">
                            <xf:repeat
                                id="repeatPlace"
                                bind="place"
                                appearance="full">
                                <xf:select1
                                    ref="@type">
                                    <xf:item>
                                        <xf:label>Paris</xf:label>
                                        <xf:value>paris</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Banlieue</xf:label>
                                        <xf:value>suburbs</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Campagne</xf:label>
                                        <xf:value>province</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Bureau des experts</xf:label>
                                        <xf:value>office</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Indéterminé</xf:label>
                                        <xf:value>indeterminate</xf:value>
                                    </xf:item>
                                </xf:select1>
                                <xf:input
                                    ref="address">
                                    <xf:label>Voie</xf:label>
                                </xf:input>
                                <xf:input
                                    ref="complement">
                                    <xf:label>Précisions géographiques</xf:label>
                                </xf:input>
                                <xf:input
                                    ref="parish">
                                    <xf:label>Paroisse</xf:label>
                                </xf:input>
                                <xf:input
                                    ref="city">
                                    <xf:label>Ville</xf:label>
                                </xf:input>
                                <xf:input
                                    ref="district">
                                    <xf:label>Département</xf:label>
                                </xf:input>
                                <xf:repeat
                                    id="repeatOwner"
                                    nodeset="owner"
                                    appearance="full">
                                    <xf:input
                                        ref=".">
                                        <xf:label>Propriétaire</xf:label>
                                    </xf:input>
                                    <xf:trigger>
                                        <xf:label>Supprimer un propriétaire</xf:label>
                                        <xf:delete
                                            nodeset="."
                                            at="1"
                                            ev:event="DOMActivate"
                                            if="count(//description/places/place/owner) > 1"/>
                                    </xf:trigger>
                                </xf:repeat>
                                <xf:trigger>
                                    <xf:label>Ajouter un propriétaire</xf:label>
                                    <xf:action
                                        ev:event="DOMActivate">
                                        <xf:insert
                                            nodeset="owner"
                                            at="index('repeatOwner')"
                                            position="after"
                                            ev:event="DOMActivate"/>
                                        <xf:setvalue
                                            ref="place/owner[index('repeatOwner')]"
                                            value=""/>
                                    </xf:action>
                                </xf:trigger>
                                <xf:trigger>
                                    <xf:label>Supprimer un lieu</xf:label>
                                    <xf:delete
                                        nodeset="."
                                        at="1"
                                        ev:event="DOMActivate"
                                        if="count(//description/places/place) > 1"/>
                                </xf:trigger>
                            </xf:repeat>
                            <xf:trigger>
                                <xf:label>Ajouter un lieu</xf:label>
                                <xf:action
                                    ev:event="DOMActivate">
                                    <xf:insert
                                        nodeset="place"
                                        at="index('repeatPlace')"
                                        position="after"
                                        ev:event="DOMActivate"/>
                                    <xf:setvalue
                                        ref="place[index('repeatPlace')]/@type"
                                        value=""/>
                                    <xf:setvalue
                                        ref="place[index('repeatPlace')]/address"
                                        value=""/>
                                    <xf:setvalue
                                        ref="place[index('repeatPlace')]/complement"
                                        value=""/>
                                    <xf:setvalue
                                        ref="place[index('repeatPlace')]/parish"
                                        value=""/>
                                    <xf:setvalue
                                        ref="place[index('repeatPlace')]/city"
                                        value=""/>
                                    <xf:setvalue
                                        ref="place[index('repeatPlace')]/province"
                                        value=""/>
                                    <xf:setvalue
                                        ref="place[index('repeatPlace')]/owner"
                                        value=""/>
                                </xf:action>
                            </xf:trigger>
                        </xf:group>
                        <!--control-->
                        <pre>
                            <xf:output
                                value="serialize(description/places, 'yes')"/>
                        </pre>
                    </xf:case>
                    <xf:case
                        id="categories"
                        selected="false">
                        <xf:label>Types d'expertise</xf:label>
                        <xf:group
                            ref="instance('xprCategories')">
                            <xf:select
                                ref="category"
                                appearance="full">
                                <xf:label>Catégories d'expertise</xf:label>
                                <xf:item>
                                    <xf:label>Estimer la valeur des biens</xf:label>
                                    <xf:value>estimation</xf:value>
                                    <xf:action
                                        ev:event="xforms-select">
                                        <xf:insert
                                            context="instance('xprModel')/description/categories"
                                            origin="instance('xprCategories')/category[@type='estimation']"/>
                                    </xf:action>
                                    <xf:action
                                        ev:event="xforms-deselect">
                                        <xf:delete
                                            ref="instance('xprModel')/description/categories/category[@type='estimation']"/>
                                    </xf:action>
                                </xf:item>
                                <xf:item>
                                    <xf:label>Recevoir et évaluer le travail réalisé</xf:label>
                                    <xf:value>acceptation</xf:value>
                                    <xf:action
                                        ev:event="xforms-select">
                                        <xf:insert
                                            context="instance('xprModel')/description/categories"
                                            origin="instance('xprCategories')/category[@type='acceptation']"/>
                                    </xf:action>
                                    <xf:action
                                        ev:event="xforms-deselect">
                                        <xf:delete
                                            ref="instance('xprModel')/description/categories/category[@type='acceptation']"/>
                                    </xf:action>
                                </xf:item>
                                <xf:item>
                                    <xf:label>Enregistrer</xf:label>
                                    <xf:value>registration</xf:value>
                                    <xf:action
                                        ev:event="xforms-select">
                                        <xf:insert
                                            context="instance('xprModel')/description/categories"
                                            origin="instance('xprCategories')/category[@type='registration']"/>
                                    </xf:action>
                                    <xf:action
                                        ev:event="xforms-deselect">
                                        <xf:delete
                                            ref="instance('xprModel')/description/categories/category[@type='registration']"/>
                                    </xf:action>
                                </xf:item>
                                <xf:item>
                                    <xf:label>Départager</xf:label>
                                    <xf:value>settlement</xf:value>
                                    <xf:action
                                        ev:event="xforms-select">
                                        <xf:insert
                                            context="instance('xprModel')/description/categories"
                                            origin="instance('xprCategories')/category[@type='settlement']"/>
                                    </xf:action>
                                    <xf:action
                                        ev:event="xforms-deselect">
                                        <xf:delete
                                            ref="instance('xprModel')/description/categories/category[@type='settlement']"/>
                                    </xf:action>
                                </xf:item>
                                <xf:item>
                                    <xf:label>Évaluer les coûts à venir</xf:label>
                                    <xf:value>assessment</xf:value>
                                    <xf:action
                                        ev:event="xforms-select">
                                        <xf:insert
                                            context="instance('xprModel')/description/categories"
                                            origin="instance('xprCategories')/category[@type='assessment']"/>
                                    </xf:action>
                                    <xf:action
                                        ev:event="xforms-deselect">
                                        <xf:delete
                                            ref="instance('xprModel')/description/categories/category[@type='assessment']"/>
                                    </xf:action>
                                </xf:item>
                            </xf:select>
                            <xf:input
                                bind="designation"
                                incremental="true">
                                <xf:label>Désignation</xf:label>
                            </xf:input>
                            <xf:select1
                                bind="designationRubric"
                                appearance="full">
                                <xf:label>En rubrique</xf:label>
                                <xf:item>
                                    <xf:label>oui</xf:label>
                                    <xf:value>true</xf:value>
                                </xf:item>
                                <xf:item>
                                    <xf:label>non</xf:label>
                                    <xf:value>false</xf:value>
                                </xf:item>
                            </xf:select1>
                        </xf:group>
                        <!--control-->
                        <pre>
                            <xf:output
                                value="serialize(description/categories, 'yes')"/>
                        </pre>
                    </xf:case>
                    
                    <xf:case
                        id="procedure"
                        selected="false">
                        <xf:label>Procédure et cadre de l’expertise</xf:label>
                        <xf:group
                            ref="description/procedure">
                            <xf:group
                                ref="framework">
                                <xf:select1
                                    bind="frameworkType"
                                    appearance="full">
                                    <!--@quest je ne suis pas certain qu'il y a besoin de détailler autant ? (juste besoin de A-B1-B2A-B2B-C)-->
                                    <!--@todo ajouter un output pour le texte de framework-->
                                    <!--@rmq voir si on peut passer par un petit modèle de raisonnement pour garder la logique B-B2-B2a-->
                                    <!--@todo à défaut, mettre un message d'alerte si B ou B2 sont cochés-->
                                    <xf:label>Procédure</xf:label>
                                    <xf:item>
                                        <xf:label>A/ Commun accord des parties</xf:label>
                                        <xf:value>a</xf:value>
                                        <xf:action
                                            ev:event="xforms-select">
                                            <xf:setvalue
                                                ref="parent::framework">Commun accord des parties</xf:setvalue>
                                        </xf:action>
                                    </xf:item>
                                    <xf:choices>
                                        <xf:label>B/ Saisie du lieutenant civil (ou autre, à préciser)</xf:label>
                                        <xf:item>
                                            <xf:label>B1/ Requête auprès du LC pour qu’il demande une expertise</xf:label>
                                            <xf:value>b1</xf:value>
                                            <xf:action
                                                ev:event="xforms-select">
                                                <xf:setvalue
                                                    ref="parent::framework">Requête auprès du lieutenant civil pour qu’il demande une expertise</xf:setvalue>
                                            </xf:action>
                                        </xf:item>
                                    </xf:choices>
                                    <xf:choices>
                                        <xf:label>B2/ Le LC est saisi dans le cadre d’une procédure</xf:label>
                                        <xf:item>
                                            <xf:label>B2a/ LC saisi dans le cadre d’une procédure (Les parties nomment chacune leur expert ou un expert commun)</xf:label>
                                            <xf:value>b2a</xf:value>
                                            <xf:action
                                                ev:event="xforms-select">
                                                <xf:setvalue
                                                    ref="parent::framework">Le lieutenant civil est saisi dans le cadre d’une procédure (les parties nomment chacune leur expert ou un expert en commun)</xf:setvalue>
                                            </xf:action>
                                        </xf:item>
                                        <xf:item>
                                            <xf:label>B2b/ LC saisi dans le cadre d’une procédure (Le LC nomme un ou deux experts)</xf:label>
                                            <xf:value>b2b</xf:value>
                                            <xf:action
                                                ev:event="xforms-select">
                                                <xf:setvalue
                                                    ref="parent::framework">Le lieutenant civil est saisi dans le cadre d’une procédure (le lieutenant civil nomme un ou deux experts)</xf:setvalue>
                                            </xf:action>
                                        </xf:item>
                                    </xf:choices>
                                    <!--@todo comment faire pour préciser si ce n'est pas le LC ?-->
                                    <xf:item>
                                        <xf:label>C/ Cas problématique</xf:label>
                                        <xf:value>c</xf:value>
                                        <xf:action
                                            ev:event="xforms-select">
                                            <xf:setvalue
                                                ref="parent::framework">Cas problématique</xf:setvalue>
                                        </xf:action>
                                    </xf:item>
                                </xf:select1>
                            </xf:group>
                            
                            <xf:group
                                ref="origination">
                                <xf:label>Origine de l'expertise</xf:label>
                                <xf:select1
                                    bind="originationType">
                                    <xf:label>Déclenchement de l’expertise</xf:label>
                                    <xf:item>
                                        <xf:label>Les parties</xf:label>
                                        <xf:value>parties</xf:value>
                                        <xf:action
                                            ev:event="xforms-select">
                                            <xf:setvalue
                                                ref="ancestor::origination"
                                                value="'Les parties'"/>
                                        </xf:action>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Une institution</xf:label>
                                        <xf:value>institution</xf:value>
                                        <xf:action
                                            ev:event="xforms-select">
                                            <xf:setvalue
                                                ref="ancestor::origination"
                                                value="'Une institution'"/>
                                        </xf:action>
                                    </xf:item>
                                </xf:select1>
                            </xf:group>
                            
                            <xf:group
                                ref="sentences">
                                <xf:label>Intervention d'une institution</xf:label>
                                <xf:repeat
                                    id="repeatSentence"
                                    bind="sentence"
                                    appearance="full">
                                    <xf:input
                                        ref="orgName"
                                        incremental="true">
                                        <xf:label>Description de l'institution</xf:label>
                                    </xf:input>
                                    <xf:repeat
                                        id="repeatDateSentence"
                                        nodeset="date">
                                        <xf:input
                                            ref=".">
                                            <xf:label>Date</xf:label>
                                        </xf:input>
                                        <xf:trigger>
                                            <xf:label>Supprimer une date</xf:label>
                                            <xf:delete
                                                nodeset="."
                                                at="1"
                                                ev:event="DOMActivate"
                                                if="count(//description/procedure/sentences/sentence/date) > 1"/>
                                        </xf:trigger>
                                    </xf:repeat>
                                    <xf:trigger>
                                        <xf:label>Ajouter une date</xf:label>
                                        <xf:action
                                            ev:event="DOMActivate">
                                            <xf:insert
                                                nodeset="date"
                                                at="index('repeatDateSentence')"
                                                position="after"
                                                ev:event="DOMActivate"/>
                                            <xf:setvalue
                                                ref="date[index('repeatDateSentence')]"
                                                value=""/>
                                        </xf:action>
                                    </xf:trigger>
                                    <xf:trigger>
                                        <xf:label>Supprimer une institution</xf:label>
                                        <xf:delete
                                            nodeset="."
                                            at="1"
                                            ev:event="DOMActivate"
                                            if="count(//description/procedure/sentences/sentence) > 1"/>
                                    </xf:trigger>
                                </xf:repeat>
                                <!--@todo si l'on a renseigné une première institution avec plusieurs sentences, lorsqu'on ajoute une institution, le même nombre de sentence est copié => le remettre à 1-->
                                <xf:trigger>
                                    <xf:label>Ajouter une institution</xf:label>
                                    <xf:action
                                        ev:event="DOMActivate">
                                        <xf:insert
                                            nodeset="sentence"
                                            at="index('repeatSentence')"
                                            position="after"
                                            ev:event="DOMActivate"/>
                                        <xf:setvalue
                                            ref="sentence[index('repeatSentence')]/orgName"
                                            value=""/>
                                        <xf:setvalue
                                            ref="sentence[index('repeatSentence')]/date"
                                            value=""/>
                                    </xf:action>
                                </xf:trigger>
                            </xf:group>
                            
                            <xf:group
                                ref="case">
                                <xf:input
                                    bind="case"
                                    incremental="true">
                                    <!--@todo mettre une zone de texte ?-->
                                    <xf:label>Cause de l'expertise</xf:label>
                                </xf:input>
                            </xf:group>
                            
                            <xf:group
                                ref="instance('xprObjects')">
                                <xf:select
                                    ref="object"
                                    appearance="full">
                                    <!--@bug il existe l'attribut selection="open" pour ces cas mais il ne semble pas fonctionner. Il permet de préciser une valeur qui ne serait pas dans la liste.-->
                                    <!-- https://sourceforge.net/p/xsltforms/mailman/message/24465876/ -->
                                    <xf:label>Objet de l'expertise</xf:label>
                                    <xf:item>
                                        <xf:label>Maison</xf:label>
                                        <xf:value>house</xf:value>
                                        <xf:action
                                            ev:event="xforms-select">
                                            <xf:insert
                                                context="instance('xprModel')/description/procedure/objects"
                                                origin="instance('xprObjects')/object[@type='house']"/>
                                        </xf:action>
                                        <xf:action
                                            ev:event="xforms-deselect">
                                            <xf:delete
                                                ref="instance('xprModel')/description/procedure/objects/object[@type='house']"/>
                                        </xf:action>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Terrain</xf:label>
                                        <xf:value>plot</xf:value>
                                        <xf:action
                                            ev:event="xforms-select">
                                            <xf:insert
                                                context="instance('xprModel')/description/procedure/objects"
                                                origin="instance('xprObjects')/object[@type='plot']"/>
                                        </xf:action>
                                        <xf:action
                                            ev:event="xforms-deselect">
                                            <xf:delete
                                                ref="instance('xprModel')/description/procedure/objects/object[@type='plot']"/>
                                        </xf:action>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Ensemble de bâtiments</xf:label>
                                        <xf:value>buildings</xf:value>
                                        <xf:action
                                            ev:event="xforms-select">
                                            <xf:insert
                                                context="instance('xprModel')/description/procedure/objects"
                                                origin="instance('xprObjects')/object[@type='buildings']"/>
                                        </xf:action>
                                        <xf:action
                                            ev:event="xforms-deselect">
                                            <xf:delete
                                                ref="instance('xprModel')/description/procedure/objects/object[@type='buildings']"/>
                                        </xf:action>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Domaine, terres, fief</xf:label>
                                        <xf:value>territory</xf:value>
                                        <xf:action
                                            ev:event="xforms-select">
                                            <xf:insert
                                                context="instance('xprModel')/description/procedure/objects"
                                                origin="instance('xprObjects')/object[@type='territory']"/>
                                        </xf:action>
                                        <xf:action
                                            ev:event="xforms-deselect">
                                            <xf:delete
                                                ref="instance('xprModel')/description/procedure/objects/object[@type='territory']"/>
                                        </xf:action>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Mur</xf:label>
                                        <xf:value>wall</xf:value>
                                        <xf:action
                                            ev:event="xforms-select">
                                            <xf:insert
                                                context="instance('xprModel')/description/procedure/objects"
                                                origin="instance('xprObjects')/object[@type='wall']"/>
                                        </xf:action>
                                        <xf:action
                                            ev:event="xforms-deselect">
                                            <xf:delete
                                                ref="instance('xprModel')/description/procedure/objects/object[@type='wall']"/>
                                        </xf:action>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Fosse d'aisance</xf:label>
                                        <xf:value>cesspool</xf:value>
                                        <xf:action
                                            ev:event="xforms-select">
                                            <xf:insert
                                                context="instance('xprModel')/description/procedure/objects"
                                                origin="instance('xprObjects')/object[@type='cesspool']"/>
                                        </xf:action>
                                        <xf:action
                                            ev:event="xforms-deselect">
                                            <xf:delete
                                                ref="instance('xprModel')/description/procedure/objects/object[@type='cesspool']"/>
                                        </xf:action>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Puits</xf:label>
                                        <xf:value>well</xf:value>
                                        <xf:action
                                            ev:event="xforms-select">
                                            <xf:insert
                                                context="instance('xprModel')/description/procedure/objects"
                                                origin="instance('xprObjects')/object[@type='well']"/>
                                        </xf:action>
                                        <xf:action
                                            ev:event="xforms-deselect">
                                            <xf:delete
                                                ref="instance('xprModel')/description/procedure/objects/object[@type='well']"/>
                                        </xf:action>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Autre</xf:label>
                                        <xf:value>other</xf:value>
                                        <xf:action
                                            ev:event="xforms-select">
                                            <xf:insert
                                                context="instance('xprModel')/description/procedure/objects"
                                                origin="instance('xprObjects')/object[@type='other']"/>
                                        </xf:action>
                                        <xf:action
                                            ev:event="xforms-deselect">
                                            <xf:delete
                                                ref="instance('xprModel')/description/procedure/objects/object[@type='other']"/>
                                        </xf:action>
                                    </xf:item>
                                </xf:select>
                                <xf:input
                                    ref="instance('xprModel')/description/procedure/objects/object[@type='other']"><xf:label>Autre, à préciser</xf:label></xf:input>
                            </xf:group>
                        </xf:group>
                        <!--control-->
                        <pre>
                            <xf:output
                                value="serialize(description/procedure, 'yes')"/>
                        </pre>
                    </xf:case>
                    <xf:case
                        id="participants"
                        selected="false">
                        <xf:label>Acteurs de l'expertise</xf:label>
                        <xf:group
                            ref="description/participants/experts">
                            <!--@todo au pluriel ?-->
                            <xf:label>Expert</xf:label>
                            <xf:repeat
                                id="repeatExpert"
                                bind="expert"
                                appearance="full">
                                <xf:label>Patronyme</xf:label>
                                <xf:input
                                    ref="name/surname"
                                    incremental="true">
                                    <xf:label>Nom</xf:label>
                                </xf:input>
                                <xf:input
                                    ref="name/forename"
                                    incremental="true">
                                    <xf:label>Prénom</xf:label>
                                </xf:input>
                                <xf:input
                                    ref="title"
                                    incremental="true">
                                    <xf:label>Dénomination de l’expert dans l'acte</xf:label>
                                </xf:input>
                                <xf:select1
                                    ref="@context">
                                    <xf:label>Expert nommé en</xf:label>
                                    <xf:item>
                                        <xf:label>premier lieu</xf:label>
                                        <xf:value>primary</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>tiers expert</xf:label>
                                        <xf:value>third-party</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>indéterminé</xf:label>
                                        <xf:value>unknown</xf:value>
                                    </xf:item>
                                </xf:select1>
                                <xf:select1
                                    ref="@appointment">
                                    <xf:label>Expert nommé</xf:label>
                                    <xf:item>
                                        <xf:label>d’office (par le lieutenant civil)</xf:label>
                                        <xf:value>court-appointed</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>par les parties</xf:label>
                                        <xf:value>appointed</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>indéterminé</xf:label>
                                        <xf:value>unknown</xf:value>
                                    </xf:item>
                                </xf:select1>
                                <xf:trigger>
                                    <xf:label>Supprimer un expert</xf:label>
                                    <xf:delete
                                        nodeset="."
                                        at="1"
                                        ev:event="DOMActivate"
                                        if="count(//description/participants/experts/expert) > 1"/>
                                </xf:trigger>
                            </xf:repeat>
                            <xf:trigger>
                                <xf:label>Ajouter un expert</xf:label>
                                <xf:action
                                    ev:event="DOMActivate">
                                    <xf:insert
                                        nodeset="expert"
                                        at="index('repeatExpert')"
                                        position="after"
                                        ev:event="DOMActivate"/>
                                    <xf:setvalue
                                        ref="expert[index('repeatExpert')]/@context"
                                        value=""/>
                                    <xf:setvalue
                                        ref="expert[index('repeatExpert')]/@appointment"
                                        value=""/>
                                    <xf:setvalue
                                        ref="expert[index('repeatExpert')]/name/surname"
                                        value=""/>
                                    <xf:setvalue
                                        ref="expert[index('repeatExpert')]/name/forename"
                                        value=""/>
                                    <xf:setvalue
                                        ref="expert[index('repeatExpert')]/title"
                                        value=""/>
                                </xf:action>
                            </xf:trigger>
                        </xf:group>
                        <!--control-->
                        <pre>
                            <xf:output
                                value="serialize(description/participants/experts, 'yes')"/>
                        </pre>
                        <xf:group
                            ref="description/participants/clerks">
                            <!--@todo au pluriel ?-->
                            <xf:label>Greffier</xf:label>
                            <xf:repeat
                                id="repeatClerk"
                                bind="clerk"
                                appearance="full">
                                <xf:label>Patronyme</xf:label>
                                <xf:input
                                    ref="name/surname"
                                    incremental="true">
                                    <xf:label>Nom</xf:label>
                                </xf:input>
                                <xf:input
                                    ref="name/forename"
                                    incremental="true">
                                    <xf:label>Prénom</xf:label>
                                </xf:input>
                                <xf:trigger>
                                    <xf:label>Supprimer un greffier</xf:label>
                                    <xf:delete
                                        nodeset="."
                                        at="1"
                                        ev:event="DOMActivate"
                                        if="count(//description/participants/clerks/clerk) > 1"/>
                                </xf:trigger>
                            </xf:repeat>
                            <xf:trigger>
                                <xf:label>Ajouter un greffier</xf:label>
                                <xf:action
                                    ev:event="DOMActivate">
                                    <xf:insert
                                        nodeset="clerk"
                                        at="index('repeatClerk')"
                                        position="after"
                                        ev:event="DOMActivate"/>
                                    <xf:setvalue
                                        ref="clerk[index('repeatClerk')]/name/surname"
                                        value=""/>
                                    <xf:setvalue
                                        ref="clerk[index('repeatClerk')]/name/forename"
                                        value=""/>
                                </xf:action>
                            </xf:trigger>
                        </xf:group>
                        <!--control-->
                        <pre>
                            <xf:output
                                value="serialize(description/participants/clerks, 'yes')"/>
                        </pre>
                        <xf:group
                            ref="description/participants/parties">
                            <!--@todo au pluriel ?-->
                            <xf:label>Partie</xf:label>
                            <xf:repeat
                                id="repeatParty"
                                bind="party"
                                appearance="full">
                                <xf:repeat
                                    id="repeatPerson"
                                    nodeset="person"
                                    appearance="full">
                                    <xf:label>Patronyme</xf:label>
                                    <xf:input
                                        ref="name/surname"
                                        incremental="true">
                                        <xf:label>Nom</xf:label>
                                    </xf:input>
                                    <xf:input
                                        ref="name/forename"
                                        incremental="true">
                                        <xf:label>Prénom</xf:label>
                                    </xf:input>
                                    <xf:input
                                        ref="occupation">
                                        <xf:label>Qualité, profession</xf:label>
                                    </xf:input>
                                    <xf:trigger>
                                        <xf:label>Supprimer une personne</xf:label>
                                        <xf:delete
                                            nodeset="."
                                            at="1"
                                            ev:event="DOMActivate"
                                            if="count(//description/participants/parties/party/person) > 1"/>
                                    </xf:trigger>
                                </xf:repeat>
                                <xf:trigger>
                                    <xf:label>Ajouter une personne</xf:label>
                                    <xf:action
                                        ev:event="DOMActivate">
                                        <xf:insert
                                            nodeset="person"
                                            at="index('repeatPerson')"
                                            position="after"
                                            ev:event="DOMActivate"/>
                                        <xf:setvalue
                                            ref="person[index('repeatPerson')]/name/surname"
                                            value=""/>
                                        <xf:setvalue
                                            ref="person[index('repeatPerson')]/name/forename"
                                            value=""/>
                                        <xf:setvalue
                                            ref="person[index('repeatPerson')]/occupation"
                                            value=""/>
                                    </xf:action>
                                </xf:trigger>
                                <!--@todo @ref-->
                                <!--<xf:select1>
                                    <xf:label>Partie</xf:label>
                                    <xf:item>
                                        <xf:label>Requérante</xf:label>
                                        <xf:value>claimant</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Opposante</xf:label>
                                        <xf:value>opposing</xf:value>
                                    </xf:item>
                                </xf:select1>-->
                                <!--@todo @ref-->
                                <!--<xf:select1>
                                    <xf:label>Qualification individuelle</xf:label>
                                    <xf:item>
                                        <xf:label>Entrepreneur</xf:label>
                                        <!-\-@todo-\->
                                        <xf:value>contractor</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:value>Propriétaire</xf:value>
                                        <xf:label>owner</xf:label>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Copropriétaire</xf:label>
                                        <xf:value>joint-owner</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Commanditaire</xf:label>
                                        <xf:value>limited-partner</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Héritier</xf:label>
                                        <xf:value>heir</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Voisin</xf:label>
                                        <xf:value>neighbour</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Locataire</xf:label>
                                        <xf:value>tenant</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Principal locataire</xf:label>
                                        <xf:value>main-tenant</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Créancier</xf:label>
                                        <xf:value>creditor</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Débiteur</xf:label>
                                        <xf:value>mortgagor</xf:value>
                                    </xf:item>
                                    <xf:item>
                                        <xf:label>Fermier judiciaire</xf:label>
                                        <!-\-@todo-/->
                                        <xf:value>fermier</xf:value>
                                    </xf:item>
                                </xf:select1>-->
                                <!--@todo faire un repeat pour les représentants et procureurs ?-->
                                <xf:group
                                    ref="representative">
                                    <xf:label>Représentants</xf:label>
                                    <xf:repeat
                                        id="repeatRepresentative"
                                        nodeset="."
                                        appearance="full">
                                        <xf:label>Patronyme</xf:label>
                                        <xf:input
                                            ref="name/surname"
                                            incremental="true">
                                            <xf:label>Nom</xf:label>
                                        </xf:input>
                                        <xf:input
                                            ref="name/forename"
                                            incremental="true">
                                            <xf:label>Prénom</xf:label>
                                        </xf:input>
                                        <xf:input
                                            ref="occupation">
                                            <xf:label>Qualité, profession</xf:label>
                                        </xf:input>
                                        <xf:trigger>
                                            <xf:label>Supprimer un représentant</xf:label>
                                            <xf:delete
                                                nodeset="."
                                                at="1"
                                                ev:event="DOMActivate"
                                                if="count(//description/participants/parties/party/representative) > 1"/>
                                        </xf:trigger>
                                    </xf:repeat>
                                    <xf:trigger>
                                        <xf:label>Ajouter un représentant</xf:label>
                                        <xf:action
                                            ev:event="DOMActivate">
                                            <xf:insert
                                                nodeset="."
                                                at="index('repeatRepresentative')"
                                                position="after"
                                                ev:event="DOMActivate"/>
                                            <xf:setvalue
                                                ref="representative[index('repeatRepresentative')]/name/surname"
                                                value=""/>
                                            <xf:setvalue
                                                ref="representative[index('repeatRepresentative')]/name/forename"
                                                value=""/>
                                            <xf:setvalue
                                                ref="representative[index('repeatRepresentative')]/occupation"
                                                value=""/>
                                        </xf:action>
                                    </xf:trigger>
                                </xf:group>
                                
                                <xf:group
                                    ref="prosecutor">
                                    <xf:label>Procureur</xf:label>
                                    <xf:repeat
                                        id="repeatProsecutor"
                                        nodeset="."
                                        appearance="full">
                                        <xf:label>Patronyme</xf:label>
                                        <xf:input
                                            ref="name/surname"
                                            incremental="true">
                                            <xf:label>Nom</xf:label>
                                        </xf:input>
                                        <xf:input
                                            ref="name/forename"
                                            incremental="true">
                                            <xf:label>Prénom</xf:label>
                                        </xf:input>
                                        <xf:trigger>
                                            <xf:label>Supprimer un procureur</xf:label>
                                            <xf:delete
                                                nodeset="."
                                                at="1"
                                                ev:event="DOMActivate"
                                                if="count(//description/participants/parties/party/prosecutor) > 1"/>
                                        </xf:trigger>
                                    </xf:repeat>
                                    <xf:trigger>
                                        <xf:label>Ajouter un procureur</xf:label>
                                        <xf:action
                                            ev:event="DOMActivate">
                                            <xf:insert
                                                nodeset="."
                                                at="index('repeatProsecutor')"
                                                position="after"
                                                ev:event="DOMActivate"/>
                                            <xf:setvalue
                                                ref="prosecutor[index('repeatProsecutor')]/name/surname"
                                                value=""/>
                                            <xf:setvalue
                                                ref="prosecutor[index('repeatProsecutor')]/name/forename"
                                                value=""/>
                                        </xf:action>
                                    </xf:trigger>
                                </xf:group>
                                <xf:trigger>
                                    <xf:label>Supprimer une partie</xf:label>
                                    <xf:delete
                                        nodeset="."
                                        at="1"
                                        ev:event="DOMActivate"
                                        if="count(//description/participants/parties/party) > 1"/>
                                </xf:trigger>
                            </xf:repeat>
                            <xf:trigger>
                                <xf:label>Ajouter une partie</xf:label>
                                <xf:action
                                    ev:event="DOMActivate">
                                    <xf:insert
                                        nodeset="party"
                                        at="index('repeatParty')"
                                        position="after"
                                        ev:event="DOMActivate"/>
                                    <!--@todo set value-->
                                </xf:action>
                            </xf:trigger>
                        </xf:group>
                        <!--control-->
                        <pre>
                            <xf:output
                                value="serialize(description/participants/parties, 'yes')"/>
                        </pre>
                        <xf:group
                            ref="description/participants/craftmen">
                            <!--@quest au pluriel ?-->
                            <xf:label>Entrepreneur, architecte ou maître d'œuvre</xf:label>
                            <xf:label>Greffier</xf:label>
                            <xf:repeat
                                id="repeatCraftman"
                                bind="craftman"
                                appearance="full">
                                <xf:label>Patronyme</xf:label>
                                <xf:input
                                    ref="name/surname"
                                    incremental="true">
                                    <xf:label>Nom</xf:label>
                                </xf:input>
                                <xf:input
                                    ref="name/forename"
                                    incremental="true">
                                    <xf:label>Prénom</xf:label>
                                </xf:input>
                                <xf:input
                                    ref="occupation"
                                    incremental="true">
                                    <xf:label>profession</xf:label>
                                </xf:input>
                                <xf:trigger>
                                    <xf:label>Supprimer un entrepreneur, architecte ou maître d'œuvre</xf:label>
                                    <xf:delete
                                        nodeset="."
                                        at="1"
                                        ev:event="DOMActivate"
                                        if="count(//description/participants/craftmen/craftman) > 1"/>
                                </xf:trigger>
                            </xf:repeat>
                            <xf:trigger>
                                <xf:label>Ajouter un entrepreneur, architecte ou maître d'œuvre</xf:label>
                                <xf:action
                                    ev:event="DOMActivate">
                                    <xf:insert
                                        nodeset="craftman"
                                        at="index('repeatCraftman')"
                                        position="after"
                                        ev:event="DOMActivate"/>
                                    <xf:setvalue
                                        ref="craftman[index('repeatCraftman')]/name/surname"
                                        value=""/>
                                    <xf:setvalue
                                        ref="craftman[index('repeatCraftman')]/name/forename"
                                        value=""/>
                                    <xf:setvalue
                                        ref="craftman[index('repeatCraftman')]/occupation"
                                        value=""/>
                                </xf:action>
                            </xf:trigger>
                        </xf:group>
                        <!--control-->
                        <pre>
                            <xf:output
                                value="serialize(description/participants/craftmen, 'yes')"/>
                        </pre>
                    </xf:case>
                    <xf:case
                        id="conclusions"
                        selected="false">
                        <xf:label>Conclusions ou dispositifs de l'expertise</xf:label>
                        <xf:group
                            ref="description/conclusions">
                            <xf:select1
                                bind="agreement"
                                appearance="full">
                                <xf:item>
                                    <xf:label>Accord</xf:label>
                                    <xf:value>Accord</xf:value>
                                    <xf:action
                                        ev:event="xforms-select">
                                        <xf:setvalue
                                            bind="agreementType">agreement</xf:setvalue>
                                    </xf:action>
                                </xf:item>
                                <xf:item>
                                    <xf:label>Désaccord</xf:label>
                                    <xf:value>Désaccord</xf:value>
                                    <xf:action
                                        ev:event="xforms-select">
                                        <xf:setvalue
                                            bind="agreementType">disagreement</xf:setvalue>
                                    </xf:action>
                                </xf:item>
                                <xf:item>
                                    <xf:label>Sans conclusion</xf:label>
                                    <xf:value>Sans conclusion</xf:value>
                                    <xf:action
                                        ev:event="xforms-select">
                                        <xf:setvalue
                                            bind="agreementType">noConclusion</xf:setvalue>
                                    </xf:action>
                                </xf:item>
                            </xf:select1>
                            <xf:repeat
                                id="repeatOpinion"
                                bind="opinion">
                                <xf:label>Transcription de toutes les conclusions ou dispositifs d'experts</xf:label>
                                <xf:textarea
                                    ref="."
                                    incremental="true">
                                    <xf:label>Conclusions</xf:label>
                                </xf:textarea>
                                <xf:trigger>
                                    <xf:label>Supprimer une conclusion</xf:label>
                                    <xf:delete
                                        nodeset="."
                                        at="1"
                                        ev:event="DOMActivate"
                                        if="count(//description/conclusions/opinion) > 1"/>
                                </xf:trigger>
                            </xf:repeat>
                            <xf:trigger>
                                <xf:label>Ajouter une conclusion</xf:label>
                                <xf:action
                                    ev:event="DOMActivate">
                                    <xf:insert
                                        nodeset="opinion"
                                        at="index('repeatOpinion')"
                                        position="after"
                                        ev:event="DOMActivate"/>
                                    <xf:setvalue
                                        ref="opinion[index('repeatOpinion')]"
                                        value=""/>
                                </xf:action>
                            </xf:trigger>
                            <xf:input
                                bind="estimation">
                                <xf:label>Montant global (pour les estimations)</xf:label>
                            </xf:input>
                            
                        </xf:group>
                        <!--control-->
                        <pre>
                            <xf:output
                                value="serialize(description/conclusions, 'yes')"/>
                        </pre>
                    </xf:case>
                    
                    <xf:case
                        id=""
                        selected="false">
                        <xf:label></xf:label>
                        <xf:group
                            ref="">
                        </xf:group>
                    </xf:case>
                </xf:switch>
            </form>
            <!--<pre>
                <xf:output
                    value="serialize(., 'yes')"/>
            </pre>-->
        </body>
    </html>
    )
};


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
    processing-instruction xml-stylesheet {'href="files/xsltforms/xsltforms/xsltforms.xsl"', 'type="text/xsl"'},
    <?css-conversion no?>,
    <html
        xmlns="http://www.w3.org/1999/xhtml"
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
            <!-- XForms data models -->
            <xf:model>
                <xf:instance>
                    <expertise
                        xmlns="">
                        <reference
                            id='reference'/>
                    </expertise>
                </xf:instance>
                <xf:submission
                    id="submit"
                    resource="form00"
                    method="get"
                    replace="instance"/>
            
            </xf:model>
        </head>
        <body>
            <header>
                <h1>Form00</h1>
            </header>
            <main>
                <section>
                    <h2>Form</h2>
                    <xf:input
                        ref="/expertise/reference"
                        incremental="true">
                        <xf:label>Input</xf:label>
                    </xf:input>
                    <xf:submit
                        submission="submit">
                        <xf:label>Envoyer</xf:label>
                    </xf:submit>
                </section>
                <section>
                    <h2>Output</h2>
                    <xf:output
                        value="/expertise/reference"/>
                </section>
                <section>
                    <h2>XML</h2>
                    <pre>
                        <xf:output
                            value="serialize(., 'yes')"/>
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
    processing-instruction xml-stylesheet {'href="files/xsltforms/xsltforms/xsltforms.xsl"', 'type="text/xsl"'},
    <?css-conversion no?>,
    <html
        xmlns="http://www.w3.org/1999/xhtml"
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
            <!-- XForms data models -->
            <xf:model>
                <xf:instance>
                    <expertise
                        xmlns="">
                        <reference
                            id='reference'/>
                    </expertise>
                </xf:instance>
                <xf:submission
                    id="submit"
                    resource="form01Result"
                    method="post"
                    replace="instance"/>
            
            </xf:model>
        </head>
        <body>
            <header>
                <h1>Form00</h1>
            </header>
            <main>
                <section>
                    <h2>Form</h2>
                    <xf:input
                        ref="/expertise/reference"
                        incremental="true">
                        <xf:label>Input</xf:label>
                    </xf:input>
                    <xf:submit
                        submission="submit">
                        <xf:label>Envoyer</xf:label>
                    </xf:submit>
                </section>
                <section>
                    <h2>Output</h2>
                    <xf:output
                        value="/expertise/reference"/>
                </section>
                <section>
                    <h2>XML</h2>
                    <pre>
                        <xf:output
                            value="serialize(., 'yes')"/>
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
%rest:path('/files/{$file=.+}')
function xpr:file($file as xs:string) as item()+ {
    let $path := file:base-dir() || 'files/' || $file
    return
        (
        web:response-header(map {'media-type': web:content-type($path)}),
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
