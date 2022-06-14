#NoEnv
SetWorkingDir %A_ScriptDir%

; macro settings
global MessageBox := False ; option to toggle MessageBoxes while opening the macro
global savesDirectory := "" ; saves folder **CASE SENSITIVE**
global launchPrograms := ["E:\speedrun\Ninjabrain-Bot-1.3.0.jar", "E:\speedrun\ModCheck-0.3.jar"] ; put a "" to actually make it work, your apps location to open, change this to whatever u want, if u dont want to launch programs just set this to []
global OpenMinecraftLauncher := False ; if you want to open multimc or the minecraft launcher automatically
global multiMCLocation := "" ; u dont need to fill this out, only if u want to launch ur minecraft launchers automatically


; in game settings
global renderDistance := 10
global fov := 110 ; Normal = 70, Quake pro = 110
global mouseSensitivity := 52
global entityDistance := 0.5 ; 50% = 0.5, 500% = 5

; preferences
global ResetSounds := False ; if you want to play the old reset sounds
