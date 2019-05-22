#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <Word.au3>
#include <Array.au3>
;$sFilePath = "D:\PhienNT\Juniper\MTP\TC1_Interface_MTU_Fragmentation.docx"
Global $sPath = "D:\PhienNT\Juniper\MTP\2_2_1_Interface_Hold_down _Timers..docx"
Global $oWord = _Word_Create()
Global $oDoc = _Word_DocOpen($oWord, $sPath)
Global $oRange = $oDoc.Range
Global $sText = $oRange.Text
Global $aLines = StringSplit($sText, @CR)

Local $all_commands[0]=[]
$testcase_name='name_of_testcase'

$RegExNonStandard="(?i)([^a-z0-9-_])|:|-"
$i=0
$found_name=False
For $element IN $aLines
   If $element='Name' and $found_name=False Then
	  $s = StringRegExpReplace($aLines[$i+1],$RegExNonStandard," ")
	  $s = StringStripWS($s, $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)
	  $testcase_name=StringLower(StringRegExpReplace($s,' ',"_"))
	  $found_name=True
   Else
	  If $element='Objective' and $found_name=False Then
		 $s = StringRegExpReplace($aLines[$i+1],$RegExNonStandard," ")
		 $s = StringStripWS($s, $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)
		 $testcase_name=StringLower(StringRegExpReplace($s,' ',"_"))
	  EndIf
   EndIf

   $command = ''
   If StringInStr($element,'# ') Then
	  $command = StringSplit($element,'#')[2]
	  _ArrayAdd($all_commands, $command,0,@CRLF)
	  ConsoleWrite($element&@CRLF)
   EndIf
   If Not getRegexByGroup($element,'>\s{0,}(show.*)',0)='' Then
	  $command = StringSplit($element,'>')[2]
	  _ArrayAdd($all_commands, $command,0,@CRLF)
	  ConsoleWrite($element&@CRLF)
   EndIf
   $i=$i+1
Next
ConsoleWrite("NAME:"&$testcase_name)
;_Word_DocClose($oDoc)
;_Word_Quit($oWord)



Func getRegexByGroup($content, $patten, $groupIndex)
   $result=''
   Local $aArray = StringRegExp($content,$patten, $STR_REGEXPARRAYFULLMATCH)
   For $i = 0 To UBound($aArray) - 1
	  $result = $aArray[$i]
   Next
   Return $result
EndFunc

