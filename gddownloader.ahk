;Geometry Dash Downloader 1.0.65
;By Dan3436

;Parameters
#NoEnv
#SingleInstance Force
#NoTrayIcon

Title := "GD Downloader"

If A_OSVersion in WIN_XP
GDPath := "C:\Documents and Settings\" A_UserName "\Application Data\GeometryDash"
GDPath := "C:\Users\" A_UserName "\AppData\Local\GeometryDash"

Gui -MinimizeBox
Gui Color, White
Gui Add, Text, x51 y14 w65 h14, Enter the ID
Gui Add, Edit, vID x50 y34 w65 h21 Number -VScroll
Gui Add, Text, x0 y61 w257 h40 -Background
Gui Add, Button, gID x75 y70 w80 h23 Default, Accept
Gui Show, w165 h102, %Title%
Return

ID:
Gui, Submit, NoHide
Gui +OwnDialogs

If ID =
{
	MsgBox, 48, Error, You must enter the ID.
	Return
}

If ID < 469775 ;First ID in which the name pattern can be used.
{
	MsgBox, 48, Error, No support for ID's less than 469775.`nThe known pattern can't be used.
	Return
}

global ID ;Make it global

Gui Destroy

Gui New
Gui -MaximizeBox
Gui Color, White
Gui Add, Text, x34 y6 w184 h33 Center, Enter the name of the audio`n(Respect upper case and characters)
Gui Add, Edit, vName x66 y41 w120 h21 -VScroll
Gui Add, Text, x0 y68 w282 h42 -Background
Gui Add, Button, gName x162 y78 w80 h23 Default, Accept
Gui Show, w252 h110, %Title%
Return

Name:
Gui, Submit, NoHide
Gui +OwnDialogs

If Name =
{
	MsgBox, 48, Error, You must enter the name.
	Return
}

Filter := {" ": "-", "&": "amp", "<": "lt", ">": "gt", """": "quot"}
For Key, Value in Filter
Name := StrReplace(Name, Key, Value) ;Apply the filter only here.
Name := SubStr(RegExReplace(Name, "[^\w-_]"), 1, 26)

/*
Filter:

(Space) = -
	 & = amp
	 < = lt
	 > = gt
	 " = quot
(Other) = (Nothing)
	
Keep "-" and "_"

Characters limit = 26
*/

Gui Destroy

Gui New
Gui -MaximizeBox
Gui Color, White
Gui Add, Text, x11 y23 w151 h15, Select the save path
Gui Add, Text, x0 y57 w286 h44 -Background
Gui Add, Button, gPath1 x27 y68 w75 h23 Default, Normal path
Gui Add, Button, gPath2 x110 y68 w75 h23, Alt. path
Gui Add, Button, gHelp x194 y68 w75 h23, Help
Gui Show, w284 h101, %Title%
Return

Path1:
SavePath := GDPath "\" ID ".mp3"
Goto Download

Path2:
Gui +OwnDialogs
FileSelectFolder, AltPath,, 0, Select the Geometry Dash folder

If ErrorLevel
Return

If !FileExist(AltPath "\Resources")
{
	MsgBox, 48, %Title%, "Resources" folder wasn't found.
	Return
}

SavePath := AltPath "\Resources\" ID ".mp3"
Goto Download

Help:
Gui +OwnDialogs
MsgBox, 64, Help, Normal path: %GDPath%`n`nAlternative path: Geometry Dash folder\Resources
Return

Download:
Gui Destroy

try DownloadFile("http://audio.ngfiles.com/" ID - Mod(ID, 1000) "/" ID "_" Name ".mp3", SavePath)

catch e { ;Error
	
	If InStr(e.Message, "0x80072F76")
		MsgBox, 48, Error, The audio was not found.`nBe sure to write the name and ID correctly.
	
	If InStr(e.Message, "0x80072EE7")
		MsgBox, 48, Error, The server name could not be resolved. Make sure you have an internet connection.
	
	If e.Message not contains 0x80072EE7,0x80072F76
		MsgBox % e.Message
	
	FileDelete % SavePath
	
	ExitApp
}

MsgBox, 64, %Title%, The audio was downloaded successfully.
ExitApp

DownloadFile(Url, File) { ;Based on the function of Bruttosozialprodukt - https://autohotkey.com/boards/viewtopic.php?f=6&t=1674
	WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	WebRequest.Open("HEAD", Url)
	WebRequest.Send()
	FinalSize := WebRequest.GetResponseHeader("Content-Length")
	Progress, MH80,, Wait..., % Url
	SetTimer, ProgressBar, 100
	UrlDownloadToFile, % Url, % File
     Progress, Off
     SetTimer, ProgressBar, Off
	Return
	
	ProgressBar:
	CurrentSize := FileOpen(File, "r").Length
	CurrentSizeTick := A_TickCount
	Speed := Round(((CurrentSize-LastSize)/1024)/((CurrentSizeTick-LastSizeTick)/1000)) . " KB/s"
	LastSizeTick := CurrentSizeTick
	LastSize := FileOpen(File, "r").Length
	PercentDone := Round(CurrentSize/FinalSize*100)
	Progress, %PercentDone%, %PercentDone%`%, Downloading...  (%Speed%), % "Downloading " ID ".mp3 (" Round(CurrentSize/1048576, 2) " MB of " Round(FinalSize/1048576, 2) " MB)"
	Return
}

GuiEscape:
GuiClose:
ExitApp
