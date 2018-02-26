## Task Lister

Task Lister is a portable task manager that can be used as an alternative to the native Windows Task Manager. It is great for flash drives or disk to use on computers that have viruses that have disabled the task manager or it can be used as a lightweight alternative. It is written in AutoHotkey.

## Example Code - Getting and refreshing the task list
This function is just a modification of the example shown at the bottom of this page: [AutoHotkey - Docs - Commands - Process](https://autohotkey.com/docs/commands/Process.htm)
```
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
```
## Motivation

I created this to help work on clients computers.

## Installation

Portable program (Plans for installer and portable option).


## Test
I have tested on Windows 10 32 Bit and Windows 7 64 Bit.

## Contributors

Ian Pride @ faithnomoread@yahoo.com - [Lateralus138] @ New Pride Services 

## License

	This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

	License provided in gpl.txt

## Latest Release
[Task Lister v1.1](https://github.com/Lateralus138/Task-Lister/raw/v1.1/Task%20Lister.exe)
