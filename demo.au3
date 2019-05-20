#include <GUIConstantsEx.au3>
#include <WinAPI.au3>
#Include <GuiListBox.au3>
#include <WindowsConstants.au3>

Global $asKeyWords[21] = [20, "fight", "first", "fly", "third", "fire", "wall", "hi", "hello", "world", "window", _
        "window 1", "window 2", "window 3", "window 4", "window 5", "window 6", "window 7", "window 8", "window 9", "window 10"]

_Main()

Func _Main()
    Local $hGUI, $hList, $hInput, $aSelected, $sChosen, $hUP, $hDOWN, $hENTER, $hESC
    Local $sCurrInput = "", $aCurrSelected[2] = [-1, -1], $iCurrIndex = -1, $hListGUI = -1

    $hGUI = GUICreate("AutoComplete Input Text", 300, 100)
    GUICtrlCreateLabel('Start to type words like "window" or "fire" to test it:', 10, 10, 280, 20)
    $hInput = GUICtrlCreateInput("", 10, 40, 280, 20)
    GUISetState(@SW_SHOW, $hGUI)

    $hUP = GUICtrlCreateDummy()
    $hDOWN = GUICtrlCreateDummy()
    $hENTER = GUICtrlCreateDummy()
    $hESC = GUICtrlCreateDummy()
    Dim $AccelKeys[4][2] = [["{UP}", $hUP], ["{DOWN}", $hDOWN], ["{ENTER}", $hENTER], ["{ESC}", $hESC]]
    GUISetAccelerators($AccelKeys)

    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                ExitLoop

            Case $hESC
                If $hListGUI <> -1 Then ; List is visible.
                    GUIDelete($hListGUI)
                    $hListGUI = -1
                Else
                    ExitLoop
                EndIf

            Case $hUP
                If $hListGUI <> -1 Then ; List is visible.
                    $iCurrIndex -= 1
                    If $iCurrIndex < 0 Then
                        $iCurrIndex = 0
                    EndIf
                    _GUICtrlListBox_SetCurSel($hList, $iCurrIndex)
                EndIf

            Case $hDOWN
                If $hListGUI <> -1 Then ; List is visible.
                    $iCurrIndex += 1
                    If $iCurrIndex > _GUICtrlListBox_GetCount($hList) - 1 Then
                        $iCurrIndex = _GUICtrlListBox_GetCount($hList) - 1
                    EndIf
                    _GUICtrlListBox_SetCurSel($hList, $iCurrIndex)
                EndIf

            Case $hENTER
                If $hListGUI <> -1 And $iCurrIndex <> -1 Then ; List is visible and a item is selected.
                    $sChosen = _GUICtrlListBox_GetText($hList, $iCurrIndex)
                EndIf

            Case $hList
                $sChosen = GUICtrlRead($hList)
        EndSwitch

        Sleep(10)
        $aSelected = _GetSelectionPointers($hInput)
        If GUICtrlRead($hInput) <> $sCurrInput Or $aSelected[1] <> $aCurrSelected[1] Then ; Input content or pointer are changed.
            $sCurrInput = GUICtrlRead($hInput)
            $aCurrSelected = $aSelected ; Get pointers of the string to replace.
            $iCurrIndex = -1
            If $hListGUI <> -1 Then ; List is visible.
                GUIDelete($hListGUI)
                $hListGUI = -1
            EndIf
            $hList = _PopupSelector($hGUI, $hListGUI, _CheckInputText($sCurrInput, $aCurrSelected)) ; ByRef $hListGUI, $aCurrSelected.
        EndIf
        If $sChosen <> "" Then
            GUICtrlSendMsg($hInput, 0x00B1, $aCurrSelected[0], $aCurrSelected[1]) ; $EM_SETSEL.
            _InsertText($hInput, $sChosen)
            $sCurrInput = GUICtrlRead($hInput)
            GUIDelete($hListGUI)
            $hListGUI = -1
            $sChosen = ""
        EndIf
    WEnd
    GUIDelete($hGUI)
EndFunc   ;==>_Main

Func _CheckInputText($sCurrInput, ByRef $aSelected)
    Local $sPartialData = ""
    If (IsArray($aSelected)) And ($aSelected[0] <= $aSelected[1]) Then
        Local $aSplit = StringSplit(StringLeft($sCurrInput, $aSelected[0]), " ")
        $aSelected[0] -= StringLen($aSplit[$aSplit[0]])
        If $aSplit[$aSplit[0]] <> "" Then
            For $A = 1 To $asKeyWords[0]
                If StringLeft($asKeyWords[$A], StringLen($aSplit[$aSplit[0]])) = $aSplit[$aSplit[0]] And $asKeyWords[$A] <> $aSplit[$aSplit[0]] Then
                    $sPartialData &= $asKeyWords[$A] & "|"
                EndIf
            Next
        EndIf
    EndIf
    Return $sPartialData
EndFunc   ;==>_CheckInputText

Func _PopupSelector($hMainGUI, ByRef $hListGUI, $sCurr_List)
    Local $hList = -1
    If $sCurr_List = "" Then
        Return $hList
    EndIf
    $hListGUI = GUICreate("", 280, 160, 10, 62, $WS_POPUP, BitOR($WS_EX_TOOLWINDOW, $WS_EX_TOPMOST, $WS_EX_MDICHILD), $hMainGUI)
    $hList = GUICtrlCreateList("", 0, 0, 280, 150, BitOR(0x00100000, 0x00200000))
    GUICtrlSetData($hList, $sCurr_List)
    GUISetControlsVisible($hListGUI) ; To Make Control Visible And Window Invisible.
    GUISetState(@SW_SHOWNOACTIVATE, $hListGUI)
    Return $hList
EndFunc   ;==>_PopupSelector

Func _InsertText(ByRef $hEdit, $sString)
    #cs
        Description: Insert A Text In A Control.
        Returns: Nothing
    #ce
    Local $aSelected = _GetSelectionPointers($hEdit)
    GUICtrlSetData($hEdit, StringLeft(GUICtrlRead($hEdit), $aSelected[0]) & $sString & StringTrimLeft(GUICtrlRead($hEdit), $aSelected[1]))
    Local $iCursorPlace = StringLen(StringLeft(GUICtrlRead($hEdit), $aSelected[0]) & $sString)
    GUICtrlSendMsg($hEdit, 0x00B1, $iCursorPlace, $iCursorPlace) ; $EM_SETSEL.
EndFunc   ;==>_InsertText

Func _GetSelectionPointers($hEdit)
    Local $aReturn[2] = [0, 0]
    Local $aSelected = GUICtrlRecvMsg($hEdit, 0x00B0) ; $EM_GETSEL.
    If IsArray($aSelected) Then
        $aReturn[0] = $aSelected[0]
        $aReturn[1] = $aSelected[1]
    EndIf
    Return $aReturn
EndFunc   ;==>_GetSelectionPointers

Func GUISetControlsVisible($hWnd) ; By Melba23.
    Local $aControlGetPos = 0, $hCreateRect = 0, $hRectRgn = _WinAPI_CreateRectRgn(0, 0, 0, 0)
    Local $iLastControlID = _WinAPI_GetDlgCtrlID(GUICtrlGetHandle(-1))
    For $i = 3 To $iLastControlID
        $aControlGetPos = ControlGetPos($hWnd, '', $i)
        If IsArray($aControlGetPos) = 0 Then ContinueLoop
        $hCreateRect = _WinAPI_CreateRectRgn($aControlGetPos[0], $aControlGetPos[1], $aControlGetPos[0] + $aControlGetPos[2], $aControlGetPos[1] + $aControlGetPos[3])
        _WinAPI_CombineRgn($hRectRgn, $hCreateRect, $hRectRgn, 2)
        _WinAPI_DeleteObject($hCreateRect)
    Next
    _WinAPI_SetWindowRgn($hWnd, $hRectRgn, True)
    _WinAPI_DeleteObject($hRectRgn)
EndFunc   ;==>GUISetControlsVisible