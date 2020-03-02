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
  
  <xsl:variable name="path" select="ixsl:get(ixsl:window(), 'location.href')"/>
  <xsl:variable name="content" select="doc(substring-before($path, '/view'))"/>  
  
  <xsl:template match="/">
    <!-- @todo améliorer dates dans le titre -->
    <xsl:result-document href="#title" method="ixsl:replace-content">
      <xsl:choose>
        <xsl:when test="(count($content//xpr:expertise) &lt; 2)">
          <xsl:value-of select="'Fiche ' || //xpr:expertise/xpr:sourceDesc/xpr:idno[@type='unitid'] || ', dossier n° ' || //xpr:expertise/xpr:sourceDesc/xpr:idno[@type='item'] || ' (' || //xpr:expertise/xpr:description/xpr:sessions/xpr:date[1]/@when || ')'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Liste détaillée</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:result-document> 
    
    <xsl:result-document href="#expertises">
      <xsl:for-each select="$content//xpr:expertise">
        <article>
          <header>
            <xsl:apply-templates select="//xpr:expertise/xpr:sourceDesc"/>
          </header>
          <div>
            <xsl:apply-templates select="xpr:description"/>
          </div>
        </article>
      </xsl:for-each>
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
      <xsl:apply-templates select="xpr:physDesc/xpr:facsimile"/>
      <xsl:apply-templates select="xpr:physDesc/xpr:extent"/>
      <xsl:apply-templates select="xpr:physDesc/xpr:appendices"/>
    </ul>
  </xsl:template>
  <xsl:template match="xpr:physDesc/xpr:facsimile">
    <li>
      <xsl:text>Vues :</xsl:text>
      <xsl:value-of select="xpr:from"/>
      <xsl:text> à </xsl:text>
      <xsl:value-of select="xpr:to"/>
    </li>
  </xsl:template>
  <xsl:template match="xpr:physDesc/xpr:extent[normalize-space(.)!='']">
    <li>
      <xsl:text>Nombre de cahiers : </xsl:text>
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:apply-templates select="@*"/>
    </li>
  </xsl:template>
  <xsl:template match="xpr:physDesc/xpr:extent/@sketch">
    <li>
      <xsl:text>Croquis sur le pv : </xsl:text>
      <xsl:choose>
        <xsl:when test=".='false'">non</xsl:when>
        <xsl:otherwise>oui</xsl:otherwise>
      </xsl:choose>
    </li>
  </xsl:template>
  <xsl:template match="xpr:physDesc/xpr:appendices/xpr:appendice[normalize-space(xpr:extent)!='']">
    <li>
      <xsl:text>Annexe : </xsl:text>
      <xsl:value-of select="(xpr:extent[normalize-space(.)!=''], xpr:type[normalize-space(.)!='']) => string-join(' ')"/>
      <xsl:if test="xpr:desc[normalize-space(.)!=''] or xpr:note[normalize-space(.)!='']">
        <xsl:text>[</xsl:text>
        <xsl:value-of select="(xpr:desc[normalize-space(.)!=''], xpr:note[normalize-space(.)!='']) => string-join('. ')"/>
        <xsl:text>]</xsl:text>
      </xsl:if>
    </li>
  </xsl:template>
  
  <xsl:template match="description">
    
  </xsl:template>
  
</xsl:transform>	
