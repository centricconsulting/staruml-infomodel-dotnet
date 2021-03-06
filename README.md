# Centric Information Model Extension for StarUML
## Overview
The **Centric Information Model StarUML Extension** exports a Centric library, DDL or StarUML Xml file from a StarUML 3.x project (mdj) file. Validated for StarUML version 3.0.0.

Running this application requires installation of **.NET Framework 4.5** or higher. Windows 10 users will already have this version of .NET installed.

## Installation
### StarUML Extension Manager
1. Open the StarUML application.
2. Select the menu **`Tools >> Extension Manager...`**
3. Click the **`Install From Url...`** button.
4. In the **`Install Extension`** field, enter **`http://github.com/centricconsulting/staruml-infomodel-dotnet`** and click the **`Install`** button.
5. The extension will automatically install.

## Extension Features
From within StarUML, select the menu **`File >> Export`** menu. You will see several options for exporting:

![alt text](https://github.com/centricconsulting/staruml-infomodel-dotnet/blob/master/menus/screenshot.png "StarUML Export Menu")

### Centric Library Export
1. Select the menu item **`File >> Export >> Centric Library...`**
2. Enter a target filename and click **`Save`**.
3. The extension will automatically generate a text file containing a Centric library.

### Centric EDW SQL Export
1. Select the menu item **`File >> Export >> Centric EDW SQL...`**
2. Enter a target filename and click **`Save`**.
3. The extension will automatically generate a SQL file containing SQL Server table DDL.

### StarUML As Xml Export
1. Select the menu item **`File >> Export >> Centric StarUML As Xml...`**
2. Enter a target filename and click **`Save`**.
3. The extension will automatically generate an Xml conversion of the StarUML Json file (*.mdj).

## Customizations
All customizations should be made in the StarUML extensions folder for the current Windows user. On Windows machines, this folder is located here: **`"C:\Users\{user}\AppData\Roaming\StarUML\extensions\user\centric.infomodel.dotnet"`**. The placeholder **`{user}`** should be replaced with your Windows login.

**Xslt File Customization**. You can alter the Xslt files **`centric-ddl-transform.xslt`** or **`centric-library-transform.xslt`** located located in the StarUML extensions folder. This file controls the generation of the library and DDL exports. Transformations are executed against the StarUML Xml file which can be generated from the similarly named menu item.

**Centric Xml Transform Utility**. You can transform Xml and Json files using the **Centric Xml Transform Utililty** application interface. This utility may be run from the StarUML extensions folder by running **`CentricXmlTransform.exe`**. This utility is also available separately from the corresponding [repository](https://github.com/centricconsulting/xml-transform-app).