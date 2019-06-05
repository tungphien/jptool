#include <GUIConstants.au3>
#include <WinAPIFiles.au3>
update()
Func update()
   $pID = Run(@ComSpec & " /c " & "git reset --hard origin/master", "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
   $pID = Run(@ComSpec & " /c " & "git pull https://tungphien:f4715c5b44ec0c14cda116cf7effb7fd568315ed@github.com/tungphien/jtool_update.git", "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
   MsgBox($MB_SYSTEMMODAL, "", "Update completed !")
   Run("JuniperTool.exe", "")
   Exit(0)
EndFunc