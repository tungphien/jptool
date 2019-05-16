#include <GUIConstants.au3>
#include <GuiListView.au3>
#include <misc.au3>
Opt("GUIOnEventMode", 1);

GUICreate("", 200, 400)
GUISetState(@SW_SHOW)

$Listview = GUICtrlCreateListView("filename", 0, 0, 200, 400);
_GUICtrlListView_SetExtendedListViewStyle($Listview, BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT, $LVS_EX_CHECKBOXES))

GUISetOnEvent($GUI_EVENT_CLOSE, "_Close")
GUISetOnEvent($GUI_EVENT_PRIMARYDOWN,"_Arrange_List")

_Create_List()

While True
    Sleep(200)
WEnd

Func _Create_List()
    Local $Item
    While $Item <> "XXXXXXXX"
        $Item = $Item & "X"
        GUICtrlCreateListViewItem($Item, $Listview)
    Wend
Endfunc

Func _Arrange_List()
    $Selected = _GUICtrlListView_GetHotItem($Listview)
    If $Selected = -1 then Return
    While _IsPressed(1)
    WEnd
    $Dropped = _GUICtrlListView_GetHotItem($Listview)
    If $Dropped > -1 then
        _GUICtrlListView_BeginUpdate($Listview)
        If $Selected < $Dropped Then
            _GUICtrlListView_InsertItem($Listview, _GUICtrlListView_GetItemTextString($Listview, $Selected), $Dropped + 1)
            _GUICtrlListView_SetItemChecked($Listview, $Dropped + 1, _GUICtrlListView_GetItemChecked($Listview, $Selected))
            _GUICtrlListView_DeleteItem($Listview, $Selected)
        ElseIf $Selected > $Dropped Then
            _GUICtrlListView_InsertItem($Listview, _GUICtrlListView_GetItemTextString($Listview, $Selected), $Dropped)
            _GUICtrlListView_SetItemChecked($Listview, $Dropped, _GUICtrlListView_GetItemChecked($Listview, $Selected + 1))
            _GUICtrlListView_DeleteItem($Listview, $Selected + 1)
        EndIf
        _GUICtrlListView_EndUpdate($Listview)
    EndIf
EndFunc

Func _Close()
    Exit(0)
EndFunc