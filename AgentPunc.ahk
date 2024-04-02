#Requires AutoHotkey v2.0
#SingleInstance
#UseHook
SetTitleMatchMode "RegEx"  ;

GetPrevChar() {
	; 临时转存剪贴板内容
	temp := A_Clipboard
	; 清空剪贴板
	A_Clipboard := ""
	; 获取当前光标位置的前一个字符
	Send "+{Left}^c{Right}"
	; 等待剪贴板更新
	ClipWait 0.2
	; 获取剪贴板中的字符，即光标前一个字符，然后恢复原来的剪贴板内容
	prevChar := A_Clipboard, A_Clipboard := temp
	Return prevChar
}

; 如果当前活动窗口没有输入法候选窗口，并且前一个字符不是中文字符，则...
#HotIf Not WinExist("ahk_class ATL:00007FF")
,:: {
	SendText ""
	If Ord(GetPrevChar()) < 9352
		SendText ","
	Else
		SendText "，"
}
.:: {
	If Ord(GetPrevChar()) < 9352
		SendText "."
	Else
		SendText "。"
}
`;:: {
	If Ord(GetPrevChar()) < 9352
		SendText ";"
	Else
		SendText "；"
}
::: {
	If Ord(GetPrevChar()) < 9352
		SendText ":"
	Else
		SendText "："
}
":: {
	If Ord(GetPrevChar()) < 9352
		SendText '"'
	Else
		Send '"'
}
':: {
	If Ord(GetPrevChar()) < 9352
		SendText "'"
	Else
		Send "'"
}
(:: {
	If Ord(GetPrevChar()) < 9352
		SendText "("
	Else
		SendText "（"
}
):: {
	If Ord(GetPrevChar()) < 9352
		SendText ")"
	Else
		SendText "）"
}
/*[:: {
	If Ord(GetPrevChar()) < 9352
		SendText "["
	Else
		SendText "【"
}
]:: {
	If Ord(GetPrevChar()) < 9352
		SendText "]"
	Else
		SendText "】"
}
*/
{:: {
	If Ord(GetPrevChar()) < 9352
		SendText "{"
	Else
		SendText "「"
}
}:: {
	If Ord(GetPrevChar()) < 9352
		SendText "}"
	Else
		SendText "」"
}
/*/:: {
	If Ord(GetPrevChar()) < 9352
		SendText "/"
	Else
		SendText "÷"
}
\:: {
	If Ord(GetPrevChar()) < 9352
		SendText "\"
	Else
		SendText "、"
}
*/
/*=:: SendText "="
+:: SendText "+"
-:: SendText "-"
*:: SendText "*"
#:: SendText "#"
`:: SendText "``"
*/
_:: {
	If Ord(GetPrevChar()) < 9352
		SendText "_"
	Else
		SendText "——"
}
!:: {
	If Ord(GetPrevChar()) < 9352
		SendText "!"
	Else
		SendText "！"
}
?:: {
	If Ord(GetPrevChar()) < 9352
		SendText "?"
	Else
		SendText "？"
}
<:: {
	If Ord(GetPrevChar()) < 9352
		SendText "<"
	Else
		SendText "《"
}
>:: {
	If Ord(GetPrevChar()) < 9352
		SendText ">"
	Else
		SendText "》"
}
; &:: SendText "&"
/*|:: {
	If Ord(GetPrevChar()) < 9352
		SendText "|"
	Else
		SendText "｜"
}
*/
; @:: SendText "@"
/*$:: {
	If Ord(GetPrevChar()) < 9352
		SendText "$"
	Else
		SendText "￥"
}
%:: SendText "%"
~:: SendText "~"
^:: SendText "^"
*/

#Alt:: {
	; global
	Switch GetPrevChar()
	{
	Case ".": Send "{Backspace}{text}。" ; 如果是小数点，则替换为中文句号
	Case "。": Send "{Backspace}{text}."
	Case ",": Send "{Backspace}{text}，"
	Case "，": Send "{Backspace}{text},"
	}
}
