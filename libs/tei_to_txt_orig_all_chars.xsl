<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:import href="tei_to_txt_orig.xsl"/>
    
    <!-- Modifications des règles qu'on ne veut pas de cette feuille -->
    <xsl:template match="tei:orig[. = '&#769;']">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="tei:pc[@type='orig']">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:l">
        <xsl:apply-templates select="descendant::tei:w[not(ancestor::tei:corr)]"/>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
    
    <!-- Normalisation unicode -->
    <xsl:template match="tei:w">
        <xsl:variable name="texte">
            <xsl:apply-templates/>
        </xsl:variable>
        <xsl:value-of select="normalize-unicode($texte, 'NFC')"/>
        <!-- If it is not the last on the line -->
        <xsl:if
            test="generate-id(.) != generate-id(ancestor::tei:l/descendant::tei:w[position() = last()]) and not(@rend)">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>