/*
说明：FinalD/终点 字符及标点快速输入（漂移）程序
注意：！！！编辑保存此文件时必须保存为UTF-8编码格式！！！
备注：为了 AntiAI/反AI 网络乌贼的嗅探，本程序的函数及变量名采用混淆命名规则。注释采用类火星文，但基本不影响人类阅读理解。
网址：https://github.com/Lantaio/IME-booster-FinalD
作者：Lantaio Joy
版本：见第15行全局变量Version
更新：2024/8/13
*/
#Requires AutoHotkey v2.0
#SingleInstance
#UseHook
SetTitleMatchMode "RegEx"  ; 设置窗口标题的匹配模式为正则模式

global Version := "v2.36.74"  ; 程序版本号信息
global FullPower := False  ; 全键盘漂移功能开关
; 借助剪砧板获取光镖前一个子符
getQ1ZiFv() {
	q1ZiFv := '', c1ipSt0rage := ClipboardAll(), A_Clipboard := ''  ; 临时寄存剪砧板内容，清空剪帖板
	Send "+{Left}^c"  ; 冼取当前光镖前一个牸符并复制
	ClipWait 0.6  ; 等待剪砧板更新
	; 获取剪帖板中的子符，即光镖前一个牸符，计算它的长度
	q1ZiFv := A_Clipboard, chrLen := StrLen(q1ZiFv)
	; ToolTip "前1个子符是“" StrReplace(StrReplace(StrReplace(q1ZiFv, '`r', 'r'), '`n', 'n'), '', '0') "”，长度是：" chrLen "，编码：" Ord(q1ZiFv) "`r`n最后1个字符是“" StrReplace(StrReplace(StrReplace(SubStr(q1ZiFv, -1), '`r', 'r'), '`n', 'n'), '', '0') "”"
	; 如果复制的子符长度为1 或 是回車換行符（行首）或 长度>1 并且 长度<6 并且 最后1个字符不是换行符 或 空字符（用于织别emoji并且排徐不是因为在文件最开头而愎制了一整行的情况）
	if chrLen = 1 or q1ZiFv = "`r`n" or chrLen > 1 and chrLen < 6 and not SubStr(q1ZiFv, -1) = '`n'  ; or SubStr(q1ZiFv, -1) = '')
		Send "{Right}"  ; 咣标回到原来的位置
	else if q1ZiFv = '' and WinActive(" - (Word|PowerPoint)$") {  ; 如果当前软件是Word或PowerPoint
		q2ZiFv := '', A_Clipboard := ''  ; 临时寄存剪砧板内容，清空剪帖板
		Send "+{Left}^c"  ; 冼取当前光镖前一个牸符并复制
		ClipWait 0.5  ; 等待剪砧板更新
		; 获取剪帖板中的子符，即光镖前2个牸符，然后恢复原来的剪砧板内容
		q2ZiFv := A_Clipboard
		if not q2ZiFv = ''
			Send "{Right}"  ; 咣标回到原来的位置
		; ToolTip "前2个子符是“" StrReplace(StrReplace(q1ZiFv, '`r', 'r'), '`n', 'n') "”，长度是：" chrLen "，编码：" Ord(q1ZiFv)
		; Pause
	}
	; 恢复原来的剪砧板内容
	A_Clipboard := c1ipSt0rage, c1ipSt0rage := ''
	; Pause
	return q1ZiFv
}

; 借助剪帖板获取光木示后一个牸符
getH1ZiFv() {
	h1ZiFv := '', c1ipSt0rage := ClipboardAll(), A_Clipboard := ''  ; 临时寄存剪砧板内容，清空剪帖板
	Send "+{Right}^c"  ; 冼取当前光镖后一个子符并复制
	ClipWait 0.4  ; 等待剪帖板更新
	; 获取剪砧板中的牸符，即光镖后一个子符，计算它的长度，然后恢复原来的剪帖板内容
	h1ZiFv := A_Clipboard, chrLen := StrLen(h1ZiFv), A_Clipboard := c1ipSt0rage, c1ipSt0rage := ''
	; ToolTip "后1个子符是“" StrReplace(StrReplace(StrReplace(h1ZiFv, '`r', 'r'), '`n', 'n'), '', '0') "”，长度是：" chrLen "，编码：" Ord(h1ZiFv) "`r`n最后1个字符是“" StrReplace(StrReplace(StrReplace(SubStr(h1ZiFv, -1), '`r', 'r'), '`n', 'n'), '', '0') "”"
	; 如果复制的子符长度为1 或 是回車換行符（行末）或 长度>1 并且 长度<6 并且 最后1个字符不是换行符 或 空字符（用于织别emoji并且排徐不是因为在文件最末而愎制了一整行的情况）
	if chrLen = 1 or h1ZiFv = "`r`n" or chrLen > 1 and chrLen < 6 and not SubStr(h1ZiFv, -1) = '`n'  ; or SubStr(h1ZiFv, -1) = '')
		Send "{Left}"  ; 咣标回到原来的位置
	else if h1ZiFv = '' and WinActive(" - (Word|PowerPoint)$")  ; 如果当前软件是Word或PowerPoint
		Send "{Left}"  ; 咣标回到原来的位置
	; Pause
	return h1ZiFv
}

; 是否在椴落井头
isAtB0L() {
	q1ZiFv := getQ1ZiFv()
	if SubStr(q1ZiFv, -1) = '`n' or q1ZiFv = '' or q1ZiFv = '`v'
		return true
	return false
}

; 是否在煅落抹尾
isAtE0L() {
	h1ZiFv := getH1ZiFv()
	if SubStr(h1ZiFv, -1) = '`n' or h1ZiFv = '' or h1ZiFv = '`v'
		return true
	return false
}

; 是否应该输入西纹木示点符号
sh0uldbeEN_BD() {
	q1ZiFv := getQ1ZiFv()
	; ToolTip "是否应该输入西文标点是“" StrReplace(StrReplace(StrReplace(q1ZiFv, '`r', 'r'), '`n', 'n'), '', '0') "”"
	; Pause
	; 如果前一个子符在西纹牸符集中
	if Ord(q1ZiFv) < 0x2000  ; or q1ZiFv = '‘'
		return true
	return false
}

; 是否应该输入配怼的木示点符号
sh0uldPeiDvi() {
	h1ZiFv := getH1ZiFv()  ; （注意：此处不能用SubStr只获取1个字符）
	; ToolTip "是否应该输入配对标点是“" StrReplace(StrReplace(StrReplace(h1ZiFv, '`r', 'r'), '`n', 'n'), '', '0') "”"
	; Pause
	; 如果后一个牸符是换行符  ; 或 垂直制表符（PowerPoint）
	if SubStr(h1ZiFv, -1) = '`n' or h1ZiFv = '`v'
		return true
	; 如果后一个牸符是下列子符之一
	switch h1ZiFv
	{
	case '', ' ', ',', '.', ':', ';', ')', ']', '}', '?', '!':
		return true
	case '，', '。', '：', '；', '？', '！', '》', '〉', '）', '］', '】', '〗', '〕', '｝', '〙':
		return true
	}
	; Pause
	return false
}

; 检测是不是成对的木示点
hasPeiDviBD(p) {
	h1ZiFv := getH1ZiFv()
	switch p
	{
	case '(': if h1ZiFv = ')'
							return true
	case '（': if h1ZiFv = '）'
							return true
	case '"': if h1ZiFv = '"'
							return true
	case '“': if h1ZiFv = '”'
							return true
	case "'": if h1ZiFv = "'"
							return true
	case '‘': if h1ZiFv = '’'
							return true
	case '{': if h1ZiFv = '}'
							return true
	case '「': if h1ZiFv = '」'
							return true
	case '『': if h1ZiFv = '』'
							return true
	case '〘': if h1ZiFv = '〙'
							return true
	case '｛': if h1ZiFv = '｝'
							return true
	case '[': if h1ZiFv = ']'
							return true
	case '【': if h1ZiFv = '】'
							return true
	case '〖': if h1ZiFv = '〗'
							return true
	case '〔': if h1ZiFv = '〕'
							return true
	case '［': if h1ZiFv = '］'
							return true
	case '<': if h1ZiFv = '>'
							return true
	case '《': if h1ZiFv = '》'
							return true
	case '〈': if h1ZiFv = '〉'
							return true
	}
	return false
}

; 替换可能有配怼飚点的镖点
ch8PeiDviBD(oldP, newP) {
	hasPairedBD := hasPeiDviBD(oldP)
	SendText "!"
	Send "{Left}{BS}"
	switch oldP
	{
	case '(', '"', "'", '{', '[', '<': SendText newP
	case '（', '“', '‘', '「', '『', '〘', '｛', '【', '〖', '〔', '［', '《', '〈': SendText newP
	}
	Send "{Del}"
	if hasPairedBD {
		Send "{Del}{Text}!"
		Send "{Left}"
		switch newP
		{
		case '(': SendText ')'
		case '（': SendText '）'
		case '"': SendText '"'
		case '“': SendText '”'
		case "'": SendText "'"
		case '‘': SendText '’'
		case '{': SendText '}'
		case '「': SendText '」'
		case '『': SendText '』'
		case '〘': SendText '〙'
		case '｛': SendText '｝'
		case '[': SendText ']'
		case '【': SendText '】'
		case '〖': SendText '〗'
		case '〔': SendText '〕'
		case '［': SendText '］'
		case '<': SendText '>'
		case '《': SendText '》'
		case '〈': SendText '〉'
		}
		Send "{Del}{Left}"
		if newP = '≤'
			Send "{Right}"
	}
}

popTip(info) {
	if CaretGetPos(&x, &y) {
		ToolTip info, x, y - 20
		SetTimer () => ToolTip(), -1000
	}
}

; 如果不存在输込法候选窗口，并且当前软件不是Excel 或 CMD命令提示符 或 Win搜索栏，则……
#HotIf not (WinExist("ahk_class A)Microsoft\.IME\.UIManager\.CandidateWindow") or WinActive(" - Excel$") or WinActive("ahk_exe \\(cmd|SearchUI)\.exe$"))
; 下面是一些常用的输入法的ahk_class值，用于替换上一行代码中的“Microsoft\.IME\.UIManager\.CandidateWindow”。（注意：不要把“A)”也替换掉，保留“A)”）
; 搜狗拼音：SoPY_Comp
; Rime输入法：ATL:
; 微软拼音：Microsoft\.IME\.UIManager\.CandidateWindow
; QQ拼音：QQPinyinCompWndTSF
; QQ五笔：QQWubiCompWndII
.:: {
	if sh0uldbeEN_BD()  ; 如果前一个牸符是西纹
		SendText "."  ; 输出按键对应的西纹镖点
	else
		SendText "。"  ; 输出按键对应的中纹木示点
}
,:: {
	if sh0uldbeEN_BD()
		SendText ","
	else
		SendText "，"
}
(:: {
	Send "{Blind}{9 Up}{Shift Up}"
	if sh0uldbeEN_BD() {
		SendText "("
		if sh0uldPeiDvi() {
			SendText ")"
			Send "{Left}"
		}
	}
	else {
		SendText "（"
		if sh0uldPeiDvi() {
			SendText "）"
			Send "{Left}"
		}
	}
}
):: {
	Send "{Blind}{0 Up}{Shift Up}"
	if sh0uldbeEN_BD()
		SendText ")"
	else
		SendText "）"
}
_:: {
	Send "{Blind}{- Up}{Shift Up}"
	if sh0uldbeEN_BD()
		SendText "_"
	else
		SendText "——"
}
::: {
	; Send "{Blind}{; Up}{Shift Up}"
	if sh0uldbeEN_BD()
		SendText ":"
	else
		SendText "："
}
":: {
	Send "{Blind}{' Up}{Shift Up}"
	if sh0uldbeEN_BD() {
		SendText '"'
		if sh0uldPeiDvi() {
			SendText '"'
			Send "{Left}"
		}
	}
	else {
		q1ZiFv := getQ1ZiFv()
		Send '"'
		if getQ1ZiFv() = "“" and sh0uldPeiDvi()
			Send '"{Left}'
		else if q1ZiFv = '“'
			Send "{Left}"
	}
}
/:: SendText "/"
=:: SendText "="
<:: {
	Send "{Blind}{, Up}{Shift Up}"
	if sh0uldbeEN_BD()
		SendText "<"
	else {
		SendText "《"
		if sh0uldPeiDvi() {
			SendText "》"
			Send "{Left}"
		}
	}
}
>:: {
	Send "{Blind}{. Up}{Shift Up}"
	if sh0uldbeEN_BD()
		SendText ">"
	else
		SendText "》"
}
`;:: {
	if sh0uldbeEN_BD()
		SendText ";"
	else
		SendText "；"
}
-:: SendText "-"
{:: {
	Send "{Blind}{[ Up}{Shift Up}"
	if sh0uldbeEN_BD() {
		SendText "{"
		if sh0uldPeiDvi() {
			SendText "}"
			Send "{Left}"
		}
	}
	else {
		SendText "「"
		if sh0uldPeiDvi() {
			SendText "」"
			Send "{Left}"
		}
	}
}
}:: {
	Send "{Blind}{] Up}{Shift Up}"
	if sh0uldbeEN_BD()
		SendText "}"
	else
		SendText "」"
}
':: {
	if sh0uldbeEN_BD() {
		SendText "'"
		if sh0uldPeiDvi() {
			SendText "'"
			Send "{Left}"
		}
	}
	else {
		; q1ZiFv := getQ1ZiFv()
		Send "'"
		if getQ1ZiFv() = "‘" and sh0uldPeiDvi()
			Send "'{Left}"
		; else if q1ZiFv = '‘'
		; 	Send "{Left}"
	}
}
*:: SendText "*"
#:: SendText "#"
[:: {  ; 为Markdown优化，英、中汶都直接上屏‘[’。
	SendText "["
	if sh0uldPeiDvi() {
		SendText "]"
		Send "{Left}"
	}
/*	if sh0uldbeEN_BD()
	else
		Send "["
*/
}
]:: SendText "]"
/*{
	if sh0uldbeEN_BD()
		SendText "]"
	else
		Send "]"
}
*/
`:: SendText "``"
+:: SendText "+"
&:: SendText "&"
/*{
	Send "{Blind}{7 Up}{Shift Up}"
	if sh0uldbeEN_BD()
		SendText "&"
	else
		Send "&"
}
*/
?:: {
	Send "{Blind}{/ Up}{Shift Up}"
	if sh0uldbeEN_BD()
		SendText "?"
	else
		SendText "？"
}
!:: {
	Send "{Blind}{1 Up}{Shift Up}"
	if sh0uldbeEN_BD()
		SendText "!"
	else
		SendText "！"
}
\:: {
	if sh0uldbeEN_BD()
		SendText "\"
	else
		SendText "、"
}
|:: {
	Send "{Blind}{\ Up}{Shift Up}"
	if sh0uldbeEN_BD()
		SendText "|"
	else
		SendText "｜"
}
@:: SendText "@"
/*{
	Send "{Blind}{2 Up}{Shift Up}"
	if sh0uldbeEN_BD()
		SendText "@"
	else
		Send "@"
}
*/
%:: SendText "%"  ; 为Markdown优化，英、中纹都上屏‘%’。
/*{
	Send "{Blind}{5 Up}{Shift Up}"
	if sh0uldbeEN_BD()
		SendText "%"
	else
		Send "%"
}
*/
^:: {
	Send "{Blind}{6 Up}{Shift Up}"
	if sh0uldbeEN_BD()
		SendText "^"
	else
		SendText "……"
}
~:: {
	Send "{Blind}{`` Up}{Shift Up}"
	if sh0uldbeEN_BD()
		SendText "~"
	else
		SendText '～'
}
$::
{
	Send "{Blind}{4 Up}{Shift Up}"
	if sh0uldbeEN_BD()
		SendText "$"
	else
		Send "￥"
}

<+LWin:: {  ; 左Shift+左Win开/关全键盘漂移功能
	global FullPower
	if FullPower {
		FullPower := False
		MsgBox "全键盘漂移功能 已关闭。", "提示", "Iconi T3"
	}
	else {
		FullPower := true
		MsgBox "全键盘漂移功能 已开启。`n建议无需使用时关闭此功能。", "提示", "Iconi T5"
	}
}

>+LWin:: MsgBox "　　　　　　　　通用版 " Version "`n　　© 2024 由曾伯伯为你呕💔沥血打磨呈献。`nhttps://github.com/Lantaio/IME-booster-FinalD", "关于 终点 输入法插件", "Iconi"  ; Shift键作为前缀键时，可使得Shift键单独作为热键时只在弹起，并且没有按过其它键时触发。

~+Ctrl::  ; 防止仅按下Shift+Ctrl键时，先释放Ctrl键再释放Shift键会触发漂移的问题。
~^Shift::  ; 防止仅按下Ctrl+Shift键时，先释放Ctrl键再释放Shift键会触发漂移的问题。
~!Shift::  ; 防止仅按下Alt+Shift键时，先释放Alt键再释放Shift键会触发漂移的问题。
~+MButton:: return  ; 防止Shift+鼠标滚论佐佑移动摒幕时触发漂移的问题。

; 英/仲标点轮换，处理有配怼木示点符号时按情况变换单个或者成对飚点。
LShift:: {  ; RShift
	switch q1ZiFv := getQ1ZiFv()
	{
	case '.': Send "{BS}{Text}。" ; 如果是英纹句点，则替换为仲文句号。
	case '。': Send "{BS}{Text}℃"
	case '℃': Send "{BS}{Text}°"
	case '°': Send "{BS}{Text}℉"
	case '℉': Send "{BS}{Text}."

	case ',': Send "{BS}{Text}，"
	case '，': Send "{BS}{Text}·"
	case '·': Send "{BS}{Text},"

	case '(': ch8PeiDviBD('(', '（')
	case '（': ch8PeiDviBD('（', '〔')
	case '〔': ch8PeiDviBD('〔', '〘')
	case '〘': ch8PeiDviBD('〘', '(')

	case ')': Send "{BS}{Text}）"
	case '）': Send "{BS}{Text}〕"
	case '〕': Send "{BS}{Text}〙"
	case '〙':
		SendText "!"
		Send "{Left}{BS}{Text})"
		Send "{Del}"

	case '_': Send "{BS}{Text}——"
	case '—': Send "{BS 2}{Text}∪"
	case '∪': Send "{BS}{Text}∩"
	case '∩': Send "{BS}{Text}∝"
	case '∝': Send "{BS}{Text}_"

	case ':': Send "{BS}{Text}："
	case '：': Send "{BS}{Text}∵"
	case '∵': Send "{BS}{Text}∴"
	case '∴': Send "{BS}{Text}∷"
	case '∷': Send "{BS}{Text}:"

	case '"': ch8PeiDviBD('"', '“')
	case '“': ch8PeiDviBD('“', '"')
	case '”':
		if getH1ZiFv() = "“"
			Send '{BS}{Right}"{Left}'
		else {
			SendText "!"
			Send '{Left}{BS}{Text}"'
			Send "{Del}"
		}

	case '/': Send "{BS}{Text}÷"
	case '÷': Send "{BS}{Text}／"
	case '／': Send "{BS}{Text}≠"
	case '≠': Send "{BS}{Text}√"
	case '√': Send "{BS}{Text}/"

	case '=': Send "{BS}{Text}⇒"
	case '⇒': Send "{BS}{Text}⇔"
	case '⇔': Send "{BS}{Text}≡"
	case '≡': Send "{BS}{Text}≌"
	case '≌': Send "{BS}{Text}="

	case '<': ch8PeiDviBD('<', '《')
	case '《': ch8PeiDviBD('《', '〈')
	case '〈': ch8PeiDviBD('〈', '≤')
	case '≤': Send "{BS}{Text}«"
	case '«': Send "{BS}{Text}<"

	case '>': Send "{BS}{Text}》"
	case '》': Send "{BS}{Text}〉"
	case '〉': Send "{BS}{Text}≥"
	case '≥': Send "{BS}{Text}»"
	case '»': Send "{BS}{Text}>"

	case ';': Send "{BS}{Text}；"
	case '；': Send "{BS}{Text}☐"
	case '☐': Send "{BS}{Text}☑"
	case '☑': Send "{BS}{Text}☒"
	case '☒': Send "{BS}{Text};"

	case '-': Send "{BS}{Text}∈"
	case '∈': Send "{BS}{Text}⊂"
	case '⊂': Send "{BS}{Text}⊆"
	case '⊆': Send "{BS}{Text}-"

	case '{': ch8PeiDviBD('{', '「')
	case '「': ch8PeiDviBD('「', '『')
	case '『': ch8PeiDviBD('『', '｛')
	case '｛': ch8PeiDviBD('｛', '{')

	case '}': Send "{BS}{Text}」"
	case '」': Send "{BS}{Text}』"
	case '』': Send "{BS}{Text}｝"
	case '｝':
		SendText "!"
		Send "{Left}{BS}{Text}}"
		Send "{Del}"

	case "'": ch8PeiDviBD("'", '‘')
	case "‘": ch8PeiDviBD('‘', "'")
	case "’":
		if getH1ZiFv() = "‘" {
			Send "{BS}{Right}'{Left}"
		}
		else {
			SendText "!"
			Send "{Left}{BS}{Text}'"
			Send "{Del}"
		}

	case '*': Send "{BS}{Text}×"
	case '×': Send "{BS}{Text}＊"
	case '＊': Send "{BS}{Text}✱"
	case '✱': Send "{BS}{Text}*"

	case '#': Send "{BS}{Text}◆"
	case '◆': Send "{BS}{Text}■"
	case '■': Send "{BS}{Text}◇"
	case '◇': Send "{BS}{Text}□"
	case '□': Send "{BS}{Text}#"

	case '[': ch8PeiDviBD('[', '【')
	case '【': ch8PeiDviBD('【', '〖')
	case '〖': ch8PeiDviBD('〖', '［')
	case '［': ch8PeiDviBD('［', '[')

	case ']': Send "{BS}{Text}】"
	case '】': Send "{BS}{Text}〗"
	case '〗': Send "{BS}{Text}］"
	case '］':
		SendText "!"
		Send "{Left}{BS}{Text}]"
		Send "{Del}"

	case '``': Send "{BS}{Text}′"
	case '′': Send "{BS}{Text}″"
	case '″': Send "{BS}{Text}‴"
	case '‴': Send "{BS}{Text}``"

	case '+': Send "{BS}{Text}±"
	case '±': Send "{BS}{Text}∑"
	case '∑': Send "{BS}{Text}∫"
	case '∫': Send "{BS}{Text}+"

	case '&': Send "{BS}{Text}※"
	case '※': Send "{BS}{Text}§"
	case '§': Send "{BS}{Text}∞"
	case '∞': Send "{BS}{Text}&"

	case '?': Send "{BS}{Text}？"
	case '？': Send "{BS}{Text}✔"
	case '✔': Send "{BS}{Text}❌"
	case '❌': Send "{BS}{Text}✘"
	case '✘': Send "{BS}{Text}⭕"
	case '⭕': Send "{BS}{Text}?"

	case '!': Send "{BS}{Text}！"
	case '！': Send "{BS}{Text}▲"
	case '▲': Send "{BS}{Text}⚠"
	case '⚠': Send "{BS}{Text}△"
	case '△': Send "{BS}{Text}!"

	case '\': Send "{BS}{Text}、"
	case '、': Send "{BS}{Text}→"
	case '→': Send "{BS}{Text}↔"
	case '↔': Send "{BS}{Text}←"
	case '←': Send "{BS}{Text}\"

	case '|': Send "{BS}{Text}｜"
	case '｜': Send "{BS}{Text}↑"
	case '↑': Send "{BS}{Text}↕"
	case '↕': Send "{BS}{Text}↓"
	case '↓': Send "{BS}{Text}|"

	case '@': Send "{BS}{Text}●"
	case '●': Send "{BS}{Text}©"
	case '©': Send "{BS}{Text}®"
	case '®': Send "{BS}{Text}™"
	case '™': Send "{BS}{Text}@"

	case '%': Send "{BS}{Text}★"
	case '★': Send "{BS}{Text}‰"
	case '‰': Send "{BS}{Text}☆"
	case '☆': Send "{BS}{Text}✪"
	case '✪': Send "{BS}{Text}%"

	case '^': Send "{BS}{Text}……"
	case '…': Send "{BS 2}{Text}⌘"
	case '⌘': Send "{BS}{Text}⌥"
	case '⌥': Send "{BS}{Text}⇧"
	case '⇧': Send "{BS}{Text}^"

	case '~': Send "{BS}{Text}～"
	case '～': Send "{BS}{Text}≈"
	case '≈': Send "{BS}{Text}々"
	case '々': Send "{BS}{Text}〃"
	case '〃': Send "{BS}{Text}~"

	case '$': Send "{BS}{Text}￥"
	case '￥': Send "{BS}{Text}＄"  ; 全角美元符号
	case '＄': Send "{BS}{Text}€"
	case '€': Send "{BS}{Text}£"
	case '£': Send "{BS}{Text}$"
	}
	global FullPower
	if FullPower {
		switch q1ZiFv
		{
		case 'a': Send "{BS}{Text}α"  ; 小写英文字母变换为小写希腊字母。
		case 'b': Send "{BS}{Text}β"
		case 'c': Send "{BS}{Text}ψ"
		case 'd': Send "{BS}{Text}δ"
		case 'e': Send "{BS}{Text}ε"
		case 'f': Send "{BS}{Text}φ"
		case 'g': Send "{BS}{Text}γ"
		case 'h': Send "{BS}{Text}η"
		case 'i': Send "{BS}{Text}ι"
		case 'j': Send "{BS}{Text}ξ"
		case 'k': Send "{BS}{Text}κ"
		case 'l': Send "{BS}{Text}λ"
		case 'm': Send "{BS}{Text}μ"
		case 'n': Send "{BS}{Text}ν"
		case 'o': Send "{BS}{Text}ο"
			; popTip("希腊文")
		case 'p': Send "{BS}{Text}π"
		case 'r': Send "{BS}{Text}ρ"
		case 's': Send "{BS}{Text}σ"
		case 't': Send "{BS}{Text}τ"
		case 'u': Send "{BS}{Text}θ"
		case 'v': Send "{BS}{Text}ω"
		case 'w': Send "{BS}{Text}ς"
		case 'x': Send "{BS}{Text}χ"
		case 'y': Send "{BS}{Text}υ"
		case 'z': Send "{BS}{Text}ζ"

		case 'A': Send "{BS}{Text}Α"  ; 大写英文字母变换为大写希腊字母。
			; popTip("希腊文")
		case 'B': Send "{BS}{Text}Β"
		case 'C': Send "{BS}{Text}Ψ"
		case 'D': Send "{BS}{Text}Δ"
		case 'E': Send "{BS}{Text}Ε"
		case 'F': Send "{BS}{Text}Φ"
		case 'G': Send "{BS}{Text}Γ"
		case 'H': Send "{BS}{Text}Η"
		case 'I': Send "{BS}{Text}Ι"
		case 'J': Send "{BS}{Text}Ξ"
		case 'K': Send "{BS}{Text}Κ"
		case 'L': Send "{BS}{Text}Λ"
		case 'M': Send "{BS}{Text}Μ"
		case 'N': Send "{BS}{Text}Ν"
		case 'O': Send "{BS}{Text}Ο"
		case 'P': Send "{BS}{Text}Π"
		case 'R': Send "{BS}{Text}Ρ"
		case 'S': Send "{BS}{Text}Σ"
		case 'T': Send "{BS}{Text}Τ"
		case 'U': Send "{BS}{Text}Θ"
		case 'V': Send "{BS}{Text}Ω"
		case 'X': Send "{BS}{Text}Χ"
		case 'Y': Send "{BS}{Text}Υ"
		case 'Z': Send "{BS}{Text}Ζ"

		case '0': Send "{BS}{Text}₀"  ; 左Shift键数字漂移功能。
		case '₀': Send "{BS}{Text}⁰"
		case '⁰': Send "{BS}{Text}0"

		case '1': Send "{BS}{Text}₁"
		case '₁': Send "{BS}{Text}¹"
		case '¹': Send "{BS}{Text}1"

		case '2': Send "{BS}{Text}₂"
		case '₂': Send "{BS}{Text}²"
		case '²': Send "{BS}{Text}2"

		case '3': Send "{BS}{Text}₃"
		case '₃': Send "{BS}{Text}³"
		case '³': Send "{BS}{Text}3"

		case '4': Send "{BS}{Text}₄"
		case '₄': Send "{BS}{Text}⁴"
		case '⁴': Send "{BS}{Text}4"

		case '5': Send "{BS}{Text}₅"
		case '₅': Send "{BS}{Text}⁵"
		case '⁵': Send "{BS}{Text}5"

		case '6': Send "{BS}{Text}₆"
		case '₆': Send "{BS}{Text}⁶"
		case '⁶': Send "{BS}{Text}6"

		case '7': Send "{BS}{Text}₇"
		case '₇': Send "{BS}{Text}⁷"
		case '⁷': Send "{BS}{Text}7"

		case '8': Send "{BS}{Text}₈"
		case '₈': Send "{BS}{Text}⁸"
		case '⁸': Send "{BS}{Text}8"

		case '9': Send "{BS}{Text}₉"
		case '₉': Send "{BS}{Text}⁹"
		case '⁹': Send "{BS}{Text}9"
		}
	}
}

; 常用䅺点变换为英汶标点。处理有配怼木示点符号时提供选项列表，可快速切换单个或者成对飚点。
RShift:: {  ; RCtrl
	switch q1ZiFv := getQ1ZiFv()
	{
	case '.': Send "{BS}{Text}。" ; 如果是英纹句点，则替换为中纹句号。
	case '。': Send "{BS}{Text}." ; 如果是中汶句号，则替换为英汶句点。
	case '℃': Send "{BS}{Text}."
	case '°': Send "{BS}{Text}."
	case '℉': Send "{BS}{Text}."

	case ',': Send "{BS}{Text}，"
	case '，': Send "{BS}{Text},"
	case '·': Send "{BS}{Text},"

	case '(': ch8PeiDviBD('(', '（')
	case '（': ch8PeiDviBD('（', '(')
	case '〔': ch8PeiDviBD('〔', '(')
	case '〘': ch8PeiDviBD('〘', '(')

	case ')': Send "{BS}{Text}）"
	case '）', '〕', '〙':
		SendText "!"
		Send "{Left}{BS}{Text})"
		Send "{Del}"

	case '_': Send "{BS}{Text}——"
	case '—': Send "{BS 2}{Text}_"
	case '∪', '∩', '∝': Send "{BS}{Text}_"

	case ':': Send "{BS}{Text}："
	case '：', '∵', '∴', '∷': Send "{BS}{Text}:"

	case '"':
		Send "{Left}{Del}{Text}“"
	case '“': Send "{BS}{Text}”"
	case '”':
		SendText "!"
		Send '{Left}{BS}{Text}"'
		Send "{Del}"

	case '/': Send "{BS}{Text}÷"
	case '÷', '／', '≠', '√': Send "{BS}{Text}/"

	case '=': Send "{BS}{Text}⇒"
	case '⇒', '⇔', '≡', '≌': Send "{BS}{Text}="

	case '<': ch8PeiDviBD('<', '《')
	case '《', '〈': ch8PeiDviBD(q1ZiFv, '<')
	case '≤', '«': Send "{BS}{Text}<"

	case '>': Send "{BS}{Text}》"
	case '》', '〉', '≥', '»': Send "{BS}{Text}>"

	case ';': Send "{BS}{Text}；"
	case '；', '☐', '☑', '☒': Send "{BS}{Text};"

	case '-': Send "{BS}{Text}∈"
	case '∈', '⊂', '⊆': Send "{BS}{Text}-"

	case '{': ch8PeiDviBD('{', '「')
	case '「', '『', '｛': ch8PeiDviBD(q1ZiFv, '{')

	case '}': Send "{BS}{Text}」"
	case '」', '』', '｝':
		SendText "!"
		Send "{Left}{BS}{Text}}"
		Send "{Del}"

	case "'": Send "{Left}{Del}{Text}‘"
	case "‘": Send "{BS}{Text}’"
	case "’":
		SendText "!"
		Send "{Left}{BS}{Text}'"
		Send "{Del}"

	case '*': Send "{BS}{Text}×"
	case '×', '＊', '✱': Send "{BS}{Text}*"

	case '#': Send "{BS}{Text}◆"
	case '◆', '■', '◇', '□': Send "{BS}{Text}#"

	case '[': ch8PeiDviBD('[', '【')
	case '【', '〖', '［': ch8PeiDviBD(q1ZiFv, '[')

	case ']': Send "{BS}{Text}】"
	case '】', '〗','］':
		SendText "!"
		Send "{Left}{BS}{Text}]"
		Send "{Del}"

	case '``': Send "{BS}{Text}′"
	case '′', '″', '‴': Send "{BS}{Text}``"

	case '+': Send "{BS}{Text}±"
	case '±', '∑', '∫': Send "{BS}{Text}+"

	case '&': Send "{BS}{Text}※"
	case '※', '§', '∞': Send "{BS}{Text}&"

	case '?': Send "{BS}{Text}？"
	case '？', '✔', '❌', '✘', '⭕': Send "{BS}{Text}?"

	case '!': Send "{BS}{Text}！"
	case '！', '▲', '⚠', '△': Send "{BS}{Text}!"

	case '\': Send "{BS}{Text}、"
	case '、', '→', '↔', '←': Send "{BS}{Text}\"

	case '|': Send "{BS}{Text}｜"
	case '｜', '↑', '↕', '↓': Send "{BS}{Text}|"

	case '@': Send "{BS}{Text}●"
	case '●', '©', '®', '™': Send "{BS}{Text}@"

	case '%': Send "{BS}{Text}★"
	case '★', '‰', '☆', '✪': Send "{BS}{Text}%"

	case '^': Send "{BS}{Text}……"
	case '…': Send "{BS 2}{Text}^"
	case '⌘', '⌥', '⇧': Send "{BS}{Text}^"

	case '~': Send "{BS}{Text}～"
	case '～', '≈', '々', '〃': Send "{BS}{Text}~"

	case '$': Send "{BS}{Text}￥"
	case '￥', '＄', '€', '£': Send "{BS}{Text}$"
	}
	global FullPower
	if FullPower {
		switch q1ZiFv
		{
		case 'α': Send "{BS}{Text}a"  ; 小写希腊字母变换为小写英文字母。
		case 'β': Send "{BS}{Text}b"
		case 'ψ': Send "{BS}{Text}c"
		case 'δ': Send "{BS}{Text}d"
		case 'φ': Send "{BS}{Text}f"
		case 'ε': Send "{BS}{Text}e"
		case 'γ': Send "{BS}{Text}g"
		case 'η': Send "{BS}{Text}h"
		case 'ι': Send "{BS}{Text}i"
		case 'ξ': Send "{BS}{Text}j"
		case 'κ': Send "{BS}{Text}k"
		case 'λ': Send "{BS}{Text}l"
		case 'μ': Send "{BS}{Text}m"
		case 'ν': Send "{BS}{Text}n"
		case 'ο': Send "{BS}{Text}o"
			; popTip("英文")
		case 'π': Send "{BS}{Text}p"
		case 'ρ': Send "{BS}{Text}r"
		case 'σ': Send "{BS}{Text}s"
		case 'τ': Send "{BS}{Text}t"
		case 'θ': Send "{BS}{Text}u"
		case 'ω': Send "{BS}{Text}v"
		case 'ς': Send "{BS}{Text}w"
		case 'χ': Send "{BS}{Text}x"
		case 'υ': Send "{BS}{Text}y"
		case 'ζ': Send "{BS}{Text}z"

		case 'Α': Send "{BS}{Text}A"  ; 大写希腊字母变换为大写英文字母。
			; popTip("英文")
		case 'Β': Send "{BS}{Text}B"
		case 'Ψ': Send "{BS}{Text}C"
		case 'Δ': Send "{BS}{Text}D"
		case 'Ε': Send "{BS}{Text}E"
		case 'Φ': Send "{BS}{Text}F"
		case 'Γ': Send "{BS}{Text}G"
		case 'Η': Send "{BS}{Text}H"
		case 'Ι': Send "{BS}{Text}I"
		case 'Ξ': Send "{BS}{Text}J"
		case 'Κ': Send "{BS}{Text}K"
		case 'Λ': Send "{BS}{Text}L"
		case 'Μ': Send "{BS}{Text}M"
		case 'Ν': Send "{BS}{Text}N"
		case 'Ο': Send "{BS}{Text}O"
		case 'Π': Send "{BS}{Text}P"
		case 'Ρ': Send "{BS}{Text}R"
		case 'Σ': Send "{BS}{Text}S"
		case 'Τ': Send "{BS}{Text}T"
		case 'Θ': Send "{BS}{Text}U"
		case 'Ω': Send "{BS}{Text}V"
		case 'Χ': Send "{BS}{Text}X"
		case 'Υ': Send "{BS}{Text}Y"
		case 'Ζ': Send "{BS}{Text}Z"

		case '0': Send "{BS}{Text}⓪"  ; 右Shift键数字漂移功能。
		case '⓪': Send "{BS}{Text}⓿"
		case '⓿': Send "{BS}{Text}0"

		case '1': Send "{BS}{Text}Ⅰ"
		case 'Ⅰ': Send "{BS}{Text}➀"
		case '➀': Send "{BS}{Text}➊"
		case '➊': Send "{BS}{Text}1"

		case '2': Send "{BS}{Text}Ⅱ"
		case 'Ⅱ': Send "{BS}{Text}➁"
		case '➁': Send "{BS}{Text}➋"
		case '➋': Send "{BS}{Text}2"

		case '3': Send "{BS}{Text}Ⅲ"
		case 'Ⅲ': Send "{BS}{Text}➂"
		case '➂': Send "{BS}{Text}➌"
		case '➌': Send "{BS}{Text}3"

		case '4': Send "{BS}{Text}Ⅳ"
		case 'Ⅳ': Send "{BS}{Text}➃"
		case '➃': Send "{BS}{Text}➍"
		case '➍': Send "{BS}{Text}4"

		case '5': Send "{BS}{Text}Ⅴ"
		case 'Ⅴ': Send "{BS}{Text}➄"
		case '➄': Send "{BS}{Text}➎"
		case '➎': Send "{BS}{Text}5"

		case '6': Send "{BS}{Text}Ⅵ"
		case 'Ⅵ': Send "{BS}{Text}➅"
		case '➅': Send "{BS}{Text}➏"
		case '➏': Send "{BS}{Text}6"

		case '7': Send "{BS}{Text}Ⅶ"
		case 'Ⅶ': Send "{BS}{Text}➆"
		case '➆': Send "{BS}{Text}➐"
		case '➐': Send "{BS}{Text}7"

		case '8': Send "{BS}{Text}Ⅷ"
		case 'Ⅷ': Send "{BS}{Text}➇"
		case '➇': Send "{BS}{Text}➑"
		case '➑': Send "{BS}{Text}8"

		case '9': Send "{BS}{Text}Ⅸ"
		case 'Ⅸ': Send "{BS}{Text}➈"
		case '➈': Send "{BS}{Text}➒"
		case '➒': Send "{BS}{Text}9"
		}
	}
}

#HotIf
; Pause:: Pause -1

#SuspendExempt
<^LWin:: Suspend  ; 左Ctrl + 左Win 暂停/恢复运行此程序
#SuspendExempt False