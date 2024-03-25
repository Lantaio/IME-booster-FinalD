#Requires AutoHotkey v2.0
#SingleInstance
; global KeyLog := ""
global LastChar := ""
global LastCharType := "e"
global LastKey := "" ; 声明全局变量以存储上一次按下的键

~a::
~b::
~c::
~d::
~e::
~f::
~g::
~h::
~i::
~j::
~k::
~l::
~m::
~n::
~o::
~p::
~q::
~r::
~s::
~t::
~u::
~v::
~w::
~x::
~y::
~z:: {
	global LastCharType := "a"
}

~0::
~1::
~2::
~3::
~4::
~5::
~6::
~7::
~8::
~9::
~NumPad0::
~NumPad1::
~NumPad2::
~NumPad3::
~NumPad4::
~NumPad5::
~NumPad6::
~NumPad7::
~NumPad8::
~NumPad9:: {
	; 将当前按键存储在 LastKey 变量中
	global LastKey := SubStr(ThisHotkey, 2), LastChar := SubStr(ThisHotkey, 2)
	, LastCharType := "n"
}

#HotIf LastCharType = "a"
~Enter:: global LastCharType := "e"
~Space:: global LastCharType := "z"

#HotIf LastCharType = "n" And LastKey = "."
~.:: {
	global LastChar := "。", LastCharType := "z"
	Send "{Backspace 2}{Text}。"
}

#HotIf LastCharType = "n"
~.:: {
	global LastKey := ".", LastChar := "."
	; SendText "."
}

#HotIf LastCharType = "e"
~.:: {
	global LastKey := ".", LastChar := "."
	; SendText "."
}

#HotIf LastCharType = "z"
~.:: {
	global LastKey := ".", LastChar := "。"
	; SendText "。"
}

#HotIf
~Enter:: global LastCharType := "e"
~Space:: global LastCharType := "e"

; 监听热键 Win + Alt
#Alt:: {
	global
	; LastChar := GetLastChar()
	Switch LastKey
	{
	; 是句点
	Case ".":
		; 如果是小数点，则替换为中文句号
		If LastChar = "." {
			LastChar := "。"
			LastCharType := "z"
			Send "{Backspace}{text}。"
		}
		; 如果是中文句号，则替换为小数点
		Else {
			LastChar := "."
			LastCharType := "e"
			Send "{Backspace}{text}."
		}
		; Return
	}
}

GetLastChar() {
	; 清空剪贴板
	A_Clipboard := ""
	; 获取当前光标位置并保存
	Send "^{LEFT}^c"
	; 等待剪贴板更新
	ClipWait
	; 获取剪贴板中的文本，即光标前一个字符
	prevChar := A_Clipboard
	Return prevChar
}
