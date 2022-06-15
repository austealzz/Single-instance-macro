#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#SingleInstance, Force
#Include %A_ScriptDir%\functions2.ahk


; i know this is a silly macro, but this is a "better" version of ronkzinho's singleinstance macro :)
; Credits: austealzz (me), ronkzinho, Ravalle/Joe for leting me use most of the code :D
; Version 3.14159265359

; settings
#Include Settings.ahk

for each, program in launchPrograms {
    SplitPath, program, filename, dir
    isOpen := False
    for proc in ComObjGet("winmgmts:").ExecQuery(Format("Select * from Win32_Process where CommandLine like ""%{1}%""", filename)) {
        isOpen := True
        break
    } 
    if (!isOpen)
        Run, %filename%, %dir%
}
if (OpenMinecraftLauncher)
SplitPath, resetMacro, filename, dir
isOpen := False
for proc in ComObjGet("winmgmts:").ExecQuery(Format("Select * from Win32_Process where CommandLine like ""%{1}%""", filename)) {
    isOpen := True
    break
} 
if (!isOpen)
    Run, %filename%, %dir%

if (FileExist(multiMCLocation . "MultiMC.exe")) {
            Run, %multiMCLocation%MultiMC.exe
} else {
   if (OpenMinecraftLauncher)
    Run, "C:\Program Files (x86)\Minecraft Launcher\Minecraft Launcher.exe"
}



; Please dont touch this
global onpreview := 0
global lastReset := 0
global mcDir := StrReplace(savesDirectory, "saves\", "")
global settings := []


savesDirectory := RegExReplace(savesDirectory, "saves(\/|\\)*", "saves\")

SetKeyDelay, 0

IfNotExist, %savesDirectory%
   msgBox, Please set your saves directory!!!

IfNotExist, %savesDirectory%_oldWorlds
FileCreateDir, %savesDirectory%_oldWorlds

Icon = %A_ScriptDir%/media/3x.ico
if (FileExist(Icon))
    Menu, Tray, Icon, %Icon%
    Menu, Tray, Tip, SingleInstance Macro Manager

If (MessageBox)
MsgBox, Press Control P to widen your game :)
WinActivate, Minecraft* 1.16.1

GetControls()
GetSettings()

Widen() {
    newHeight := Floor(A_ScreenHeight / 2.5)
    yPos := (A_ScreenHeight/2) - (newHeight/2)
    WinMaximize, Minecraft*
    WinRestore, Minecraft*
    Sleep, 200
    WinMove, Minecraft*,, 0, %yPos%, %A_ScreenWidth%, %newHeight%
}

inFullscreen()
{
   optionsFile := StrReplace(savesDirectory, "saves\", "options.txt")
   FileReadLine, fullscreenLine, %optionsFile%, 17
   if (InStr(fullscreenLine, "true"))
      return 1
   else
      return 0
}


CheckLogs(key)
{
   numLines := 0
   found := False
   {
   Loop, Read, %mcDir%logs/latest.log
      numLines += 1
   }
   Loop, Read, %mcDir%logs/latest.log
   {
      if ((numLines - A_Index) < 1)
      {
         if (InStr(A_LoopReadLine, key)){
            OutputDebug, % A_LoopReadLine
            found := True
         }
      }
   }

   return found
}


CheckJoinedWorld()
{
   return CheckLogs("Loaded 0")
}

CheckPreview()
{
   return CheckLogs("Starting Preview")
}

Move()
{
	Loop, Files, %savesDirectory%*, D
   {
     _Check :=SubStr(A_LoopFileName,1,1)
      If (_Check!="_")
      {
        FileMoveDir, %savesDirectory%%A_LoopFileName%, %savesDirectory%_oldWorlds\%A_LoopFileName%%A_NowUTC%, R
      }
   }
}

Attempts()
{
   FileRead, wv, attempts.txt
   if errorlevel
   wv := 0
   wv += 1
   filedelete, attempts.txt
   fileappend, attempts.txt %wv%
   FileRead, wv, attempts_Day.txt
   if errorlevel
   wv := 0
   wv += 1
   filedelete, attempts_Day.txt
   fileappend, %wv%, attempts_Day.txt
}


Reset()
{
   lp := settings["key_LeavePreview"]
   lastReset := A_NowUTC
   SetTimer, waitForGame, Off
   if (onpreview == 1)
   {
      ControlSend,, {Blind}{%lp%}, Minecraft*
      SetTimer, waitForGame, Off
      onpreview := 0
      if (ResetSounds)
      ResetSound()
   }
   Else {
      ResetSettings()
      Sleep, 890
      Send, {Blind}{Esc}+{Tab}{Enter}
      if (ResetSounds)
      ResetSound()
   }
}


Setup()
{  
   Sleep, %freezingWaitingDelay%
   SetTimer, waitForGame, Off
   Loop
   {
      if (A_NowUTC - lastReset >= 20)
      {
         SetTimer, waitForGame, Off
         onpreview := False
         break
         return
      }
      if (CheckPreview()){
         onpreview := True
         ControlSend,, {F3 down}{Esc}{F3 up}, Minecraft
         SetTimer, waitForGame, 20
         break
      }
      else if (A_NowUTC - lastReset >= 5 && CheckJoinedWorld()){
         break
         return
      }
   }
   Until onpreview
}

ResetSettingsOnWorldLoad() {
    GetSettings()
    fovPresses := (110 - FOV) * 143 / 80
    renderPresses := (32 - renderDistance) * 143 / 30
    entityPresses := (5 - entityDistance) * 143 / 4.5
    SetKeyDelay, 1
    if (FOV != (options.fov * 40 + 70) || renderDistance != options.renderDistance || entityDistance != options.entityDistanceScaling) {
        ControlSend,, {Blind}{Esc}{Tab 6}{Enter}{Tab}, Minecraft*
        if (FOV != currentFOV) {
            SetKeyDelay, 0
            ControlSend,, {Blind}{Right 143}, Minecraft*
            ControlSend,, {Blind}{Left %fovPresses%}, Minecraft*
            SetKeyDelay, 1
        }
        ControlSend,, {Blind}{Tab 5}{Enter}{Tab 4}, Minecraft*
        if (renderDistance != currentRenderDistance) {
            SetKeyDelay, 0
            ControlSend,, {Blind}{Right 143}, Minecraft*
            ControlSend,, {Blind}{Left %renderPresses%}, Minecraft*
            SetKeyDelay, 1
        }
        if (entityDistance != currentEntityDistance) {
            ControlSend,, {Blind}{Tab 13}, Minecraft*
            SetKeyDelay, 0
            ControlSend,, {Blind}{Right 143}, Minecraft*
            ControlSend,, {Blind}{Left %entityPresses%}, Minecraft*
            ControlSend,, {Blind}{Esc}, Minecraft*
        }
        ControlSend,, {Blind}{Esc}, Minecraft*
    }
    SetKeyDelay, 0
    SensPresses := ceil(mouseSensitivity/1.408)
    ControlSend,, {Blind}{Esc}{Tab 6}{enter}{Tab 7}{enter}{tab}{enter}{tab}{Left 150}{Right %SensPresses%}{Esc 3}, Minecraft*
    Sleep, 200
    ControlSend,, {F3 down}{Esc}{F3 up}, Minecraft*
}


ResetSettings() {
    global performanceMethod, lowRender, renderDistance, entityDistance, FOV
    GetSettings()
    fovPresses := (110 - FOV) * 143 / 80
    desiredRd := performanceMethod == "S" ? lowRender : renderDistance
    renderPresses := desiredRd - 2
    entityPresses := (5 - entityDistance) * 143 / 4.5
    SetKeyDelay, 0
    if (desiredRd != settings.renderDistance) {
        ControlSend,, {Blind}{Shift down}{F3 down}{F 32}{F3 up}{Shift up}, Minecraft*
        ControlSend,, {Blind}{F3 down}{F %renderPresses%}{D}{F3 up}, Minecraft*
    }
    if (FOV != (settings.fov * 40 + 70) || entityDistance != settings.entityDistanceScaling) {
        ControlSend,, {Blind}{Esc}{Tab 6}{Enter}{Tab}, Minecraft*
        if (FOV != currentFOV) {
            ControlSend,, {Blind}{Right 143}, Minecraft*
            ControlSend,, {Blind}{Left %fovPresses%}, Minecraft*
        }
        if (entityDistance != settings.entityDistanceScaling) {
            ControlSend,, {Blind}{Tab 5}{Enter}{Tab 17}, Minecraft*
            SetKeyDelay, 0
            ControlSend,, {Blind}{Right 143}, Minecraft*
            ControlSend,, {Blind}{Left %entityPresses%}, Minecraft*
        }
        ControlSend,, {Blind}{Esc 2}, Minecraft*
    }


    SensPresses := ceil(mouseSensitivity/1.408)
    ControlSend,, {Blind}{Esc}{Tab 6}{enter}{Tab 7}{enter}{tab}{enter}{tab}{Left 150}{Right %SensPresses%}{Esc 3}, Minecraft*
}


GetSettings() {
    Loop, Read, %mcDir%/options.txt
    {
        line = %A_LoopReadLine%
        if (!InStr(line, "key")) {
            kv := StrSplit(line, ":")
            if (kv.MaxIndex() == 2) {
                key = % kv[1]
                value = % kv[2]
                StringReplace, key, key, %A_Space%,, All
                StringReplace, value, value, %A_Space%,, All
                settings[key] := value
            }
        }
    }
}


ResetSound()
{
   SoundPlay, %A_ScriptDir%\media\reset.wav
}

CheckBlind()
{
   ControlSend,, {Esc}{Tab 7}{Enter}{Tab 4}{Enter}{Tab}{Enter}, Minecraft
   ControlSend,, {f3 down}{n}{f3 up}, Minecraft
   Send, {t}
   Sleep, 100
   Send, {/}
   Send, locate stronghold{Enter}

}
CheckNether()
{
   ControlSend,, {Esc}{Tab 7}{Enter}{Tab 4}{Enter}{Tab}{Enter}, Minecraft
   ControlSend,, {f3 down}{n}{f3 up}, Minecraft
   Send, {t}
   Sleep, 100
   Send, {/}
   Send, locate fortress{Enter}
   Sleep, 100
   Send, {t}
   Sleep, 100
   Send {/}
   Send, locate bastion_remnant{Enter}
}

ResetUsingLan()
{
   ControlSend,, {Esc}{Tab 7}{Enter}{Tab 4}{Enter}{Tab}{Enter}, Minecraft
   ControlSend,, {f3 down}{n}{f3 up}, Minecraft
   Sleep, 100
   Send, {t}
   Sleep, 100
   Send, {/}
   Send, locate buried_treasure{Enter}
   Sleep, 100
   Send, {t}
   Sleep, 100
   Send, {/}
   Send, locate shipwreck{Enter}
}

waitForGame:
   if (lastReset == "") {
      SetTimer, waitForGame, Off
      return
   }
   if (A_NowUTC - lastReset >= 60)
   {
      onpreview := False
      SetTimer, waitForGame, Off
   }
   if (CheckJoinedWorld() && onpreview)
   {
      ResetSettingsOnWorldLoad()
      onpreview := False
      SetTimer, waitForGame, Off
   }
   return

SetTimer, waitForGame, Off
#IfWinExist, Minecraft*
{
   U::
   Reset()
   Setup()
   Move()
   Attempts()
   return

   ^J::
   ResetUsingLan()
   return

   End::
   ResetSettings()
   return

   ^P::
   Widen()
   return

   ^G::
   CheckNether()
   return

   ^H::
   CheckBlind()
   return
}

{
   F5::Reload

   F12::Exit
}



