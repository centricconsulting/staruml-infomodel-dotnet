# staruml-infomodel
Centric Library Export StarUML Extension. Exports a Centric Library Xml or text file from a StarUML 3.x project (mdj) file. Validated for StarUML version 3.0.0. The Java source project is http://github.com/centricconsulting/staruml-infomodel-java.

**NOTE: Compatible only with StarUML verion 3.0 and higher.**  For compatability with StarUML version 2.x use this repository: http://github.com/centricconsulting/staruml-infomodel-2.0.

**NOTE: Requires installation of the Java Runtime Environment 1.6.0.45 (Oracle 6u45) or higher.**

## Extension Use
1. From within StarUML, select the menu ```File >> Export >> Centric Library Transform...``` or ```File >> Export >> Centric Library Xml...```
2. Enter a target filename and click ```Save```.
3. The extension will automatically generate the file.

## Extension Installation Options
### #1 - StarUML Extension Manager
1. Install Java Runtime Environment 1.6.0.45 or higher. http://www.oracle.com/technetwork/java/javase/downloads/index.html
2. Windows Users:
    * Ensure that the System Environment variable, ```JAVA_HOME```, is set to the Java installation root folder.
    * Ensure that the System Environment variable, ```Path```, includes the ```%JAVA_HOME%\bin```.  This will allow the java.exe to run from any path.
3. Open the StarUML application.
4. Select the menu ```Tools >> Extension Manager...```
5. Click the ```Install From Url...``` button.
6. In the ```Install Extension``` field, enter ```http://github.com/centricconsulting/staruml-infomodel``` and click the ```Install``` button.
7. The extension will automatically install.

### #2 - Manual Windows Installation
1. Install Java 1.6 or higher. http://www.oracle.com/technetwork/java/javase/downloads/index.html
2. Windows Users:
    * Ensure that the System Environment variable, ```JAVA_HOME```, is set to the Java installation root folder.
    * Ensure that the System Environment variable, ```Path```, includes the ```%JAVA_HOME%\bin```.  This will allow the java.exe to run from any path.
3. Open Windows Explorer and navigate to the StarUML User Extensions folder, ```C:\Users\{user}\AppData\Roaming\StarUML\extensions\user```, where ```{user}``` is your windows login user name.
4. Download the file http://github.com/jkanel/staruml-infomodel/archive/master.zip to your local drive.
5. Open the zip archive and extract the ```staruml-infomodel-master``` folder to the ```\extensions\user``` folder (see #1, above).
6. The extension is now installed.

## Customization
The following methods of customization are supported.

**NOTE**: All customizations should be made in the StarUML User Extensions >> Centric Library Export folder.  On Windows machines, this folder is located here: ```"C:\Users\{user}\AppData\Roaming\StarUML\extensions\user\com.centric.infomodel"```.  The placeholder {user} should be replaced with your Windows account name.

1. **Xslt File**. You can alter the Xslt file ```transform.xslt``` located located in the StarUML User Extensions folder.  This file controls the generation of the Library text file based on Xml derived from the StarUML project.