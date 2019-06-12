#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>

Local $test[2][3] = [['this', 'is', 'a'], ['test', 'test', 'test']]
$Form1 = GUICreate("Form1", 623, 307, 192, 114)
$List = GUICtrlCreateListView("", 5,5, 400, 200)
_GUICtrlListView_InsertColumn($List, 0, "ID", 150)
_GUICtrlListView_InsertColumn($List, 1, "Name", 250)
_GUICtrlListView_InsertColumn($List, 2, "Description", 150)
_GUICtrlListView_AddArray($List, $test)
_GUICtrlListView_SetColumnWidth($List, 0, 0)
$Button1 = GUICtrlCreateButton("Button1", 16, 264, 75, 25)
$cDummy = GUICtrlCreateDummy()
GUISetState(@SW_SHOW)

GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")

While 1
    $nMsg = GUIGetMsg()
    Switch $nMsg
        Case $GUI_EVENT_CLOSE
            Exit
        Case $Button1, $cDummy
            MsgBox(0, "test", StringSplit(_GUICtrlListView_GetItemTextString($List), "|")[1])
    EndSwitch
WEnd


;===============================================================================
;
; Function Name:    _ListView_Sort()
; Description:      Sorting ListView items when column click
; Parameter(s):     $cIndex - Column index
; Return Value(s):  None
; Requirement(s):   AutoIt 3.2.12.0 and above
; Author(s):        R.Gilman (a.k.a rasim)
;
; ATTEMPT TO Mod for use with multi list views
;
;================================================================================
Func _ListView_Sort($Listview,$cIndex = 0)
    Local $iColumnsCount, $iDimension, $iItemsCount, $aItemsTemp, $aItemsText, $iCurPos, $iImgSummand, $i, $j

    $iColumnsCount = _GUICtrlListView_GetColumnCount($Listview)

    $iDimension = $iColumnsCount * 2

    $iItemsCount = _GUICtrlListView_GetItemCount($Listview)

    Local $aItemsTemp[1][$iDimension]

    For $i = 0 To $iItemsCount - 1
        $aItemsTemp[0][0] += 1
        ReDim $aItemsTemp[$aItemsTemp[0][0] + 1][$iDimension]

        $aItemsText = _GUICtrlListView_GetItemTextArray($Listview, $i)
        $iImgSummand = $aItemsText[0] - 1

        For $j = 1 To $aItemsText[0]
            $aItemsTemp[$aItemsTemp[0][0]][$j - 1] = $aItemsText[$j]
            $aItemsTemp[$aItemsTemp[0][0]][$j + $iImgSummand] = _GUICtrlListView_GetItemImage($Listview, $i, $j - 1)
        Next
    Next

    $iCurPos = $aItemsTemp[1][$cIndex]
    _ArraySort($aItemsTemp, 0, 1, 0, $cIndex)
    If StringInStr($iCurPos, $aItemsTemp[1][$cIndex]) Then _ArraySort($aItemsTemp, 1, 1, 0, $cIndex)

    For $i = 1 To $aItemsTemp[0][0]
        For $j = 1 To $iColumnsCount
            _GUICtrlListView_SetItemText($Listview, $i - 1, $aItemsTemp[$i][$j - 1], $j - 1)
            _GUICtrlListView_SetItemImage($Listview, $i - 1, $aItemsTemp[$i][$j + $iImgSummand], $j - 1)
        Next
    Next
EndFunc
;================================================================================

Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
    Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $hWndListView
    $hWndListView = $List
    If Not IsHWnd($List) Then $hWndListView = GUICtrlGetHandle($List)

    $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    $iCode = DllStructGetData($tNMHDR, "Code")

    Switch $hWndFrom
        Case $hWndListView
            Switch $iCode

                Case $LVN_COLUMNCLICK
                    Local $tInfo = DllStructCreate($tagNMLISTVIEW, $ilParam)
                    Local $ColumnIndex = DllStructGetData($tInfo, "SubItem")
                    _ListView_Sort($hWndFrom,$ColumnIndex)

                Case $NM_DBLCLK
                    ; Fire the dummy if the ListView is double clicked
                    GUICtrlSendToDummy($cDummy)

            EndSwitch
    EndSwitch

    Return $GUI_RUNDEFMSG
EndFunc