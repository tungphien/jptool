#include "JSON.au3"
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <GUIConstants.au3>
#include <constants.au3>
#include <File.au3>
#include <WinAPIFiles.au3>
#include <FileConstants.au3>
#include <GuiListView.au3>
#include <ColorConstants.au3>


#Region Read config json
$data = FileRead("config.json")
$object = json_decode($data)
#EndRegion

#Region GUI
;GUI
Global $hGUI = GUICreate("Juniper Tool - Phiên Ngô", 600, 600)
$closeBtn = GUICtrlCreateButton("Exit", 510, 560, 80, 30)
$helpBtn = GUICtrlCreateButton("About", 420, 560, 80, 30)
Local $lblPythonVersion = GUICtrlCreateLabel(">> Your system is running with python version: ", 10, 570)
Local $lblPythonVersionValue = GUICtrlCreateLabel("", 230, 570, 100,30)
$inputFile = GUICtrlCreateInput("Path of yaml file",10, 10, 490)
$browseFileBtn = GUICtrlCreateButton("Browse file", 510, 10, 80, 30)

GUICtrlCreateGroup("Actions", 10, 50, 580, 70)
$formatFileBtn = GUICtrlCreateButton("Format and Re-Index Unique", 20, 75, 180, 30)
GUICtrlSetImage($formatFileBtn,"format.ico",221,0)

GUICtrlCreateGroup("Gererate testcase", 10, 150, 580, 340)
Local $openOutputWhenDone = GUICtrlCreateCheckbox("Open output when done", 450, 130)
GUICtrlSetState($openOutputWhenDone, $GUI_CHECKED)
GUICtrlCreateLabel("Testcase file", 20, 170, 200)
$cmbFileName = GUICtrlCreateCombo("", 130, 170, 300)
GUICtrlCreateLabel("(*)", 440, 170)
GUICtrlSetColor (-1, $COLOR_RED )
$testcase_FileName =json_get($object,'[testcase_filename]')
GUICtrlSetData($cmbFileName, $testcase_FileName, "routing_interfaces.yaml")
GUICtrlCreateLabel("Name of testcase", 20, 200, 200)
$txtTestcaseName = GUICtrlCreateInput("name_of_testcase", 130, 200,300)
GUICtrlCreateLabel("(*)", 440, 200)
GUICtrlSetColor (-1, $COLOR_RED )

Local $idComboBox = GUICtrlCreateCombo("Select", 20, 230,200)
Local $stepsWithoutKeyword=json_get($object,'[step_without_keyword]')
Local $stepsWithKeyword=json_get($object,'[step_with_keyword]')
GUICtrlSetData($idComboBox, $stepsWithoutKeyword & "|" &  $stepsWithKeyword, "Select")
$txtKeyword = GUICtrlCreateInput("Name of step", 230, 230,200)
$addStepBtn = GUICtrlCreateButton("Add", 440, 230,60,60)
GUICtrlSetState($addStepBtn, $GUI_DISABLE)
$deleteStepBtn = GUICtrlCreateButton("Delete", 510, 230,60,60)
$stepList = GUICtrlCreateListView("#|Step|Keyword", 20, 260, 410, 220, $LVS_SHOWSELALWAYS)
$generateStepBtn = GUICtrlCreateButton("Generate testcase", 440, 360, 140, 120)
GUICtrlSetImage($generateStepBtn, "generate.ico",221,0)

GUICtrlCreateGroup("Output path", 10, 500, 580, 50)
$outputHyperlink = GUICtrlCreateInput("", 20, 520, 550, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY))


$PYTHON_FULLTEXT_VERSION =''
$PYTHON_CMD = getPythonVersion()
GUICtrlSetData($lblPythonVersionValue,$PYTHON_FULLTEXT_VERSION)
GUISetState(@SW_SHOW, $hGUI)
#EndRegion


Func addStep()
   $comboValue = GUICtrlRead($idComboBox)
   $txtValue = GUICtrlRead($txtKeyword)
   if StringInStr($stepsWithoutKeyword, $comboValue) Then
	  GUICtrlCreateListViewItem(_GUICtrlListView_GetItemCount($stepList)+1 &"|"& $comboValue & "| ", $stepList)
   Else
	  If $txtValue='' Or StringInStr($txtValue,' ') Then
		 MsgBox($MB_ICONERROR, "", "Invalid name of keyword !")
	  Else
		 GUICtrlCreateListViewItem(_GUICtrlListView_GetItemCount($stepList)+1 &"|"& $comboValue & "|" & $txtValue, $stepList)
	  EndIf
   EndIf
EndFunc
Func deleteStep()
   $iIndex = _GUICtrlListView_GetSelectedIndices($stepList)
    _GUICtrlListView_DeleteItem($stepList, $iIndex)
EndFunc
Func changeComboStep()
   $comboValue = GUICtrlRead($idComboBox)
   If $comboValue=='Select' Then
	  GUICtrlSetState($addStepBtn, $GUI_DISABLE)
   Else
	  GUICtrlSetState($addStepBtn, $GUI_ENABLE)
   EndIf

   If StringInStr($stepsWithoutKeyword, $comboValue) Then
	  GUICtrlSetState($txtKeyword, $GUI_DISABLE)
   Else
	  GUICtrlSetState($txtKeyword, $GUI_ENABLE)
   EndIf
EndFunc
While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE, $closeBtn
                    ExitLoop
        Case $helpBtn
            displayHelp()
        Case $browseFileBtn
            displayBrowseFile()
        Case $formatFileBtn
            doFormat()
	    Case $generateStepBtn
		    doGenerateSteps()
	    Case $addStepBtn
			addStep()
	    Case $deleteStepBtn
			deleteStep()
	    Case $idComboBox
		    changeComboStep()

    EndSwitch
WEnd

Func validateFormBeforeGenerate()
   $testcaseName = GUICtrlRead($txtTestcaseName)
   $validateMsg=''
   If $testcaseName='' Or StringInStr($testcaseName,' ') Then
	  $validateMsg=$validateMsg & 'Invalid name of testcase !'& @CRLF
   EndIf
   If _GUICtrlListView_GetItemCount($stepList)<=0 Then
	  $validateMsg=$validateMsg & 'Please add step to testcase !'& @CRLF
   EndIf
   Return $validateMsg
EndFunc

Func doGenerateSteps()
   $testcaseName = GUICtrlRead($txtTestcaseName)
   $fileOfTestcase = GUICtrlRead($cmbFileName)
   $validateMsg = validateFormBeforeGenerate()
   If Not $validateMsg='' Then
	  MsgBox($MB_ICONERROR, "", $validateMsg)
   Else
	  $strSteps='' ;step#kword@step1#keyword1
	  For $x = 0 To _GUICtrlListView_GetItemCount($stepList) - 1
		  $itemText = _GUICtrlListView_GetItemTextString($stepList,$x)
		  $txtArr = StringSplit($itemText,'|')
		  $strSteps = $strSteps & $txtArr[2] & '#' & $txtArr[3] & '@'
	  Next
	  ConsoleWrite($strSteps)
	  $cmd =$PYTHON_CMD &' main.py -s "' & $strSteps &'" -tn "'& $testcaseName & '" -fn "'& $fileOfTestcase &'"'
	  ConsoleWrite($cmd)
	  Local $iPID = Run(@ComSpec & " /c " & $cmd, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	  ;MsgBox($MB_ICONINFORMATION, "", "The formatted file: output/test_case_generate.yaml")
	  $filePath = @ScriptDir & '\output\'& $fileOfTestcase
	  GUICtrlSetData($outputHyperlink, $filePath)
	  OpenFile($filePath)
   EndIf
EndFunc

Func doFormat()
    $filePath = GUICtrlRead($inputFile)
    if FileExists($filePath)==0 Then
	   MsgBox($MB_ICONERROR, "", "File not found !")
    Else
	   $answer = MsgBox($MB_YESNO, "Confirm", "Do you want to FORMAT and RE-INDEX UNIQUE this file? " & @CRLF & $filePath)
	   If  $answer = 6 Then ;If select OK
		   Local $iPID = Run(@ComSpec & " /c " & $PYTHON_CMD &' main.py -f "' & $filePath &'"', "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		   Local $aArray = _PathSplit($filePath, "", "", "", "")
		   Local $newPath= StringReplace ( $filePath, ".yaml", $filePath&"_temp.yaml")
		   ;MsgBox($MB_ICONINFORMATION, "", "The formatted file: " & @CRLF & $newPath)
		   GUICtrlSetData($outputHyperlink, $newPath)
		   OpenFile($newPath)
	   EndIf
    EndIf

EndFunc

Func displayBrowseFile()

    ; Create a constant variable in Local scope of the message to display in FileOpenDialog.
    Local Const $sMessage = "Hold down Ctrl or Shift to choose multiple files."

    ; Display an open dialog to select a list of file(s).
    Local $sFileOpenDialog = FileOpenDialog($sMessage, @WindowsDir & "\", "your yaml file (*.yaml)", BitOR($FD_FILEMUSTEXIST, $FD_MULTISELECT))
    If @error Then
        ; Display the error message.
        MsgBox($MB_SYSTEMMODAL, "", "No file(s) were selected.")

        ; Change the working directory (@WorkingDir) back to the location of the script directory as FileOpenDialog sets it to the last accessed folder.
        FileChangeDir(@ScriptDir)
    Else
        ; Change the working directory (@WorkingDir) back to the location of the script directory as FileOpenDialog sets it to the last accessed folder.
        FileChangeDir(@ScriptDir)

        ; Replace instances of "|" with @CRLF in the string returned by FileOpenDialog.
        $sFileOpenDialog = StringReplace($sFileOpenDialog, "|", @CRLF)

        ; Display the list of selected files.
        ;MsgBox($MB_SYSTEMMODAL, "", "You chose the following files:" & @CRLF & $sFileOpenDialog)
		ControlSetText($hGUI,"",$inputFile,$sFileOpenDialog)
    EndIf
EndFunc

Func getPythonVersion()
   $python_version_cmd = Run(@ComSpec &" /c python --version" , "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
   Local $python='python'
   Local $consoleOutput = getOutputOfProcess($python_version_cmd)
   $PYTHON_FULLTEXT_VERSION = $consoleOutput
   Local $aArray = StringRegExp($consoleOutput,'Python\s+(\d).*', $STR_REGEXPARRAYGLOBALMATCH)
   For $i = 0 To UBound($aArray) - 1
	   if $aArray[$i]=3 Then
		   $python='python'
	   EndIf
   Next

   Return $python
EndFunc

Func _IsChecked($idControlID)
    Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

Func OpenFile($file_path)
   If _IsChecked($openOutputWhenDone) Then
	  Sleep(500)
	  $notepad_path = 'C:\Program Files (x86)\Notepad++\notepad++.exe'
	  if FileExists($notepad_path)==0 Then
		 $notepad_path = 'notepad.exe'
	  EndIf
	  Run($notepad_path & " " & $file_path)
   EndIf
EndFunc
Func getOutputOfProcess($iPID)
   Local $output = Null
   While 1
	   $line = StdoutRead($iPID)
	   If @error Then ExitLoop
	   If Not $line = '' Then
		  $output = $line
	   EndIf
   Wend
   While 1
	   $line = StderrRead($iPID)
	   If @error Then ExitLoop
	   If Not $line = '' Then
		 $output = $line
	   EndIf
   Wend
   Return $output
EndFunc
Func displayHelp()
   MsgBox(0, "About Jtool!", "Author: Phiên Ngô "& @CRLF & @CRLF &"* Prerequisite"& @CRLF &"- install python."& @CRLF & @CRLF &"* Functionals"& @CRLF &"- Format yaml file and re-index unique."& @CRLF &"- Generate common steps for testcase.")
EndFunc