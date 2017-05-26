#include <Inet.au3>
#include <array.au3>

;~ _PUBG_ME_StatGet("sdoddler", "squad", "oc")

Func _PUBG_ME_StatGet($player, $gMode="",$region = "", $debug = 0)
	$region = StringLower($region)
	$gmode = StringLower($gmode)
$url = "https://pubg.me/player/"
$url &= $player
if $gmode <> "" Then $url &= "/" & $gmode
if $region <> "" Then $url &= "?region=" & $region
$hDownload = InetGet($url, "Test.Txt",  $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)
			Do
				Sleep(20)
			Until InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)

		$file = FileOpen("Test.Txt", 0)

		$a = """"
		$line = FileReadLine($file)

While @error = 0

		;MsgBox(0,"WORKING",$line)
		; $line
		If StringInStr($line, "<div class=" & $a & "d-flex row page-container" & $a & ">") > 0 Then
;;ConsoleWrite($line &@LF &@LF)
ExitLoop
		else
	$line = FileReadLine($file)
		EndIf


WEnd

$array = StringRegExp($line,"(a class=" & $a & "profile-match-title.*?<|class=" & $a & "value.*?<|class=" & $a & "label.*?<)",3)
if IsArray($array) Then
	if $debug Then ConsoleWrite("Data found :)"&@LF)
Else
	ConsoleWrite("No Data Availalbe for this Region" &@LF)
	Dim $retArray[6]
	$retArray[0] = 0
	$retArray[1] = 0
	$retArray[2] = 0
	$retArray[3] = 0
	$retArray[4] = 0
	$retArray[5] = 0
	Return $retArray
EndIf

$lastUp = StringRegExp($line, "div class=" & $a & "last-updated.*?<",3)
;_ArrayDisplay($lastUp)

if IsArray($lastUp) Then
	$lastUp = StringRegExp($lastUp[0], "(?<=>)(.*)(?=<)",1)
	$lastUpdate = $lastUp[0]
;_ArrayDisplay($lastUpdate)
EndIf

$winKillRating = StringRegExp($line, "(wkbalancemode" & $a & " data-set="& $a & ".*?" & $a&")",3)
if IsArray($winKillRating) Then
	$winKillRating[0] = StringReplace($winKillRating[0],"wkbalancemode" & $a ,"")
	$wkRating = StringRegExp($winKillRating[0], "(?<="&$a&")(.*)(?="&$a&")",1)
;~ 	$lastUpdate = $lastUp[0]

	$wkRating = StringReplace(StringReplace($wkRating[0],"[",""),"]","")
;~ 	ConsoleWrite($wkRating &@LF)
	$wkSplit = StringSplit($wkRating, ",")

	$winRating = $wkSplit[1]
	$killRating = $wksplit[2]
EndIf

;~ _ArrayDisplay($array)

For $i = 0 to UBound($array)-1
	$temp = StringRegExp($array[$i],"(?<=>)(.*)(?=<)",1)
	$array[$i] = $temp[0]
Next

if $debug then _ArrayDisplay($array)
	DIm $soloArray[1000][2]
		Local $solocount = 0, $duoCount = 0, $squadCount=0
		DIm $duoArray[1000][2]
		DIm $squadArray[1000][2]

		Switch $gmode
			Case ""
				$mode = "solo"

			Case "Solo"
				$mode = "Solo"

			Case "Duo"
				$mode = "Duo"

			Case "Squad"
				$mode = "Squad"

		EndSwitch


		For $i = 0 to UBound($array)-1
			if $gmode = "" Then
			if $array[$i] = "solo" OR $array[$i] = "duo" OR $array[$i] = "squad" Then
				$mode = $array[$i]
				$i+=1
			EndIf
			EndIf

			Switch $mode
				Case "Solo"
					$soloArray[$solocount][1] = $array[$i]
					$i+=1
					if StringInStr($array[$i],"rating") Then $array[$i] = "Rating"
					$soloArray[$solocount][0] = $array[$i]

					$solocount +=1
				Case "Duo"
					$duoArray[$duocount][1] = $array[$i]
					$i+=1
					if StringInStr($array[$i],"rating") Then $array[$i] = "Rating"
					$duoArray[$duocount][0] = $array[$i]
					$duocount +=1
				Case "Squad"
;~ 					if $debug then ConsoleWrite($i &@LF)
					$squadArray[$squadcount][1] = $array[$i]
					$i+=1
;~ 					if $debug then ConsoleWrite($i &@LF)
					if StringInStr($array[$i],"rating") Then $array[$i] = "Rating"
					$squadArray[$squadcount][0] = $array[$i]
					$squadcount +=1

			EndSwitch

		Next


ReDim $soloArray[$solocount][2]
ReDim $duoArray[$duocount][2]
ReDim $squadArray[$squadcount][2]

If $solocount = 0 Then $soloArray = 0
If $duocount = 0 Then $duoArray = 0
If $squadcount = 0 Then $squadArray = 0

;~ _ArrayDisplay($soloArray)
;~ _ArrayDisplay($duoArray)
;~ _ArrayDisplay($squadArray)

Dim $retArray[6]
$retArray[0] = $lastUpdate
$retArray[1] = $soloArray
$retArray[2] = $duoArray
$retArray[3] = $squadArray
$retArray[4] = $winRating
$retArray[5] = $killRating


;~ _ArrayDisplay($retArray)
Return $retArray

EndFunc
