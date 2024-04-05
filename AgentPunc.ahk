/*
说明：AgentPunc™/标点特工™ 智能中英文标点符号输入代理器。
作者：Lantaio Joy
版本：0.3.6
更新：2024.4.5
*/
#Requires AutoHotkey v2.0
#SingleInstance
#UseHook
SetTitleMatchMode "RegEx"  ; 设置窗口标题的匹配模式为正则模式

; 借助剪砧板获取光镖位置前一个子符
GetPrevChar() {
	; 临时寄存剪贴板内容
	clipStorage := ClipboardAll()
	; 清空剪贴板
	A_Clipboard := ""
	; 获取当前光镖位置的前一个子符
	Send "+{Left}^c"
	; 等待剪贴板更新
	ClipWait 0.2
	; 获取剪贴板中的字符，即光镖前一个子符，然后恢复原来的剪贴板内容
	prevChar := A_Clipboard, A_Clipboard := clipStorage, clipStorage := ""
	if prevChar != '' and (StrLen(prevChar) = 1 or prevChar = "`r`n")
		Send "{Right}"
	; Send StrLen(prevChar)
	return prevChar
}

; 借助剪砧板获取光镖位置后一个子符
GetNextChar() {
	; 临时寄存剪贴板内容
	clipStorage := ClipboardAll()
	; 清空剪贴板
	A_Clipboard := ""
	; 获取当前光镖位置的后一个子符
	Send "+{Right}^c"
	; 等待剪贴板更新
	ClipWait 0.2
	; 获取剪贴板中的字符，即光镖后一个子符，然后恢复原来的剪贴板内容
	nextChar := A_Clipboard, A_Clipboard := clipStorage, clipStorage := ""
	if nextChar != '' and (StrLen(nextChar) = 1 or nextChar = "`r`n")
		Send "{Left}"
	; Send Ord(nextChar)
	return nextChar
}

; 判断接下来是否该输入英文标点（还是中文标点）
ExpectEnglishPunc() {
	prevChar := GetPrevChar()
	; 如果前一个字符在英文字符集中，则……
	if Ord(prevChar) < 0x200A
		return true
	else if prevChar = '‘'
		return true
	else
		return false
}

; 判断光镖是否在行末
IsEndOfLine() {
	nextChar := GetNextChar()
	; 如果下一个子符是换行符 或 回车符 或 回车换行符 或 为空子符串，则……
	if nextChar = "`n" or nextChar = "`r" or nextChar = "`r`n" or nextChar = ''
		return true
	else
		return false
}

/*IsAutoOKApp() {
	if WinActive("ahk_exe sublime")
		return false
	else
		return true
}
*/

; 如果不存在输入法候选窗口，并且当前活动窗口不是Excel，则……
#HotIf not (WinExist("ahk_class ^ATL:") or WinActive("Excel"))  ; or WinActive("ahk_class ConsoleWindowClass"))
,:: {
	; 如果接下来该输入英文标点，则……
	if ExpectEnglishPunc()
		SendText ","  ; 输出按键对应的英文标点
	else
		SendText "，"  ; 输出按键对应的中文标点
}
.:: {
	if ExpectEnglishPunc()
		SendText "."
	else
		SendText "。"
}
`;:: {
	if ExpectEnglishPunc()
		SendText ";"
	else
		SendText "；"
}
::: {
	if ExpectEnglishPunc()
		SendText ":"
	else
		SendText "："
}
":: {
	if ExpectEnglishPunc() {
		SendText '"'
		if IsEndOfLine() {
			SendText '"'
			Send "{Left}"
		}
	}
	else {
		SendText "“"
		if IsEndOfLine() {
			SendText '”'
			Send "{Left}"
		}
	}
}
':: {
	if ExpectEnglishPunc() {
		SendText "'"
		if IsEndOfLine() {
			SendText "'"
			Send "{Left}"
		}
	}
	else {
		SendText "‘"
		if IsEndOfLine() {
			SendText '’'
			Send "{Left}"
		}
	}
}
(:: {
	if ExpectEnglishPunc()
		SendText "("
	else
		SendText "（"
}
):: {
	if ExpectEnglishPunc()
		SendText ")"
	else
		SendText "）"
}
[:: {
	SendText "["
/*	if ExpectEnglishPunc()
	else
		Send "["
*/
}
]:: {
	SendText "]"
/*	if ExpectEnglishPunc()
	else
		Send "]"
*/
}
{:: {
	if ExpectEnglishPunc()
		SendText "{"
	else
		SendText "「"
}
}:: {
	if ExpectEnglishPunc()
		SendText "}"
	else
		SendText "」"
}
/:: {
	SendText "/"
/*	if ExpectEnglishPunc()
	else
		Send "/"
*/
}
\:: {
	if ExpectEnglishPunc()
		SendText "\"
	else
		SendText "、"
}
/*=:: SendText "="
+:: SendText "+"
-:: SendText "-"
*:: SendText "*"
#:: SendText "#"
`:: SendText "`"
*/
_:: {
	if ExpectEnglishPunc()
		SendText "_"
	else
		SendText "——"
}
!:: {
	if ExpectEnglishPunc()
		SendText "!"
	else
		SendText "！"
}
?:: {
	if ExpectEnglishPunc()
		SendText "?"
	else
		SendText "？"
}
<:: {
	if ExpectEnglishPunc()
		SendText "<"
	else
		SendText "《"
}
>:: {
	if ExpectEnglishPunc()
		SendText ">"
	else
		SendText "》"
}
; &:: SendText "&"
|:: {
	if ExpectEnglishPunc()
		SendText "|"
	else
		Send "{Blind}\"
}
$:: {
	if ExpectEnglishPunc()
		SendText "$"
	else
		Send "{Blind}4"
}
; @:: SendText "@"
; %:: SendText "%"
~:: {
	if ExpectEnglishPunc()
		SendText "~"
	else
		Send "{Blind}``"
}
^:: {
		Send "{Blind}6"
/*	if ExpectEnglishPunc()
		SendText "^"
	else
*/
}

#Alt:: {
	switch GetPrevChar()
	{
	case ".": Send "{BS}{Text}。" ; 如果是英文句点，则替换为中文句号。
	case "。": Send "{BS}{Text}." ; 如果是中文句号，则替换为英文句点。

	case ",": Send "{BS}{Text}，"
	case "，": Send "{BS}{Text},"

	case ";": Send "{BS}{Text}；"
	case "；": Send "{BS}{Text};"

	case ":": Send "{BS}{Text}："
	case "：": Send "{BS}{Text}:"

	case '"': Send "{BS}{Text}“"
	case "“": Send "{BS}{Text}”"
	case "”": Send '{BS}{Text}"'

	case "'": Send "{BS}{Text}‘"
	case "‘": Send "{BS}{Text}’"
	case "’": Send "{BS}{Text}'"

	case "(": Send "{BS}{Text}（"
	case "（": Send "{BS}{Text}("

	case ")": Send "{BS}{Text}）"
	case "）": Send "{BS}{Text})"

	case "[": Send "{BS}{Text}【"
	case "【": Send "{BS}{Text}〖"
	case "〖": Send "{BS}{Text}["

	case "]": Send "{BS}{Text}】"
	case "】": Send "{BS}{Text}〗"
	case "〗": Send "{BS}{Text}]"

	case "{": Send "{BS}{Text}「"
	case "「": Send "{BS}{Text}『"
	case "『": Send "{BS}{Text}{"

	case "}": Send "{BS}{Text}」"
	case "」": Send "{BS}{Text}』"
	case "』": Send "{BS}{Text}}"

	case "/": Send "{BS}{Text}÷"
	case "÷": Send "{BS}{Text}/"

	case "\": Send "{BS}{Text}、"
	case "、": Send "{BS}{Text}\"

	case "=": Send "{BS}{Text}≈"
	case "≈": Send "{BS}{Text}≃"
	case "≃": Send "{BS}{Text}≅"
	case "≅": Send "{BS}{Text}="

	case "+": Send "{BS}{Text}⌥"
	case "⌥": Send "{BS}{Text}⌘"
	case "⌘": Send "{BS}{Text}+"

	case "-": Send "{BS}{Text}→"
	case "→": Send "{BS}{Text}↔"
	case "↔": Send "{BS}{Text}-"

	case "*": Send "{BS}{Text}×"
	case "×": Send "{BS}{Text}*"

	case "#": Send "{BS}{Text}■"
	case "■": Send "{BS}{Text}□"
	case "□": Send "{BS}{Text}#"

	case "``": Send "{BS}{Text}°"
	case "°": Send "{BS}{Text}``"

	case "_": Send "{BS}{Text}——"
	case "—": Send "{BS 2}{Text}_"

	case "!": Send "{BS}{Text}！"
	case "！": Send "{BS}{Text}!"

	case "?": Send "{BS}{Text}？"
	case "？": Send "{BS}{Text}?"

	case "<": Send "{BS}{Text}《"
	case "《": Send "{BS}{Text}<"

	case ">": Send "{BS}{Text}》"
	case "》": Send "{BS}{Text}◆"
	case "◆": Send "{BS}{Text}◇"
	case "◇": Send "{BS}{Text}>"

	case "&": Send "{BS}{Text}℃"
	case "℃": Send "{BS}{Text}℉"
	case "℉": Send "{BS}{Text}&"

	case "|": Send "{BS}{Text}｜"
	case "｜": Send "{BS}{Text}|"

	case "$": Send "{BS}{Text}￥"
	case "￥": Send "{BS}{Text}$"

	case "@": Send "{BS}{Text}●"
	case "●": Send "{BS}{Text}○"
	case "○": Send "{BS}{Text}@"

	case "%": Send "{BS}{Text}★"
	case "★": Send "{BS}{Text}☆"
	case "☆": Send "{BS}{Text}%"

	case "~": Send "{BS}{Text}～"
	case "～": Send "{BS}{Text}˜"
	case "˜": Send "{BS}{Text}≋"
	case "≋": Send "{BS}{Text}~"

	case "^": Send "{BS}{Text}……"
	case "…": Send "{BS 2}{Text}▲"
	case "▲": Send "{BS}{Text}△"
	case "△": Send "{BS}{Text}^"
	}
}
