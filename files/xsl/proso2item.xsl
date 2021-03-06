<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xpr="xpr"
  xmlns:eac="eac"
  exclude-result-prefixes="xs"
  extension-element-prefixes="ixsl"
  version="3.1"
  >
  
  <xsl:variable name="path" select="ixsl:get(ixsl:window(), 'location.href')"/>
  <xsl:variable name="content" select="doc(substring-before($path, '/view'))"/>
  
  <xsl:template match="/">
        
    <xsl:result-document href="#title" method="ixsl:replace-content">
      <xsl:text>Fiche n° </xsl:text>
      <xsl:value-of select="$content//eac:eac-cpf/@xml:id"/>
    </xsl:result-document> 
    
    <xsl:result-document href="#experts">
      <xsl:for-each select="$content//eac:eac-cpf">
        <header>
          <h2>
            <xsl:text>Fiche n° </xsl:text>
            <xsl:value-of select="$content//eac:eac-cpf/@xml:id"/>
          </h2>
        </header>
        <ul>
          <li>
            <xsl:text>Id : </xsl:text>
            <xsl:value-of select="normalize-space(eac:cpfDescription/eac:identity/eac:entityId)"/>
          </li>
          <li>
            <xsl:text>Nom : </xsl:text>
            <xsl:value-of select="normalize-space(eac:cpfDescription/eac:identity/eac:nameEntry[1]/eac:part[1])"/>
          </li>
          <li>
            <xsl:text>Date de naissance : </xsl:text>
            <xsl:value-of select="normalize-space(eac:cpfDescription/eac:description/eac:existDates/eac:dateRange/eac:fromDate/@standardDate)"/>
           </li>
            <li>
              <xsl:text>Date de décès : </xsl:text>
              <xsl:value-of select="normalize-space(eac:cpfDescription/eac:description/eac:existDates/eac:dateRange/eac:toDate/@standardDate)"/>
            </li>
            <li>
              <xsl:text>Type d’entité : </xsl:text>
              <xsl:value-of select="normalize-space(eac:cpfDescription/eac:identity/eac:entityType)"/>
            </li>
            <li><a href="{'/xpr/biographies/' || @xml:id || '/view'}">Voir</a> | <a href="{'/xpr/biographies/' || @xml:id || '/modify'}">Modifier</a></li>
          </ul>
        </xsl:for-each>
    </xsl:result-document>
    
  </xsl:template>
  
  <xsl:template match="th" mode="ixsl:onclick">
    <xsl:variable name="colNr" as="xs:integer"  select="count(preceding-sibling::th)+1"/>  
    <xsl:apply-templates select="ancestor::table[1]" mode="sort">
      <xsl:with-param name="colNr" select="$colNr"/>
      <xsl:with-param name="dataType" select="if (@data-type='number') then 'number' else 'text'"/>
      <xsl:with-param name="ascending" select="not(../../@data-order=$colNr)"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="table" mode="sort">
    <xsl:param name="colNr" as="xs:integer" required="yes"/>
    <xsl:param name="dataType" as="xs:string" required="yes"/>
    <xsl:param name="ascending" as="xs:boolean" required="yes"/>
    <xsl:result-document href="#{@id}" method="ixsl:replace-content">
      <thead data-order="{if ($ascending) then $colNr else -$colNr}">
        <xsl:copy-of select="thead/tr"/>
      </thead>
      <tbody>
        <xsl:perform-sort select="tbody/tr">
          <xsl:sort select="td[$colNr]" 
            data-type="{$dataType}" 
            order="{if ($ascending) then 'ascending' else 'descending'}"/>
        </xsl:perform-sort>
      </tbody>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="input[@type='checkbox'][@name='genre']" mode="ixsl:onclick">
    <xsl:variable name="this" select="."/>
    <!--<xsl:message>Checked <xsl:value-of select="ixsl:get($this, 'checked')"/></xsl:message>-->
    <xsl:for-each select="//div[@id='books']//tr[@data-genre=$this/@value]">
      <ixsl:set-style name="display" 
        select="if (ixsl:get($this,'checked')) 
        then 'table-row' 
        else 'none'"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="th" mode="ixsl:onmouseover">
    <xsl:for-each select="//div[@id='sortToolTip']">
      <ixsl:set-style name="left" select="concat(ixsl:get(ixsl:event(), 'clientX') + 30, 'px')"/>
      <ixsl:set-style name="top" select="concat(ixsl:get(ixsl:event(), 'clientY') - 15, 'px')"/>
      <ixsl:set-style name="visibility" select="'visible'"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="th" mode="ixsl:onmouseout">
    <xsl:for-each select="//div[@id='sortToolTip']">
      <ixsl:set-style name="visibility" select="'hidden'"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="send-request">
    <xsl:variable name="request" select="
      map{
      'method': 'GET',
      'href': 'http://localhost:8984/xpr/expertises/z1j828d011'
      } "/>
    <ixsl:schedule-action http-request="$request">
      <xsl:call-template name="handle-response"/>
    </ixsl:schedule-action>
  </xsl:template>
  
  <xsl:template name="handle-response">
    <xsl:context-item as="map(*)" use="required"/>
    <xsl:for-each select="?body">
      <xsl:call-template name="process-response-body"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="process-response-body">
    <h2>Hello</h2>
  </xsl:template>
  
</xsl:transform>	
