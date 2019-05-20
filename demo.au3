#include <GuiComboBox.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

Global $cCombo1, $cCombo2

_Main()

Func _Main()

    ; Create GUI
    GUICreate("ComboBox Auto Complete", 400, 296)
    $cCombo1 = GUICtrlCreateCombo("", 2, 2, 396, 296)
    GUICtrlSetData(-1, "Apple|Orange|Tomato")
    $cCombo2 = GUICtrlCreateCombo("", 2, 42, 396, 296)
    GUICtrlSetData(-1, "One|Two|Three")
    GUISetState()

    GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")

    ; Loop until user exits
    Do
    Until GUIGetMsg() = $GUI_EVENT_CLOSE
    GUIDelete()
EndFunc   ;==>_Main

Func _Edit_Changed($cCombo)
    _GUICtrlComboBox_AutoComplete($cCombo)
EndFunc   ;==>_Edit_Changed

Func WM_COMMAND($hWnd, $iMsg, $iwParam, $ilParam)

    #forceref $hWnd, $iMsg, $ilParam

    $iIDFrom = BitAND($iwParam, 0xFFFF) ; Low Word
    $iCode = BitShift($iwParam, 16) ; Hi Word
    If $iCode = $CBN_EDITCHANGE Then
        Switch $iIDFrom
            Case $cCombo1
                _Edit_Changed($cCombo1)
            Case $cCombo2
                _Edit_Changed($cCombo2)
        EndSwitch
    EndIf
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND