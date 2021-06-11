<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei" version="2.0">

    <xsl:output encoding="UTF-8" indent="no" method="text"/>
    
    <xsl:param name="decoupage">aucun</xsl:param><!-- Valeurs possibles: par-feuillet, par-recto, aucun -->

    <xsl:template match="/">
        <!-- Changer cette variable pour changer le préfixe des fichiers de sortie -->
        <xsl:variable name="filename" select="substring-before(tokenize(base-uri(), '/')[last()], '.')"/>
        <xsl:choose>
            <xsl:when test="$decoupage = 'aucun'">
                <xsl:result-document href="{$filename}.txt">
                    <!-- JBC: take only body, to avoid picking verse quotations from other fragments or mss
        inside the front and back. -->
                    <xsl:apply-templates select="descendant::tei:body/descendant::tei:l"/>
                </xsl:result-document>
            </xsl:when>
            <xsl:when test="$decoupage = 'par-feuillet'">
                <xsl:for-each select="descendant::tei:body/descendant::tei:pb[not(matches(@n,'v'))]">
                    <xsl:variable name="n" select="@n"/>
                    <xsl:result-document href="{$filename}_{$n}.txt">
                        <xsl:variable name="pbid" select="generate-id(.)"/>
                        <xsl:apply-templates
                            select="following::tei:l[generate-id(preceding::tei:pb[1]) = $pbid or generate-id(preceding::tei:pb[2]) = $pbid]"
                        />
                    </xsl:result-document>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$decoupage = 'par-recto'">
                <xsl:for-each select="descendant::tei:pb">
                    <xsl:variable name="n" select="@n"/>
                    <xsl:result-document href="{$filename}_{$n}.txt">
                        <xsl:variable name="pbid" select="generate-id(.)"/>
                        <xsl:apply-templates
                            select="following::tei:l[generate-id(preceding::tei:pb[1]) = $pbid]"
                        />
                    </xsl:result-document>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$decoupage = 'par-colonne'">
                <xsl:for-each select="descendant::tei:cb">
                    <xsl:variable name="n" select="@n"/>
                    <xsl:result-document href="{$filename}_{$n}.txt">
                        <xsl:variable name="cbid" select="generate-id(.)"/>
                        <xsl:apply-templates
                            select="following::tei:l[generate-id(preceding::tei:cb[1]) = $cbid]"
                        />
                    </xsl:result-document>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
        <!--        <xsl:for-each select="descendant::tei:pb">
            <xsl:variable name="n" select="@n"/>
            <xsl:result-document href="{$filename}_{$n}.txt">
                <xsl:variable name="pbid" select="generate-id(.)"/>
                <xsl:apply-templates
                    select="following::tei:l[generate-id(preceding::tei:pb[1]) = $pbid]"/>
            </xsl:result-document>
        </xsl:for-each>-->

        <!--        <xsl:for-each-group select="descendant::tei:l" group-starting-with="tei:pb">
            <xsl:result-document href="{$filename}_{current-group()/tei:pb/@n}.txt">
                <xsl:apply-templates select="current-group()"/>
            </xsl:result-document>
        </xsl:for-each-group>      -->

        <!--<xsl:apply-templates select="descendant::tei:l"/>-->
    </xsl:template>

    <!-- Configuration particulière pour les BDD d'analyse allogr.   -->
    <xsl:template match="tei:del"/>

    <!-- Suppression des accents, tildes, lettres suscrites, ponctuation
    => cette règle est sans doute à reverser dans la feuille teiverscsv (car cette feuille sera en facteur commun avec d'autres transformations)
    -->
   <!-- <xsl:template match="tei:orig[. = '&#769;']"/>
    <xsl:template match="text()">
        <xsl:value-of 
            select="translate(., '&#x0303;⁹&#x035B;&#x1DD1;&#x0367;&#x0365;&#x0363;&#870;&#868;&#869;&#775;', '')"/>
    </xsl:template>-->
    <!-- Idem -->
    <xsl:template match="tei:pc[@type='orig']"/>

    <xsl:template match="tei:l">
        <xsl:text>§</xsl:text>
        <xsl:apply-templates select="descendant::tei:w[not(ancestor::tei:corr)]"/><!-- 18  oct. 2016: Pourquoi avais-je commenté cette ligne?
        Quelle était l'objectif de l'autre version ? Faut-il créer un paramètre ?
        -->
        <!-- Pour avoir la ponctuation -->
        <!--<xsl:apply-templates select="descendant::tei:w[not(ancestor::tei:corr or ancestor::tei:num or ancestor::tei:persName or ancestor::tei:name)] | descendant::tei:pc[@type='orig' and not(ancestor::tei:w or ancestor::tei:num or ancestor::tei:persName or ancestor::tei:name)] | descendant::tei:num | descendant::tei:persName | descendant::tei:name"/>-->
        <xsl:text>§</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="tei:w">
        <xsl:apply-templates/>
        <!-- If it is not the last on the line -->
        <xsl:if
            test="generate-id(.) != generate-id(ancestor::tei:l/descendant::tei:w[position() = last()]) and not(@rend)">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:hi[matches(@rend, 'detach')]">
        <xsl:apply-templates/>
        <xsl:text> </xsl:text>
        <!-- Ajout d'un espace après les initiales détachées: paraît se justifier car souvent, le copiste traite la seconde lettre de la ligne comme une lettre de début de mot -->
    </xsl:template>


    <!--    <xsl:template match="tei:lb">
        <xsl:text>&#10;</xsl:text>
    </xsl:template>-->

    <xsl:template match="tei:space[@quantity='0.5']">
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:space">
        <xsl:text> </xsl:text>
    </xsl:template>

    <!--    <xsl:template match="tei:del">
        <xsl:text>&lt;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>></xsl:text>
    </xsl:template>-->
    
    
    <!-- peut-être qu'agir au niveau du choice serait préférable -->
    <xsl:template match="tei:choice">
        <xsl:apply-templates select="tei:abbr|tei:orig|tei:sic"/>
    </xsl:template>

    <xsl:template match="tei:corr"/>

    <xsl:template match="tei:note"/>

    <xsl:template match="tei:gap"/>

    <xsl:template match="tei:reg"/>

    <xsl:template match="tei:expan"/>
    
    <!-- Suppression de la ponctuation éditoriale -->
    <xsl:template match="tei:pc[@type='supplied']"/>    

    <!--    <xsl:template match="//tei:add[@place='above']">
        <sup><xsl:apply-templates/></sup>
    </xsl:template>
    
    <xsl:template match="//tei:add[@place='margin']">
       <xsl:text>**</xsl:text><xsl:apply-templates/>
    </xsl:template>-->

</xsl:stylesheet>
