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



$FormLogin = GUICreate("Login", 400, 250, -1, -1); begining of Login
$PASSWORD = GUICtrlCreateInput("", 65, 167, 220, 21, BitOR($ES_PASSWORD,$ES_AUTOHSCROLL))
$ButtonOk = GUICtrlCreateButton("&OK", 200, 220, 75, 25, 0)
$ButtonCancel = GUICtrlCreateButton("&Cancel", 280, 220, 75, 25, 0)
$passwordlabel = GUICtrlCreateLabel("Password:", 8, 172, 50, 17)
$usernamelabel = GUICtrlCreateLabel("Username:", 8, 143, 52, 17)
$USERNAME = GUICtrlCreateInput("", 65, 144, 220, 21)
GUISetState(@SW_SHOW)



While 1
    $MSG = GUIGetMsg()
    Switch $MSG
    Case $ButtonOk
        If VerifyLogin(GUICtrlRead($USERNAME),GUICtrlRead($PASSWORD)) = 1 Then
            GUIDelete($FormLogin)
            MsgBox(-1,"Junipuer tool","Login Successful")
            RunP()
        Else
            MsgBox($MB_ICONERROR,"Error"," Username or Password is not correct !")
        EndIf
    Case -3
        ExitLoop
    Case $ButtonCancel
        ExitLoop
    EndSwitch
WEnd

Func VerifyLogin($USERNAME,$PASSWORD)
    If $USERNAME = "" And $PASSWORD = "" Then
        Return 1
    Else
        Return 0
    EndIf
EndFunc; End login



Func RunP()
Opt("GUIOnEventMode", 1);
;Your Code begining here
EndFunc
