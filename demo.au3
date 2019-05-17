#include <GUIConstants.au3>
#Include <GuiCombo.au3>
#include <file.au3>

GUICreate("ICDL Passwords", 200, 200)
GUISetState (@SW_SHOW)

GUICtrlCreateLabel("Students Name:", 15, 15)
$Username = GUICtrlCreateCombo("", 15, 35, 170, 20)
$old_string = ""
GUICtrlCreateLabel("Type the students name in full", 15, 65)
GUICtrlCreateLAbel("ie: firstname lastname", 15, 80)

$GetPassword = GUICtrlCreateButton("Get Password", 50, 160, 100)

$file = FileOpen(@ScriptDir&"\"&"users.txt", 0)
If $file = -1 Then
    MsgBox(0, "Error", "Unable to open file containing passwords")
    Exit
EndIf
$NumberOfLines = _FileCountLines(@ScriptDir&"\"&"users.txt")

$LineNumber = 1
$EndOfFile = ("EndOfFile")
While 1
    $Line = FileReadLine($File, $LineNumber)
    If @error = -1 Then ExitLoop
    $Line1 = Stringlen($Line)
    $Line2 = $line1 - 6
    $Line3 = StringRight($Line, $line2)
    _GUICtrlComboAddString($Username, $line3)
    $LineNumber = $lineNumber + 1
WEnd

While 1
    $msg = GUIGetMsg()
    Select
        Case $msg = $GUI_EVENT_CLOSE
            ExitLoop
        Case $msg = $GetPassword
            $UName = StringUpper(GUICtrlRead($Username))
            For $i = 0 To $NumberOfLines Step 1
            $line = FileReadLine($file, $i)
            If @error = -1 Then ExitLoop
            $UsernameAndPassword = StringRegExp($line, $Uname, 0)
                If @extended = 1 then
                    $Password = StringLeft($line, 6)
                    MsgBox(0, "Password Is", "The password for "&GUICtrlRead($Username)&" is: " &$Password)
                EndIF
            Next
        Case $msg = $Username
            MsgBox(0, "test", "case 4 was called")
        Case Else
            _GUICtrlComboAutoComplete ($USername, $old_string)
    EndSelect
WEnd