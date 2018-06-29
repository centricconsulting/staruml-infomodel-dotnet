/*
 * Copyright (c) 2018 Centric Consulting, LLC. All rights reserved.
 * Jeff Kanel
 */


/* ###############################################################################
######################   REFERENCES   ############################################
############################################################################### */

var exec = require('child_process').exec

/* ###############################################################################
######################   GLOBAL VALUES   #########################################
############################################################################### */

const PROCESS_EXECUTABLE = "CentricXmlTransform.exe"

/* ##############################################################################
######################   EXPORT CENTRIC LIBRARY   ################################
############################################################################### */

// file filters
const CENTRIC_LIBRARY_FILE_FILTERS = [
  {name: "Text Files", extensions: ["txt"]},
  {name: "All Files", extensions: ["*"]}
]

const CENTRIC_LIBRARY_FILE_TRANSFORM = "centric-library-transform.xslt";

function _handleExportCentricLibrary (defaultFilePath)
{

    // test that the file is ready for export
    if(!alertFileSave()) return;

    // set the default file name
    var _fileName = null
    if(defaultFilePath != null)
    {
      _fileName = defaultFilePath
    } else 
    {
      _fileName = app.project.getProject().name + ".txt"
    }

    // get the file path
    var targetFilePath = app.dialogs.showSaveDialog("Export Centric Library", _fileName, CENTRIC_LIBRARY_FILE_FILTERS)

    // execute the transformation
    if(targetFilePath)
    {
      var command = PROCESS_EXECUTABLE
      + " -source \"" + normalizePath(app.project.getFilename()) + "\""
      + " -xslt \"" + CENTRIC_LIBRARY_FILE_TRANSFORM + "\""
      + " -target \"" + normalizePath(targetFilePath) + "\""
      + " -overwrite"

      executeCommand(command);
    }
}

/* ##############################################################################
######################   EXPORT CENTRIC DDL LIBRARY   ################################
############################################################################### */

const CENTRIC_DDL_FILE_FILTERS = [
  {name: "SQL Files", extensions: ["sql"]},
  {name: "All Files", extensions: ["*"]}
]

const CENTRIC_DDL_FILE_TRANSFORM = "centric-ddl-transform.xslt";

// command hook
function _handleExportCentricDDL (defaultFilePath) 
{
    // test that the file is ready for export
    if(!alertFileSave()) return;

    // set the default file name
    var _fileName = null
    if(defaultFilePath != null)
    {
      _fileName = defaultFilePath
    } else 
    {
      _fileName = app.project.getProject().name + ".sql"
    }

    // get the file path
    var targetFilePath = app.dialogs.showSaveDialog("Export Centric EDW SQL", _fileName, CENTRIC_DDL_FILE_FILTERS)

    // execute the transformation
    if(targetFilePath)
    {
      var command = PROCESS_EXECUTABLE
      + " -source \"" + normalizePath(app.project.getFilename()) + "\""
      + " -xslt \"" + CENTRIC_DDL_FILE_TRANSFORM + "\""
      + " -target \"" + normalizePath(targetFilePath) + "\""
      + " -overwrite"

      executeCommand(command);
    }
}

/* ###############################################################################
######################   EXPORT STARUML XML   ####################################
############################################################################### */

// file filters
const STARUML_XML_FILE_FILTERS = [
  {name: "Xml Files", extensions: ["xml"]},
  {name: "All Files", extensions: ["*"]}
]

// command hook
function _handleExportStarUMLXml (defaultFilePath) 
{
    // test that the file is ready for export
    if(!alertFileSave()) return;

    // set the default file name
    var _fileName = null
    if(defaultFilePath != null)
    {
      _fileName = defaultFilePath
    } else 
    {
      _fileName = app.project.getProject().name + ".xml"
    }

    // get the file path
    var targetFilePath = app.dialogs.showSaveDialog("Export StarUML As Xml", _fileName, STARUML_XML_FILE_FILTERS)

    // execute the transformation
    if(targetFilePath)
    {

      var command = PROCESS_EXECUTABLE
      + " -source \"" + normalizePath(app.project.getFilename()) + "\""
      + " -target \"" + normalizePath(targetFilePath) + "\""
      + " -xml -supress"

      executeCommand(command);
    }
}

/* ###############################################################################
######################   SUPPORT FUNCTIONS   #####################################
############################################################################### */

function alertFileSave ()
{
  var jsonFilePath = app.project.getFilename()
  if(jsonFilePath == null || app.repository.isModified())
  {
    var buttonId = app.dialogs.showInfoDialog("Please save the project before exporting.")
    return false;
  }

  return true;
}

function buildFilePath (directory, filename)
{
    return normalizePath(directory) + "/" + filename  
}

function normalizePath (path)
{
  // perform a global replace
  var newPath = path.replace(/\\/g,"/")
  
  if(newPath.endsWith("/"))
  {
    return newPath.substring(0,newPath.length()-2)
  }
  else
  {
    return newPath
  }
}


function executeCommand(command)
{
  var args = {cwd: __dirname}

  exec(command,args,function (error, stdout, stderr)
  {
    if (error !== null)
    {
      console.log("Command execute failed: " + stderr)
      var buttonId = app.dialogs.showErrorDialog("Centric Library Export encountered an error:\r\n\r\n" + stderr)
      throw error
      return stderr
    }
    else
    {
      console.log("Successfully executed command:\r\n" + command)
      return stdout
    }
  })
}

/* ###############################################################################
######################   INITIALIZATION   ########################################
############################################################################### */

function init ()
{
    app.commands.register("centriclibrary:export", _handleExportCentricLibrary)
    app.commands.register("centricddl:export", _handleExportCentricDDL)
    app.commands.register("starumlxml:export", _handleExportStarUMLXml)
}

exports.init = init