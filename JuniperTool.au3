#include <Date.au3>
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
#include <Word.au3>


; check upgrade
If checkUpdate() = True Then
   $answer = MsgBox(BitOR($MB_YESNO, $MB_ICONQUESTION), "Confirm", "Have new update for this tool! Do you want to upgrade? ")
   If  $answer = 6 Then ;If select OK
	 updateApp()
   EndIf
EndIf

Global $version = 'Version: 2.6'
Global $ComboBox_NameOfStep_Changed = False
Global $indexStepUpdate = Null
Global $COMMIT_FILE=''
Global $trackingUndoListView=''
Global $trackingRedoListView=''
Opt("GUIOnEventMode", 1);

#Region Loading
loadingProgress(500,"Load Juniper Tool","Openning Program")
Func loadingProgress($timeout, $title, $msg)
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
Global $userNameValue = ''
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
Global $hGUI = GUICreate("Juniper Tool - Phi�n Ng�", 600, 600)
GUICtrlCreateTab(0, 0, 603, 490)

#Region Tab Generate Yaml
GUICtrlCreateTabItem("Yaml")
GUICtrlCreateGroup("", 10, 20, 580, 80)
GUICtrlCreateLabel("Testcase file", 20, 40, 200)
Local $cmbFileName = GUICtrlCreateCombo("", 130, 40, 300)
GUICtrlCreateLabel("(*)", 440, 40)
GUICtrlSetColor (-1, $COLOR_RED )
Local $testcase_FileName = StringRegExpReplace(json_get($object,'[testcase_filename]'),'@\d+','')
GUICtrlCreateLabel("Name of testcase", 20, 70, 200)
Local $txtTestcaseName = GUICtrlCreateInput("name_of_testcase", 130, 70,300)
GUICtrlCreateLabel("(*)", 440, 70)
GUICtrlSetColor (-1, $COLOR_RED )
Local $loadMTPBtn = GUICtrlCreateButton("Load MTP", 460, 40,120,50)
GUICtrlSetTip(-1, "Click here to browse the MTP file.", 'Browse the MTP file', $TIP_INFOICON)
GUICtrlSetImage($loadMTPBtn,"icons\word.ico",221,0)

#Region Read tsc.yaml
Local $aInput
$file = "tcs.yaml"

_FileReadToArray($file, $aInput)
$common_keyword = ''
$common_step = ''
For $i = 1 to UBound($aInput) -1
    $data = getRegexPatten($aInput[$i],'#(.*)@')
	if Not $data='' Then
	  If $data='run_event' Or $data='run_keyword' Or $data='create_dictionary_and_get' Or $data='create_dictionary_and_check' Then
		 $common_keyword = $common_keyword &'|' & $data
	  Else
		 $common_step = $common_step &'|' & $data
	  EndIf
    EndIf
Next

#EndRegion

Local $cmbNameOfStep = GUICtrlCreateCombo("Name of step", 10, 110, 440, 21, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL, $CBS_SORT))
GUICtrlSetTip(-1, "You can input text or select the common step.", 'Name of step', $TIP_INFOICON)
Local $cmbKeyword = GUICtrlCreateCombo("", 10, 140,200,21, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL, $CBS_SORT))
GUICtrlSetTip(-1, "You can be select a Keyword", 'Name of Keyword', $TIP_INFOICON)
Local $cmbSubKeyword = GUICtrlCreateCombo("", 220, 140, 230,21,BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL, $CBS_SORT))
GUICtrlSetTip(-1, "You can be select a Sub-Keyword", 'Name of Sub-Keyword', $TIP_INFOICON)


Local $addStepBtn = GUICtrlCreateButton("Add", 460, 110,130,50)
GUICtrlSetTip(-1, "Add step into list.", 'Add step', $TIP_INFOICON)
GUICtrlSetImage($addStepBtn,"icons\add.ico",221,0)
Local $updateStepBtn = GUICtrlCreateButton("Update", 460, 110,130,50)
GUICtrlSetTip(-1, "Update the change of selected step.", 'Update step', $TIP_INFOICON)
GUICtrlSetImage($updateStepBtn,"icons\update.ico",221,0)


Local $deleteStepBtn = GUICtrlCreateButton("Delete", 530, 170,60,40)
GUICtrlSetTip(-1, "Delete step from list.", 'Delete step', $TIP_INFOICON)
GUICtrlSetImage($deleteStepBtn,"icons\delete.ico",221,0)
Local $downBtn = GUICtrlCreateButton("Down", 530, 270,60,40)
GUICtrlSetTip(-1, "Move down step.", 'Move down', $TIP_INFOICON)
GUICtrlSetImage($downBtn,"icons\down.ico",221,0)
Local $upBtn = GUICtrlCreateButton("Up", 530, 220,60,40)
GUICtrlSetTip(-1, "Move up step.", 'Move up', $TIP_INFOICON)
GUICtrlSetImage($upBtn,"icons\up.ico",221,0)
Local $duplicateBtn = GUICtrlCreateButton("Copy", 530, 320,60,40)
GUICtrlSetTip(-1, "Duplicate the selected step.", 'Duplicate step', $TIP_INFOICON)

GUICtrlSetImage($duplicateBtn,"icons\duplicate.ico",221,0)
Local $reloadBtn = GUICtrlCreateButton("Reload", 530, 370,60,40)
GUICtrlSetTip(-1, "Reset all data of elements on form.", 'Refresh form', $TIP_INFOICON)
GUICtrlSetImage($reloadBtn,"icons\reload.ico",221,0)

Local $stepList = GUICtrlCreateListView("", 10, 170, 510, 310)
GUICtrlSetTip(-1, "Double click on the row to Update."& @CRLF & "Ctrl + Z to Undo"& @CRLF & "Ctrl + Y to Redo", 'List of steps', $TIP_INFOICON)
; Add columns
_GUICtrlListView_InsertColumn($stepList, 0, "#", 30)
_GUICtrlListView_InsertColumn($stepList, 1, "Name of step", 150)
_GUICtrlListView_InsertColumn($stepList, 2, "Keyword", 150)
_GUICtrlListView_InsertColumn($stepList, 3, "Sub-Keyword", 150)
_GUICtrlListView_SetExtendedListViewStyle($stepList, BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT))

Local $generateStepBtn = GUICtrlCreateButton("Generate testcase", 530, 420, 60, 60, $BS_ICON)
GUICtrlSetTip(-1, "Generate steps into YAML file.", 'Generate YAML file', $TIP_INFOICON)
GUICtrlSetImage($generateStepBtn, "icons\yaml.ico", 1)
updateButtonStatus()
#EndRegion

#Region Tab Format Yaml
GUICtrlCreateTabItem("Format")
Local $inputFile = GUICtrlCreateInput("Path of yaml file",10, 40, 480,30)
Local $browseFileBtn = GUICtrlCreateButton("Browse file", 500, 40, 90, 30)

GUICtrlCreateGroup("Actions", 10, 80, 580, 70)
Local $formatFileBtn = GUICtrlCreateButton("Format and Re-Index Unique", 20, 105, 180, 30)
GUICtrlSetTip(-1, "Click here to format and re-index unique.", 'Format and Re-Index Unique', $TIP_INFOICON)
GUICtrlSetImage($formatFileBtn,"icons\format.ico",221,0)
#EndRegion

#Region Tab Setting
GUICtrlCreateTabItem("Setting")
Local $openOutputWhenDone = GUICtrlCreateCheckbox("Open output when done", 10, 30)
GUICtrlSetState($openOutputWhenDone, $GUI_CHECKED)
Local $inputAgniPath = GUICtrlCreateInput("",10, 60, 480,30)
GUICtrlSetData($inputAgniPath, json_get($object,'[agni_path]'))
Local $browseAgniPathBtn = GUICtrlCreateButton("Browse folder", 500, 60, 90, 30)
Local $refreshAgniKeywordBtn = GUICtrlCreateButton("Refresh Agni Keyword", 10, 100, 150, 30)
GUICtrlSetTip(-1, "Click here to get the latest keywords from your Agni directory.", 'Refresh Agni Keyword', $TIP_INFOICON)
GUICtrlSetImage($refreshAgniKeywordBtn,"icons\refresh.ico",221,0)
#EndRegion

#Region Tab About
GUICtrlCreateTabItem("About")
Local $lblAbout = GUICtrlCreateLabel("", 10, 30, 600,450)
GUICtrlSetData($lblAbout,"Author: Phi�n Ng� "& @CRLF & @CRLF &"* Prerequisite"& @CRLF &"- install python."& @CRLF &"- install git."& @CRLF & @CRLF &"* Functionals"& @CRLF &"- Format yaml file and re-index unique step."& @CRLF &"- Generate steps for testcase.")
#EndRegion

GUICtrlCreateTabItem("") ; end tabitem definition

Local $lblUserName = GUICtrlCreateLabel("", 10, 570, 200,30)
GUICtrlSetColor ($lblUserName, $COLOR_RED )
Local $lblPythonVersionValue = GUICtrlCreateLabel("", 260, 570, 100,30)
GUICtrlCreateLabel($version, 530, 570, 100,30)

GUICtrlCreateGroup("Output path", 10, 500, 580, 50)
Local $outputHyperlink = GUICtrlCreateInput("", 20, 520, 560, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY))
Local $PYTHON_FULLTEXT_VERSION =''
Local $PYTHON_CMD = getPythonVersion()

#EndRegion
#Region Keyboards detect
Local $ctrlY = GUICtrlCreateDummy()
Local $ctrlZ = GUICtrlCreateDummy()
Local $ctrlS = GUICtrlCreateDummy()
Local $hDelKey = GUICtrlCreateDummy()
Dim $AccelKeys[4][2]=[["^z", $ctrlZ], ["^y", $ctrlY], ["^s", $ctrlS],["{DELETE}", $hDelKey]]
GUISetAccelerators($AccelKeys)
GUICtrlSetOnEvent($ctrlZ, "_ControlZAction")
GUICtrlSetOnEvent($ctrlY, "_ControlYAction")
GUICtrlSetOnEvent($ctrlS, "_ControlSAction")
#EndRegion
$doubleClickDummy = GUICtrlCreateDummy()

GUICtrlSetOnEvent($duplicateBtn,'duplicateStep')
GUICtrlSetOnEvent($reloadBtn,'initForm')
GUICtrlSetOnEvent($refreshAgniKeywordBtn,'refreshAgniKeyword')
GUICtrlSetOnEvent($browseFileBtn, "browseYamlFile")
GUICtrlSetOnEvent($loadMTPBtn, "browseWordFile")
GUICtrlSetOnEvent($browseAgniPathBtn, "displayBrowseFolder")
GUICtrlSetOnEvent($formatFileBtn, "doFormat")
GUICtrlSetOnEvent($generateStepBtn, "doGenerateSteps")
GUICtrlSetOnEvent($addStepBtn, "addStep")
GUICtrlSetOnEvent($updateStepBtn,"updateStep")
GUICtrlSetOnEvent($deleteStepBtn, "deleteStep")
GUICtrlSetOnEvent($hDelKey, "deleteStep")
GUICtrlSetOnEvent($cmbKeyword, "changeComboKeyword")
GUICtrlSetOnEvent($cmbNameOfStep,"changeComboStep")
GUICtrlSetOnEvent($downBtn, "moveDownStep")
GUICtrlSetOnEvent($upBtn, "moveUpStep")
GUISetOnEvent($GUI_EVENT_PRIMARYDOWN,"_Arrange_ListStep")
GUISetOnEvent($GUI_EVENT_CLOSE, "_Close")
GUICtrlSetOnEvent($doubleClickDummy, "listDoubleClick")
GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")

While True
	;Sleep(200)
   Switch _GUICtrlComboBox_GetCurSel($cmbKeyword)
	  Case 4
		  _GUICtrlComboBox_SetCurSel($cmbKeyword, 5)
   EndSwitch
   If $ComboBox_NameOfStep_Changed Then
	 $ComboBox_NameOfStep_Changed = False
	 changeComboStep()
   EndIf
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
   initForm()
EndFunc

Func getListViewContent()
   $arrSteps=''
   For $x = 0 To _GUICtrlListView_GetItemCount($stepList) - 1
	  $itemText = _GUICtrlListView_GetItemTextString($stepList,$x)
	  $txtArr = StringSplit($itemText,'|')
	  $obj = ''
	  If StringInStr($common_step, $txtArr[2]) > 0 Then
		 $txtArr[3] = $txtArr[2]
	  EndIf
	  $obj = $obj & $txtArr[2] & '#' & $txtArr[3]
	  If StringStripWS($txtArr[4],  $STR_STRIPSPACES)<>'' Then
		 $obj = $obj & '#' & $txtArr[4]
	  EndIf
	  If $arrSteps<>'' Then
		 $arrSteps = $arrSteps & ',"' & $obj & '"'
	  Else
		 $arrSteps = '"' & $obj & '"'
	  EndIf
   Next
   Return $arrSteps
EndFunc

Func addTrackingLog($isRedo=False)
   If $isRedo = True Then
	  If $trackingRedoListView<>'' Then
		 If (StringInStr($trackingRedoListView,'@') <= 0 and $trackingRedoListView <> getListViewContent()) or (StringInStr($trackingRedoListView,'@') > 0 and StringInStr($trackingRedoListView, '@' & getListViewContent()) <=0 ) Then
			$trackingRedoListView = $trackingRedoListView &'@' & getListViewContent()
		 EndIf
	  Else
		 If $trackingRedoListView <> getListViewContent() Then
			$trackingRedoListView = getListViewContent()
		 EndIf
	  EndIf
   Else
	  If $trackingUndoListView<>'' Then
		 If (StringInStr($trackingUndoListView,'@') <= 0 and $trackingUndoListView <> getListViewContent()) or (StringInStr($trackingUndoListView,'@') > 0 and StringInStr($trackingUndoListView, '@' & getListViewContent()) <=0 ) Then
			$trackingUndoListView = $trackingUndoListView &'@' & getListViewContent()
		 EndIf
	  Else
		 If $trackingUndoListView <> getListViewContent() Then
			$trackingUndoListView = getListViewContent()
		 EndIf
	  EndIf
   EndIf
EndFunc

Func bindingDataListView($listviewData)
   $arrSteps= StringSplit($listviewData, ',')
   For $rd = 1 to UBound($arrSteps) - 1
	  $row = StringRegExpReplace($arrSteps[$rd],'\"',"")
	  $cols = StringSplit($row,'#')
	  $col2 =''
	  $col3 =''
	  $col4 =''
	  $numberOfCol = UBound($cols)-1
	  If  $numberOfCol >=1 Then
		 $col2= $cols[1]
	  EndIf
	  If StringInStr($common_step,$col2) <=0 Then
		 If  $numberOfCol >=2 Then
			$col3= $cols[2]
		 EndIf
		 If  $numberOfCol >=3 Then
			$col4= $cols[3]
		 EndIf
	  EndIf
	  GUICtrlCreateListViewItem( 1 &"|"& $col2 & "|" & $col3 &"|"&$col4, $stepList)
   Next
   updateIndexNumber()
EndFunc

Func handleTrackingLog($trackingLogData)
   $arr = StringSplit($trackingLogData,'@')
   $data = $arr[UBound($arr)-1]
   ; reset list Step
   _GUICtrlListView_DeleteAllItems($stepList)
   bindingDataListView($data)

  _ArrayDelete($arr, UBound($arr)-1)
  _ArrayDelete($arr, 0)
  $trackingLogData=_ArrayToString($arr, '@')
  Return $trackingLogData
EndFunc

Func _ControlZAction()
   if $trackingUndoListView <> '' Then
	  addTrackingLog(True)
	  $trackingUndoListView = handleTrackingLog($trackingUndoListView)
   EndIf
EndFunc

Func _ControlYAction()
   if $trackingRedoListView<>'' Then
	  addTrackingLog(False)
  	  $trackingRedoListView = handleTrackingLog($trackingRedoListView)
   EndIf
EndFunc

Func _ControlSAction()
   If $indexStepUpdate<>Null Then
	  updateStep()
   EndIf
EndFunc


#Region List Step Control
Func moveDownStep()
   addTrackingLog()
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
   addTrackingLog()
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
   addTrackingLog()
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
   addTrackingLog()
   $cmbNameOfStepValue = GUICtrlRead($cmbNameOfStep)
   $cmbKeywordValue = GUICtrlRead($cmbKeyword)
   $cmbSubKeywordValue = GUICtrlRead($cmbSubKeyword)
   If $cmbNameOfStepValue='' Or StringInStr($cmbNameOfStepValue,' ') Or (StringInStr($common_step,$cmbNameOfStepValue) <= 0 And $cmbKeywordValue = '') Then
	  MsgBox($MB_ICONERROR, "", "Invalid name of step ! Step must be have Keyword !")
   Else
	  If StringInStr($common_step,$cmbNameOfStepValue) > 0 Then
		 GUICtrlCreateListViewItem(_GUICtrlListView_GetItemCount($stepList)+1 &"|"& $cmbNameOfStepValue & "| | ", $stepList)
	  Else
		 GUICtrlCreateListViewItem(_GUICtrlListView_GetItemCount($stepList)+1 &"|"& $cmbNameOfStepValue & "|" & $cmbKeywordValue&"|"&$cmbSubKeywordValue, $stepList)
	  EndIf
   EndIf
   updateIndexNumber()
   updateButtonStatus()
EndFunc

Func updateStep()
   addTrackingLog()
   If $indexStepUpdate<>Null Then
	  $cmbNameOfStepValue = GUICtrlRead($cmbNameOfStep)
	  $cmbKeywordValue = GUICtrlRead($cmbKeyword)
	  $cmbSubKeywordValue = GUICtrlRead($cmbSubKeyword)
	  If $cmbNameOfStepValue='' Or StringInStr($cmbNameOfStepValue,' ') Or (StringInStr($common_step,$cmbNameOfStepValue) <= 0 And $cmbKeywordValue = '') Then
		 MsgBox($MB_ICONERROR, "", "Invalid name of step ! Step must be have Keyword !")
	  Else
		 _GUICtrlListView_SetItemText($stepList, $indexStepUpdate, $cmbNameOfStepValue , 1)
		 If StringInStr($common_step,$cmbNameOfStepValue) <= 0 Then
			_GUICtrlListView_SetItemText($stepList, $indexStepUpdate, $cmbKeywordValue , 2)
			_GUICtrlListView_SetItemText($stepList, $indexStepUpdate, $cmbSubKeywordValue, 3)
		 Else
			_GUICtrlListView_SetItemText($stepList, $indexStepUpdate, '' , 2)
			_GUICtrlListView_SetItemText($stepList, $indexStepUpdate, '', 3)
		 EndIf

		 ;set state for button add and update
		 GUICtrlSetState($updateStepBtn, $GUI_HIDE)
		 GUICtrlSetState($addStepBtn, $GUI_SHOW)
		 $indexStepUpdate = Null
	  EndIf
   EndIf
EndFunc

Func deleteStep()
   addTrackingLog()
   $iIndex = _GUICtrlListView_GetSelectedIndices($stepList)
   _GUICtrlListView_DeleteItem($stepList, $iIndex)
   updateIndexNumber()
   updateButtonStatus()
EndFunc

#EndRegion

Func changeComboStep()
   $comboValue = GUICtrlRead($cmbNameOfStep)
   If $comboValue <> '' Then
	  GUICtrlSetState($addStepBtn, $GUI_ENABLE)
	  If StringInStr($common_step, $comboValue)>0 Then
		 GUICtrlSetState($cmbKeyword, $GUI_DISABLE)
		 GUICtrlSetState($cmbSubKeyword, $GUI_DISABLE)
	  Else
		 GUICtrlSetState($cmbKeyword, $GUI_ENABLE)
		 GUICtrlSetState($cmbSubKeyword, $GUI_ENABLE)
	  EndIf
   Else
	  GUICtrlSetState($addStepBtn, $GUI_DISABLE)
	  GUICtrlSetState($cmbKeyword, $GUI_DISABLE)
	  GUICtrlSetState($cmbSubKeyword, $GUI_DISABLE)
   EndIf


EndFunc

Func changeComboKeyword()
   $comboValue = GUICtrlRead($cmbKeyword)
   ConsoleWrite($comboValue)
   If  StringInStr($comboValue, "--")>0 Then
	   $comboValue = ""
	   _GUICtrlComboBox_SetEditText($cmbKeyword, $comboValue)
   EndIf

   If $comboValue <>'' Then
	   bindingDataToAgniKeywordCombobox()
   EndIf
EndFunc

Func bindingDataToAgniKeywordCombobox()
   $comboValue = GUICtrlRead($cmbKeyword)
   If $comboValue=='run_event' Or $comboValue=='run_keyword' Then
	  GUICtrlSetState($cmbSubKeyword, $GUI_ENABLE)
	  If $comboValue=='run_event' Then
		 GUICtrlSetData($cmbSubKeyword, '')
		 GUICtrlSetData($cmbSubKeyword, json_get($object,'[run_event_keywords]'))
	  EndIf
	  If $comboValue=='run_keyword' Then
		 ; get all keyword from agni
		 GUICtrlSetData($cmbSubKeyword, '')
		 stringJoin($agni_keywors ,'|')
		 GUICtrlSetData($cmbSubKeyword, stringJoin($agni_keywors ,'|'))
	  EndIf
   Else
	  GUICtrlSetData($cmbSubKeyword, '')
	  GUICtrlSetState($cmbSubKeyword, $GUI_DISABLE)
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
	  loadingProgress(500,"Read new keywords from Agni folder","Reading...")
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
	  Local $arrSteps= StringRegExpReplace(getListViewContent(),',',' ')
	  $cmd =$PYTHON_CMD &' main.py -s ' & $arrSteps &' -tn "'& $testcaseName & '" -fn "'& $fileOfTestcase &'" -usr "'& $userNameValue & '"'
	  WriteLog($cmd)
	  Local $iPID = Run(@ComSpec & " /c " & $cmd, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	  loadingProgress(500,"Generate testcase","Processing...")

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
		   $cmd = $PYTHON_CMD & ' main.py -f "' & $filePath & '"'
		   WriteLog($cmd)
		   Local $iPID = Run(@ComSpec & " /c " & $cmd, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		   loadingProgress(500,"Format yaml file","Processing...")
		   $filePath = @ScriptDir & '\output\'& getFileNameFromPath($filePath)
		   GUICtrlSetData($outputHyperlink, $filePath)
		   OpenFile($filePath)
	   EndIf
	EndIf

EndFunc

Func getFileNameFromPath($path)
   Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
   Local $aPathSplit = _PathSplit($path, $sDrive, $sDir, $sFileName, $sExtension)
   Return $aPathSplit[$PATH_FILENAME] & $aPathSplit[$PATH_EXTENSION]
EndFunc

Func browseYamlFile()
   $sFileOpenDialog = displayBrowseFile('(*.yaml)')
   ControlSetText($hGUI,"",$inputFile, $sFileOpenDialog)
EndFunc

Func browseWordFile()
   $sFileOpenDialog = displayBrowseFile('(*.docx)}(*.doc)')
   If Not $sFileOpenDialog='' Then
	  handleMTP($sFileOpenDialog)
   EndIf
EndFunc

Func aliasNameByCharacter($str, $pattern, $character)
   $str = StringRegExpReplace($str,$pattern," ")
   $str = StringStripWS($str, $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)
   $str=StringLower(StringRegExpReplace($str,' ', $character))
   Return $str
EndFunc

Func handleMTP($sPath)
   GuiSetState(@SW_DISABLE, $hGUI)
   ProgressOn("Loading command from MTP file.", "Processing", "0%")
   Local $oWord = _Word_Create()
   Local $oDoc = _Word_DocOpen($oWord, $sPath)
   Local $oRange = $oDoc.Range
   Local $sText = $oRange.Text
   Local $aLines = StringSplit($sText, @CR)

   Local $all_commands[0]=[]
   $testcase_name='name_of_testcase'

   $RegExNonStandard="(?i)([^a-z0-9-_])|:|-"
   $i=0
   $found_name=False
   $line_count = UBound($aLines)
   For $element IN $aLines
	  If $i < $line_count-2 Then
		 $next_line_content = $aLines[$i+1]
		 If $element='Name' and $found_name=False Then
			$testcase_name = aliasNameByCharacter($next_line_content,$RegExNonStandard, "_")
			$found_name=True
		 Else
			If $element='Objective' and $found_name=False Then
			   $testcase_name = aliasNameByCharacter($next_line_content,$RegExNonStandard,"_")
			EndIf
		 EndIf
	  EndIf

	  $command = ''
	  If StringInStr($element,'# ') Then
		 $command = StringSplit($element,'#')[2]
		 $command = StringStripWS($command, $STR_STRIPLEADING)
		 _ArrayAdd($all_commands, $command ,0,@CRLF)
	  EndIf
	  If Not getRegexPatten($element,'>\s{0,}(show.*)')='' Then
		 $command = StringSplit($element,'>')[2]
		 $command = StringStripWS($command, $STR_STRIPLEADING)
		 _ArrayAdd($all_commands, $command,0,@CRLF)
	  EndIf
	  $i=$i+1
   Next
   ProgressSet(80, "80%")
   _Word_DocClose($oDoc)
   _Word_Quit($oWord)
   GUICtrlSetData($txtTestcaseName,$testcase_name)
   addStepByListCommands($all_commands)
   ProgressSet(100, "Complete", "Complete")
   ProgressOff()
   GuiSetState(@SW_ENABLE, $hGUI)
EndFunc

Func addStepByListCommands($all_commands)
   ; reset list Step
   _GUICtrlListView_DeleteAllItems($stepList)
   ; set default value
   GUICtrlCreateListViewItem(_GUICtrlListView_GetItemCount($stepList)+1 &"|add_timestamp|", $stepList)
   If UBound($all_commands)<=0 Then
	   MsgBox($MB_ICONERROR, "", "This MTP have no test log !")
   Else
	  For $command In $all_commands
		 $step_name = aliasNameByCharacter($command,'\s+|/|-|\|',"_")
		 $keyword = 'run_keyword'
		 $sub_keyword = ''
		 $mk_command = StringRegExpReplace($step_name,'run_',"", 1)
		 ; check if command already exist in common steps
		 If StringInStr($common_step, $mk_command) Then
			GUICtrlCreateListViewItem(_GUICtrlListView_GetItemCount($stepList)+1 &"|"& $mk_command & "| | ", $stepList)
		 Else
			If getRegexPatten($command,'^show\s.*') Then
			   $keyword = 'create_dictionary_and_check'
			   $step_name = StringRegExpReplace($step_name,'^show_',"verify_")
			Else
			   If getRegexPatten($command,'^set\s.*') or getRegexPatten($command,'^commit\s.*') or getRegexPatten($command,'^delete\s.*') Then
				  $keyword = 'run_event'
				  $sub_keyword = 'On CLI'
			   Else
				  $keyword = 'run_keyword'
			   EndIf
			EndIf
			GUICtrlCreateListViewItem(_GUICtrlListView_GetItemCount($stepList)+1 &"|"& $step_name & "|" & $keyword&"|"&$sub_keyword, $stepList)
		 EndIf
	  Next
   EndIf
EndFunc

Func displayBrowseFile($format)
   ;ConsoleWrite("your yaml file (*." & $format & ")")
	; Create a constant variable in Local scope of the message to display in FileOpenDialog.
	Local Const $sMessage = "Select your files."

	; Display an open dialog to select a list of file(s).
	Local $sFileOpenDialog = FileOpenDialog($sMessage, @WindowsDir & "\", "Select your file in format "& $format &"", $FD_FILEMUSTEXIST)
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
		Return $sFileOpenDialog
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
   Local $consoleOutput = getOutputOfProcess($python_version_cmd)
   $PYTHON_FULLTEXT_VERSION = $consoleOutput
   Return 'python'
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
	  Run('"' & $editor  & '" "' & $file_path & '"')
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

Func getRegexPatten($content, $patten)
   $result=''
   Local $aArray = StringRegExp($content,$patten, $STR_REGEXPARRAYGLOBALMATCH)
   For $i = 0 To UBound($aArray) - 1
	  $result = $aArray[$i]
   Next
   Return $result
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
    $iIDFrom = BitAND($iwParam, 0xFFFF) ; Low Word
    $iCode = BitShift($iwParam, 16) ; Hi Word
    If $iCode = $CBN_EDITCHANGE Then
        Switch $iIDFrom
            Case $cmbSubKeyword
                _Edit_Changed($cmbSubKeyword)
			Case $cmbNameOfStep
				_Edit_Changed($cmbNameOfStep)
			   Switch $iCode
				   Case $CBN_EDITUPDATE, $CBN_EDITCHANGE ; when user types in new data
					   ; _Combo_Changed()
					   $ComboBox_NameOfStep_Changed = True
				   Case $CBN_SELCHANGE ; item from drop down selected
					   ;_Combo_Changed()
					   $ComboBox_NameOfStep_Changed = True
				   ;Case $CBN_KILLFOCUS
					   ;_Combo_LostFocus()
				   ;Case $CBN_SETFOCUS
					   ;_Combo_GotFocus()
			   EndSwitch
        EndSwitch
    EndIf
    Return $GUI_RUNDEFMSG
 EndFunc   ;==>WM_COMMAND
#EndRegion


Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
    Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $hWndListView
    $hWndListView = $stepList
    If Not IsHWnd($stepList) Then $hWndListView = GUICtrlGetHandle($stepList)

    $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    $iCode = DllStructGetData($tNMHDR, "Code")

    Switch $hWndFrom
        Case $hWndListView
            Switch $iCode
                Case $NM_DBLCLK
                  ; Fire the dummy if the ListView is double clicked
				  GUICtrlSendToDummy($doubleClickDummy)
				  $indexStepUpdate = _GUICtrlListView_GetSelectedIndices($stepList)
		 EndSwitch
    EndSwitch

    Return $GUI_RUNDEFMSG
 EndFunc

Func listDoubleClick()
   $currentArr = StringSplit(_GUICtrlListView_GetItemTextString($stepList),'|')
   If $currentArr[2]<>'' Then
	  ;binding data to the input when double click
	  _GUICtrlComboBox_SetEditText ( $cmbNameOfStep, $currentArr[2])
	  If StringInStr($common_step, $currentArr[2]) > 0 Then
		 _GUICtrlComboBox_SetEditText ( $cmbKeyword, '')
	  Else
		 _GUICtrlComboBox_SetEditText ( $cmbKeyword, $currentArr[3])
	  EndIf
	  _GUICtrlComboBox_SetEditText($cmbSubKeyword, $currentArr[4])
	  GUICtrlSetState($updateStepBtn, $GUI_SHOW)
	  GUICtrlSetState($addStepBtn, $GUI_HIDE)
   Else
	  MsgBox($MB_ICONERROR, "", "The row select to update must be without empty !")
   EndIf
EndFunc

#EndRegion
Func duplicateStep()
   $listCount = _GUICtrlListView_GetItemCount($stepList)
   $Selected = _GUICtrlListView_GetSelectedIndices($stepList)
   $currentArr = StringSplit(_GUICtrlListView_GetItemTextString($stepList, $Selected+0),'|')
   ; insert this value for new rown
   GUICtrlCreateListViewItem($listCount + 1 &"|"& $currentArr[2] & "|" & $currentArr[3]&"|"&$currentArr[4], $stepList)
EndFunc
Func initForm()
   GuiSetState(@SW_DISABLE, $hGUI)
   ProgressOn("Initialing tool", "Processing", "0%")
   GUICtrlSetState($updateStepBtn, $GUI_HIDE)
   GUICtrlSetState($addStepBtn, $GUI_SHOW)
   $selected_row = Null
   ; reset testcase file name
   GUICtrlSetData($cmbFileName,'')
   GUICtrlSetData($cmbFileName, $testcase_FileName, "routing_interfaces.yaml")
   ; reset testcase name
   GUICtrlSetData($txtTestcaseName,'')
   ; reset combo common function step
   GUICtrlSetData($cmbKeyword, '')
   GUICtrlSetData($cmbKeyword, $common_keyword, '')
   ; reset combo keyword
   GUICtrlSetData($cmbSubKeyword, '')
   GUICtrlSetState($cmbSubKeyword, $GUI_DISABLE)
   ; reset combo name of keyword
   GUICtrlSetData($cmbNameOfStep,$common_step , '')
   ; reset list Step
   _GUICtrlListView_DeleteAllItems($stepList)
   ; Set default add_timestamp
   GUICtrlCreateListViewItem(_GUICtrlListView_GetItemCount($stepList)+1 &"|add_timestamp|", $stepList)
   ; update status button
   updateButtonStatus()
   GUICtrlSetState($addStepBtn, $GUI_DISABLE)
   GUICtrlSetState($upBtn, $GUI_DISABLE)
   GUICtrlSetState($downBtn, $GUI_DISABLE)
   ; reset output path
   GUICtrlSetData($outputHyperlink, '')
   GUICtrlSetData($lblPythonVersionValue,$PYTHON_FULLTEXT_VERSION)
   ProgressSet(80, "80%")

   ; add tracking
   $trackingUndoListView=''
   $trackingRedoListView=''
   addTrackingLog()
   ProgressSet(100, "Complete", "Complete")
   ProgressOff()
   GuiSetState(@SW_ENABLE, $hGUI)
EndFunc

Func updateButtonStatus()
   $listCount = _GUICtrlListView_GetItemCount($stepList)
   If $listCount>0 Then
	  GUICtrlSetState($duplicateBtn, $GUI_ENABLE)
   Else
	  GUICtrlSetState($duplicateBtn, $GUI_DISABLE)
   EndIf
EndFunc

Func checkUpdate()
   ProgressOn("Checking for update tool", "Checking...", "0%")
   $isNeedToUpdate = False
   if FileExists('.git')==0 Then
	  $pID = Run(@ComSpec & " /c " & "git init & git remote add origin https://github.com/tungphien/jtool_update.git", "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	  $isNeedToUpdate = True
	  Return $isNeedToUpdate
   EndIf

   $pID = Run(@ComSpec & " /c " & "git fetch origin", "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
   Local $consoleOutput = getOutputOfProcess($pID)
   Sleep(500)
   WriteLog($consoleOutput)
   WriteLog('==================')
   $pID = Run(@ComSpec & " /c " & "git log origin/master -p -1", "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
   Sleep(500)
   Local $consoleOutput = getOutputOfProcess($pID)
   WriteLog($consoleOutput)
   $commit_id = getRegexPatten($consoleOutput,'commit\s*(.*)\n*Author')
   $commit_file_name = 'commit-'& $commit_id &'.log'
   ProgressSet(80, "80%")
   if FileExists($commit_file_name)==0 Then
	  $COMMIT_FILE = $commit_file_name
	  $isNeedToUpdate = True
   Else
	  $isNeedToUpdate =False
   EndIf
   ProgressSet(100, "Complete", "Complete")
   ProgressOff()
   Return $isNeedToUpdate
EndFunc

Func updateApp()
   GUISetState(@SW_HIDE, $hGUI)
   loadingProgress(300,"Upgrade the Tool","Upgrading...")
   Local $prevCommitFiles = _FileListToArray(@ScriptDir, "commit-*.log")
   For $i = 0 To UBound($prevCommitFiles) - 1
	  FileDelete($prevCommitFiles[$i])
   Next
   WriteLog('', $COMMIT_FILE)
   FileSetAttrib($COMMIT_FILE,"+H")
   Run("updater.exe", "")
   _Close()
EndFunc

Func WriteLog($content, $fileName='app.log')
   _FileWriteLog(@ScriptDir & '\'& $fileName, $content)
EndFunc
