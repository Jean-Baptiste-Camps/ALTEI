<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs xhtml tei"
    version="2.0">
    
<!--    À refaire, car elle sort de l'html, là-->
    
    <xsl:output encoding="UTF-8" method="text"/>
    
    <xsl:template match="/">
<!--        <html>
            <head><meta charset="UTF-8"/></head>
            <body><xsl:apply-templates/></body>
        </html>-->
        <!-- JBC: take only body, to avoid picking verse quotations from other fragments
        inside the front and back. 
        -->
        <xsl:apply-templates select="descendant::tei:body/descendant::tei:l"/>
    </xsl:template>
    
    
    <!--<xsl:template match="tei:space[@quantity='0.5']">
        <xsl:text>  </xsl:text>
    </xsl:template>-->
    <xsl:template match="tei:pc[@type='orig']"/>
    
    <xsl:template match="tei:pc[@type='supplied']">
        <xsl:apply-templates/>
        <xsl:text> </xsl:text>
    </xsl:template>


<!--    <xsl:template match="tei:lg">
        <!-\-<b>[<xsl:value-of select="@n"/>]</b> -\-><br/>
        <!-\-<table>-\->
        <xsl:apply-templates/>
        <!-\-</table>-\->
    </xsl:template>-->
    
<!--    <xsl:template match="tei:hi">
        <!-\-<b>-\->
            <xsl:apply-templates/>
        <!-\-</b>-\->
    </xsl:template>-->
    
<!--    <xsl:template match="tei:l">
        <tr>
            <td>
                <b><xsl:call-template name="lb"/></b>
            </td>
            <td>
                <xsl:apply-templates/>
            </td>
        </tr>
    </xsl:template>-->

<!-- Sans numéros de page-->
    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>
    
<!--Avec numéros de page -->
  <!--  <xsl:template name="lb">
        <xsl:variable name="ndepage">
            <xsl:number count="tei:lb" level="any"/>
        </xsl:variable>
        <xsl:if test="$ndepage mod 4 = 0">
            <xsl:value-of select="$ndepage"/>
        </xsl:if>
    </xsl:template>-->
    
  
    
    <xsl:template match="tei:del"/>
    
    
    <xsl:template match="tei:corr"/>
    <!--<xsl:template match="tei:sic"></xsl:template>-->
    
    <!--<xsl:template match="tei:note">
        [[<xsl:apply-templates/>]]
    </xsl:template>-->
    <xsl:template match="tei:note"/>
    <xsl:template match="tei:head"/>
    <xsl:template match="tei:gap"/>
    <!--
    <xsl:template match="tei:gap">
        <xsl:text>[...]</xsl:text>
    </xsl:template>-->
    
    <xsl:template match="tei:teiHeader"/>
    
    <xsl:template match="tei:orig"/>
    
    <xsl:template match="tei:abbr"/>
    
    <xsl:template match="tei:subst">
        <xsl:apply-templates select="tei:add"/>
    </xsl:template>
   
   <!-- gestion espacement -->
   
    <xsl:template match="tei:l">
        <xsl:apply-templates/>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
    
    <!-- <xsl:template match="tei:w[@rend='elision']">
        <xsl:apply-templates/><xsl:text>'</xsl:text>
    </xsl:template>
    <xsl:template match="tei:w[@rend='aggl']">
        <xsl:apply-templates/><xsl:text>  </xsl:text>
    </xsl:template>-->
    <xsl:template match="tei:w">
        <xsl:variable name="texte">
            <xsl:apply-templates/>
        </xsl:variable>
        <xsl:value-of select="normalize-unicode($texte, 'NFC')"/>
        <!-- Gestion alambiquée des élisions, car l'encodage devrait etre amélioré -->
        <xsl:if test="@rend='elision' and not(following-sibling::element()[1][local-name(.) = 'pc' and @type = 'supplied'])">
            <xsl:text>'</xsl:text>
        </xsl:if>
        <xsl:text> </xsl:text>
    </xsl:template>
   
    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    
</xsl:stylesheet>