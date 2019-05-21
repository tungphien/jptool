#include <Word.au3>
#include <Array.au3>
;$sFilePath = "D:\PhienNT\Juniper\MTP\TC1_Interface_MTU_Fragmentation.docx"
Global $sPath = "D:\PhienNT\Juniper\MTP\01_ECMP_Add_New_Interfaces.docx"
Global $oWord = _Word_Create()
Global $oDoc = _Word_DocOpen($oWord, $sPath)
Global $oRange = $oDoc.Range
Global $sText = $oRange.Text
Global $aLines = StringSplit($sText, @CR)

For $element IN $aLines
   If StringInStr($element,'> show') Or  StringInStr($element,'> set') Then
	  ConsoleWrite($element& @CRLF)
   EndIf
Next

_Word_DocClose($oDoc)