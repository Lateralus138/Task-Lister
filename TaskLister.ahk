; List all tasks in a Gui with a ComboBox

; Init
#NoEnv
#SingleInstance, Force
SendMode Input
SetWorkingDir %A_ScriptDir%
OnMessage(0x200,"WM_MOUSEHOVER")
OnMessage(0x18,"WM_SHOWWINDOW")
OnMessage(0x2a3,"WM_MOUSELEAVE")
OnMessage(0x201,"WM_LBUTTONDOWN")
CoordMode, ToolTip, Client
; Vars
defaultWidth:=240

; Build menus, intial loops and guis here
Menu, MainMenu, Add, &Run,FileOpen, +Break
Menu, MainMenu, Add, E&xit,GuiClose
Menu, HelpMenu, Add, &Help,Help, +Break
Menu, HelpMenu, Add, &About,About
Menu, MyMenuBar, Add, &File, :MainMenu
Menu, MyMenuBar, Add, &Help, :HelpMenu

Menu, Tray, NoStandard
Menu, Tray, Tip, % Spaces("Tab") Spaces("Tab") "Task Lister`nRight click for menu"
Menu, Tray, Add, &Run, FileOpen
Menu, Tray, Add, &Help, Help
Menu, Tray, Add, &About Task Lister, About
Menu, Tray, Add
Menu, Tray, Add, E&xit,GuiClose

tl:=TaskList(,,1)
Gui, Margin, 1, 1
Gui, Color,0xFEFEFA 0xFFFFFF
Gui, Font, s15 w500, Segoe UI
Gui, Add,Progress,Section  w%defaultWidth% Background0x0D4F82 c0x0078D7, 100
Gui, Add, Text, w%defaultWidth% +BackgroundTrans 0x200 +Center c0xFEFEFA yp, Task Lister
MinButton(200,20,"FEFEFA","FEFEFA",True)
CloseButton(220,8,"FEFEFA","FEFEFA",True)
Gui, Font, s8 w100 c0xFEFEFA, Segoe UI
Gui, Add, Progress, Background0x0D4F82 w%defaultWidth% h20 xs c0x0078D7, 100
MenuItem("&File",28,,1)
MenuItem("&About")

Gui, Font, s9 w400
Gui, Add, ComboBox, xs  Choose1 vChoice w%defaultWidth% 0x1 h250 +ReadOnly, % tl
Button("0x0D4F82","0x0078D7",defaultWidth,"&Kill Selected Task","Task Lister","FEFEFA",13)
Button("0x0D4F82","0x0078D7",defaultWidth,"&Open Process Location`n(If possible)","Task Lister","FEFEFA",13)
Gui, Show, , Task Lister
WinSet, TransColor, 0x123456 , Task Lister
Gui, -Caption +Border
Gui, Show, AutoSize, Task Lister
Gui, +LastFound +HwndMainHwnd
this_id:=WinExist()
ControlSend, ComboBox1,{Right}, ahk_id %this_id%
VarSetCapacity(tme,16,0)
NumPut(16,tme,0), NumPut(2,tme,4), NumPut(MainHwnd,tme,8)
DllCall( "TrackMouseEvent","uint",&tme )
SetTimer,RefreshList, 150
; End auto execute
Return

; Hotkeys
!r::Reload
#IfWinActive, Task Lister
Alt & k::Gosub, ButtonKillSelectedTask
Alt & o::Gosub, Open
Alt & f::
	CoordMode, Mouse, Client
	MouseMove,%S2X%,%S2Y2%
	Menu, MainMenu, Show
	CoordMode, Mouse, Screen
Return
Alt & a::
	CoordMode, Mouse, Client
	MouseMove,%S2X%,%S2Y2%
	Menu, HelpMenu, Show
	CoordMode, Mouse ,Screen
Return
;$Down::Send, {Down}{Home}
#IfWinActive
; Functions
#Include, TLLib.ahk
#Include, ProcessInfo.ahk

; Classes


; Subs
Open:
	Gui, Submit, NoHide
	DetectHiddenWindows, On
	WinGet,expid,PID, ahk_exe %Choice%
	this_path:=GetModuleFileNameEx(expid)
	SplitPath,this_path, ,ndir
	If ndir
		Run % ndir
	Else
		MsgBox,64,Task Lister Info,% "Can not get path from executable."
	DetectHiddenWindows, Off
Return
ButtonKillSelectedTask:
	Gui, Submit, NoHide
	SetTimer, HideCMD, -1
	ShellExec("taskkill.exe","/im "  Choice " /f")
	WinWaitNotActive, ahk_class ConsoleWindowClass
	Gui, Flash
	Gosub, RefreshList
Return
HideCMD:
	IfWinExist, ahk_class ConsoleWindowClass
		{
			WinHide, ahk_class ConsoleWindowClass
			SetTimer, HideCMD, Off
		}
	Else
		SetTimer,HideCMD,-1
Return
RefreshList:
	IfWinActive, % "ahk_id " this_id
		{
			exe:=""
			Gui, Submit, NoHide
			Loop, Parse, % TaskList(,,1), |
				{
					exe:=(A_LoopField == Choice)?1:0
					If exe
						Break
				}
			If (!Choice || !exe)
				{
					ControlFocus,ComboBox1, ahk_id %this_id%
					ControlSend, ComboBox1,{Down}, ahk_id %this_id%
				}
			If (tl != TaskList(,,1))
				{
					IfWinActive, ahk_id %this_id%
						{
							WinActivate, ahk_id %this_id%
							GuiControl,,ComboBox1, % "|" TaskList(,,1)
							ToolTip % "TaskList updated"
							ttx:=window._x("ahk_id " this_id)+(E1X-2)
							tty:=window._y("ahk_id " this_id)+(E1Y-2)
							WinMove, ahk_class tooltips_class32, ,%ttx% ,%tty%
							Sleep,1
							If TT_FADE("in",32)
								{
									Sleep, 1000
									TT_FADE("out",16)
								}
						}
					proc:=""
					proc:=TaskList(,1)
					tl:=TaskList(,,1)
				}
			ControlGetFocus,focus, ahk_id %this_id%
			If (focus != "Edit1")
				ControlSend, ComboBox1,{Right}, ahk_id %this_id%
		}
Return
FileOpen:
	FileSelectFile,file,3, % A_WinDir "\System32"
	If file
		{
			Run, % file
			file:=""
		}
Return
Help:
	MsgBox,68,Task Lister Help,	%	Spaces("Tab")	"Task Lister is a simple program to view or kill`n"
										.						"Windows processes. In this portable program some`n"
										.						"process locations can not be opened in explorer,`n"
										.						"but others can.`n`n"
										.						"Hotkeys" A_Tab "Function`n"
										.						"-------" A_Tab "--------`n"
										.						"Alt+K" A_Tab "Kill selected process.`n"
										.						"Alt+O" A_Tab "Open selected processes folder location.`n`n"
										.						"Email me with questions or suggestions?"
	IfMsgBox, Yes
		Gosub, Email
Return
About:	
	MsgBox,64,Task Lister Info,	%	Spaces("Tab")	"Task Lister is a portable task manager for the Windows `n"
										.						"OS. It can be put on a disk or flash drive to use on systems `n"
										.						"that have been infected by viruses and the default Task `n"
										.						"Manager has been disabled.`n`n"
										.	Spaces("Tab")	"This is not a full-featured task manager, but feel free to`n"
										.						"use as a light-weight replacement for your task manager on`n"
										.						"your own system.`n`n"
										.						"Written in AutoHotkey by Ian Pride @ New Pride Services 2016"
Return
Email:
	Run, mailto:faithnomoread@yahoo.com
Return
KillTT:
	counters2=255
	Loop
		{
			If (counters2 <= -1)
				Break
			Sleep, 1
			SetTrans("ahk_class tooltips_class32",counters2)
			counters2-=16
		}
	ToolTip
Return
GuiClose:
	ExitApp