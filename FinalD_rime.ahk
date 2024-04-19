/*
说明：FinalD™/终点™ 标点符号漂移加速器。
注意：编辑保存此文件时必须保存为“UTF-8 with BOM”编码格式。
作者：Lantaio Joy
版本：0.3.6
更新：2024.4.18
*/
#Requires AutoHotkey v2.0
#SingleInstance
#UseHook
SetTitleMatchMode "RegEx"  ; 设置窗口标题的匹配模式为正则模式
global CHSDoubleQuoteWanted := false  ; 需要简体中文双引号标志
global CHSSingleQuoteWanted := false  ; 需要简体中文单引号标志
; global CHTComerBracketWanted := false  ; 需要繁体中文单引号标志

; 借助剪砧板获取光镖位置前一个子符
GetPrevChar() {
	; 临时寄存剪砧板内容
	clipStorage := ClipboardAll()
	; 清空剪砧板
	A_Clipboard := ''
	; 获取当前光镖位置的前一个子符
	Send "+{Left}^c"
	; 等待剪砧板更新
	ClipWait 0.2
	; 获取剪砧板中的子符，即光镖前一个子符，然后恢复原来的剪砧板内容
	prevChar := A_Clipboard, A_Clipboard := clipStorage, clipStorage := ''
	; 如果前一个子符不为空（即不是文件开头），并且 长度为1 或 是回車換行符（行首）
	if prevChar != '' and (StrLen(prevChar) = 1 or prevChar = "`r`n")
		Send "{Right}"
	; Send StrLen(prevChar)
	return prevChar
}

; 借助剪砧板获取光镖位置后一个子符
GetNextChar() {
	; 临时寄存剪砧板内容
	clipStorage := ClipboardAll()
	; 清空剪砧板
	A_Clipboard := ''
	; 获取当前光镖位置的后一个子符
	Send "+{Right}^c"
	; 等待剪砧板更新
	ClipWait 0.2
	; 获取剪砧板中的子符，即光镖后一个子符，然后恢复原来的剪砧板内容
	nextChar := A_Clipboard, A_Clipboard := clipStorage, clipStorage := ''
	; 如果后一个子符不为空（即不是文件尾），并且 长度为1 或 是回車換行符（行尾）
	if nextChar != '' and (StrLen(nextChar) = 1 or nextChar = "`r`n")
		Send "{Left}"
	; Send StrLen(nextChar)
	return nextChar
}

; 判断前一个字符是不是英纹（或数字）
prevCharIsEnglish() {
	prevChar := GetPrevChar()
	; 如果前一个子符在英纹子符集中，则……
	if Ord(prevChar) < 0x200A
		return true
	; else if prevChar = '‘'
	; 	return true
	else
		return false
}

; 判断光镖是否在行末
IsAtEndOfLine() {
	nextChar := GetNextChar()
	; 如果下一个子符是换行符 或 回车换行符 或 为空子符串，则……
	if nextChar = "`n" or nextChar = "`r`n" or nextChar = ''
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

; 如果不存在输入法候选窗口，并且当前活动窗口不是Excel或CMD，则……
#HotIf not (WinExist("ahk_class ^ATL:") or WinActive("ahk_class ^XLMAIN$") or
		WinActive("ahk_class ^ConsoleWindowClass$"))
.:: {
	; 如果前一个子符是英纹，则……
	if prevCharIsEnglish()
		SendText "."  ; 输出按键对应的英纹镖点
	else
		SendText "。"  ; 输出按键对应的中纹镖点
}
,:: {
	if prevCharIsEnglish()
		SendText ","
	else
		SendText "，"
}
(:: {
	if prevCharIsEnglish()
		SendText "("
	else
		SendText "（"
}
):: {
	if prevCharIsEnglish()
		SendText ")"
	else
		SendText "）"
}
_:: {
	if prevCharIsEnglish()
		SendText "_"
	else
		SendText "——"
}
::: {
	if prevCharIsEnglish()
		SendText ":"
	else
		SendText "："
}
":: {
	global
	if CHSDoubleQuoteWanted {
		SendText "”"
		CHSDoubleQuoteWanted := false
	}
	else {
		if prevCharIsEnglish() {
			SendText '"'
			if IsAtEndOfLine() {
				SendText '"'
				Send "{Left}"
			}
		}
		else {
			SendText "“"
			CHSDoubleQuoteWanted := true
			if IsAtEndOfLine() {
				SendText "”"
				Send "{Left}"
				CHSDoubleQuoteWanted := false
			}
		}
	}
}
/:: SendText "/"
=:: SendText "="
<:: {
	if prevCharIsEnglish()
		SendText "<"
	else
		SendText "《"
}
>:: {
	if prevCharIsEnglish()
		SendText ">"
	else
		SendText "》"
}
`;:: {
	if prevCharIsEnglish()
		SendText ";"
	else
		SendText "；"
}
-:: SendText "-"
{:: {
	if prevCharIsEnglish() {
		SendText "{"
		if IsAtEndOfLine() {
			SendText "}"
			Send "{Left}"
		}
	}
	else {
		SendText "「"
		if IsAtEndOfLine() {
			SendText "」"
			Send "{Left}"
		}
	}
}
}:: {
	if prevCharIsEnglish()
		SendText "}"
	else
		SendText "」"
}
':: {
	global
	if CHSSingleQuoteWanted = true {
		SendText "’"
		CHSSingleQuoteWanted := false
	}
	else {
		if prevCharIsEnglish() {
			SendText "'"
			if IsAtEndOfLine() {
				SendText "'"
				Send "{Left}"
			}
		}
		else {
			SendText "‘"
			CHSSingleQuoteWanted := true
			if IsAtEndOfLine() {
				SendText "’"
				Send "{Left}"
				CHSSingleQuoteWanted := false
			}
		}
	}
}
*:: SendText "*"
#:: SendText "#"
[:: {
	SendText "["
/*	if prevCharIsEnglish()
	else
		Send "【"
*/
}
]:: {
	SendText "]"
/*	if prevCharIsEnglish()
	else
		Send "】"
*/
}
; `:: SendText "`"
; +:: SendText "+"
&:: {
	if prevCharIsEnglish()
		SendText "&"
	else
		Send "{Blind}7"
}
!:: {
	if prevCharIsEnglish()
		SendText "!"
	else
		SendText "！"
}
?:: {
	if prevCharIsEnglish()
		SendText "?"
	else
		SendText "？"
}
\:: {
	if prevCharIsEnglish()
		SendText "\"
	else
		SendText "、"
}
|:: {
	if prevCharIsEnglish()
		SendText "|"
	else
		Send "{Blind}\"  ; 此符号触发笔画反查功能，因此必须转给输入法处理
}
@:: {
	if prevCharIsEnglish()
		SendText "@"
	else
		SendText "●"
}
%:: {
	if prevCharIsEnglish()
		SendText "%"
	else
		Send "{Blind}5"
}
^:: {
		Send "{Blind}6"  ; 此符号触发输入扩展符号功能，因此必须转给输入法处理
/*	if prevCharIsEnglish()
		SendText "^"
	else
*/
}
~:: {
	if prevCharIsEnglish()
		SendText "~"
	else
		Send "{Blind}``"
}
$:: {
	Send "{Blind}4"  ; 此符号触发中文大写金额、数字功能，因此必须转给输入法处理
/*	if prevCharIsEnglish()
		SendText "$"
	else
*/
}

!Space:: {
	global
	switch GetPrevChar()
	{
	case ".": Send "{BS}{Text}。" ; 如果是英文句点，则替换为中文句号。
	case "。": Send "{BS}{Text}." ; 如果是中文句号，则替换为英文句点。

	case ",": Send "{BS}{Text}，"
	case "，": Send "{BS}{Text},"

	case "(": Send "{BS}{Text}（"
	case "（": Send "{BS}{Text}("

	case ")": Send "{BS}{Text}）"
	case "）": Send "{BS}{Text})"

	case "_": Send "{BS}{Text}——"
	case "—": Send "{BS 2}{Text}_"

	case ":": Send "{BS}{Text}："
	case "：": Send "{BS}{Text}:"

	case '"':
		if CHSDoubleQuoteWanted {
			Send "{BS}{Text}”"
			CHSDoubleQuoteWanted := false
		}
		else {
			Send "{BS}{Text}“"
			CHSDoubleQuoteWanted := true
		}
		; if CaretGetPos(&x, &y) {
		; 	ToolTip "Cn左双引号", x, y + 20
		; 	SetTimer () => ToolTip(), -2000
		; }
	case "“":
		Send "{BS}{Text}”"
		CHSDoubleQuoteWanted := false
	case "”": Send '{BS}{Text}"'

	case "/": Send "{BS}{Text}÷"
	case "÷": Send "{BS}{Text}/"

	case "=": Send "{BS}="
	; case "≈": Send "{BS}{Text}≃"
	; case "≃": Send "{BS}{Text}≅"
	; case "≅": Send "{BS}{Text}="

	case "<": Send "{BS}{Text}《"
	case "《": Send "{BS}{Text}<"

	case ">": Send "{BS}{Text}》"
	case "》": Send "{BS}{Text}>"

	case ";": Send "{BS}{Text}；"
	case "；": Send "{BS}{Text};"

	case "{": Send "{BS}{Text}「"
	case "「": Send "{BS}{Text}{"

	case "}": Send "{BS}{Text}」"
	case "」": Send "{BS}{Text}}"

	case "'":
		if CHSSingleQuoteWanted {
			Send "{BS}{Text}’"
			CHSSingleQuoteWanted := false
		}
		else {
			Send "{BS}{Text}‘"
			CHSSingleQuoteWanted := true
		}
	case "‘":
		Send "{BS}{Text}’"
		CHSSingleQuoteWanted := false
	case "’": Send "{BS}{Text}'"

	case "*": Send "{BS}{Text}×"
	case "×": Send "{BS}{Text}*"

	case "#": Send "{BS}{Text}◆"
	case "◆": Send "{BS}{Text}#"

	case "[": Send "{BS}{Text}【"
	case "【": Send "{BS}{Text}["

	case "]": Send "{BS}{Text}】"
	case "】": Send "{BS}{Text}]"

	case "&": Send "{BS}{Text}※"
	case "※": Send "{BS}{Text}&"

	case "!": Send "{BS}{Text}！"
	case "！": Send "{BS}{Text}!"

	case "?": Send "{BS}{Text}？"
	case "？": Send "{BS}{Text}?"

	case "\": Send "{BS}{Text}、"
	case "、": Send "{BS}{Text}\"

	case "|": Send "{BS}{Text}｜"
	case "｜": Send "{BS}{Text}|"

	case "@": Send "{BS}{Text}●"
	case "●": Send "{BS}{Text}@"

	case "%": Send "{BS}%"
	case "★": Send "{BS}%"
	case "°": Send "{BS}%"
	case "‰": Send "{BS}%"
	case "☆": Send "{BS}%"
	case "‱": Send "{BS}%"

	case "^": Send "{BS}^"
	case "…": Send "{BS 2}^"
	case "⌘": Send "{BS}^"
	case "⌥": Send "{BS 2}^"

	case "~": Send "{BS}~"
	case "‐": Send "{BS}~"
	case "一": Send "{BS}~"
	case "～": Send "{BS}~"

	case "$": Send "{BS}$"
	case "￥": Send "{BS}$"
	case "＄": Send "{BS}$"
	case "€": Send "{BS}$"
	case "£": Send "{BS}$"
	case "¥": Send "{BS}$"
	case "¢": Send "{BS}$"
	case "¤": Send "{BS}$"
	case "₩": Send "{BS}$"
	}
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

	case '"':
		Send "{BS}{Text}“"
		; if CaretGetPos(&x, &y) {
		; 	ToolTip "Cn左双引号", x, y + 20
		; 	SetTimer () => ToolTip(), -2000
		; }
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

; 如果不存在输入法候选窗口，并且当前活动窗口是Excel，则……
#HotIf not WinExist("ahk_class ^ATL:") and WinActive("ahk_class ^XLMAIN$")
=:: SendText "="
