<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:msxsl="urn:schemas-microsoft-com:xslt"
  xmlns:user="urn:schemas-microsoft-com:user"
  exclude-result-prefixes="#default msxsl xsl user">

<xsl:output encoding="UTF-8" method="text" omit-xml-declaration="yes" indent="no" />
<!-- xsl:output encoding="UTF-8" method="xml" omit-xml-declaration="no" indent="yes" / -->
<xsl:strip-space elements="*" />

<!-- ##################################################################################### -->
<!-- TEMPLATE: TOP LEVEL -->
<!-- Generates the Model Xml and sends to output template -->
<!-- ##################################################################################### -->

<xsl:template match="/">

<!-- NOTE:
  This code will generate the xml as an output. 
  Also requires activating the xsl:output with method="xml". 

  <xsl:call-template name="build-model-xml"/>

-->

<xsl:variable name="model-xml">
  <xsl:call-template name="build-model-xml"/>
</xsl:variable>

<xsl:apply-templates select="msxsl:node-set($model-xml)/model" mode="build-output"/>

</xsl:template>

<!-- ##################################################################################### -->
<!-- TEMPLATE: GENERATE OUTPUT -->
<!-- Generates the output using the Model Xml as an input (see DTD below) -->
<!-- ##################################################################################### -->

<!-- TEMPLATE: MODEL NODE -->
<xsl:template match="model" mode="build-output">
/* ##################################################################################
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

DOCUMENT INFORMATION  (<xsl:value-of select="count(subject/entity[@implement='true'])" /> Tables)

FILE:      <xsl:value-of select="file" />
MODEL:     <xsl:value-of select="name" />
AUTHOR:    <xsl:value-of select="author" />
MODIFIED:  <xsl:value-of select="modify-timestamp" />

Transform Generated on <xsl:value-of select="transform-timestamp" />

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
##################################################################################### */


<xsl:apply-templates select="subject" />
</xsl:template>

<!-- TEMPLATE: SUBJECT NODES -->
<xsl:template match="subject">
/* ##################################################################################
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

SUBJECT AREA: <xsl:value-of select="name" /> (<xsl:value-of select="count(entity[@implement='true'])" /> Tables)

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
##################################################################################### */

<xsl:apply-templates select="entity[@implement='true']" />
</xsl:template>

<!-- TEMPLATE: ENTITTY NODES -->
<xsl:template match="entity">
<xsl:variable name="table-name" select="user:GetTableName(name)" />
/* ##################################################################################
TABLE: <xsl:value-of select="$table-name" />
##################################################################################### */

CREATE TABLE dbo.[<xsl:value-of select="$table-name" />] (
  -- NAMED KEY COLUMN
  <xsl:value-of select="$table-name" />_key INT IDENTITY(1000,1)

  -- GRAIN COLUMNS<xsl:choose>
<xsl:when test="@infer-grain='true'">
, <xsl:value-of select="user:GetColumnPhrase(name, 'REFERENCE', name)" /> NOT NULL</xsl:when>
<xsl:otherwise>
  <xsl:for-each select="attribute[@implement='true' and @grain='true']" >
    <xsl:call-template name="column-phrase">
      <xsl:with-param name="grain" select="true()" /> 
      <xsl:with-param name="required" select="true()" />
    </xsl:call-template></xsl:for-each>
  </xsl:otherwise>
</xsl:choose>

  -- ATTRIBUTE COLUMNS - ENTITY REFERENCE <xsl:for-each
    select="attribute[@reference='true' and @implement='true' and not(@grain='true')]" >
    <xsl:call-template name="column-phrase">
      <xsl:with-param name="grain" select="false()" /> 
      <xsl:with-param name="required" select="false()" />
    </xsl:call-template></xsl:for-each>

  -- ATTRIBUTE COLUMNS - LITERALS<xsl:for-each
    select="attribute[not(@reference='true') and @implement='true' and not(@grain='true')]" >
    <xsl:call-template name="column-phrase" />
  </xsl:for-each>

/* ### BOILERPLATE BELOW THIS LINE ### */

  -- SOURCE COLUMNS
, source_uid VARCHAR(200)
, source_rev_timestamp DATETIME2
, source_rev_actor_desc VARCHAR(200)

  -- AUDIT BATCH KEY
, batch_key INT

  -- TEMPORAL COLUMNS
, version_begin_timestamp DATETIME2
    GENERATED ALWAYS AS ROW START
    CONSTRAINT dbo_<xsl:value-of select="$table-name" />_version_begin
    DEFAULT SYSUTCDATETIME() NOT NULL

, version_end_timestamp DATETIME2
    GENERATED ALWAYS AS ROW END
    CONSTRAINT dbo_<xsl:value-of select="$table-name" />_version_end
    DEFAULT CONVERT(DATETIME2,'9999-12-31 23:59:59') NOT NULL

, PERIOD FOR SYSTEM_TIME(
    version_begin_timestamp, version_end_timestamp)

  -- PRIMARY KEY ON GRAIN COLUMNS
, CONSTRAINT dbo_<xsl:value-of select="$table-name" />_pk PRIMARY KEY CLUSTERED (<xsl:choose>
<xsl:when test="@infer-grain='true'">
  <xsl:value-of select="user:GetColumnName(name, 'REFERENCE', name)" />
</xsl:when>
<xsl:otherwise>
  <xsl:for-each select="attribute[@implement='true' and @grain='true']" >
    <xsl:call-template name="column-name">
    <xsl:with-param name="position" select="position()" />
    </xsl:call-template>
  </xsl:for-each>
</xsl:otherwise>
</xsl:choose>)

) WITH (SYSTEM_VERSIONING = ON (
  HISTORY_TABLE = dbo.<xsl:value-of select="$table-name" />_version));

<!-- NOT IMPLEMENTED 
<xsl:apply-templates select="attribute" />
<xsl:apply-templates select="measure" />
<xsl:apply-templates select="instance" />
-->

</xsl:template>


<!-- NOT IMPLEMENTED -->
<!-- TEMPLATE: ATTRIBUTE NODES -->
<xsl:template match="attribute">
ATTRIBUTE: <xsl:value-of select="name" />
</xsl:template>

<!-- NOT IMPLEMENTED -->
<!-- TEMPLATE: MEASURES NODES -->
<xsl:template match="measure">
MEASURE: <xsl:value-of select="name" />
</xsl:template>

<!-- NOT IMPLEMENTED -->
<!-- TEMPLATE: INSTANCE NODES -->
<xsl:template match="instance">
INSTANCE: <xsl:value-of select="name" />
</xsl:template>



<!-- ##################################################################################### -->
<!-- TEMPLATES: SQL COLUMN GENERATION -->
<!-- ##################################################################################### -->

<xsl:template name="column-phrase" match="attributes">
<xsl:param name="grain" />
<xsl:param name="required" />
, <xsl:value-of select="user:GetColumnPhrase(name, type-name, reference-name)" />
<xsl:if test="$required"> NOT NULL</xsl:if>
<xsl:if test="not($grain) and @reference='true'"> DEFAULT 'UNKNOWN'</xsl:if>
</xsl:template>

<xsl:template name="column-name" match="attributes">
<xsl:param name="position" />
<xsl:if test="$position>1">, </xsl:if><xsl:value-of select="user:GetColumnName(name, type-name, reference-name)" />
</xsl:template>

<!-- ##################################################################################### -->
<!-- C# CODE -->
<!-- Provides support code for the output transformation -->
<!-- ##################################################################################### -->

<msxsl:script language="C#" implements-prefix="user">
  <msxsl:using namespace="System"/>
  <msxsl:assembly name="System.Core" />
  <msxsl:using namespace="System.Linq" />
  <msxsl:using namespace="System.Collections.Generic"/>
  <msxsl:using namespace="System.Text"/>  
  <msxsl:using namespace="System.Text.RegularExpressions"/>

<![CDATA[

public string GetTableName(String ClassName)
{
    String Result = FormatAsDatabaseObject(ClassName);
    return ApplyDatabaseAbbreviations(Result);
}

public string GetColumnName(String AttributeName, String AttributeClassName, String ReferenceAttributeName)
{
  // blend the attribute and reference attribute names
  if(!String.IsNullOrEmpty(ReferenceAttributeName))
  {
    AttributeName = BlendAttributeNames(AttributeName, ReferenceAttributeName);
    
    //override the Attribute Class for reference columns
    AttributeClassName = "REFERENCE";
  }

  String ColumnName = FormatAsDatabaseObject(AttributeName);

  // determine the AttributeClassInfo
  AttributeClassInfo aci = AttributeClassInfo.GetInfo(AttributeClassName);

  // assert the suffix
  if(aci != null) ColumnName = aci.AssertColumnSuffix(ColumnName);

  // apply abbreviations
  ColumnName = ApplyDatabaseAbbreviations(ColumnName);

  if(aci == null)
  {
    return ColumnName + " {Invalid Attribute Class: " + AttributeClassName + "}";
  }
  else
  {
    return ColumnName;
  }
}

public String BlendAttributeNames(String PrimaryAttributeName, String SecondaryAttributeName)
{

    if(PrimaryAttributeName.EndsWith(SecondaryAttributeName))
    {
      return PrimaryAttributeName;

    } else if(SecondaryAttributeName.StartsWith(PrimaryAttributeName) || SecondaryAttributeName.EndsWith(PrimaryAttributeName))
    {
      return SecondaryAttributeName;
    }
    else
    {
      return PrimaryAttributeName + " " + SecondaryAttributeName;
    }
}

public string GetColumnPhrase(String AttributeName, String AttributeClassName, String ReferenceAttributeName)
{
  String ColumnName = GetColumnName(AttributeName, AttributeClassName, ReferenceAttributeName);

  //override the Attribute Class for reference columns
  if(!String.IsNullOrEmpty(ReferenceAttributeName))
  {
    AttributeClassName = "REFERENCE";
  }

  // determine the AttributeClassInfo
  AttributeClassInfo aci = AttributeClassInfo.GetInfo(AttributeClassName);

  if(aci == null)
  {
    return ColumnName;
  }
  else
  {
    return aci.BuildColumnPhrase(ColumnName);
  }
}

private string FormatAsDatabaseObject(String Name)
{
    // perform basic formatting: trim and replace spaces with underscore
    String Result = Name.Trim().Replace(" ","_").ToLower();
    
    // remove non-alphanumeric characters
    Regex rgx = new Regex("[^a-zA-Z0-9_]");
    Result = rgx.Replace(Result, "");

    // collapse any occurrances of multiple underscores
    rgx = new Regex("[_]{2,100}");
    return rgx.Replace(Result, "_");
    
}

private String ApplyDatabaseAbbreviations(String Name)
{
  Dictionary<string, string> dictionary = new Dictionary<string, string>();

  dictionary.Add("transaction", "tran");
  dictionary.Add("premium", "prem");
  dictionary.Add("effective", "effect");
  dictionary.Add("collated", "coll");
  dictionary.Add("collate", "coll");
  dictionary.Add("headquarter", "hq");
  dictionary.Add("corporate", "corp");
  dictionary.Add("expired", "expire");
  dictionary.Add("expiration", "expire");
  dictionary.Add("classification", "class");
  dictionary.Add("workers_compensation", "wc");
  dictionary.Add("workers_comp", "wc");
  
  String WorkingName = Name.ToLower().Trim();

  foreach(KeyValuePair<string, string> abbr in dictionary)
  {
    if(WorkingName.IndexOf(abbr.Key) >= 0)
    {
      WorkingName = WorkingName.Replace(abbr.Key, abbr.Value);
    }
  }

  return WorkingName;
}

public class AttributeClassInfo
{
  public string Suffix {get; set;}
  public string[] VariantSuffixes {get; set;}
  public string DataType {get; set;}

  public AttributeClassInfo(string Suffix, string DataType, string[] VariantSuffixes = null)
  {
    this.Suffix = Suffix;
    this.DataType = DataType;
    this.VariantSuffixes = VariantSuffixes;
  }

  public string AssertColumnSuffix(String ColumnName)
  {

    // clean the name
    String WorkingName = ColumnName.Trim();

    // test if the asserted suffix is already in place
    if(WorkingName.EndsWith(this.Suffix))
    {
      return WorkingName;
    }
    // test if variant suffixes are being used, and then replace
    if(this.VariantSuffixes != null)
    {
      foreach(String VariantSuffix in this.VariantSuffixes)
      {
        if(WorkingName.EndsWith(VariantSuffix))
        {
          return WorkingName.Substring(0, WorkingName.Length-VariantSuffix.Length) + this.Suffix;
        }
      }
    }

    // append the asserted suffix
    return WorkingName + this.Suffix;

  }

  public string BuildColumnPhrase(String ColumnName)
  {
    return ColumnName + " " + this.DataType;
  }

  public static AttributeClassInfo GetInfo(string AttributeClassName)
  {

    // prepare the Attribute Class
    if(String.IsNullOrEmpty(AttributeClassName)) return null;
  
    switch(AttributeClassName.Trim().ToUpper())
    {
      case "REFERENCE":
        return new AttributeClassInfo("_uid", "VARCHAR(200)");

      case "DATE":
        return new AttributeClassInfo("_date", "DATE");

      case "TIMESTAMP":
        return new AttributeClassInfo("_timestamp", "DATETIME2", new String[] {"_dtm", "_date", "_datetime"});

      case "TIME ORDINAL":
        return new AttributeClassInfo("", "INT");

      case "NAME":
        return new AttributeClassInfo("_name", "VARCHAR(200)");

      case "DESCRIPTION":
        return new AttributeClassInfo("_desc", "VARCHAR(1000)", new String[] {"_description", "_name"});

      case "CODE":
        return new AttributeClassInfo("_code", "VARCHAR(20)");

      case "LOCATOR":
        return new AttributeClassInfo("_address", "VARCHAR(200)");

      case "CURRENCY": 
        return new AttributeClassInfo("_amount", "DECIMAL(20,12)", new String[] {"_amt", "_dollars", "_dollar"});

      case "QUANTITY":
        return new AttributeClassInfo("_quantity", "DECIMAL(20,12)", new String[] {"_qty", "_amount"});

      case "VALUE":
        return new AttributeClassInfo("_value", "FLOAT", new String[] {"_val", "_pct", "_percent","_percentage"});

      case "VALUE INTEGER":
        return new AttributeClassInfo("_value", "INT", new String[] {"_val", "_int", "_integer"});

      case "IDENTIFIER":
        return new AttributeClassInfo("_identifier", "VARCHAR(200)", new String[] {"_number", "_numbers", "_nbr", "_num", "_id"});

      case "NUMBER":
        return new AttributeClassInfo("_number", "VARCHAR(200)", new String[] {"_nbr", "_num", "_identifier", "_id"});

      case "INDICATOR":
        return new AttributeClassInfo("_ind", "BIT", new String[] {"_indicator", "_indicators", "_flag", "_flags"});

      case "FLAG":
        return new AttributeClassInfo("_flag", "VARCHAR(20)", new String[] {"_code", "_flags"});

      case "NOTE":
        return new AttributeClassInfo("_note", "VARCHAR(200)", new String[] {"_comment", "_comments", "_notes"});

      case "LIST":
        return new AttributeClassInfo("_list", "VARCHAR(2000)", new String[] {"_listing"});

      case "COUNT":
        return new AttributeClassInfo("_count", "INT", new String[] {"_quantity", "_qty", "_counts", "_ct"});

      case "ORDINAL":
        return new AttributeClassInfo("_index", "INT", new String[] {"_count", "_quantity", "_qty", "_value", "_val"});

      case "RATE":
        return new AttributeClassInfo("_rate", "DECIMAL(20,12)", new String[] {"_ratio", "_value", "_val", "_percent", "_pct", "_percentage"});

      default:
        return null;
    }
  }
}

]]>

</msxsl:script>


<!-- ##################################################################################### -->
<!-- TEMPLATE: BUILD THE MODEL XML -->
<!--

This section converts StarUML (Xml equivalent) to a Model Xml document having the
following structure.  Note that the resulting Xml is stored in a variable for re-use
in the build-output template.

<!DOCTYPE model [

  <!ELEMENT model (name, file, modify-timestamp, transform-timestamp, author, entity*)>

    <!ELEMENT name xs:text CDATA  #REQUIRED "Name of the model.">
    <!ELEMENT file xs:text CDATA  #REQUIRED "Name of the file.">
    <!ELEMENT modify-timestamp xs:datetime CDATA #REQUIRED "Timestamp on which the file was last modified.">
    <!ELEMENT transform-timestamp xs:datetime CDATA #REQUIRED "Timestamp on which the Xsl transform was generated.">
    <!ELEMENT author xs:date CDATA  #REQUIRED "Author(s) of the file.">

    <!ELEMENT subject (name, entity*)>

      <!ELEMENT name xs:text CDATA  #REQUIRED "Name of the subject area.">

      <!ELEMENT entity (name, attribute*, measure*, instance*)>
        <!ATTLIST entity
          implement xs:text (true | false) #DEFAULT false "Indicates whether use the entity in physical implementations, e.g. DDL."
          infer-grain xs:text (true | false) #DEFAULT false "Indicates whether the entity DDL implementation should infer a grain column.">

        <!ELEMENT name  xs:text CDATA #REQUIRED "Name of the entity.">

        <!ELEMENT attribute (name, reference-name?, type-name?, definition?, multiplicity)>
        <!ATTLIST attribute
          implement xs:text (true | false) #DEFAULT false "Indicates whether use the attribute in physical implementations, e.g. DDL."
          grain xs:text (true | false) #DEFAULT false "Indicates whether attribute is part of the entity grain."
          reference xs:text (true | false) #DEFAULT false "Indicates whether the attribute is a reference to another entity."
          derived xs:text (true | false) #DEFAULT false "Indicates whether the attribute is derived or formulated from other attributes.">

          <!ELEMENT name xs:text CDATA #REQUIRED "Name of the attribute.">
          <!ELEMENT reference-name xs:text CDATA "Name of the reference entity.">
          <!ELEMENT type-name xs:text CDATA "Name of the attribute type (attribute class).">
          <!ELEMENT definition xs:text CDATA "Business definition of the attribute.">
          <!ELEMENT multiplicity xs:text (0..1 | 1 | 0..* | 1..* | *) #DEFAULT 1 "Guidelines on calcuting or deriving the attribute.">

        <!ELEMENT measure (name, reference-name?, type-name?, definition?, specification?)>
        <!ATTLIST measure
          reference xs:text (true | false) #DEFAULT false "Indicates whether the attribute is a reference to another entity.">

          <!ELEMENT name "Name of the measure.">
          <!ELEMENT reference-name "Name of the resulting reference entity.">
          <!ELEMENT type-name "Name of the resulting attribute type (attribute class).">
          <!ELEMENT definition "Business definition of the measure.">
          <!ELEMENT specification "Guidelines on calcuting or deriving the measure.">

        <!ELEMENT instance (name, definition?)>
          <!ELEMENT name "Name of the instance.">
          <!ELEMENT definition "Business definition of the instance.">
]>

-->
<!-- ##################################################################################### -->

<xsl:template name="build-model-xml">
<model entity-count="{count(//ownedElements[
    _type='UMLClass'
    and not(visibility)
    and ancestor::ownedElements[
      _type='UMLSubsystem' 
      and name!='Attribute Classes']
  ])}">
  <name><xsl:value-of select="document/name" /></name>
  <file><xsl:value-of select="document/@sourceFile" /></file>
  <author><xsl:value-of select="document/author" /></author>
  <modify-timestamp><xsl:value-of select="document/@sourceModifiedTimestamp" /></modify-timestamp>
  <transform-timestamp><xsl:value-of select="document/@transformedTimestamp" /></transform-timestamp>

<!-- NOTE:
  Exclude Subject Areas (UMLSubsystem) called "Attribute Classes"
  Include only Subject Areas having an immediate child Entity (UMLClass) -->
<xsl:apply-templates select="//ownedElements[
    _type='UMLSubsystem' 
    and name !='Attribute Classes' 
    and child::ownedElements[_type='UMLClass']
  ]" mode="subject" />
</model>
</xsl:template>

<!-- TEMPLATE: SUBJECT NODES -->
<xsl:template match="ownedElements" mode="subject">
<subject entity-count="{count(.//ownedElements[_type='UMLClass'])}">
  <name><xsl:value-of select="name" /></name>

<xsl:apply-templates select="ownedElements[_type='UMLClass']" mode="entity" />
</subject>
</xsl:template>

<!-- TEMPLATE: ENTITY NODES -->
<xsl:template match="ownedElements" mode="entity">
<xsl:variable name="class-id" select="_id" />

<xsl:variable name="implement">
  <xsl:choose>
  <xsl:when test="visibility">false</xsl:when>
  <xsl:otherwise>true</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="infer-grain">
  <xsl:choose>
  <xsl:when test="count(attributes[isUnique='true'])=0">true</xsl:when>
  <xsl:otherwise>false</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<entity implement="{$implement}" infer-grain="{$infer-grain}">
  <name><xsl:value-of select="name" /></name>

<xsl:apply-templates select="attributes" mode="attribute" />
<xsl:apply-templates select="operations" mode="measure" />
<xsl:apply-templates select="//ownedElements[_type='UMLEnumeration' and stereotype/_ref=$class-id]/literals" mode="instance" />
</entity>
</xsl:template>

<!-- TEMPLATE: ATTRIBUTE NODES -->
<xsl:template match="attributes" mode="attribute">
<xsl:variable name="stereotype-class-id" select="stereotype/_ref" />
<xsl:variable name="type-class-id" select="type/_ref" />

<xsl:variable name="implement">
  <xsl:choose>
  <xsl:when test="not(visibility) and not(ancestor::ownedElements[_type='UMLClass'][1]/visibility) and (not(multiplicity) or multiplicity='0..1')">true</xsl:when>
  <xsl:otherwise>false</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="grain">
  <xsl:choose>
  <xsl:when test="isUnique='true'">true</xsl:when>
  <xsl:otherwise>false</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="reference">
  <xsl:choose>
  <xsl:when test="$stereotype-class-id">true</xsl:when>
  <xsl:otherwise>false</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="derived">
  <xsl:choose>
  <xsl:when test="isDerived='true'">true</xsl:when>
  <xsl:otherwise>false</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<attribute implement="{$implement}" grain="{$grain}" reference="{$reference}" derived="{$derived}">
  <name><xsl:value-of select="name" /></name>
<xsl:choose>
  <xsl:when test="$stereotype-class-id"><reference-name><xsl:value-of select="//ownedElements[_type='UMLClass' and _id=$stereotype-class-id]/name" /></reference-name></xsl:when>
  <xsl:when test="$type-class-id"><type-name><xsl:value-of select="//ownedElements[_type='UMLClass' and _id=$type-class-id]/name" /></type-name></xsl:when>
  <xsl:otherwise><type-name>{Unknown}</type-name></xsl:otherwise>
</xsl:choose>
  <definition><xsl:value-of select="documentation" /></definition>
  <multiplicity>
    <xsl:choose>
      <xsl:when test="multiplicity"><xsl:value-of select="multiplicity" /></xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </multiplicity>
</attribute>
</xsl:template>

<!-- TEMPLATE: MEASURE NODES -->
<xsl:template match="operations" mode="measure">
<xsl:variable name="stereotype-class-id" select="stereotype/_ref" />

<xsl:variable name="reference">
  <xsl:choose>
  <xsl:when test="$stereotype-class-id">true</xsl:when>
  <xsl:otherwise>false</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<measure reference="${reference}">
  <name><xsl:value-of select="name" /></name>
  <xsl:if test="$stereotype-class-id">
    <reference-name><xsl:value-of select="//ownedElements[_type='UMLClass' and _id=$stereotype-class-id]/name" /></reference-name>
  </xsl:if>
  <definition><xsl:value-of select="documentation" /></definition>
  <specification><xsl:value-of select="specification" /></specification>
</measure>
</xsl:template>

<!-- TEMPLATE: INSTANCE NODES -->
<xsl:template match="literals" mode="instance">
<instance>
  <name><xsl:value-of select="name" /></name>
  <definition><xsl:value-of select="documentation" /></definition>
</instance>
</xsl:template>

</xsl:stylesheet>
