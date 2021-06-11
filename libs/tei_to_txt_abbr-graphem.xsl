<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:import href="tei_to_txt_orig.xsl"/>
    
    <!-- Without allographs but with abreviations -->
    <xsl:template match="tei:choice">
        <xsl:apply-templates select="tei:abbr|tei:reg|tei:sic"/>
    </xsl:template>
    
    
    <!-- Remove allographs -->
    <xsl:template match="tei:orig"/>
    
    <!-- But, we keep original diacritics -->
    <xsl:template match="tei:orig[not(parent::tei:choice)]">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- Keep normalised letter forms -->
    <xsl:template match="tei:reg">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- And remove editorial diacritics -->
    <xsl:template match="tei:reg[not(parent::tei:choice)]"/>
    
    
    
    
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
    <!-- Here, we want decomposed normalisation, for character counts -->
    <xsl:template match="tei:w">
        <xsl:variable name="texte">
            <xsl:apply-templates/>
        </xsl:variable>
        <xsl:value-of select="translate(normalize-unicode($texte, 'NFD'), ' ', '')"/>
        <!-- If it is not the last on the line -->
        <xsl:if
            test="generate-id(.) != generate-id(ancestor::tei:l/descendant::tei:w[position() = last()])">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>