#Include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>

$hGUI = GUICreate("Test", 300, 200)
$iLabel = GUICtrlCreateLabel("Test", 10, 10)
$iBtn = GUICtrlCreateButton("Exit", 200, 100, 60, 60)
$key = GUICtrlCreateInput("Keys to press (optional)", 16, 160, 145, 21)
ControlFocus($hGUI, "", $iLabel)
GUISetState()

GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")

Do
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE, $iBtn
            GUIDelete()
            Exit
    EndSwitch
Until False

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
    Switch $hWnd
        Case $hGUI
            Switch BitAND($wParam, 0xFFFF)
                Case $key
                    Switch BitShift($wParam, 16)
                        Case $EN_KILLFOCUS
                            If GUICtrlRead($key) = "" Then GUICtrlSetData($key, "Keys to press (optional)")
                        Case $EN_SETFOCUS
                            If GUICtrlRead($key) = "Keys to press (optional)" Then GUICtrlSetData($key, "")
                    EndSwitch
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND