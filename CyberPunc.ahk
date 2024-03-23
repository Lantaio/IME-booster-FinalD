#Requires AutoHotkey v2.0
#SingleInstance
; global KeyLog := ""
global LastChar := ""
global LastCharType := "e"
global LastKey := "" ; 声明全局变量以存储上一次按下的键
; 监听热键 Win + Alt
$#Alt:: {
	global
	; 检查是否是小数点
	Switch LastKey
	{
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
		Return
	}
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
~9:: {
	global
	LastKey := SubStr(ThisHotkey, 2) ; 将当前按键存储在 LastKey 变量中
	LastChar := SubStr(ThisHotkey, 2)
	LastCharType := "1"
}

#HotIf IsNumber(LastCharType)
$.:: {
	global
	LastKey := SubStr(ThisHotkey, 2) ; 将当前按键存储在 LastKey 变量中
	LastChar := "."
	SendText "."
}
:*?:..::
{
	global
	LastChar := "。"
	LastCharType := "z"
	SendText "。"
}

#HotIf LastCharType = "e"
$.:: {
	global
	LastKey := SubStr(ThisHotkey, 2) ; 将当前按键存储在 LastKey 变量中
	LastChar := "."
	SendText "."
}

#HotIf LastCharType = "z"
$.:: {
	global
	LastKey := SubStr(ThisHotkey, 2) ; 将当前按键存储在 LastKey 变量中
	LastChar := "。"
	SendText "。"
}
