#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include %A_ScriptDir%\Settings.ahk

GetControls() {
    Loop, Read, %mcDir%/options.txt
    {
        line = %A_LoopReadLine%
        if (InStr(line, "key")) {
            kv := StrSplit(line, ":")
            if (kv.MaxIndex() == 2) {
                key = % kv[1]
                value = % kv[2]
                StringReplace, key, key, %A_Space%,, All
                StringReplace, value, value, %A_Space%,, All
                if (InStr(value, "key.keyboard.")) {
                    split := StrSplit(value, "key.keyboard.")
                    StringLower, value, % split[2]
                }
                if (InStr(value, "key.mouse.")) {
                    split := StrSplit(value, "key.mouse.")
                    switch (split[2])
                    {
                        case "left":
                            value := "LButton"
                        case "right":
                            value := "RButton"
                        case "middle":
                            value := "MButton"
                        case "4":
                            value := "XButton1"
                        case "5":
                            value := "XButton2"
                    }
                }
                if (InStr(value, "left.")) {
                    split := StrSplit(value, "left.")
                    StringLower, value, % split[2]
                    value := "L" . value
                }
                if (InStr(value, "right.")) {
                    split := StrSplit(value, "right.")
                    StringLower, value, % split[2]
                    value := "R" . value
                }
                settings[key] := value
            }
        }
    }
}


