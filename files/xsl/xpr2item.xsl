<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xpr="xpr"
  exclude-result-prefixes="xs"
  extension-element-prefixes="ixsl"
  version="3.1"
  >
  
  <!-- This style sheet displays the books.xml file.  -->
  
  
  <xsl:template match="/">
    <!-- @todo améliorer dates dans le titre -->
    <xsl:result-document href="#title" method="ixsl:replace-content">
      <xsl:value-of select="'Fiche ' || //xpr:expertise/xpr:sourceDesc/xpr:idno[@type='unitid'] || ', dossier n° ' || //xpr:expertise/xpr:sourceDesc/xpr:idno[@type='item'] || ' (' || //xpr:expertise/xpr:description/xpr:sessions/xpr:date[1]/@when || ')'"/>
    </xsl:result-document> 
    
    <xsl:result-document href="#expertises">
      <header>
        <xsl:apply-templates select="//xpr:expertise/xpr:sourceDesc"/>
      </header>
      <article>
        <xsl:apply-templates select="xpr:description"/>
      </article>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="xpr:sourceDesc">
    <ul>
      <xsl:for-each select="xpr:idno">
        <li>
          <xsl:value-of select="@type"/>
          <xsl:text> : </xsl:text>
          <xsl:value-of select="."/>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>
  <xsl:template match="description">
    
  </xsl:template>
  
</xsl:transform>	
