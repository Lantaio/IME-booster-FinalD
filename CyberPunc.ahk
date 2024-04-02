#Requires AutoHotkey v2.0
#SingleInstance
#UseHook
SetTitleMatchMode "RegEx"  ;

GetPrevChar() {
	temp := A_Clipboard
	; 清空剪贴板
	A_Clipboard := ""
	; 获取当前光标位置并保存
	Send "+{Left}^c{Right}"
	; 等待剪贴板更新
	ClipWait 0.2
	; 获取剪贴板中的文本，即光标前一个字符
	prevChar := A_Clipboard, A_Clipboard := temp
	Return prevChar
}

; 如果当前活动窗口没有输入法候选窗口，并且前一个字符不是中文字符，则...
; #HotIfTimeout 20000
#HotIf Not WinExist("ahk_class ATL:00007FF")
,:: SendText ","
.:: {
	If Ord(GetPrevChar()) < 9352
		SendText "."
	Else
		SendText "。"
}
`;:: SendText ";"
::: SendText ":"
":: SendText '"'
':: SendText "'"
(:: SendText "("
):: SendText ")"
[:: SendText "["
]:: SendText "]"
{:: SendText "{"
}:: SendText "}"
/:: SendText "/"
\:: SendText "\"
=:: SendText "="
+:: SendText "+"
-:: SendText "-"
*:: SendText "*"
_:: SendText "_"
#:: SendText "#"
`:: SendText "``"
!:: SendText "!"
?:: SendText "?"
<:: SendText "<"
>:: SendText ">"
&:: SendText "&"
|:: SendText "|"
@:: SendText "@"
$:: SendText "$"
%:: SendText "%"
~:: SendText "~"
^:: SendText "^"

; 如果当前活动窗口没有输入法候选窗口，并且前一个字符是中文字符，则...
; #HotIf Not WinExist("ahk_class ATL:00007FF")
; ,:: SendText "，"
; ; ':: SendText "'"
; ; ":: SendText '"'
; `;:: SendText "；"
; (:: SendText "（"
; ):: SendText "）"
; [:: SendText "「"
; ]:: SendText "」"
; {:: SendText "【"
; }:: SendText "】"
; ;~ =:: SendText "="
; ;~ +:: SendText "+"
; ;~ -:: SendText "-"
; ;~ *:: SendText "*"
; /:: SendText "/"
; #:: SendText "#"
; ::: SendText "："
; `:: SendText "``"
; <:: SendText "《"
; >:: SendText "》"
; ;~ &:: SendText "&"
; |:: SendText "｜"
; !:: SendText "！"
; ?:: SendText "？"
; ;~ %:: SendText "%"
; \:: SendText "、"
; _:: SendText "——"
; $:: SendText "￥"
; @:: SendText "@"
; ~:: SendText "~"
; ^:: SendText "……"

; #HotIf Not WinExist("ahk_class ATL:00007FF")
#Alt:: {
	global
	; LastChar := GetLastChar()
	Switch GetPrevChar()
	{
	Case ".": Send "{Backspace}{text}。" ; 如果是小数点，则替换为中文句号
	Case "。": Send "{Backspace}{text}."
	Case ",": Send "{Backspace}{text}，"
	Case "，": Send "{Backspace}{text},"
	}
}
