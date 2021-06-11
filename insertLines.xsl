<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:alto="http://www.loc.gov/standards/alto/ns-v4#"
    exclude-result-prefixes="xs tei"
    version="2.0">
    
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    
    <!-- Get the collection of ALTO -->
    <xsl:variable name="myURI">
        <xsl:value-of select="tokenize(base-uri(), '/')[position() != last()]" separator="/"/>
        <xsl:text>/?select=*.xml</xsl:text>
    </xsl:variable>
    
    <xsl:variable name="myCollection" select="collection($myURI)"/>
    
    <!-- Create a list of doc indexes -->
    <xsl:variable name="docsIndexes">
        <index>
            <xsl:for-each select="$myCollection">
                <xsl:sort select="tokenize(document-uri(.), '/')[last()]"/>
             <srcDoc>
                 <srcUri>
                     <xsl:value-of select="document-uri()"/>
                 </srcUri>
                 <index>
                     <xsl:value-of select="position()"/>
                 </index>
             </srcDoc>
            </xsl:for-each>
        </index>
    </xsl:variable>
    
    <!-- Get the TEI -->
    <xsl:variable name="teiText" select="/tei:TEI/tei:text"/>
    
    
    <xsl:template match="@* | node()" mode="alto">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="alto"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- UNCOMMENT TO SWITCH TO ALLOGRAPHETIC -->
    
    <!-- Version originale -->
    <!--<xsl:import href="libs/tei_to_txt_orig.xsl"/>-->
    <!-- Conservation des accents, abréviations, ponctuation -->
    <!--<xsl:import href="libs/tei_to_txt_orig_all_chars.xsl"/>-->
    <!-- GRAPHEMATIC VERSION -->
    <xsl:import href="libs/tei_to_txt_abbr-graphem.xsl"/>
    
    <xsl:template match="/">
        <!-- iterate over alto -->
        <xsl:for-each select="$myCollection[descendant::alto:alto]">
            <xsl:copy-of select="$docsIndexes"/>
            <!-- Create output document -->
            <!--<xsl:value-of select="position()"/>
            <xsl:value-of select="concat(document-uri(.), '_out.xml')"/>-->
            <xsl:variable name="outfile">
                <xsl:value-of select="tokenize(document-uri(.), '/')[position() != last()]" separator="/"/>
                <xsl:text>/out/</xsl:text>
                <xsl:value-of select="tokenize(document-uri(.), '/')[last()]"/>
            </xsl:variable>
            <xsl:result-document href="{$outfile}">
                <xsl:apply-templates select="descendant::alto:alto" mode="alto"/>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- Consider only default text lines -->
    <xsl:template match="alto:TextLine[@TAGREFS = ancestor::alto:alto/alto:Tags/alto:OtherTag[@LABEL='Default']/@ID]" mode="alto">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <!-- Now, the crucial part: get the text line -->
            <!-- Get current document index, this is going to get a bit ugly -->
            <!--<xsl:value-of select="$myURI/*[. = document-uri(/)]"/>-->
            <!--<xsl:value-of select="document-uri(/)"/>-->
            <xsl:variable name="myURI" select="document-uri(/)"/>
            <xsl:variable name="myPage"
                select="$docsIndexes/descendant::srcDoc[srcUri = $myURI]/index"/>
            <xsl:variable name="myLine" 
                select="count(preceding::alto:TextLine[@TAGREFS = ancestor::alto:alto/alto:Tags/alto:OtherTag[@LABEL='Default']/@ID]
                ) + 1"/>
            <!-- Get the line in fulltext. Ugly too ;) -->
            <!-- DEBUG -->
            <!--<xsl:for-each select="$myPage">
                <xsl:text>p. </xsl:text>
                <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:text> and  </xsl:text>
                <xsl:for-each select="$myLine">
                <xsl:text>l. </xsl:text>
                <xsl:value-of select="."/>
                </xsl:for-each>-->
                <!-- /DEBUG -->
                <!-- WEIIIIRD behaviour with duplication of element -->
                <!--<xsl:copy-of select="$teiText/tei:body/descendant::tei:pb[count(preceding::tei:pb)+1 = $myPage]/following::tei:lb[$myLine]"/>-->
            <!-- DON'T BLOODY ASK ME WHY BUT 
                $teiText/descendant::tei:pb[$myPage] creates duplicates
                and
                $teiText/descendant::tei:pb[count(preceding::tei:pb)+1 = $myPage] not
            -->
            <xsl:apply-templates select="alto:Shape"/>
            <xsl:element name="String" namespace="http://www.loc.gov/standards/alto/ns-v4#">
                <xsl:attribute name="CONTENT">
                    <xsl:variable name="myContent">
                        <content>
                            <xsl:choose>
                                <xsl:when test="$teiText/descendant::tei:pb[count(preceding::tei:pb)+1 = $myPage]/following::tei:lb[$myLine]">
                                    <xsl:apply-templates select="$teiText/descendant::element()[
                                        generate-id(preceding-sibling::tei:lb[1])
                                        =
                                        generate-id($teiText/descendant::tei:pb[count(preceding::tei:pb)+1 = $myPage]/following::tei:lb[$myLine])
                                        ]"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>[ERROR]</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </content>
                    </xsl:variable>                              
                    <xsl:apply-templates select="
                        normalize-unicode(normalize-space($myContent))
                        " mode="#default"/>
                </xsl:attribute>
                <!-- Get the other attributes -->
                <xsl:copy-of select="alto:String/@*[not(local-name() = 'CONTENT')]"/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>