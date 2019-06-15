#include <MsgBoxConstants.au3>

; Retrieve 5 characters from the 10th position in the string.
Local $sString = StringMid("This is a sentence with whitespace.",1, 5)
MsgBox($MB_SYSTEMMODAL, "", $sString)