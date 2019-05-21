#include <ButtonConstants.au3>
#include <EditConstants.au3>
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
#include <misc.au3>
#include <Array.au3>
#include <GuiComboBox.au3>

Opt("GUIOnEventMode", 1);
#Region Loading
loadindProgess(500,"Load Juniper Tool","Openning Program")
Func loadindProgess($timeout, $title, $msg)
   ProgressOn($title, $msg, "0%"); Just to let more beautiful
   For $i = 10 To 100 Step 10
	   Sleep(100)
	   ProgressSet($i, $i & "%")
   Next
   ProgressSet(100, "Complete", "Complete")
   Sleep($timeout)
   ProgressOff()
EndFunc
#EndRegion

#Region Login GUI
$FormLogin = GUICreate("Login to Juniper Tool", 320, 150, -1, -1); begining of Login
$usernamelabel = GUICtrlCreateLabel("Username:", 20, 20, 52, 17)
$USERNAME = GUICtrlCreateInput("",  80, 20, 220, 21)
$passwordlabel = GUICtrlCreateLabel("Password:", 20, 50, 50, 17)
$PASSWORD = GUICtrlCreateInput("", 80, 50, 220, 21, BitOR($ES_PASSWORD,$ES_AUTOHSCROLL))
$ButtonOk = GUICtrlCreateButton("&OK", 80, 90, 75, 25, 0)
$ButtonCancel = GUICtrlCreateButton("&Cancel", 160, 90, 75, 25, 0)
GUISetState(@SW_SHOW)
GUISetOnEvent($GUI_EVENT_CLOSE, "_Close")
GUICtrlSetOnEvent($ButtonCancel, "_Close")
GUICtrlSetOnEvent($ButtonOk, "_Login")
#Region Enter Key to Login
Local $hEnterKey = GUICtrlCreateDummy()
Dim $EnterKeys[1][2]=[["{ENTER}", $hEnterKey]]
GUISetAccelerators($EnterKeys)
GUICtrlSetOnEvent($hEnterKey, "_Login")
#EndRegion
#EndRegion

#Region Read config json
$data = FileRead("config.json")
$object = json_decode($data)
#EndRegion

#Region Read agni keywords
$data_agni = FileRead("agni_keywords.json")
$object_agni = json_decode($data_agni)
$agni_keywors = json_get($object_agni,'[keywords]')
;_ArrayDisplay($agni_keywors)
#EndRegion

#Region APP GUI
Global $hGUI = GUICreate("Juniper Tool - Phiên Ngô", 600, 600)
GUICtrlCreateTab(0, 0, 603, 490)

#Region Tab Generate Yaml
GUICtrlCreateTabItem("Yaml")
GUICtrlCreateGroup("", 10, 20, 580, 80)
GUICtrlCreateLabel("Testcase file", 20, 40, 200)
Local $cmbFileName = GUICtrlCreateCombo("", 130, 40, 300)
GUICtrlCreateLabel("(*)", 440, 40)
GUICtrlSetColor (-1, $COLOR_RED )
Local $testcase_FileName =json_get($object,'[testcase_filename]')
GUICtrlSetData($cmbFileName, $testcase_FileName, "routing_interfaces.yaml")
GUICtrlCreateLabel("Name of testcase", 20, 70, 200)
Local $txtTestcaseName = GUICtrlCreateInput("name_of_testcase", 130, 70,300)
GUICtrlCreateLabel("(*)", 440, 70)
GUICtrlSetColor (-1, $COLOR_RED )

Local $idComboBox = GUICtrlCreateCombo("", 10, 110,200,21,BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
#Region Read tsc.yaml
Local $aInput
$file = "tcs.yaml"

_FileReadToArray($file, $aInput)
$common_step = ''
Local $common_funtion[0]=[]
Local $other_function[0]=[]
For $i = 1 to UBound($aInput) -1
    $data = getRegexByGroup($aInput[$i],'#(.*)@',0)
	if Not $data='' Then
	  If $data='run_event' Or $data='run_keyword' Or $data='create_dictionary_and_get' Or $data='create_dictionary_and_check' Then
		 _ArrayAdd($common_funtion,$data)
	  Else
		 _ArrayAdd($other_function, $data)
	  EndIf
	  ;$common_step = $common_step & '|' & $data
    EndIf
Next
_ArraySort($common_funtion, 0)
_ArraySort($other_function, 0)
$break_line = ''
For $i = 1 To 64 Step 1
   $break_line=$break_line&'-'
Next
$common_step = stringJoin($common_funtion, '|') & '|'& $break_line &'|' & stringJoin($other_function, '|')

#EndRegion

GUICtrlSetData($idComboBox, $common_step)
Local $cmbAgniKeyword = GUICtrlCreateCombo("", 220, 110, 230,21,BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL, $CBS_SORT))
GUICtrlSetState($cmbAgniKeyword, $GUI_DISABLE)
Local $txtKeyword = GUICtrlCreateInput("Name of step", 10, 140, 440)
Local $addStepBtn = GUICtrlCreateButton("Add", 460, 110,130,50)
GUICtrlSetImage($addStepBtn,"icons\add.ico",221,0)
GUICtrlSetState($addStepBtn, $GUI_DISABLE)
Local $deleteStepBtn = GUICtrlCreateButton("Delete", 530, 170,60,40)
GUICtrlSetImage($deleteStepBtn,"icons\delete.ico",221,0)
GUICtrlSetState($deleteStepBtn, $GUI_DISABLE)
Local $downBtn = GUICtrlCreateButton("Down", 530, 270,60,40)
GUICtrlSetImage($downBtn,"icons\down.ico",221,0)
Local $upBtn = GUICtrlCreateButton("Up", 530, 220,60,40)
GUICtrlSetImage($upBtn,"icons\up.ico",221,0)
GUICtrlSetState($downBtn, $GUI_DISABLE)
GUICtrlSetState($upBtn, $GUI_DISABLE)
Local $duplicateBtn = GUICtrlCreateButton("Copy", 530, 320,60,40)
GUICtrlSetImage($duplicateBtn,"icons\duplicate.ico",221,0)
Local $reloadBtn = GUICtrlCreateButton("Reload", 530, 370,60,40)
GUICtrlSetImage($reloadBtn,"icons\reload.ico",221,0)

Local $stepList = GUICtrlCreateListView("", 10, 170, 510, 310)
; Add columns
_GUICtrlListView_InsertColumn($stepList, 0, "#", 30)
_GUICtrlListView_InsertColumn($stepList, 1, "Function of step", 150)
_GUICtrlListView_InsertColumn($stepList, 2, "Name of Step", 150)
_GUICtrlListView_InsertColumn($stepList, 3, "Keyword", 150)
_GUICtrlListView_SetExtendedListViewStyle($stepList, BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT))
; Set default add_timestamp
GUICtrlCreateListViewItem(_GUICtrlListView_GetItemCount($stepList)+1 &"|add_timestamp|add_timestamp", $stepList)
Local $generateStepBtn = GUICtrlCreateButton("Generate testcase", 530, 420, 60, 60, $BS_ICON)
GUICtrlSetImage($generateStepBtn, "icons\yaml.ico", 1)
updateButtonStatus()
#EndRegion

#Region Tab Format Yaml
GUICtrlCreateTabItem("Format")
Local $inputFile = GUICtrlCreateInput("Path of yaml file",10, 40, 480,30)
Local $browseFileBtn = GUICtrlCreateButton("Browse file", 500, 40, 90, 30)

GUICtrlCreateGroup("Actions", 10, 80, 580, 70)
Local $formatFileBtn = GUICtrlCreateButton("Format and Re-Index Unique", 20, 105, 180, 30)
GUICtrlSetImage($formatFileBtn,"icons\format.ico",221,0)
#EndRegion
GUICtrlCreateTabItem("Setting")

#Region Tab Setting
Local $openOutputWhenDone = GUICtrlCreateCheckbox("Open output when done", 10, 30)
GUICtrlSetState($openOutputWhenDone, $GUI_CHECKED)
Local $inputAgniPath = GUICtrlCreateInput("",10, 60, 480,30)
GUICtrlSetData($inputAgniPath, json_get($object,'[agni_path]'))
Local $browseAgniPathBtn = GUICtrlCreateButton("Browse folder", 500, 60, 90, 30)
Local $refreshAgniKeywordBtn = GUICtrlCreateButton("Refresh Agni Keyword", 10, 100, 150, 30)
GUICtrlSetImage($refreshAgniKeywordBtn,"icons\refresh.ico",221,0)
#EndRegion
GUICtrlCreateTabItem("") ; end tabitem definition

Local $closeBtn = GUICtrlCreateButton("Exit", 510, 560, 80, 30)
GUICtrlSetImage($closeBtn,"icons\exit.ico",221,0)
Local $helpBtn = GUICtrlCreateButton("About", 420, 560, 80, 30)
GUICtrlSetImage($helpBtn,"icons\about.ico",221,0)
Local $lblPythonVersionValue = GUICtrlCreateLabel("", 10, 570, 100,30)
Local $lblUserName = GUICtrlCreateLabel("", 200, 570, 200,30)
GUICtrlSetColor ($lblUserName, $COLOR_RED )

GUICtrlCreateGroup("Output path", 10, 500, 580, 50)
Local $outputHyperlink = GUICtrlCreateInput("", 20, 520, 560, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY))


Local $PYTHON_FULLTEXT_VERSION =''
Local $PYTHON_CMD = getPythonVersion()
GUICtrlSetData($lblPythonVersionValue,$PYTHON_FULLTEXT_VERSION)
;GUISetState(@SW_SHOW, $hGUI)
#EndRegion
#Region Delete Key detect
Local $hDelKey = GUICtrlCreateDummy()
Dim $AccelKeys[1][2]=[["{DELETE}", $hDelKey]]
GUISetAccelerators($AccelKeys)
#EndRegion
GUICtrlSetOnEvent($duplicateBtn,'duplicateStep')
GUICtrlSetOnEvent($reloadBtn,'reloadForm')
GUICtrlSetOnEvent($refreshAgniKeywordBtn,'refreshAgniKeyword')
GUICtrlSetOnEvent($closeBtn, "_Close")
GUICtrlSetOnEvent($helpBtn, "displayHelp")
GUICtrlSetOnEvent($browseFileBtn, "displayBrowseFile")
GUICtrlSetOnEvent($browseAgniPathBtn, "displayBrowseFolder")
GUICtrlSetOnEvent($formatFileBtn, "doFormat")
GUICtrlSetOnEvent($generateStepBtn, "doGenerateSteps")
GUICtrlSetOnEvent($addStepBtn, "addStep")
GUICtrlSetOnEvent($deleteStepBtn, "deleteStep")
GUICtrlSetOnEvent($hDelKey, "deleteStep")
GUICtrlSetOnEvent($idComboBox, "changeComboStep")
GUICtrlSetOnEvent($downBtn, "moveDownStep")
GUICtrlSetOnEvent($upBtn, "moveUpStep")
GUISetOnEvent($GUI_EVENT_PRIMARYDOWN,"_Arrange_ListStep")
GUISetOnEvent($GUI_EVENT_CLOSE, "_Close")
GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
Local $userNameValue = ''

While True
	;Sleep(200)
    Switch _GUICtrlComboBox_GetCurSel($idComboBox)
	  Case 4
	      _GUICtrlComboBox_SetCurSel($idComboBox, 5)
    EndSwitch
WEnd

Func _Login()
   Local $users = StringSplit(json_get($object,'[users]'),'|')
   If _ArraySearch($users,GUICtrlRead($USERNAME)) >= 1 And GUICtrlRead($PASSWORD) = "" Then
	  $userNameValue=GUICtrlRead($USERNAME)
	  GUICtrlSetData($lblUserName,'Welcome to: '& $userNameValue)
	  GUIDelete($FormLogin)
	  RunApp()
   Else
	  $userNameValue=''
      MsgBox($MB_ICONERROR,"Error"," Username or Password is not correct !")
   EndIf
 EndFunc; End login

Func RunApp()
   GUISetState(@SW_SHOW, $hGUI)
EndFunc

#Region List Step Control
Func moveDownStep()
   $listCount = _GUICtrlListView_GetItemCount($stepList)
   $Selected = _GUICtrlListView_GetSelectedIndices($stepList)

   if $Selected + 1 < $listCount Then
	  _GUICtrlListView_BeginUpdate($stepList)
	  $currentArr = StringSplit(_GUICtrlListView_GetItemTextString($stepList, $Selected+0),'|')
	  $nextArr = StringSplit(_GUICtrlListView_GetItemTextString($stepList, $Selected+1),'|')
	  ; update value for next row
	  _GUICtrlListView_AddSubItem($stepList, $Selected + 1, $currentArr[2], 1)
	  _GUICtrlListView_AddSubItem($stepList, $Selected + 1, $currentArr[3], 2, 2)
	  _GUICtrlListView_AddSubItem($stepList, $Selected + 1, $currentArr[4], 3, 3)
	  ; update value for current row
	  _GUICtrlListView_AddSubItem($stepList, $Selected+0, $nextArr[2], 1)
	  _GUICtrlListView_AddSubItem($stepList, $Selected+0, $nextArr[3], 2, 2)
	  _GUICtrlListView_AddSubItem($stepList, $Selected+0, $nextArr[4], 3, 3)
	  updateIndexNumber()
	  _GUICtrlListView_EndUpdate($stepList)
   EndIf

EndFunc

Func moveUpStep()
   $Selected = _GUICtrlListView_GetSelectedIndices($stepList)

   if $Selected - 1 >= 0 Then
	  _GUICtrlListView_BeginUpdate($stepList)
	  $currentArr = StringSplit(_GUICtrlListView_GetItemTextString($stepList, $Selected+0),'|')
	  $prevArr = StringSplit(_GUICtrlListView_GetItemTextString($stepList, $Selected-1),'|')
	  ; update value for prev row
	  _GUICtrlListView_AddSubItem($stepList, $Selected - 1, $currentArr[2], 1)
	  _GUICtrlListView_AddSubItem($stepList, $Selected - 1, $currentArr[3], 2, 2)
	  _GUICtrlListView_AddSubItem($stepList, $Selected - 1, $currentArr[4], 3, 3)
	  ; update value for current row
	  _GUICtrlListView_AddSubItem($stepList, $Selected+0, $prevArr[2], 1)
	  _GUICtrlListView_AddSubItem($stepList, $Selected+0, $prevArr[3], 2, 2)
	  _GUICtrlListView_AddSubItem($stepList, $Selected+0, $prevArr[4], 3, 3)
	  updateIndexNumber()
	  _GUICtrlListView_EndUpdate($stepList)
   EndIf
EndFunc

Func updateIndexNumber()
   $listCount = _GUICtrlListView_GetItemCount($stepList)
   For $x = 0 To $listCount - 1
	   _GUICtrlListView_AddSubItem($stepList, $x, $x+1,0)
   Next
   if $listCount>=2 Then
	  GUICtrlSetState($downBtn, $GUI_ENABLE)
	  GUICtrlSetState($upBtn, $GUI_ENABLE)
   Else
	  GUICtrlSetState($downBtn, $GUI_DISABLE)
	  GUICtrlSetState($upBtn, $GUI_DISABLE)
   EndIf
   if $listCount>0 Then
	  GUICtrlSetState($deleteStepBtn, $GUI_ENABLE)
   Else
	  GUICtrlSetState($deleteStepBtn, $GUI_DISABLE)
   EndIf
EndFunc

Func _Arrange_ListStep()
   If _GUICtrlListView_GetItemCount($stepList) > 0 Then
	  $Selected = _GUICtrlListView_GetHotItem($stepList)
	  If $Selected = -1 then Return
	  While _IsPressed(1)
	  WEnd
	  $Dropped = _GUICtrlListView_GetHotItem($stepList)
	  If $Dropped > -1 then
		_GUICtrlListView_BeginUpdate($stepList)
		If $Selected < $Dropped Then
			_GUICtrlListView_InsertItem($stepList, "", $Dropped + 1)
			_GUICtrlListView_AddSubItem($stepList, $Dropped + 1, _GUICtrlListView_GetItemText($stepList, $Selected, 1), 1)
			_GUICtrlListView_AddSubItem($stepList, $Dropped + 1, _GUICtrlListView_GetItemText($stepList, $Selected, 2), 2, 2)
			_GUICtrlListView_AddSubItem($stepList, $Dropped + 1, _GUICtrlListView_GetItemText($stepList, $Selected, 3), 3, 3)
			_GUICtrlListView_SetItemChecked($stepList, $Dropped + 1, _GUICtrlListView_GetItemChecked($stepList, $Selected))
			_GUICtrlListView_DeleteItem($stepList, $Selected)
		ElseIf $Selected > $Dropped Then
			_GUICtrlListView_InsertItem($stepList, "", $Dropped)
			_GUICtrlListView_AddSubItem($stepList, $Dropped, _GUICtrlListView_GetItemText($stepList, $Selected + 1, 1), 1)
			_GUICtrlListView_AddSubItem($stepList, $Dropped, _GUICtrlListView_GetItemText($stepList, $Selected + 1, 2), 2, 2)
			_GUICtrlListView_AddSubItem($stepList, $Dropped, _GUICtrlListView_GetItemText($stepList, $Selected + 1, 3), 3, 3)
			_GUICtrlListView_SetItemChecked($stepList, $Dropped, _GUICtrlListView_GetItemChecked($stepList, $Selected + 1))
			_GUICtrlListView_DeleteItem($stepList, $Selected + 1)
		EndIf
		updateIndexNumber()
		_GUICtrlListView_EndUpdate($stepList)
	  EndIf
   EndIf
EndFunc

Func addStep()
   $comboValue = GUICtrlRead($idComboBox)
   $txtValue = GUICtrlRead($txtKeyword)
   $agniKeywordValue = GUICtrlRead($cmbAgniKeyword)
   If $txtValue='' Or StringInStr($txtValue,' ') Then
	  MsgBox($MB_ICONERROR, "", "Invalid name of step !")
   Else
	  GUICtrlCreateListViewItem(_GUICtrlListView_GetItemCount($stepList)+1 &"|"& $comboValue & "|" & $txtValue&"|"&$agniKeywordValue, $stepList)
   EndIf
   updateIndexNumber()
   updateButtonStatus()
EndFunc

Func deleteStep()
   $iIndex = _GUICtrlListView_GetSelectedIndices($stepList)
   _GUICtrlListView_DeleteItem($stepList, $iIndex)
   updateIndexNumber()
   updateButtonStatus()
EndFunc

#EndRegion

Func changeComboStep()
   $comboValue = GUICtrlRead($idComboBox)
   If  StringInStr($comboValue, "--")>0 Then
	   $comboValue = ""
	   _GUICtrlComboBox_SetEditText($idComboBox, $comboValue)
   EndIf

   If $comboValue=='' Then
	  GUICtrlSetState($addStepBtn, $GUI_DISABLE)
   Else
	  GUICtrlSetState($addStepBtn, $GUI_ENABLE)
	  bindingDataToAgniKeywordCombobox()
	  If $comboValue=='run_event' Or $comboValue=='run_keyword' Then
		 $comboValue = $comboValue & '_'
	  EndIf
	  If $comboValue=='create_dictionary_and_get' Then
		 $comboValue = 'get_'
	  EndIf
	  If $comboValue=='create_dictionary_and_check' Then
		 $comboValue = 'verify_'
	  EndIf
   EndIf
   GUICtrlSetData($txtKeyword, $comboValue)
EndFunc

Func bindingDataToAgniKeywordCombobox()
   $comboValue = GUICtrlRead($idComboBox)
   If $comboValue=='run_event' Or $comboValue=='run_keyword' Then
	  GUICtrlSetState($cmbAgniKeyword, $GUI_ENABLE)
	  If $comboValue=='run_event' Then
		 GUICtrlSetData($cmbAgniKeyword, '')
		 GUICtrlSetData($cmbAgniKeyword, 'On CLI|On Config')
	  EndIf
	  If $comboValue=='run_keyword' Then
		 ; get all keyword from agni
		 GUICtrlSetData($cmbAgniKeyword, '')
		 stringJoin($agni_keywors ,'|')
		 GUICtrlSetData($cmbAgniKeyword, stringJoin($agni_keywors ,'|'))
	  EndIf
   Else
	  GUICtrlSetData($cmbAgniKeyword, '')
	  GUICtrlSetState($cmbAgniKeyword, $GUI_DISABLE)
   EndIf
EndFunc

Func stringJoin($array, $slash)
   $result=''
   For $element IN $array
	  If $result='' Then
		 $result = $element
	  Else
		 $result = $result & ''& $slash &'' & $element
	  EndIf
   Next
   Return $result
EndFunc

Func refreshAgniKeyword()
   If Not json_get($object,'[agni_path]') = '' Then
	  $cmd =$PYTHON_CMD &' main.py -r true'
	  Local $iPID = Run(@ComSpec & " /c " & $cmd, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	  loadindProgess(500,"Read new keywords from Agni folder","Reading...")
	  RestartScript()
   Else
	  MsgBox($MB_ICONERROR,"Error"," Please update your agni folder !")
   EndIf
EndFunc

Func updateAgniPath($new_agni_path)
   Local $aInput
   $filePath = "config.json"
   $tempfile = 'temp.json'
   $fileO = FileOpen($tempfile, 2)
   _FileReadToArray($filePath, $aInput)
   For $i = 1 to UBound($aInput) -1
	  $content = $aInput[$i]
	  If StringInStr($aInput[$i],'"agni_path"')>0 Then
		 $content = StringRegExpReplace($aInput[$i], '"agni_path":.*,', '"agni_path":"'&$new_agni_path&'",')
	  EndIf

	  FileWrite($fileO, $content & @CRLF)
   Next
   FileClose($fileO)
   FileDelete($filePath)
   FileMove('temp.json', $filePath)
EndFunc

Func validateFormBeforeGenerate()
   $testcaseName = GUICtrlRead($txtTestcaseName)
   $fileName = GUICtrlRead($cmbFileName)
   $validateMsg=''
   If $fileName='' Or StringInStr($fileName,' ') Then
	  $validateMsg=$validateMsg & 'Invalid name of testcase file !'& @CRLF
   EndIf
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
	  Local $arrSteps='' ;[function#stepname#keyword, function#stepname#keyword]
	  For $x = 0 To _GUICtrlListView_GetItemCount($stepList) - 1
		 $itemText = _GUICtrlListView_GetItemTextString($stepList,$x)
		 $txtArr = StringSplit($itemText,'|')
		 $obj = ''
		 $obj = $obj & $txtArr[2] & '#' & $txtArr[3]
		 If Not $txtArr[4]='' Then
			$obj = $obj & '#' & $txtArr[4]
		 EndIf
		 $arrSteps = $arrSteps & ' "' & $obj & '"'
	  Next

	  $cmd =$PYTHON_CMD &' main.py -s ' & $arrSteps &' -tn "'& $testcaseName & '" -fn "'& $fileOfTestcase &'" -usr "'& $userNameValue & '"'
	  Local $iPID = Run(@ComSpec & " /c " & $cmd, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	  loadindProgess(500,"Generate testcase","Processing...")
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
	   $answer = MsgBox(BitOR($MB_YESNO, $MB_ICONQUESTION), "Confirm", "Do you want to FORMAT and RE-INDEX UNIQUE this file? " & @CRLF & $filePath)
	   If  $answer = 6 Then ;If select OK
		   Local $iPID = Run(@ComSpec & " /c " & $PYTHON_CMD &' main.py -f "' & $filePath &'"', "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		   loadindProgess(500,"Format yaml file","Processing...")
		   GUICtrlSetData($outputHyperlink, $filePath)
		   OpenFile($filePath)
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

Func displayBrowseFolder()
    ; Create a constant variable in Local scope of the message to display in FileSelectFolder.
    Local Const $sMessage = "Select your AGNI folder"

    ; Display an open dialog to select a file.
    Local $sFileSelectFolder = FileSelectFolder($sMessage, "")
    If @error Then
        ; Display the error message.
        MsgBox($MB_SYSTEMMODAL, "", "No folder was selected.")
    Else
        GUICtrlSetData($inputAgniPath, $sFileSelectFolder)
		$new_agni_path = StringRegExpReplace($sFileSelectFolder,'\\','\\\\\\\\')
		updateAgniPath($new_agni_path)
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
	  $editor = 'notepad.exe'
	  $notepad_path_32 = 'C:\Program Files (x86)\Notepad++\notepad++.exe'
	  $notepad_path_64 = 'C:\Program Files\Notepad++\notepad++.exe'
	  if FileExists($notepad_path_32)==1 Then
		 $editor = $notepad_path_32
	  EndIf
	  if FileExists($notepad_path_64)==1 Then
		 $editor = $notepad_path_64
	  EndIf
	  Run($editor & " " & $file_path)
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

Func getRegexByGroup($content, $patten, $groupIndex)
   $result=''
   Local $aArray = StringRegExp($content,$patten, $STR_REGEXPARRAYGLOBALMATCH)
   For $i = 0 To UBound($aArray) - 1
	  $result = $aArray[$i]
   Next
   Return $result
EndFunc

Func displayHelp()
   MsgBox(0, "About Jtool!", "Author: Phiên Ngô "& @CRLF & @CRLF &"* Prerequisite"& @CRLF &"- install python."& @CRLF & @CRLF &"* Functionals"& @CRLF &"- Format yaml file and re-index unique step."& @CRLF &"- Generate steps for testcase.")
EndFunc

Func RestartScript()
    If @Compiled = 1 Then
        Run( FileGetShortName(@ScriptFullPath))
    Else
        Run( FileGetShortName(@AutoItExe) & " " & FileGetShortName(@ScriptFullPath))
    EndIf
    Exit
EndFunc

Func _Close()
	Exit(0)
EndFunc

#Region AutoCompleted AgniKeyword Combobox
Func _Edit_Changed($cCombo)
    _GUICtrlComboBox_AutoComplete($cCombo)
EndFunc   ;==>_Edit_Changed

Func WM_COMMAND($hWnd, $iMsg, $iwParam, $ilParam)

    #forceref $hWnd, $iMsg, $ilParam

    $iIDFrom = BitAND($iwParam, 0xFFFF) ; Low Word
    $iCode = BitShift($iwParam, 16) ; Hi Word
    If $iCode = $CBN_EDITCHANGE Then
        Switch $iIDFrom
            Case $cmbAgniKeyword
                _Edit_Changed($cmbAgniKeyword)
            ;Case $cCombo2
                ;_Edit_Changed($cCombo2)
        EndSwitch
    EndIf
    Return $GUI_RUNDEFMSG
 EndFunc   ;==>WM_COMMAND
#EndRegion
#EndRegion
Func duplicateStep()
   $listCount = _GUICtrlListView_GetItemCount($stepList)
   $Selected = _GUICtrlListView_GetSelectedIndices($stepList)
   $currentArr = StringSplit(_GUICtrlListView_GetItemTextString($stepList, $Selected+0),'|')
   ; insert this value for new row
   GUICtrlCreateListViewItem($listCount + 1 &"|"& $currentArr[2] & "|" & $currentArr[3]&"|"&$currentArr[4], $stepList)
EndFunc
Func reloadForm()
   ; reset testcase file name
   GUICtrlSetData($cmbFileName,'')
   GUICtrlSetData($cmbFileName,$testcase_FileName,'')
   ; reset testcase name
   GUICtrlSetData($txtTestcaseName,'')
   ; reset combo common function step
   GUICtrlSetData($idComboBox, '')
   GUICtrlSetData($idComboBox, $common_step, '')
   ; reset combo keyword
   GUICtrlSetData($cmbAgniKeyword, '')
   GUICtrlSetState($cmbAgniKeyword, $GUI_DISABLE)
   ; reset textbox name of keyword
   GUICtrlSetData($txtKeyword, '')
   ; reset list Step
   _GUICtrlListView_DeleteAllItems($stepList)
   ; Set default add_timestamp
   GUICtrlCreateListViewItem(_GUICtrlListView_GetItemCount($stepList)+1 &"|add_timestamp|add_timestamp", $stepList)
   ; update status button
   updateButtonStatus()
   GUICtrlSetState($addStepBtn, $GUI_DISABLE)
   GUICtrlSetState($upBtn, $GUI_DISABLE)
   GUICtrlSetState($downBtn, $GUI_DISABLE)
   ; reset output path
   GUICtrlSetData($outputHyperlink, '')
EndFunc

Func updateButtonStatus()
   $listCount = _GUICtrlListView_GetItemCount($stepList)
   If $listCount>0 Then
	  GUICtrlSetState($duplicateBtn, $GUI_ENABLE)
   Else
	  GUICtrlSetState($duplicateBtn, $GUI_DISABLE)
   EndIf
EndFunc