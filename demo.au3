#include <Array.au3>
#include <File.au3>

Run(@ComSpec & " /c " & 'echo *.log\ntcs.yaml\nconfig.json > .gitignore', "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)