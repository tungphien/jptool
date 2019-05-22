#include <MsgBoxConstants.au3>
#include <StringConstants.au3>

; Strip leading and trailing whitespace as well as the double spaces (or more) in between the words.
MsgBox($MB_SYSTEMMODAL, "", $sString)
Local $sString = StringStripWS("   This   is   a   sentence   with   whitespace.    ", $STR_STRIPLEADING)
MsgBox($MB_SYSTEMMODAL, "", $sString)