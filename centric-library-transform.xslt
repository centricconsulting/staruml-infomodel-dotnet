<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output encoding="UTF-8" method="text" omit-xml-declaration="yes" indent="no" />
  <xsl:strip-space elements="*"/>

<xsl:template match="/">

  <!-- column headers --> 
  <xsl:text disable-output-escaping="yes">Subject&#x9;</xsl:text>
  <xsl:text disable-output-escaping="yes">Entity&#x9;</xsl:text>
  <xsl:text disable-output-escaping="yes">Component&#x9;</xsl:text>
  <xsl:text disable-output-escaping="yes">Element&#x9;</xsl:text>
  <xsl:text disable-output-escaping="yes">Multiplicity&#x9;</xsl:text>
  <xsl:text disable-output-escaping="yes">Element Class&#x9;</xsl:text>
  <xsl:text disable-output-escaping="yes">Reference Entity&#x9;</xsl:text>
  <xsl:text disable-output-escaping="yes">Grain Flag&#x9;</xsl:text>
  <xsl:text disable-output-escaping="yes">Realization&#x9;</xsl:text>
  <xsl:text disable-output-escaping="yes">Description&#xa;</xsl:text>

  <!-- all instances are called separately --> 
  <xsl:for-each select="//ownedElements[_type='UMLClass' and ancestor::ownedElements[_type='UMLSubsystem'][1]/name !='Attribute Classes']">
    <xsl:sort select="ancestor::ownedElements[_type='UMLSubsystem'][1]/name" data-type="text"/>
    <xsl:sort select="name" data-type="text"/>
    <xsl:call-template name="entity" />
  </xsl:for-each>

  <!-- all instances are called separately --> 
  <xsl:for-each select="//literals">
    <xsl:sort select="//ownedElements[_id=./stereotype/_ref]/name" data-type="text"/>
    <xsl:call-template name="instance" />
  </xsl:for-each>

</xsl:template>


  <!-- ##################################################################################### -->
  <!-- CREATE ENTITY ROWS -->
  <!-- ##################################################################################### -->
  
  <xsl:template name="entity" match="ownedElements">

    <xsl:variable name="stereotype-class-id" select="stereotype/_ref" />

    <!-- Subject Column --> 
    <xsl:value-of select="ancestor::ownedElements[_type='UMLSubsystem'][1]/name"/>
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Entity Column --> 
    <xsl:value-of select="name"/>
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Component Column --> 
    <xsl:text disable-output-escaping="yes">Entity&#x9;</xsl:text>

    <!-- Element Column --> 
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Multiplicity Column-->
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>    

    <!-- Element Class Column --> 
    <xsl:text disable-output-escaping="yes">[Reference]&#x9;</xsl:text>

    <!-- Reference Column-->
    <xsl:value-of select="name"/>
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Grain Column-->
    <xsl:if test="count(./attribute[isUnique='true'])=0">Grain</xsl:if>
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Realization Column--> 
    <xsl:choose>
    <xsl:when test="not(visibility)">Physical</xsl:when>
    <xsl:otherwise>Virtual</xsl:otherwise>
    </xsl:choose>
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>  

    <!-- Description Column --> 
    <xsl:value-of select="normalize-space(documentation)"/>

    <!-- END OF LINE -->
    <xsl:text disable-output-escaping="yes">&#xa;</xsl:text> 
  
    <!-- Express children of entity -->
    <!-- ### Entity >> Attributes ###  -->
    <xsl:for-each select=".//attributes">
      <xsl:call-template name="attribute" />
    </xsl:for-each>

    <!-- ### Entity >> Measures ###  -->
    <xsl:for-each select=".//operations">
      <xsl:call-template name="measure" />
    </xsl:for-each>

  </xsl:template>

  <!-- ##################################################################################### -->
  <!-- CREATE ATTRIBUTE ROWS --> 
  <!-- ##################################################################################### -->
  
  <xsl:template name="attribute" match="attributes">

    <!-- Subject Column --> 
    <xsl:value-of select="ancestor::ownedElements[_type='UMLSubsystem'][1]/name"/>
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Entity Column --> 
    <xsl:value-of select="ancestor::ownedElements[_type='UMLClass'][1]/name"/>
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Component Column --> 
    <xsl:text disable-output-escaping="yes">Attribute&#x9;</xsl:text>

    <!-- Element Column --> 
    <xsl:value-of select="name"/>
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Multiplicity Column-->
    <xsl:choose>
    <xsl:when test="not(multiplicity)">1</xsl:when>
    <xsl:otherwise><xsl:value-of select="multiplicity"/></xsl:otherwise>
    </xsl:choose>
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Element Class Column --> 
    <xsl:choose>
      <xsl:when test="sterotype/_ref">[Reference]</xsl:when>
      <xsl:when test="type/_ref"><xsl:value-of select="//ownedElements[_id=./type/_ref]/name"/></xsl:when>
      <xsl:otherwise>{Missing}</xsl:otherwise>
    </xsl:choose>
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Reference Column-->
    <xsl:value-of select="//ownedElements[_id=./type/_ref]/name"/>
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>


    <!-- Grain Column-->
    <xsl:if test="isUnique='true'">Grain</xsl:if>
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Realization Column--> 
    <xsl:choose>
    <xsl:when test="not(visibility) and not(ancestor::ownedElements[_type='UMLClass'][1]/visibility) and (not(multiplicity) or multiplicity = '0..1')">Physical</xsl:when>
    <xsl:otherwise>Virtual</xsl:otherwise>
    </xsl:choose>
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Description Column --> 
    <xsl:value-of select="normalize-space(documentation)"/>
    
    <!-- END OF LINE -->
    <xsl:text disable-output-escaping="yes">&#xa;</xsl:text>   
    
  </xsl:template>

  <!-- ##################################################################################### -->
  <!-- CREATE MEASURE ROWS -->  
  <!-- ##################################################################################### -->
  
  <xsl:template name="measure" match="ownedElements">

    <!-- Subject Column --> 
    <xsl:value-of select="ancestor::ownedElements[_type='UMLSubsystem'][1]/name"/>
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Entity Column --> 
    <xsl:value-of select="ancestor::ownedElements[_type='UMLClass'][1]/name"/>
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Component Column -->     
    <xsl:text disable-output-escaping="yes">Measure&#x9;</xsl:text>

        <!-- Element Column --> 
    <xsl:value-of select="name"/>
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Multiplicity Column-->
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>    

    <!-- Element Class Column --> 
    <xsl:choose>
      <xsl:when test="sterotype/_ref">[Reference]</xsl:when>
      <xsl:when test="type/_ref"><xsl:value-of select="//ownedElements[_id=./type/_ref]/name"/></xsl:when>
      <xsl:otherwise>{Missing}</xsl:otherwise>
    </xsl:choose>
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Reference Column-->
    <xsl:value-of select="//entity[@id=current()/@reference-object-id]/name"/>
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Grain Column-->
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Realization Column--> 
    <xsl:text disable-output-escaping="yes">Virtual&#x9;</xsl:text>    
    
    <!-- Description Column -->
    <xsl:value-of select="normalize-space(documentation)"/>
    <xsl:if test="string-length(specification)>0">
    <xsl:if test="string-length(description)>0"> </xsl:if>[Specification] <xsl:value-of select="normalize-space(specification)" />
    </xsl:if>
    
    <!-- END OF LINE -->  
    <xsl:text disable-output-escaping="yes">&#xa;</xsl:text>       
    
  </xsl:template>   

  <!-- ##################################################################################### -->
  <!-- CREATE INSTANCE ROWS -->  
  <!-- ##################################################################################### -->
  
  <xsl:template name="instance" match="literals">

    <xsl:variable name="stereotype-class-id" select="ancestor::ownedElements[_type='UMLEnumeration'][1]/stereotype/_ref" />

    <!-- Subject Column -->
    <xsl:choose>
      <xsl:when test="//ownedElements[_type='UMLClass' and _id=$stereotype-class-id]/ancestor::ownedElements[_type='UMLSubsystem'][1]">
      <xsl:value-of select="//ownedElements[_type='UMLClass' and _id=$stereotype-class-id]/ancestor::ownedElements[_type='UMLSubsystem'][1]/name"/></xsl:when>
      <xsl:otherwise>{Unknown}</xsl:otherwise>
    </xsl:choose>
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Entity Column -->
    <xsl:choose>
      <xsl:when test="//ownedElements[_type='UMLClass' and _id=$stereotype-class-id]">
      <xsl:value-of select="//ownedElements[_type='UMLClass' and _id=$stereotype-class-id]/name"/></xsl:when>
      <xsl:otherwise>{<xsl:value-of select="ancestor::ownedElements[_type='UMLEnumeration'][1]/name"/>}</xsl:otherwise>
    </xsl:choose>
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Component Column -->     
    <xsl:text disable-output-escaping="yes">Instance&#x9;</xsl:text>

    <!-- Element Column --> 
    <xsl:value-of select="name"/>
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Multiplicity Column-->
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Element Class Column --> 
    <xsl:text disable-output-escaping="yes">[Reference]&#x9;</xsl:text>

    <!-- Reference Column-->
    <xsl:choose>
      <xsl:when test="//ownedElements[_type='UMLClass' and _id=$stereotype-class-id]">
      <xsl:value-of select="//ownedElements[_type='UMLClass' and _id=$stereotype-class-id]/name"/></xsl:when>
      <xsl:otherwise>{<xsl:value-of select="ancestor::ownedElements[_type='UMLEnumeration'][1]/name"/>}</xsl:otherwise>
    </xsl:choose>
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>

    <!-- Grain Column -->
    <xsl:text disable-output-escaping="yes">&#x9;</xsl:text>    

    <!-- Realization Column--> 
    <xsl:text disable-output-escaping="yes">Virtual&#x9;</xsl:text>   

    <!-- Description Column --> 
    <xsl:value-of select="normalize-space(documentation)"/>
    
    <!-- END OF LINE -->
    <xsl:text disable-output-escaping="yes">&#xa;</xsl:text>      
    
  </xsl:template>   
 

</xsl:stylesheet>
