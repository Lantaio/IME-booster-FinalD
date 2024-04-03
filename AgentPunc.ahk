#Requires AutoHotkey v2.0
#SingleInstance
#UseHook
SetTitleMatchMode "RegEx"  ; 设置窗口标题的匹配模式为正则模式

; 借助剪贴板获取光标位置前一个字符
GetPrevChar() {
	; 临时寄存剪贴板内容
	temp := A_Clipboard
	; 清空剪贴板
	A_Clipboard := ""
	; 获取当前光标位置的前一个字符
	Send "+{Left}^c{Right}"
	; 等待剪贴板更新
	ClipWait 0.2
	; 获取剪贴板中的字符，即光标前一个字符，然后恢复原来的剪贴板内容
	prevChar := A_Clipboard, A_Clipboard := temp
	return prevChar
}

; 判断接下来该输入英文标点还是中文标点
ExpectEnglishPunc() {
	prevChar := GetPrevChar()
	; 如果前一个字符不在中文字符集中，则……
	if Ord(prevChar) < 0x200A
		return true
	else if prevChar = '‘'
		return true
	else
		return false
}

; 如果存在输入法候选窗口，则……
#HotIf not WinExist("ahk_class ^ATL:")
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
	if ExpectEnglishPunc()
		SendText '"'
	else
		Send "{Blind}'"
}
':: {
	if ExpectEnglishPunc()
		SendText "'"
	else
		Send "'"
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
	SendText "\"
/*	if ExpectEnglishPunc()
	else
		SendText "、"
*/
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
	SendText "<"
/*	if ExpectEnglishPunc()
	else
		SendText "《"
*/
}
>:: {
	SendText ">"
/*	if ExpectEnglishPunc()
	else
		SendText "》"
*/
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
		Send "+``"
}
^:: {
	if ExpectEnglishPunc()
		SendText "^"
	else
		Send "+6"
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

	case "^": Send "{BS}{Text}▲"
	case "▲": Send "{BS}{Text}△"
	case "△": Send "{BS}{Text}^"
	}
}
