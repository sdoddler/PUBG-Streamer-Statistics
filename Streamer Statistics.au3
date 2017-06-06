#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Resources\Helmet Icon.ico
#AutoIt3Wrapper_Outfile=PUBG Streamer Statistics.Exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         sDoddler

	Script Function:
	Template AutoIt script.

	Plan - have a Program that streamers can use to create Text Files that update regularly to display stats on stream

	Main Gui = Large Drop down of "Categories"
	Each Category shows certain options that you can choose and then clikc "Add to list"
	- Then prompts on where to save the file.
	- Adds to List or Listview

	- Can Group Wins/Kills from Solo/Duo/Squad together.
	- Use a drop down to choose "Solo, Duo, Squad or ALL"

	Can increase or decrease *refresh time* -- Not currently Available.
	Can minimise to tray.


#ce ----------------------------------------------------------------------------


#include <Array.au3>
#include <File.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ComboConstants.au3>
#include <ButtonConstants.au3>
#include <TrayConstants.au3>
#include <Guilistview.au3>
#include <GuiRichEdit.au3>
#include <Color.au3>
#include <Misc.au3>
#include "_PUBG_ME.au3"

$appDir = @AppDataDir & "\PUBG Streamer Statistics\"
If Not (FileExists($appDir)) Then DirCreate($appDir)

if not (FileExists(@ScriptDir & "\Resources\Stats")) Then DirCreate(@ScriptDir & "\Resources\Stats")

$scriptDir = @ScriptDir
FileChangeDir(@ScriptDir)


FileInstall(".\resources\blep4.jpg", $appDir & "blep4.jpg")
FileInstall(".\resources\plus.ico", $appDir & "plus.ico")
FileInstall(".\resources\delete.ico", $appDir & "delete.ico")

FileInstall(".\resources\twitter_icon.ico", $appDir & "twitter_icon.ico")
FileInstall(".\resources\mudrpg_icon.ico", $appDir & "mudrpg_icon.ico")
FileInstall(".\resources\website_icon.ico", $appDir & "website_icon.ico")
FileInstall(".\resources\github.ico", $appDir & "github.ico")
FileInstall(".\resources\pubgme.ico", $appDir & "pubgme.ico")



If StringRight($scriptDir, 1) <> "\" Then $scriptDir &= "\"
Global $settings = $appDir & "Settings.ini", $saveini = $appDir & "UpdateStats.ini"
Global $lastSaveDir = IniRead($settings, "Settings", "LastSaveDir", @ScriptDir)
Global $testTick = 0

;; ===== Settings Menu On/Off =======
Global $enableSettings = False
;; ========


;;====== THIS IS WHERE WE TURN THE TIMER ON AND OFF =======
Global $autoUpdate = True
if $autoUpdate Then $tUpdate = TimerInit()
;;======

;; Default User Load
$def_user = IniRead($settings,"Settings","DefaultUser","sDoddler")

; ============ Tray Items Start ============
; 1= prmarydown or left click
Opt("TrayMenuMode", 3)
; Set tray Icon
;~ TraySetIcon("Shell32.dll", -87)
;only show the menu when prmarydown or left click
TraySetClick(9)
; Put some Items in the tray
$RefreshTray = TrayCreateItem("Manual Refresh")
$RestoreTray = TrayCreateItem("Restore")
$ExitTray = TrayCreateItem("Exit")
; ============ Gui Items Start ============

Opt("GuiResizeMode", $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKSIZE)

#Region ====== hMain GUI ======

$hMain = GUICreate("PUBG Streamer Stats", 495, 495, -1, -1, $WS_MINIMIZEBOX + $WS_SIZEBOX)

$mFile = GUICtrlCreateMenu("File")
if $enableSettings then
$mSettings = GUICtrlCreateMenuItem("Settings", $mFile, -1, 0)
else
	$mSettings = -1234567
EndIf
$mMinimizeToTray = GUICtrlCreateMenuItem("Minimize to Tray", $mFile, -1, 0)

$def_minimizeToTray = IniRead($settings, "Settings", "MinimizeToTray", True)
_LOG($def_minimizeToTray)
If $def_minimizeToTray = 1 	Then 	$def_minimizeToTray = True
If $def_minimizeToTray = 0 	Then 	$def_minimizeToTray = False
_Log($def_minimizeToTray)
If $def_minimizeToTray Then
	GUICtrlSetState($mMinimizeToTray, $GUI_CHECKED)
EndIf
$def_StatName = IniRead($settings, "Settings", "IncludeStatName",False)

If $def_StatName = 1 	Then 	$def_StatName = True
If $def_StatName = 0 	Then 	$def_StatName = False

$mManualRefresh = GUICtrlCreateMenuItem("Manual Refresh (all files)", $mFile, -1, 0)
$mExit = GUICtrlCreateMenuItem("Exit", $mFile, -1, 1)

GUICtrlCreateLabel("PUBG Streamer Stats", 10, 10, 250)
GUICtrlSetFont(-1, 16)

GUICtrlCreateGraphic(5, 30, 500, 20)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKSIZE)
GUICtrlSetGraphic(-1, $GUI_GR_COLOR, 0xA1A1A1)
GUICtrlSetGraphic(-1, $GUI_GR_MOVE, 0, 5)
GUICtrlSetGraphic(-1, $GUI_GR_LINE, 400, 5)

$gTwitterIcon = GUICtrlCreateIcon($appDir & "twitter_icon.ico", 0, 300, 2, 32, 32)
GUICtrlSetCursor($gTwitterIcon, 0)
GUICtrlSetTip($gTwitterIcon, "Follow for updates on the program as it develops :)", "sDoddler's Twitter Page")

$gGithubIcon = GUICtrlCreateIcon($appDir & "github.ico", 0, 335, 2, 32, 32)
GUICtrlSetCursor($gGithubIcon, 0)
GUICtrlSetTip($gGithubIcon, "Source code and more info at my Github for PUBG Streamer Statistics.", "My GitHub for this Project")

$gPUBGMEIcon = GUICtrlCreateIcon($appDir & "pubgme.ico", 0, 370, 2, 32, 32)
GUICtrlSetCursor($gPUBGMEIcon, 0)
GUICtrlSetTip($gPUBGMEIcon, " ", "PUBG.ME")

$gMudrpgIcon = -4563653
$gWebsiteIcon = -4198031
;~ $gMudrpgIcon = GUICtrlCreateIcon($appDir & "mudrpg_icon.ico", 0, 335, 2, 32, 32)
;~ GUICtrlSetCursor($gMudrpgIcon, 0)
;~ GUICtrlSetTip($gMudrpgIcon, "MUDRPG is an interactive chat based game. Check it out <3", "My Side project on Twitch.tv")
;~ $gWebsiteIcon = GUICtrlCreateIcon($appDir & "website_icon.ico", 0, 370, 2, 32, 32)
;~ GUICtrlSetCursor($gWebsiteIcon, 0)
;~ GUICtrlSetTip($gWebsiteIcon, " ", "sDoddler's Website")

GUICtrlCreatePic($appDir & "blep4.jpg", 410, 3, 76, 310)

GUICtrlCreateLabel("Categories:", 10, 50, 100)
GUICtrlSetFont(-1, 12)


$str_Categories = "Play|Wins|Kills"
$def_Category = IniRead($settings, "Settings", "DefaultCategory", "Kills")
$gCategories = GUICtrlCreateCombo("", 120, 48, 200, 35, $CBS_DROPDOWNLIST)
GUICtrlSetData(-1, $str_Categories, $def_Category)
GUICtrlSetFont(-1, 12)

$globalCategory = $def_Category

#Region ======= Play GUI =======
Dim $play_array[12]
$play_array[0] = GUICtrlCreateGroup("Play", 5, 80, 400, 170)

$play_array[10] = GUICtrlCreateRadio("Rating", 10, 100)
GUICtrlSetState(-1, $GUI_CHECKED)

$play_array[11] = GUICtrlCreateRadio("Rank", 10, 120)

$play_array[1] = GUICtrlCreateRadio("Rounds Played", 10, 140)

$play_array[3] = GUICtrlCreateRadio("Days Played", 10, 160)

$play_array[4] = GUICtrlCreateRadio("Total Distance", 10, 180)

$play_array[5] = GUICtrlCreateRadio("Average Distance", 10, 200)

$play_array[6] = GUICtrlCreateRadio("Average Dist. on Foot", 10, 220)

$play_array[7] = GUICtrlCreateRadio("Average Dist. in Vehicle", 140, 100)

$play_array[8] = GUICtrlCreateRadio("Weapons Acquired", 140, 120)

$play_array[9] = GUICtrlCreateRadio("Stats Last Updated", 140, 140)

#CS === TIME PLAYED CURRENTLY NOT AVAILABLE ===
$play_array[2] = GUICtrlCreateRadio("Time Played", 140, 140) ;; Currently does not track properly.
GUICtrlSetState($play_array[2], $GUI_DISABLE)
GUICtrlSetState($play_array[2], $GUI_HIDE)
#CE === TIME PLAYED CURRENTLY NOT AVAILABLE ===
#EndRegion ======= Play GUI =======

#Region ======= Wins GUI =======
Dim $wins_array[14]
$wins_array[0] = GUICtrlCreateGroup("Wins", 5, 80, 400, 170)

$wins_array[1] = GUICtrlCreateRadio("Wins", 10, 100)
GUICtrlSetState(-1, $GUI_CHECKED)

$wins_array[13] = GUICtrlCreateRadio("Win Rating", 10, 120)

$wins_array[3] = GUICtrlCreateRadio("Win Rank", 10, 140)

$wins_array[4] = GUICtrlCreateRadio("Win Rate %", 10, 160)

$wins_array[2] = GUICtrlCreateRadio("Top 10s", 10, 180)

$wins_array[5] = GUICtrlCreateRadio("Top 10 Rate %", 10, 200)

$wins_array[6] = GUICtrlCreateRadio("Average Time Survived", 10, 220)

$wins_array[7] = GUICtrlCreateRadio("Longest Time Survived", 140, 100)

$wins_array[8] = GUICtrlCreateRadio("Total Heals", 140, 120)

$wins_array[9] = GUICtrlCreateRadio("Total Boosts", 140, 140)

$wins_array[10] = GUICtrlCreateRadio("Team Kills", 140, 160)

$wins_array[11] = GUICtrlCreateRadio("Suicides", 140, 180)

$wins_array[12] = GUICtrlCreateRadio("Revives", 140, 200)
#EndRegion ======= Wins GUI =======

#Region ======= Kills GUI =======
Dim $kills_array[15]
$kills_array[0] = GUICtrlCreateGroup("Kills", 5, 80, 400, 170)

$kills_array[1] = GUICtrlCreateRadio("Players Killed", 10, 100)
GUICtrlSetState(-1, $GUI_CHECKED)

$kills_array[2] = GUICtrlCreateRadio("Assists", 10, 120)

$kills_array[14] = GUICtrlCreateRadio("Kill Rating", 10, 140)

$kills_array[3] = GUICtrlCreateRadio("Kill Rank", 10, 160)

$kills_array[4] = GUICtrlCreateRadio("Headshots", 10, 180)

$kills_array[5] = GUICtrlCreateRadio("Longest Kill", 10, 200)

$kills_array[6] = GUICtrlCreateRadio("Total Damage Dealt", 10, 220)

$kills_array[7] = GUICtrlCreateRadio("Vehicles Destroyed", 140, 100)

$kills_array[8] = GUICtrlCreateRadio("Road Kills", 140, 120)

$kills_array[9] = GUICtrlCreateRadio("K/D Ratio", 140, 140)

$kills_array[10] = GUICtrlCreateRadio("Most Kills", 140, 160)

$kills_array[11] = GUICtrlCreateRadio("Kill Streak", 140, 180)

; Average Damage
$kills_array[12] = GUICtrlCreateRadio("Average Damage", 140, 200)

; DBNO
$kills_array[13] = GUICtrlCreateRadio("DBNO", 140, 220)
#EndRegion ======= Kills GUI =======


GUICtrlCreateLabel("PUBG Username:", 5, 263, 100)
GUICtrlSetFont(-1,9)

$gUser = GUICtrlCreateInput($def_user, 110, 258)

$gCheckStat = GUICtrlCreateCheckbox("Include Stat Name in File", 230, 258)

If $def_StatName Then
	GUICtrlSetState($gCheckStat, $GUI_CHECKED)
EndIf

GUICtrlCreateLabel("Region:", 5, 293, 45)
GUICtrlSetFont(-1, 9)

$str_regions = "AS|EU|NA|OC|SA"
$def_region = IniRead($settings, "Settings", "DefaultRegion", "OC")
$gRegions = GUICtrlCreateCombo("", 50, 288, 105, 35, $CBS_DROPDOWNLIST)
GUICtrlSetData(-1, $str_regions, $def_region)
GUICtrlSetFont(-1, 10)

GUICtrlCreateLabel("Game Mode:", 160, 293, 100)
GUICtrlSetFont(-1, 9)

$str_modes = "Solo|Duo|Squad|All"
$def_mode = IniRead($settings, "Settings", "DefaultMode", "Solo")
$gMode = GUICtrlCreateCombo("", 233, 288, 100, 35, $CBS_DROPDOWNLIST)
GUICtrlSetData(-1, $str_modes, $def_mode)
GUICtrlSetFont(-1, 10)

_ModeSwitch($def_mode)

;~ $encMinus = GUICtrlCreateButton("", 265, $winHeight - 105, 40, 40, $BS_ICON)
;~ GUICtrlSetImage(-1, $iconsIcl, 19)
;~ GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT + $GUI_DOCKWIDTH)

$bAdd = GUICtrlCreateButton("", 345, 288, 24, 24, $BS_ICON)
GUICtrlSetImage(-1, $appDir & "plus.ico", 0, 0)

$bDel = GUICtrlCreateButton("", 380, 288, 24, 24, $BS_ICON)
GUICtrlSetImage(-1, $appDir & "delete.ico", 0, 0)



Local $iStylesEx = BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT, $LVS_EX_SUBITEMIMAGES)
$idListview = GUICtrlCreateListView("", 5, 320, 482, 125, BitOR($LVS_SHOWSELALWAYS, $LVS_REPORT))
GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKBOTTOM)
_GUICtrlListView_SetExtendedListViewStyle($idListview, $iStylesEx)

_GUICtrlListView_AddColumn($idListview, "Filename")
_GUICtrlListView_AddColumn($idListview, "Username")
_GUICtrlListView_AddColumn($idListview, "Stat")
_GUICtrlListView_AddColumn($idListview, "Mode")
_GUICtrlListView_AddColumn($idListview, "Region")
_GUICtrlListView_AddColumn($idListview, "Include Stat Name")


#EndRegion ====== hMain GUI ======
;;;;;; ========================


_CategorySwitch($globalCategory)
_LoadRules()


$def_interval = Iniread($settings, "Settings", "DefaultInterval",60)
;======== Setting Default Interval Manually while API Not Released ======
$def_interval = 300
;========
$def_UseAPIKey = Iniread($settings, "Settings", "UseAPIKey",0)
$def_APIKey = Iniread($settings, "Settings", "CustomAPIKey","")
$def_hideAPI = IniRead($settings, "Settings", "HideAPIKey",1)

_Log("Default Interval: " & $def_interval)
_Log("Interval *1000 = " & $def_interval *1000)

GUISetState()



#Region ====== Settings GUI ======

$hSettings = GUICreate("Settings", 300, 200, -1, -1, $WS_POPUP + $WS_BORDER)

GUICtrlCreateLabel("Username: ", 10,12) ;<====== Change this to STEAM ID If necessary and provide Link on how to find it.

;$gUser = GUICtrlCreateInput($def_user,100,10,100)

GUICtrlCreateLabel("Refresh Interval: ", 10, 43)

$gInterval = GUICtrlCreateCombo("",100,40,100,-1,$CBS_DROPDOWNLIST)
GUICtrlSetData(-1,"30|60|90|120|240|300",$def_interval)

;~ GUICtrlCreateLabel("", 10, 72)
$cbCustomAPIKey = GUICtrlCreateCheckbox("Use Custom API Key",10,70)
if $def_UseAPIKey > 0 Then GUICtrlSetState(-1, $GUI_CHECKED)
$gAPIKey = GUICtrlCreateInput($def_APIKey,10,100)
if $def_hideAPI = 1 Then
	GUICtrlSetStyle($gAPIKey, $ES_PASSWORD ,$WS_EX_CLIENTEDGE)
	GUICtrlSendMsg($gAPIKey, $EM_SETPASSWORDCHAR, Asc("*"), 0)
EndIf
if $def_UseAPIKey = 0 Then GUICtrlSetState(-1, $GUI_DISABLE)


$cbHideAPI = GUICtrlCreateCheckbox("Hide",130,100)
if $def_hideAPI = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
if $def_UseAPIKey = 0 Then GUICtrlSetState(-1, $GUI_DISABLE)

GUISetFont(12)
$gSetSave = GUICtrlCreateButton("Save", 10, 165)

$gSetCancel = GUICtrlCreateButton("Cancel", 235, 165)

GUISetFont(8.5)

#EndRegion ====== Settings GUI ======

While 1

	$msg = GUIGetMsg(1)

	Switch $msg[1]
		Case $hMain
			Switch $msg[0]
				Case $GUI_EVENT_CLOSE
					_Exit()
				Case $GUI_EVENT_MINIMIZE
					if $def_minimizeToTray Then _GuiMinimizeToTray($hMain)
				Case $mSettings
					GUISetState(@SW_DISABLE, $hMain)
					GUISetState(@SW_SHOW, $hSettings)

				Case $mExit
					_Exit()
				Case $gMudrpgIcon
					ShellExecute('https://twitch.tv/mudrpg')
				Case $gGithubIcon
					ShellExecute('https://github.com/sdoddler/PUBG-Streamer-Statistics')
				Case $gTwitterIcon
					ShellExecute('https://twitter.com/sdoddler')
				Case $gPUBGMEIcon
					ShellExecute('https://pubg.me')
				Case $gWebsiteIcon
					ShellExecute('https://www.sdoddler.com/pubg')
				Case $gCategories
					$globalCategory = GUICtrlRead($gCategories)
					_CategorySwitch($globalCategory)
				Case $gMode
					$globalMode = GUICtrlRead($gMode)
					_ModeSwitch($globalMode)
				Case $bAdd
					_AddRule()
				Case $bDel
					_DelRules()
				Case $mMinimizeToTray
					If BitAND(GUICtrlRead($mMinimizeToTray), $GUI_CHECKED) = $GUI_CHECKED Then
						GUICtrlSetState($mMinimizeToTray, $GUI_UNCHECKED)
						$def_minimizeToTray = False
					Else
						GUICtrlSetState($mMinimizeToTray, $GUI_CHECKED)
						$def_minimizeToTray = True
					EndIf
					_Log($def_minimizeToTray)

				Case $gCheckStat
					If BitAND(GUICtrlRead($gCheckStat), $GUI_CHECKED) = $GUI_CHECKED Then

						$def_StatName = True
					Else

						$def_StatName = False
					EndIf
				Case $mManualRefresh
					_AutoUpdate()
			EndSwitch
		Case $hSettings
			Switch $msg[0]
				Case $gSetCancel
					_CancelSettings()
					GUISetState(@SW_ENABLE, $hMain)
					GUISetState(@SW_HIDE, $hSettings)

				Case $gSetSave
					_SaveSettings()
					GUISetState(@SW_ENABLE, $hMain)
					GUISetState(@SW_HIDE, $hSettings)

				Case $cbCustomAPIKey
					If BitAND(GUICtrlRead($cbCustomAPIKey), $GUI_CHECKED) = $GUI_CHECKED Then
						GUICtrlSetState($gAPIKey, $GUI_ENABLE)
						GUICtrlSetState($cbHideAPI, $GUI_ENABLE)

					Else
						GUICtrlSetState($gAPIKey, $GUI_DISABLE)
						GUICtrlSetState($cbHideAPI, $GUI_DISABLE)
					EndIf
				Case $cbHideAPI
					If BitAND(GUICtrlRead($cbHideAPI), $GUI_CHECKED) = $GUI_CHECKED Then
;~ 						GUICtrlSetStyle($gAPIKey, $ES_PASSWORD ,$WS_EX_CLIENTEDGE)
						GUICTRlsetstate($gAPIKey, @SW_LOCK)
						GUICtrlSendMsg($gAPIKey, $EM_SETPASSWORDCHAR, Asc("*"), 0)

						GUICTRlsetstate($gAPIKey, @SW_UNLOCK)
					Else
						GUICTRlsetstate($gAPIKey, @SW_LOCK)
;~ 						GUICtrlSetStyle($gAPIKey, -1,$WS_EX_CLIENTEDGE)
						GUICtrlSendMsg($gAPIKey, $EM_SETPASSWORDCHAR, 0, 0)
						GUICTRlsetstate($gAPIKey, @SW_UNLOCK)
					EndIf
			EndSwitch

	EndSwitch

	; switch to get tray messages
	$tmsg = TrayGetMsg()
	Switch $tmsg
		Case $TRAY_EVENT_PRIMARYDOUBLE
			WinSetState($hMain, "", @SW_RESTORE)
			WinActivate($hMain)
		Case $RestoreTray
			WinSetState($hMain, "", @SW_RESTORE)
			WinActivate($hMain)
		Case $RefreshTray
			_AutoUpdate()
		Case $ExitTray
			_Exit()
	EndSwitch

	if TimerDiff($tUpdate) > $def_interval * 1000 Then
		_AutoUpdate()
		$tUpdate = TimerInit()
	EndIf

WEnd

Func _Exit()
	IniWrite($settings, "Settings", "LastSaveDir", $lastSaveDir)
	IniWrite($settings, "Settings", "DefaultMode", GUICtrlRead($gMode))
	IniWrite($settings, "Settings", "DefaultRegion", GUICtrlRead($gRegions))
	IniWrite($settings, "Settings", "DefaultCategory", GUICtrlRead($gCategories))
	if $def_minimizeToTray Then
		IniWrite($settings, "Settings", "MinimizeToTray", 1)
	Else
		IniWrite($settings, "Settings", "MinimizeToTray", 0)
	EndIf
	if $def_StatName Then
		IniWrite($settings, "Settings", "IncludeStatName", 1)
	Else
		IniWrite($settings, "Settings", "IncludeStatName", 0)
	EndIf
	Exit
EndFunc   ;==>_Exit

Func _CancelSettings()
	GUICtrlSetData($gUser, $def_user)
	GUICtrlSetData($gAPIKey, $def_APIKey)
	GUICtrlSetData($gInterval, "")
	GUICtrlSetData($gInterval, "30|60|90|120|240|300",$def_interval)


	if $def_hideAPI = 1 Then
		GUICtrlSetState($cbHideAPI, $GUI_CHECKED)
		GUICtrlSetStyle($gAPIKey, $ES_PASSWORD ,$WS_EX_CLIENTEDGE)
		GUICtrlSendMsg($gAPIKey, $EM_SETPASSWORDCHAR, Asc("*"), 0)
	Else
		GUICtrlSetState($cbHideAPI, $GUI_UNCHECKED)
		GUICtrlSetStyle($gAPIKey, $ES_PASSWORD ,$WS_EX_CLIENTEDGE)
		GUICtrlSendMsg($gAPIKey, $EM_SETPASSWORDCHAR, 0, 0)
	EndIf

	if $def_UseAPIKey = 0 Then
		GUICtrlSetState($cbCustomAPIKey, $GUI_CHECKED)
		GUICtrlSetState($cbHideAPI, $GUI_DISABLE)
		GUICtrlSetState($gAPIKey, $GUI_DISABLE)
	Else
		GUICtrlSetState($cbCustomAPIKey, $GUI_CHECKED)
		GUICtrlSetState($cbHideAPI, $GUI_ENABLE)
		GUICtrlSetState($gAPIKey, $GUI_ENABLE)
	EndIf
EndFunc

Func _SaveSettings()
	$def_user = GUICtrlRead($gUser)
	$def_interval = GUICtrlRead($gInterval)
	$def_APIKey = GUICtrlRead($gAPIKey)

	If BitAND(GUICtrlRead($cbHideAPI), $GUI_CHECKED) = $GUI_CHECKED Then
		$def_hideAPI = 1
	Else
		$def_hideAPI = 0
	EndIf

	If BitAND(GUICtrlRead($cbCustomAPIKey), $GUI_CHECKED) = $GUI_CHECKED Then
		$def_UseAPIKey = 1
	Else
		$def_UseAPIKey = 0
	EndIf

	IniWrite($settings,	"Settings",	"DefaultUser",		$def_user)
	IniWrite($settings, "Settings", "DefaultInterval",	$def_interval)
	IniWrite($settings, "Settings", "UseAPIKey",		$def_UseAPIKey)
	IniWrite($settings, "Settings", "CustomAPIKey",		$def_APIKey)
	IniWrite($settings, "Settings", "HideAPIKey",		$def_hideAPI)
EndFunc

Func _AutoUpdate()
	$updateIni = @ScriptDir & "\Resources\Update.ini"

	TraySetToolTip("Updating Files, Please wait")

	$secNames = IniReadSectionNames($saveini)

	Dim $updateArray[1000][6]
	$updateCount = 0
	if IsArray($secNames) Then
	For $i = 1 to $secNames[0]
		$updateArray[$updateCount][0] = IniRead($saveini, $secNames[$i], "Username", "ERROR")
		$updateArray[$updateCount][1] = IniRead($saveini, $secNames[$i], "Stat", "ERROR")
		$updateArray[$updateCount][2] = IniRead($saveini, $secNames[$i], "Mode", "ERROR")
		$updateArray[$updateCount][3] = IniRead($saveini, $secNames[$i], "Region", "ERROR")
		$updateArray[$updateCount][4] = IniRead($saveini, $secNames[$i], "Filename", "ERROR")
		$updateArray[$updateCount][5] = IniRead($saveini, $secNames[$i], "IncludeStat", "No")

		if $updateArray[$updateCount][2] = "All" Then
			IniWrite($updateIni,"solo_" &$updateArray[$updateCount][3], $updateArray[$updateCount][0], 1)
			IniWrite($updateIni,"duo_" &$updateArray[$updateCount][3], $updateArray[$updateCount][0], 1)
			IniWrite($updateIni,"squad_" &$updateArray[$updateCount][3], $updateArray[$updateCount][0], 1)
		Else
			IniWrite($updateIni,$updateArray[$updateCount][2] & "_" &$updateArray[$updateCount][3], $updateArray[$updateCount][0], 1)
		EndIf

		$updateCount +=1
		;_UpdateStat($secNames[$i], IniRead($saveini, $secNames[$i], "Stat", "ERROR"), IniRead($saveini, $secNames[$i], "Mode", "ERROR"), IniRead($saveini, $secNames[$i], "Region", "ERROR"),1)
	Next
	ReDim $updateArray[$updateCount][6]
	Else
	Return 0
	EndIf
;~ 	_ArrayDisplay($updateArray) === Debug the Update Array

	$secNames = IniReadSectionNames($updateIni)

	if IsArray($secNames) Then
	For $i = 1 to $secNames[0]
		$section = IniReadSection($updateIni, $secNames[$i])
		$split = StringSplit($secNames[$i],"_")
;~ 		$returnedArray = _PUBG_ME_StatGet(Player, Mode, Region)
		for $j = 1 to $section[0][0]

			_Log("sending Stat get to Pubg.me ." & @LF & @TAB &  "User:" & $section[$j][0] & @LF & @TAB & "Mode: " & $split[1] & @LF & @TAB & "Region: " & $split[2])
			$returnedArray = _PUBG_ME_StatGet($section[$j][0], $split[1], $split[2])
			;_ArrayDisplay($returnedArray)

			$statGetError = False
			if $returnedArray[1] = 0 AND $returnedArray[2] = 0 AND $returnedArray[3] = 0 Then
			$statGetError = True
			Else
			if not($statGetError) Then _UnloadResults($returnedArray,$section[$j][0], $split[1], $split[2])
			EndIf
_LOG($statGetError)
		Next
	Next
	EndIf

	FileDelete($updateIni)

	For $i = 0 to UBound($updateArray)-1
		_UpdateStat($updateArray[$i][4], $updateArray[$i][0], $updateArray[$i][1], $updateArray[$i][2], $updateArray[$i][3], $updateArray[$i][5],1)
	Next

;~ Dim $pullArray[1000][4]
;~ $pullCount = 0
;~ 	For $i = 0 to UBound($updateArray)-1
;~ 		$add = True
;~ 		for $j = 0 to UBound($pullArray)-1
;~ 			if $updateArray[$i][0] = $pullArray[$j][0] AND $updateArray[$i][2] = $pullArray[$j][2] AND $updateArray[$i][3] = $pullArray[$j][3] Then
;~ 			$add = False
;~ 			EndIf
;~ 			if $updateArray[$i][2] = "All" Then
;~ 				if $updateArray[$i][0] = $pullArray[$j][0] AND $updateArray[$i][2] = $pullArray[$j][2] AND $updateArray[$i][3] = $pullArray[$j][3] Then
;~ 			EndIf
;~ 		Next
;~ 		if $add Then
;~ 			if $updateArray[$i][2] = "All" Then
;~
;~ 			Else
;~
;~ 			EndIf
;~ 		EndIf
;~
;~ 	Next
EndFunc

Func _UnloadResults($rArray, $rUser, $rMode, $rRegion)

	$uIni = @ScriptDir & "\Resources\Stats\" & $rUser & ".ini"


	For $i = 1 to UBound($rArray)-1

		$tempArray = $rArray[$i]
		if IsArray($tempArray) Then
			IniWriteSection($uIni, $rMode & "_" & $rRegion, $tempArray, 0)
		EndIf
		IniWrite($uIni,  $rMode & "_" & $rRegion, "LastUpdated", $rArray[0])
		IniWrite($uIni,  $rMode & "_" & $rRegion, "Win Rating", $rArray[4])
		IniWrite($uIni,  $rMode & "_" & $rRegion, "Kill Rating", $rArray[5])

	Next

EndFunc

Func _UpdateStat($file, $iUser, $stat, $mode, $region, $includeStatName, $debug = 0)
	_Log("Starting Update with the following settings: " &@LF & "File: " & $file &@LF& "Stat: " & $stat &@LF &  "Region: " & $region)
	$testTick +=1
;~ 	_Log("Tick: " & $testTick)

	$uIni = @ScriptDir & "\Resources\Stats\" & $iUser & ".ini"

	$corrStat = _StatFind($stat)

	if $mode <> "All" Then
		$finalStat = IniRead($uIni, $mode & "_" & $region, $corrStat, "N/A")
	Else
		$finalStat = _AllStatMath($iUser, $corrStat, $mode, $region)
	EndIf

	if $includeStatName = "Yes" Then
		ConsoleWrite("Result: " & $stat & ": " & $finalStat &@LF)
		$fHandle = FileOpen($file,2)
	FileWrite($fHandle, $stat & ": " & $finalStat)
	FileClose($fHandle)
	Else
		ConsoleWrite("Result: " & $finalStat &@LF)
		$fHandle = FileOpen($file,2)
	FileWrite($fHandle, $finalStat)
	FileClose($fHandle)
	EndIf




EndFunc

Func _StatFind($iStat)
	Switch $iStat
		#Region ====== Play Stats =====
		Case "Rating"
			Return $iStat
		Case "Rank"
			Return $iStat
		Case "Rounds Played"
			Return "Matches Played"
		Case "Time Played"
			Return $iStat
		Case "Days Played"
			Return "Daily Logins"
		Case "Total Distance"
			Return "Total Distance Travelled"
		Case "Average Distance"
			Return "Avg Distance Travelled"
		Case "Average Dist. on Foot"
			Return "Avg Distance on Foot"
		Case "Average Dist. in Vehicle"
			Return "Avg Distance in Vehicle"
		Case "Weapons Acquired"
			Return $iStat
		Case "Stats Last Updated"
			Return "LastUpdated"
		#EndRegion
		#Region ====== Wins Stats =====
		Case "Wins"
			Return $iStat
		Case "Win Rating"
			Return $iStat
		Case "Win Rank"
			Return $iStat
		Case "Win Rate %"
			Return "Win Rate"
		Case "Top 10s"
			Return "Top 10's"
		Case "Top 10 Rate %"
			Return "Top 10 Rate"
		Case "Average Time Survived"
			Return "Avg Survival Time"
		Case "Longest Time Survived"
			Return $iStat
		Case "Total Heals"
			Return $iStat
		Case "Total Boosts"
			Return $iStat
		Case "Team Kills"
			Return $iStat
		Case "Suicides"
			Return $iStat
		Case "Revives"
			Return $iStat
			#EndRegion
			#Region ======= Kill Stats ====
		Case "Players Killed"
			Return "Kills"
		Case "Assists"
			Return $iStat
		Case "Kill Rating"
			Return $iStat
		Case "Kill Rank"
			Return $iStat
		Case "Headshots"
			Return $iStat
		Case "Longest Kill"
			Return $iStat
		Case "Total Damage Dealt"
			Return $iStat
		Case "Vehicles Destroyed"
			Return $iStat
		Case "Road Kills"
			Return $iStat
		Case "K/D Ratio"
			Return "Kill / Death Ratio"
		Case "Most Kills"
			Return "Most Kills In Match"
		Case "Kill Streak"
			Return "Best Kill Streak"
		Case "Average Damage"
			Return "AVG Damage Per Match"
		Case "DBNO"
			Return $iStat
			#EndRegion
	EndSwitch
EndFunc

Func _AllStatMath($iUser, $iStat, $iMode, $iRegion)
	$uIni = @ScriptDir & "\Resources\Stats\" & $iUser & ".ini"

	$finalStat = 0
	$statCount = 0
	Switch $iStat
		#Region ====== Combined =====
		;~ 		Case "Time Played"
			Case "Matches Played", "Weapons Acquired", "Wins", "Top 10's", "Total Heals", "Total Boosts", "Team Kills", _
				"Suicides", "Revives", "Total Damage Dealt", "Players Killed", "Assists", "Headshots", "Vehicles Destroyed", "Road Kills", "DBNO"
				$stat1 = Int(StringReplace(IniRead($uIni, "solo_" & $iregion, $iStat, 0),",",""))
				$stat2 = Int(StringReplace(IniRead($uIni, "duo_" & $iregion, $iStat, 0),",",""))
				$stat3 = Int(StringReplace(IniRead($uIni, "squad_" & $iregion, $iStat, 0),",",""))
				$finalStat = $stat1 + $stat2 + $stat3
				Return $finalStat
				#EndRegion

		Case "Avg Distance Travelled", "Avg Distance on Foot", "Avg Distance in Vehicle"
			$stat1 = StringReplace(IniRead($uIni, "solo_" & $iregion, $iStat, "N/A")," km", "")
			if $stat1 <> "N/A" Then
				$statCount +=1
				$finalStat += $stat1
			EndIf

				$stat2 = StringReplace(IniRead($uIni, "duo_" & $iregion, $iStat, "N/A")," km", "")
			if $stat2 <> "N/A" Then
				$statCount +=1
				$finalStat += $stat2
			EndIf

				$stat3 = StringReplace(IniRead($uIni, "squad_" & $iRegion, $iStat, "N/A")," km", "")
			if $stat3 <> "N/A" Then
				$statCount +=1
				$finalStat += $stat3
			EndIf

			$finalStat = Round( $finalStat / $statCount,2)
				$finalStat = $finalStat & " km"
				Return $finalStat
		Case "Total Distance Travelled"
			$stat1 = Round(StringReplace(StringReplace(IniRead($uIni, "solo_" & $iRegion, $iStat, "N/A")," km", ""),",",""),2)
			if $stat1 <> "N/A" Then
				$finalStat += $stat1
			EndIf

				$stat2 = Round(StringReplace(StringReplace(IniRead($uIni, "duo_" & $iRegion, $iStat, "N/A")," km", ""),",",""),2)
			if $stat2 <> "N/A" Then
				$finalStat += $stat2
			EndIf

				$stat3 = Round(StringReplace(StringReplace(IniRead($uIni, "squad_" & $iRegion, $iStat, "N/A")," km", ""),",",""),2)
			if $stat3 <> "N/A" Then
				$finalStat += $stat3
			EndIf

				$finalStat = $finalStat & " km"
				Return $finalStat


		Case "Win Rate", "Top 10 Rate"
			$stat1 = StringReplace(IniRead($uIni, "solo_" & $iRegion, $iStat, "N/A"),"%", "")
			if $stat1 <> "N/A" Then
				$statCount +=1
				$finalStat += $stat1
			EndIf

				$stat2 = StringReplace(IniRead($uIni, "duo_" & $iRegion, $iStat, "N/A"),"%", "")
			if $stat2 <> "N/A" Then
				$statCount +=1
				$finalStat += $stat2
			EndIf

				$stat3 = StringReplace(IniRead($uIni, "squad_" & $iRegion, $iStat, "N/A"),"%", "")
			if $stat3 <> "N/A" Then
				$statCount +=1
				$finalStat += $stat3
			EndIf

			$finalStat = Round( $finalStat / $statCount,2)
				$finalStat = $finalStat & "%"
				Return $finalStat
		Case "Avg Survival Time"
			$stat1 = StringReplace(IniRead($uIni, "solo_" & $iRegion, $iStat, "N/A"),"m", "")
			if $stat1 <> "N/A" Then
				$statCount +=1
				$finalStat += $stat1
			EndIf

				$stat2 = StringReplace(IniRead($uIni, "duo_" & $iRegion, $iStat, "N/A"),"m", "")
			if $stat2 <> "N/A" Then
				$statCount +=1
				$finalStat += $stat2
			EndIf

				$stat3 = StringReplace(IniRead($uIni, "squad_" & $iRegion, $iStat, "N/A"),"m", "")
			if $stat3 <> "N/A" Then
				$statCount +=1
				$finalStat += $stat3
			EndIf

			$finalStat = Round( $finalStat / $statCount,2)
				$finalStat = $finalStat & "m"
				Return $finalStat
		Case "Longest Time Survived"
			$stat1 = StringReplace(IniRead($uIni, "solo_" & $iRegion, $iStat, "N/A"),"m", "")
			if $stat1 <> "N/A" Then
				$finalStat = $stat1
			EndIf

			$stat2 = StringReplace(IniRead($uIni, "duo_" & $iRegion, $iStat, "N/A"),"m", "")
			if $stat2 <> "N/A" Then
				if $stat2 > $finalStat Then $finalStat = $stat2
			EndIf

			$stat3 = StringReplace(IniRead($uIni, "squad_" & $iRegion, $iStat, "N/A"),"m", "")
			if $stat3 <> "N/A" Then
				if $stat3 > $finalStat Then $finalStat =  $stat3
			EndIf

			Return $finalStat & "m"
		Case "Longest Kill"
			$stat1 = Int(StringReplace(StringReplace(IniRead($uIni, "solo_" & $iRegion, $iStat, "N/A"),"m", ""),",",""))
			if $stat1 <> "N/A" Then
				$finalStat = $stat1
			EndIf

			$stat2 = Int(StringReplace(StringReplace(IniRead($uIni, "duo_" & $iRegion, $iStat, "N/A"),"m", ""),",",""))
			if $stat2 <> "N/A" Then
				if $stat2 > $finalStat Then $finalStat = $stat2
			EndIf

			$stat3 = Int(StringReplace(StringReplace(IniRead($uIni, "squad_" & $iRegion, $iStat, "N/A"),"m", ""),",",""))
			if $stat3 <> "N/A" Then
				if $stat3 > $finalStat Then $finalStat =  $stat3
			EndIf

			Return $finalStat & "m"


		Case "Kill / Death Ratio", "AVG Damage Per Match"
				$stat1 = IniRead($uIni, "solo_" & $iRegion, $iStat, "N/A")
			if $stat1 <> "N/A" Then
				$statCount +=1
				$finalStat += $stat1
			EndIf

				$stat2 = IniRead($uIni, "duo_" & $iRegion, $iStat, "N/A")
			if $stat2 <> "N/A" Then
				$statCount +=1
				$finalStat += $stat2
			EndIf

				$stat3 = IniRead($uIni, "squad_" & $iRegion, $iStat, "N/A")
			if $stat3 <> "N/A" Then
				$statCount +=1
				$finalStat += $stat3
			EndIf

			$finalStat = Round( $finalStat / $statCount,2)
				Return $finalStat
		Case "Most Kills In Match", "Best Kill Streak"
			_Log("Most Kills in Match\BestKillStreak")

			$stat1 = Int(IniRead($uIni, "solo_" & $iRegion, $iStat, "N/A"))
			_Log("Stat1: " & $stat1)
			if $stat1 <> "N/A" Then
				$finalStat = $stat1
			EndIf

			$stat2 = Int(IniRead($uIni, "duo_" & $iRegion, $iStat, "N/A"))
			_Log("Stat2: " & $stat2)
			if $stat2 <> "N/A" Then
				if $stat2 > $finalStat Then $finalStat = $stat2
			EndIf

			$stat3 = Int(IniRead($uIni, "squad_" & $iRegion, $iStat, "N/A"))
			_Log("Stat3: " & $stat3)
			if $stat3 <> "N/A" Then
				if $stat3 > $finalStat Then $finalStat = $stat3
			EndIf

			Return $finalStat
	EndSwitch
EndFunc

Func _AddRule()
	$currCat = GUICtrlRead($gCategories)
	$currStatH = _CheckChecked($currCat)
	$currStat = GUICtrlRead($currStatH, 1)
	$currRegion = GUICtrlRead($gRegions)
	$currMode = GUICtrlRead($gMode)
	$currUser = GUICtrlRead($gUser)

	if $currUser = "" Then
		MsgBox(48,"Username Cannot be empty","The Username field cannot be empty")
		Return -1
	EndIf

	$currFile = FileSaveDialog("Save " & $currStat & " on " & $currRegion & " for " & $currMode & "...", $lastSaveDir, "Text files (*.txt)", 18, "", $hMain)
	If $currFile = "" Then Return

	$lv_count = _GUICtrlListView_GetItemCount($idListview)
	For $i = 0 To $lv_count
		If $currFile = _GUICtrlListView_GetItemText($idListview, $i) Then
			$iRes = MsgBox(52, "Rule Already exists", "There is already an rule to save to this location, would you like to overwrite this?")
			If $iRes = 7 Then Return
			_GUICtrlListView_DeleteItem($idListview, $i)
			ExitLoop
		EndIf
	Next


	$dirSplit = StringSplit($currFile, "\")
	$currDir = StringTrimRight($currFile, StringLen($dirSplit[$dirSplit[0]]))
	$lastSaveDir = $currDir

	$item = _GUICtrlListView_AddItem($idListview, $currFile)
	_GUICtrlListView_AddSubItem($idListview, $item, $currUser, 1)
	_GUICtrlListView_AddSubItem($idListview, $item, $currStat,2)
	_GUICtrlListView_AddSubItem($idListview, $item, $currMode, 3)
	_GUICtrlListView_AddSubItem($idListview, $item, $currRegion, 4)
	if $def_StatName Then
	_GUICtrlListView_AddSubItem($idListview, $item, "Yes", 5)
	IniWrite($saveini, $currFile, "IncludeStat", "Yes")
	Else
	_GUICtrlListView_AddSubItem($idListview, $item, "No", 5)
	IniWrite($saveini, $currFile, "IncludeStat", "No")
	EndIf

	IniWrite($saveini, $currFile, "Filename", $currFile)
	IniWrite($saveini, $currFile, "Username", $currUser)
	IniWrite($saveini, $currFile, "Stat", $currStat)
	IniWrite($saveini, $currFile, "Mode", $currMode)
	IniWrite($saveini, $currFile, "Region", $currRegion)
EndFunc   ;==>_AddRule

Func _DelRules()

	$selIndicies = _GUICtrlListView_GetSelectedIndices($idListview, True)

	If $selIndicies[0] > 1 Then
		$iRes = MsgBox(52, "Multiple rules selected", "Multiple rules have been selected are you sure you wish to delete all of them?")
		If $iRes = 7 Then Return
	ElseIf $selIndicies[0] = 0 Then
		Return
	Else
		$iRes = MsgBox(52, "Delete rule", "Do you wish to delete the Rule saving to: " & _GUICtrlListView_GetItemText($idListview, $selIndicies[1]))
		If $iRes = 7 Then Return
	EndIf

	For $i = 1 To $selIndicies[0]
		IniDelete($saveini, _GUICtrlListView_GetItemText($idListview, $selIndicies[$i]))
	Next
	_GUICtrlListView_DeleteItemsSelected($idListview)
EndFunc   ;==>_DelRules

Func _LoadRules()
	$secNames = IniReadSectionNames($saveini)
	if IsArray($secNames) Then
	For $i = 1 To $secNames[0]
		$item = _GUICtrlListView_AddItem($idListview, $secNames[$i])
		_GUICtrlListView_AddSubItem($idListview, $item, IniRead($saveini, $secNames[$i], "Username", "DELETE THIS RULE"), 1)
		_GUICtrlListView_AddSubItem($idListview, $item, IniRead($saveini, $secNames[$i], "Stat", "DELETE THIS RULE"), 2)
		_GUICtrlListView_AddSubItem($idListview, $item, IniRead($saveini, $secNames[$i], "Mode", "DELETE THIS RULE"), 3)
		_GUICtrlListView_AddSubItem($idListview, $item, IniRead($saveini, $secNames[$i], "Region", "DELETE THIS RULE"), 4)
		_GUICtrlListView_AddSubItem($idListview, $item, IniRead($saveini, $secNames[$i], "IncludeStat", "No"), 5)
	Next
	EndIf
EndFunc   ;==>_LoadRules

Func _CheckChecked($category)
	Switch $category
		Case "Kills"
			For $i = 0 To UBound($kills_array) - 1
				If BitAND(GUICtrlRead($kills_array[$i]), $GUI_CHECKED) = $GUI_CHECKED Then Return $kills_array[$i]
			Next
		Case "Play"
			For $i = 0 To UBound($play_array) - 1
				If BitAND(GUICtrlRead($play_array[$i]), $GUI_CHECKED) = $GUI_CHECKED Then Return $play_array[$i]
			Next
		Case "Wins"
			For $i = 0 To UBound($wins_array) - 1
				If BitAND(GUICtrlRead($wins_array[$i]), $GUI_CHECKED) = $GUI_CHECKED Then Return $wins_array[$i]
			Next
	EndSwitch
	ConsoleWrite("ERROR" & @LF)
EndFunc   ;==>_CheckChecked

Func _ModeSwitch($iMode)
	Switch $iMode
		Case "All"

			if BitAND(GUICtrlRead($kills_array[3]), $GUI_CHECKED) = $GUI_CHECKED Then GUICtrlSetState($kills_array[1],$GUI_CHECKED)
			if BitAND(GUICtrlRead($kills_array[14]), $GUI_CHECKED) = $GUI_CHECKED Then GUICtrlSetState($kills_array[1],$GUI_CHECKED)

			if BitAND(GUICtrlRead($play_array[10]), $GUI_CHECKED) = $GUI_CHECKED Then GUICtrlSetState($play_array[1],$GUI_CHECKED)
			if BitAND(GUICtrlRead($play_array[3]), $GUI_CHECKED) = $GUI_CHECKED Then GUICtrlSetState($play_array[1],$GUI_CHECKED)
			if BitAND(GUICtrlRead($play_array[11]), $GUI_CHECKED) = $GUI_CHECKED Then GUICtrlSetState($play_array[1],$GUI_CHECKED)

			if BitAND(GUICtrlRead($wins_array[3]), $GUI_CHECKED) = $GUI_CHECKED Then GUICtrlSetState($wins_array[1],$GUI_CHECKED)
			if BitAND(GUICtrlRead($wins_array[13]), $GUI_CHECKED) = $GUI_CHECKED Then GUICtrlSetState($wins_array[1],$GUI_CHECKED)

			;Rating
			GUICtrlSetState($play_array[10], $GUI_DISABLE)
			GUICtrlSetState($play_array[3], $GUI_DISABLE)
			GUICtrlSetState($play_array[11], $GUI_DISABLE)

			;WinRank
			GUICtrlSetState($wins_array[13], $GUI_DISABLE)
			;WinRating
			GUICtrlSetState($wins_array[3], $GUI_DISABLE)


			;Kill Rating
			GUICtrlSetState($kills_array[14], $GUI_DISABLE)
			;Kill Rank
			GUICtrlSetState($kills_array[3], $GUI_DISABLE)

		Case Else

			;Rating
			GUICtrlSetState($play_array[10], $GUI_ENABLE)
			GUICtrlSetState($play_array[3], $GUI_ENABLE)
			GUICtrlSetState($play_array[11], $GUI_ENABLE)

			;WinRank
			GUICtrlSetState($wins_array[13], $GUI_ENABLE)
			;WinRating
			GUICtrlSetState($wins_array[3],$GUI_ENABLE)


			;Kill Rating
			GUICtrlSetState($kills_array[14], $GUI_ENABLE)
			;Kill Rank
			GUICtrlSetState($kills_array[3], $GUI_ENABLE)

	EndSwitch
EndFunc

Func _CategorySwitch($category)
	Switch $category
		Case "Kills"
			_GUIState("Play", $GUI_HIDE)
			_GUIState("Wins", $GUI_HIDE)
			_GUIState("Kills", $GUI_Show)
		Case "Play"
			_GUIState("Kills", $GUI_HIDE)
			_GUIState("Wins", $GUI_HIDE)
			_GUIState("Play", $GUI_SHOW)
		Case "Wins"
			_GUIState("Kills", $GUI_HIDE)
			_GUIState("Play", $GUI_HIDE)
			_GUIState("Wins", $GUI_SHOW)
	EndSwitch
EndFunc   ;==>_CategorySwitch

Func _GUIState($guiCategory, $state)
	Switch $guiCategory
		Case "Play"
			For $i = 0 To UBound($play_array) - 1
				GUICtrlSetState($play_array[$i], $state)
			Next
		Case "Wins"
			For $i = 0 To UBound($wins_array) - 1
				GUICtrlSetState($wins_array[$i], $state)
			Next
		Case "Kills"
			For $i = 0 To UBound($kills_array) - 1
				GUICtrlSetState($kills_array[$i], $state)
			Next
	EndSwitch
EndFunc   ;==>_GUIState

Func _GuiMinimizeToTray($h_wnd)

	; check if 1 = Window exists, then check to see if its 16 = Window is minimized
	If BitAND(WinGetState($h_wnd), 1) Or Not BitAND(WinGetState($h_wnd), 16) Then
		; change the window state to hide
		WinSetState($h_wnd, "", @SW_HIDE)
	EndIf

EndFunc   ;==>_GuiMinimizeToTray

Func _Log($msg)
	ConsoleWrite($msg &@LF)
EndFunc