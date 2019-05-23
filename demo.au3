#include <GuiConstantsEx.au3>
#include <GuiComboBox.au3>

Opt("GUIOnEventMode", 1)

Global $ComboBox_Changed = False
Global Const $DebugIt = 1

Global Const $WM_COMMAND = 0x0111

$hGUI = GUICreate("My GUI combo")  ; Will create a dialog box that when displayed is centered
GUISetOnEvent($GUI_EVENT_CLOSE, "_Terminate")

$hCombo = _GUICtrlComboBox_Create($hGUI, "item1|item2|item3", 10, 10) ; Create Combo items

; Set a default item
_GUICtrlComboBox_SelectString ($hCombo, "item2")

$btn = GUICtrlCreateButton("Ok", 40, 75, 60, 20)
GUICtrlSetOnEvent(-1, "OKPressed")

GUISetState()
GUIRegisterMsg($WM_COMMAND, "MY_WM_COMMAND")

; Just idle around
While 1
    Sleep(10)

    If $ComboBox_Changed Then
        $ComboBox_Changed = False

        _Combo_Changed()
    EndIf
WEnd

Func OKPressed()
    MsgBox(0, "OK Pressed", "ID=" & @GUI_CtrlId & " WinHandle=" & @GUI_WinHandle & " CtrlHandle=" & @GUI_CtrlHandle)
EndFunc   ;==>OKPressed

Func _Terminate()
    Exit
EndFunc   ;==>_Terminate

Func _Combo_GotFocus()
    ;----------------------------------------------------------------------------------------------
    If $DebugIt Then _DebugPrint("_Combo_GotFocus")
    ;----------------------------------------------------------------------------------------------
EndFunc   ;==>_Combo_GotFocus

Func _Combo_LostFocus()
    ;----------------------------------------------------------------------------------------------
    If $DebugIt Then _DebugPrint("_Combo_LostFocus")
    ;----------------------------------------------------------------------------------------------
EndFunc   ;==>_Combo_LostFocus

Func _Combo_Changed()
    ;----------------------------------------------------------------------------------------------
    If $DebugIt Then _DebugPrint("Combo Changed: " & _GUICtrlComboBox_GetEditText ($hCombo))
    ;----------------------------------------------------------------------------------------------
EndFunc   ;==>_Combo_Changed

Func MY_WM_COMMAND($hWnd, $msg, $wParam, $lParam)
    Local $nNotifyCode = _HiWord($wParam)
    Local $hID = _LoWord($wParam)
    Local $hCtrl = $lParam

    Switch $hCtrl
        Case $hCombo
            Switch $nNotifyCode
                Case $CBN_EDITUPDATE, $CBN_EDITCHANGE ; when user types in new data
                    ; _Combo_Changed()
                    $ComboBox_Changed = True
                Case $CBN_SELCHANGE ; item from drop down selected
                    ;_Combo_Changed()
                    $ComboBox_Changed = True
                Case $CBN_KILLFOCUS
                    _Combo_LostFocus()
                Case $CBN_SETFOCUS
                    _Combo_GotFocus()
            EndSwitch
    EndSwitch
    ; Proceed the default Autoit3 internal message commands.
    ; You also can complete let the line out.
    ; !!! But only 'Return' (without any value) will not proceed
    ; the default Autoit3-message in the future !!!
    Return $GUI_RUNDEFMSG
EndFunc   ;==>MY_WM_COMMAND

Func _DebugPrint($s_Text, $line = @ScriptLineNumber)
    ConsoleWrite( _
            "!===========================================================" & @LF & _
            "+======================================================" & @LF & _
            "-->Line(" & StringFormat("%04d", $line) & "):" & @TAB & $s_Text & @LF & _
            "+======================================================" & @LF)
EndFunc   ;==>_DebugPrint

Func _HiWord($x)
    Return BitShift($x, 16)
EndFunc   ;==>_HiWord

Func _LoWord($x)
    Return BitAND($x, 0xFFFF)
EndFunc   ;==>_LoWord