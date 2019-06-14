
#include <GUIConstantsEx.au3>
#include <ListViewConstants.au3>
#include <WindowsConstants.au3>
#include <GUIListView.au3>

#Region ### START Koda GUI section ### Form=
$Form1 = GUICreate("Form1", 355, 226, 192, 114)
$ListView1 = GUICtrlCreateListView("col1|col2|col3", 48, 16, 250, 150, BitOR($LVS_REPORT,$LVS_SHOWSELALWAYS), BitOR($WS_EX_CLIENTEDGE,$LVS_EX_FULLROWSELECT))
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 0, 50)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 1, 50)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 2, 50)
$ListView1_0 = GUICtrlCreateListViewItem("a1|b1|c1", $ListView1)
$ListView1_1 = GUICtrlCreateListViewItem("a2|b2|c2", $ListView1)
$ListView1_2 = GUICtrlCreateListViewItem("a3|b3|c3", $ListView1)
$Button1 = GUICtrlCreateButton("Button1", 136, 184, 75, 25)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

While 1
    $nMsg = GUIGetMsg()
    Switch $nMsg
        Case $GUI_EVENT_CLOSE
            Exit
        Case $Button1
            MsgBox(4160, "Information", "Selected Indices: " & _GUICtrlListView_GetSelectedIndices($ListView1))
    EndSwitch
WEnd