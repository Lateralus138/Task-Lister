/* 
Library of Lateralus138's window functions, objects, and classes for AutoHotkey.
GuiLib also provides a basic screen/window interface, (API you might say)
for better window/window placement and manipulation. Plans to make this as 
universal as possible. Email: faithnomoread@yahoo.com for help, suggestions,
or possible collaboration.
*/


; Functions
GetControls(title,control:=0,posvar:=0){
	If (control && posvar)
		{
			namenum:=EnumVarName(control)
			ControlGetPos,x,y,w,h,%control%,%title%
			pos:=(posvar == "X")?x
			:(posvar == "Y")?y
			:(posvar == "W")?w
			:(posvar == "H")?h
			:(posvar == "X2")?x+w
			:(posvar == "Y2")?Y+H
			:0
			Globals.SetGlobal(namenum posvar,pos)
			Return pos
		}
	Else If !(control && posvar)
		{
			WinGet,a,ControlList,%title%
			Loop,Parse,a,`n
				{
					namenum:=EnumVarName(A_LoopField)
					If namenum
						{
							ControlGetPos,x,y,w,h,%A_LoopField%,%title%
							Globals.SetGlobal(namenum "X",x)
							Globals.SetGlobal(namenum "Y",y)
							Globals.SetGlobal(namenum "W",w)
							Globals.SetGlobal(namenum "H",h)
							Globals.SetGlobal(namenum "X2",x+w)
							Globals.SetGlobal(namenum "Y2",y+h)				
						}
				}
			Return a
		}
}
EnumVarName(control){
	name:=InStr(control,"msctls_p")?"MP"
	:InStr(control,"Static")?"S"
	:InStr(control,"Button")?"B"
	:InStr(control,"Edit")?"E"
	:InStr(control,"ListBox")?"LB"
	:InStr(control,"msctls_u")?"UD"
	:InStr(control,"ComboBox")?"CB"
	:InStr(control,"ListView")?"LV"
	:InStr(control,"SysTreeView")?"TV"
	:InStr(control,"SysLink")?"L"
	:InStr(control,"msctls_h")?"H"
	:InStr(control,"SysDate")?"TD"
	:InStr(control,"SysMonthCal")?"MC"
	:InStr(control,"msctls_t")?"SL"
	:InStr(control,"msctls_s")?"SB"
	:InStr(control,"327701")?"AX"
	:InStr(control,"SysTabC")?"T"
	:0
	num:=(name == "MP")?SubStr(control,18)
	:(name == "S")?SubStr(control,7)
	:(name == "B")?SubStr(control,7)
	:(name == "E")?SubStr(control,5)
	:(name == "LB")?SubStr(control,8)
	:(name == "UD")?SubStr(control,15)
	:(name == "CB")?SubStr(control,9)
	:(name == "LV")?SubStr(control,14)
	:(name == "TV")?SubStr(control,14)
	:(name == "L")?SubStr(control,8)
	:(name == "H")?SubStr(control,16)
	:(name == "TD")?SubStr(control,18)
	:(name == "MC")?SubStr(control,14)
	:(name == "SL")?SubStr(control,18)
	:(name == "SB")?SubStr(control,19)
	:(name == "AX")?SubStr(control,5)
	:(name == "T")?SubStr(control,16)
	:0
	Return name num
}
MouseOver(xa,ya,xb,yb)
{
	MouseGetPos, px, py
	isOver := px >= xa AND px <= xb AND py >= ya AND py <= yb
	Return isOver
}
ShellExec(path,args:=""){
	DllCall("shell32\ShellExecute"
			, "uint",0,"uint",0
			, "str",path,"str",args
			, "uint",0,"int",1)
}
SetParent(child,parent){
	WinGet,chid,ID, % child
	WinGet,did,ID, % parent
	Return DllCall("SetParent","uint",chid,"uint",did)
}
SetTrans(win,trans){
	win:=WinExist(win)
	Return DllCall("SetLayeredWindowAttributes"
					,"uint",win,"uint",0
					,"uchar",trans,"uint",2)
}
TaskList(delim:="|",getArray:=0,sort:=0){
	d := delim
	s := 4096  
	Process, Exist  
	h := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", ErrorLevel, "Ptr")
	DllCall("Advapi32.dll\OpenProcessToken", "Ptr", h, "UInt", 32, "PtrP", t)
	VarSetCapacity(ti, 16, 0)  
	NumPut(1, ti, 0, "UInt")  
	DllCall("Advapi32.dll\LookupPrivilegeValue", "Ptr", 0, "Str", "SeDebugPrivilege", "Int64P", luid)
	NumPut(luid, ti, 4, "Int64")
	NumPut(2, ti, 12, "UInt")  
	r := DllCall("Advapi32.dll\AdjustTokenPrivileges", "Ptr", t, "Int", false, "Ptr", &ti, "UInt", 0, "Ptr", 0, "Ptr", 0)
	DllCall("CloseHandle", "Ptr", t)  
	DllCall("CloseHandle", "Ptr", h)  
	hModule := DllCall("LoadLibrary", "Str", "Psapi.dll")  
	s := VarSetCapacity(a, s)  
	c := 0  
	DllCall("Psapi.dll\EnumProcesses", "Ptr", &a, "UInt", s, "UIntP", r)
	Loop, % r // 4  
	{
	   id := NumGet(a, A_Index * 4, "UInt")
	   h := DllCall("OpenProcess", "UInt", 0x0010 | 0x0400, "Int", false, "UInt", id, "Ptr")
	   if !h
		  continue
	   VarSetCapacity(n, s, 0)  
	   e := DllCall("Psapi.dll\GetModuleBaseName", "Ptr", h, "Ptr", 0, "Str", n, "UInt", A_IsUnicode ? s//2 : s)
	   if !e    
		  if e := DllCall("Psapi.dll\GetProcessImageFileName", "Ptr", h, "Str", n, "UInt", A_IsUnicode ? s//2 : s)
			{
				 SplitPath, n, n
			}
	   DllCall("CloseHandle", "Ptr", h)  
	   if (n && e)  
		  l .= n . d, c++
	}
	DllCall("FreeLibrary", "Ptr", hModule)  
	l:=SubStr(l,1,StrLen(l)-1) " " ndir
	If getArray
		{
			proc:=!proc?Object():""
			Loop, Parse, l, |
				proc.Push(A_LoopField)
		}
	If sort
		Sort, l, D%delim%
	Return getArray?proc:l
}

;; Additional functions for tasklister
TT_FADE(state,inc:=8,max:=255,win:="ahk_class tooltips_class32"){
	c:=InStr(state,"in")?-1
	:InStr(state,"out")?255
	:0
	If (!c || !inc || !max) 
		Return 0
	Loop
		{
			Sleep, 1
			SetTrans(win,c)
			If InStr(state,"in")
				{
					If (c >= max)
						Break
					c+=inc
				}
			Else
				{
					If (c <= -1 && (win == "ahk_class tooltips_class32"))
						{
							ToolTip
							Break
						}
					c-=inc				
				}
		}
	Return 1
}
CloseButton(x,y,lcolor,dcolor,small:=False){
	small:=small?3:4
	big:=small*3
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% x%x% y%y% w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% y+0 x+0 w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% y+0 x+0 w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% y+0 xp-%small% w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% y+0 xp-%small% w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% yp-%big% xp+%big% w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% yp-%small% x+0 w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% yp+%big% xp-%small% w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% y+0 x+0 w%small% h%small%, 100
}
MinButton(x,y,lcolor,dcolor,small:=False){
	small:=small?3:4
	big:=small*3
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% x%x% y%y% w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% yp x+0 w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% yp x+0 w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% yp x+0 w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% yp x+0 w%small% h%small%, 100
}
Spaces(a:=1){
	a:=InStr(a,"tab")?4:a
	Loop, % a
		b.=A_Space
	Return b
}
WM_LBUTTONDOWN(){
	Global
	Local over
	GetControls("Task Lister")
	over:=MouseOver(MP2X,MP7Y,MP7X2,MP2Y2)?7
	:MouseOver(MP7X,MP7Y,MP15X2,MP15Y2)?1
	:MouseOver(S3X,S3Y,S3X2,S3Y2)?6
	:MouseOver(S2X,S2Y,S2X2,S2Y2)?5
	:(MouseOver(S1X,S1Y,S1X2,S1Y2) || MouseOver(MP16X,MP16Y,MP16X2,MP16Y2))?4
	:MouseOver(MP17X,MP17Y,MP17X2,MP17Y2)?3
	:MouseOver(MP18X,MP18Y,MP18X2,MP18Y2)?2
	:0
	If (over == 7)
		{
			Gui, Flash
			WinMinimize, ahk_id %this_id%
		}
	If (over == 1)
		ExitApp
	If (over == 6){
			MouseMove,%S2X%,%S2Y2%
			Menu, HelpMenu, Show
		}
	If (over == 5){
			MouseMove,%S2X%,%S2Y2%
			Menu, MainMenu, Show
		}
	If (over == 4)
		PostMessage, 0xA1, 2,,, ahk_id %this_id%
	If (over == 3)
		Gosub, ButtonKillSelectedTask
	If (over == 2)
		Gosub, Open
}
WM_MOUSEHOVER(){
	Global
	Local over
	GetControls("Task Lister")
	over:=MouseOver(MP17X,MP17Y,MP17X2,MP17Y2)?1
	:MouseOver(MP18X,MP18Y,MP18X2,MP18Y2)?2
	:MouseOver(CB1X,CB1Y,CB1X2,CB1Y2)?3
	:0
	If (over == 1){
		SetTimer,TT_OVER_1,-1250
	}
	If (over == 2){
		SetTimer,TT_OVER_2,-1250
	}
	If (over != 3)
		ControlSend, ComboBox1,{Right}, ahk_id %this_id%
	If !over {	
		DllCall( "TrackMouseEvent","uint",&tme )
		ToolTip
	}
}
TT_OVER_1(){
	Global
	If !WinExist("ahk_class tooltips_class32")
		{
			Static c:=0
			GetControls("Task Lister")
			If Mod(++c,2)
				{
					If MouseOver(MP17X,MP17Y,MP17X2,MP17Y2)
						{
							ToolTip % "Alt+K"
							Sleep, 3000
							ToolTip
						}		
				}
		}
}
TT_OVER_2(){
	Global
	If !WinExist("ahk_class tooltips_class32")
		{
			Static c:=0
			GetControls("Task Lister")
			If Mod(++c,2)
				{
					If MouseOver(MP18X,MP18Y,MP18X2,MP18Y2)
						{
							ToolTip % "Alt+O"
							Sleep, 3000
							ToolTip
						}
				}
		}
}
WM_SHOWWINDOW(){
	Global
	Local over
	GetControls("Task Lister")
	over:=MouseOver(CB1X,CB1Y,CB1X2,CB1Y2)?1:0
	If (over != 1)
		ControlSend, ComboBox1,{Right}, ahk_id %this_id%
	DllCall( "TrackMouseEvent","uint",&tme )
}
WM_MOUSELEAVE(){
	ToolTip
}
Button(bc,fc,w,txt,title,txtc:="Black",txts:=9,txtw:=500,font:="Segoe UI"){
	ns:=InStr(txt,"`n")
	h:=!ns?txts*3:txts*4
	vc:=!ns?200:0
	Gui, Font, c%txtc% s%txts% w%txtw%, % font
	Gui, Add, Progress, Background%bc% c%fc% w%w% h%h%, 100
	Gui, Add, Text, xp yp w%w% h%h% 0x%vc% +Center +BackgroundTrans,	%	txt
}
MenuItem(txt,w:=40,h:=20,first:=0){
	xpos:=first?"p":"+0"
	Gui, Add, Text, w%w% h%h% x%xpos% yp +BackgroundTrans +Center 0x200, % txt
}
; Classes
Class Globals { ; my favorite way to set and retrive global tions. Good for
	SetGlobal(name,value=""){ ; setting globals from other tions
		Global
		%name%:=value
		Return
	}
	GetGlobal(name){	
		Global
		Local var:=%name%
		Return var
	}
}
; Main window class, syntax E.g.: 
; windowXPos:=window._x("Window Title") or MsgBox % window._w("ahk_class Shell_TrayWnd")
; or any other way a function or expression can be called/ran/stored. 
Class window {
	_x(title){ 						; Get a windows upper left x position relative to the desktop. This applies 
		WinGetPos,x,,,, %title% 	; to next 3 functions; y, width, and height respectively.
		Return x						; title - can be anything that can be passed to WinGetPos
	}									; E.g.: Window Title, ahk_class Shell_TrayWnd, etc...
	_y(title){
		WinGetPos,,y,,, %title%
		Return y
	}
	_w(title){
		WinGetPos,,,w,, %title%
		Return w
	}
	_h(title){
		WinGetPos,,,,h, %title%
		Return h
	}
	_halfw(title){ 				; Get the half width of a window to use in conjunction with screen._cx()
		WinGetPos,,,w,, %title% 	; to perfectly center a window in the desktop. Formula for a windows
		Return w/2 					; center X pos be WindowX:=screen._cx() - window._halfw("Window Title")
	}
	_halfh(title){
		WinGetPos,,,,h, %title%
		Return h/2
	}
	; Window controls class, syntax E.g.:
	; controlXpos:=window.controls._x("Static1","Window Title") 
	; or MsgBox % window.controls._x2("msctls_progress322","Window Title")
	Class controls {
		_x(control,title){ 								; Get a controls X position relative to the desktop.
			ControlGetPos,x,,,,% control,% title		; This applies to the next 5 functions for y, Width,
			Return x										; Height, x2 position (x+w) and y2 for MouseOver 
		}													; function.
		_y(control,title){
			ControlGetPos,,y,,,% control,% title
			Return y
		}
		_w(control,title){
			ControlGetPos,,,w,,% control,% title
			Return w
		}
		_h(control,title){
			ControlGetPos,,,,h,% control,% title
			Return h
		}
		_x2(control,title){
			ControlGetPos,x,,w,,% control,% title
			Return x+w
		}
		_y2(control,title){
			ControlGetPos,,y,,h,% control,% title
			Return y+h
		}
	}
}
; Get the desktops width and height, syntax E.g.:
; screenWidth:=screen._w() or MsgBox % screen._h() 
Class screen {
	_w(){
		SysGet,w,16
		Return w
	}
	_h(){				; 17 gets the hieght minus the taskbar.
		SysGet,h,17	; using _hbar() for full height.
		Return h
	}
	_hbar(){			; 79 gets height plus the taskbar.
		SysGet,h,79
		Return h	
	}
	_cx(){ 						; Screen center X
		Return (screen._w()/2)		
	}
	_cy(){						; Screen center y minus taskbar
		Return (screen._h()/2)		
	}
	_cybar(){						; Screen center y plus taskbar
		Return (screen._hbar()/2)		
	}
}