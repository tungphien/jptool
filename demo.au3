#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <Marquee.au3>

Const $GetMsg = "This is a test sample."

$hGUI = GUICreate("", 500, 100, -1, -1, -1, $WS_EX_TOPMOST)
GUISetBkColor(0xC0C0C0)

; Marquee
$aMarquee = _GUICtrlMarquee_Init()
;;;;;_GUICtrlMarquee_SetScroll($aMarquee, "", "Slide", "Left", 2, 1)
;_GUICtrlMarquee_SetScroll($iIndex, $iLoop = Default, $sMove = Default, $sDirection = Default, $iScroll = Default, $iDelay = Default)
_GUICtrlMarquee_SetScroll($aMarquee, 0, Default, "Left", 20, 1)
_GUICtrlMarquee_SetDisplay($aMarquee, 0, 0x000000, 0xC0C0C0, 8.5, "Courier New")
_GUICtrlMarquee_Create($aMarquee, $GetMsg, 80, 16, 300, 20)

GUISetState()

Do
Until GUIGetMsg() = -3