/*
 * 说明：FinalD/终点 输入法插件，标点及扩展符号快速输入/变换程序。
 * 注意：⚠编辑此文件后必须保存为UTF-8 with BOM编码格式！
 * 网址：https://github.com/Lantaio/IME-booster-FinalD
 * 作者：Lantaio Joy
 * 版本：见下面的全局变量Version，或运行此程序后按 左Win+Alt+. 查看。
 * 更新：2026/7/1
 */
#Requires AutoHotkey >=v2.0.26  ; 此程序只能在 >=v2.0.26版的AutoHotkey正常运行
#SingleInstance  ; 只允许运行1个实例
#UseHook  ; 使用键盘钩子，相当于在每个热键前面使用$前缀，以避免Send函数触发它自己
Critical "On"  ; 将所有线程默认设置为关键线程（不可中断），使短按按键可以按顺序执行，并缓存未处理的按键
CoordMode "Caret", "Screen"  ; 设置CaretGetPos函数的坐标模式为相对于屏幕
CoordMode "Mouse", "Screen"  ; 设置MouseGetPos函数的坐标模式为相对于屏幕
CoordMode "ToolTip", "Screen"  ; 设置ToolTip函数的坐标模式为相对于屏幕
SetTitleMatchMode "RegEx"  ; 设置窗口标题的匹配模式为正则模式（※ 此模式默认区分大小写）
; KeyHistory 60
; OnError handleError  ; 指定错误处理函数（避免不存在当前窗口时会弹出错误信息的问题）

global Version := "v8.74.222`n　　　 © 2024~2026"  ; 此程序的版本号
global HolyShift := true  ; 标记是否只按下了Shift键，是则为 true
global Prev := ''  ; 光标前1个内容

#Include <Caret>  ; 和光标有关的函数
; #Include <Debugger>  ; 和调试有关的函数
#Include <IME>  ; 和输入法有关的函数
#Include <Selection>  ; 和选择有关的函数
#Include "MySettings\AppGroup.ahk"  ; 引入用户自定义的程序组信息
#Include "MySettings\Shortcut.ahk"  ; 引入用户自定义的快捷键信息

/*
 * 借助剪贴板获取光标前一个内容（字符）
 * 返回值：
 *   clip (string) 通过 Shift+← 键选取的光标前一个内容（字符）
 */
getPrev() {
	clipCache := ClipboardAll(), A_Clipboard := ''  ; 临时寄存剪贴板内容，清空剪贴板
	Send "+{Left}^c"  ; 选取当前光标前一个字符并复制
	ClipWait 0.7, 1  ; 等待剪贴板更新
	; 获取剪贴板中的字符（一般是光标前一个字符），计算它的长度
	clip := A_Clipboard, clipLen := StrLen(clip)
/*	if Debug {
		ToolTip "前1个字符是“" FormatString(clip) "”，长度：" clipLen "，编码：" Ord(clip) "`r`n最后1个字符是“" FormatString(SubStr(clip, -1)) "”"
		; ListVars  ; 调试时查看变量值
		Pause
	}
*/
	; 如果复制的字符长度为1 或 是回车換行符（行首）或 是emoji
	if clipLen = 1 or clip ~= '`a)^\R$' or IsEmoji(clip)  ; chrLen > 1 and chrLen < 6 and not c1ip ~= '`a)\R$'
		Send "{Right}"  ; 光标回到原来的位置
	; 否则，如果当前软件是Word或PowerPoint
	else if clip = '' and WinActive(" - Word$") {
		A_Clipboard := ''  ; 清空剪贴板
		Send "+{Left}^c"  ; 选取当前光标前一个字符并复制
		ClipWait 0.4, 1  ; 等待剪贴板更新
		; 获取剪贴板中的字符，即光标前2个字符
		clip2 := A_Clipboard
/*		if Debug {
			ToolTip "Office前2个字符是“" FormatString(clip2) "”，长度：" clipLen "，编码：" Ord(clip2) "`r`n最后1个字符是“" FormatString(SubStr(clip2, -1)) "”"
			; ListVars  ; 调试时查看变量值
			Pause
		}
*/
		if not clip2 = ''
			Send "{Right}"  ; 光标回到原来的位置
	}
	; 恢复原来的剪贴板内容
	A_Clipboard := clipCache, clipCache := ''
	if WinActive("ahk_group Slow")  ; 如果是反应慢的应用，暂停一下以等待光标完成向右移动
		Sleep 50
	return clip
}

/*
 * 借助剪贴板获取光标后一个内容（字符）
 * 返回值：
 *   clip (string) 通过Shift+→键选取的光标后一个内容（字符）
 */
getNext() {
	clipCache := ClipboardAll(), A_Clipboard := ''  ; 临时寄存剪贴板内容，清空剪贴板
	Send "+{Right}^c"  ; 选取当前光标后一个字符并复制
	ClipWait 0.4, 1  ; 等待剪贴板更新
	; 获取剪贴板中的字符，即光标后一个字符，计算它的长度，然后恢复原来的剪贴板内容
	clip := A_Clipboard, clipLen := StrLen(clip), A_Clipboard := clipCache, clipCache := ''
/*	if Debug {
		ToolTip "后1个字符是“" FormatString(clip) "”，长度：" clipLen "，编码：" Ord(clip) "`r`n最后1个字符是“" FormatString(SubStr(clip, -1)) "”"
		; ListVars  ; 调试时查看变量值
		Pause
	}
*/
	; 如果复制的字符长度为1 或 是回车換行符（行末）或 是emoji
	if clipLen = 1 or clip ~= '`a)^\R$' or IsEmoji(clip)  ;chrLen > 1 and chrLen < 6 and not c1ip ~= '`a)\R$'
		Send "{Left}"  ; 光标回到原来的位置
	if WinActive("ahk_group Slow")  ; 如果是反应慢的软件，暂停一下以等待光标完成向左移动
		Sleep 50
	return clip
}

/*
 * 标点符号循环漂移
 * 参数：
 *   origin (string) 将要被转换的标点符号
 *   pList* (string array)(可变) 标点符号循环漂移列表（数组）
 */
drift(origin, pList*) {
	i := 0
	loop pList.length
		if origin = pList[A_Index] {  ; 如果将要被转换的标点符号在漂移列表中
			i := A_Index
			break
		}
	if i = 0 or i = pList.length  ; 如果在漂移列表中不存在这个标点符号 或者 是列表中最后1个标点符号
		i := 1  ; 定位列表中第1个标点符号
	else
		i += 1  ; 定位列表中所找到的标点符号的下1个标点符号
	if origin = '…' or origin = '—'  ; 如果原来的标点是‘……’或‘——’
		Send "{BS}"  ; 多输入1个退格键
	Send "{BS}{Text}" pList[i]  ; 漂移标点符号
	if Tip
		switch pList[i] {
			case '，', '：', '；', '？', '！', '｜', '～', '＄', '／', '＼', '〈': showTip("中", 1)
			case '］', '｝', '〉': showTip("后", 1)
		}
}

/*
 * 转换有配对标点的标点
 * 参数：
 *   origin (string) 将要被转换的标点
 *   target (string) 转换成的目标标点
 */
driftPair(origin, target) {
	SendText "!"
	Send "{Left}{BS}"
	SendText target
	if Tip and InStr("（“‘［｛〈", target)
		showTip("前", 1)
	Send "{Del}"
	if Smart and hasPair(origin) {
		Send "{Del}{Text}!"
		Send "{Left}"
		switch target {
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
		if Tip and InStr("（“‘［｛〈", target)
			showTip("配对", 1)
		Send "{Del}{Left}"
		if target = '≤'
			Send "{Right}"
	}
}

/*
 * 检测传入的字符是不是希腊字母，如果是则将其变换为对应的英文字母；或 如果是数字，将其变换为上下标数字形式
 * 参数：
 *   char (string) 待检测的字符
 */
driftToENG(char) {
	switch char {
		; 小写希腊字母变换为小写英文字母
		case 'α': Send "{BS}{Text}a"
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
		; 大写希腊字母变换为大写英文字母
		case 'Α': Send "{BS}{Text}A"
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
		; 数字变换为上下标数字形式
		case '0', '⓪', '₀', '⁰', '⓿': drift(char, '0', '₀', '⁰', '⓪')
		case '1', 'Ⅰ', 'ⅰ', '➀', '₁', '¹', '➊': drift(char, '1', '₁', '¹', '➀')
		case '2', 'Ⅱ', 'ⅱ', '➁', '₂', '²', '➋': drift(char, '2', '₂', '²', '➁')
		case '3', 'Ⅲ', 'ⅲ', '➂', '₃', '³', '➌': drift(char, '3', '₃', '³', '➂')
		case '4', 'Ⅳ', 'ⅳ', '➃', '₄', '⁴', '➍': drift(char, '4', '₄', '⁴', '➃')
		case '5', 'Ⅴ', 'ⅴ', '➄', '₅', '⁵', '➎': drift(char, '5', '₅', '⁵', '➄')
		case '6', 'Ⅵ', 'ⅵ', '➅', '₆', '⁶', '➏': drift(char, '6', '₆', '⁶', '➅')
		case '7', 'Ⅶ', 'ⅶ', '➆', '₇', '⁷', '➐': drift(char, '7', '₇', '⁷', '➆')
		case '8', 'Ⅷ', 'ⅷ', '⓼', '₈', '⁸', '➑': drift(char, '8', '₈', '⁸', '⓼')
		case '9', 'Ⅸ', 'ⅸ', '⓽', '₉', '⁹', '➒': drift(char, '9', '₉', '⁹', '⓽')
	}
}

/*
 * 检测传入的字符是不是英文字母，如果是则将其变换为对应的希腊字母；或 如果是数字，将其变换为对应的罗马数字形式
 * 参数：
 *   char (string) 待检测的字符
 */
driftToGRC(char) {
	switch char {
		; 小写英文字母变换为小写希腊字母
		case 'a': Send "{BS}{Text}α"
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
		; 大写英文字母变换为大写希腊字母
		case 'A': Send "{BS}{Text}Α"
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
		; 数字变换为罗马数字形式
		case '0', '⓪', '₀', '⁰', '⓿': drift(char, '⓿', '0')
		case '1', 'Ⅰ', 'ⅰ', '➀', '₁', '¹', '➊': drift(char, 'Ⅰ', 'ⅰ', '➊')
		case '2', 'Ⅱ', 'ⅱ', '➁', '₂', '²', '➋': drift(char, 'Ⅱ', 'ⅱ', '➋')
		case '3', 'Ⅲ', 'ⅲ', '➂', '₃', '³', '➌': drift(char, 'Ⅲ', 'ⅲ', '➌')
		case '4', 'Ⅳ', 'ⅳ', '➃', '₄', '⁴', '➍': drift(char, 'Ⅳ', 'ⅳ', '➍')
		case '5', 'Ⅴ', 'ⅴ', '➄', '₅', '⁵', '➎': drift(char, 'Ⅴ', 'ⅴ', '➎')
		case '6', 'Ⅵ', 'ⅵ', '➅', '₆', '⁶', '➏': drift(char, 'Ⅵ', 'ⅵ', '➏')
		case '7', 'Ⅶ', 'ⅶ', '➆', '₇', '⁷', '➐': drift(char, 'Ⅶ', 'ⅶ', '➐')
		case '8', 'Ⅷ', 'ⅷ', '⓼', '₈', '⁸', '➑': drift(char, 'Ⅷ', 'ⅷ', '➑')
		case '9', 'Ⅸ', 'ⅸ', '⓽', '₉', '⁹', '➒': drift(char, 'Ⅸ', 'ⅸ', '➒')
	}
}

/*
 * 根据提供的前标点返回对应的后标点。
 * 参数：
 *   front (string) 前标点
 * 返回值：
 *   (string) 对应的后标点
 */
getPair(front) {
	switch front {
		case '(': return ')'
		case '（': return '）'
		case '"': return '"'
		case "'": return "'"
		case '{': return '}'
		case '「': return '」'
		case '[': return ']'
		case '【': return '】'
		case '《': return '》'
	}
}

/*
 * 检测front标点是否有配对的后标点
 * 参数：
 *   front (string) 检测这个前标点是否有相配对的后标点
 * 返回值：
 *   true / false
 */
hasPair(front) {
	back := getNext()  ; 获取光标后1个内容
	return isPair(front, back)
}

/*
 * 检测front和back两个参数是不是成对的标点
 * 参数：
 *   front (string) 前内容（标点），检测是否和back是成对的标点
 *   back (string) 后内容（标点），检测是否和front是成对的标点
 * 返回值：
 *   true / false
 */
isPair(front, back) {
	switch front {
		case '(': return back = ')'
		case '（': return back = '）'
		case '"': return back = '"'
		case '“': return back = '”'
		case "'": return back = "'"
		case '‘': return back = '’'
		case '{': return back = '}'
		case '「': return back = '」'
		case '『': return back = '』'
		case '〘': return back = '〙'
		case '｛': return back = '｝'
		case '[': return back = ']'
		case '【': return back = '】'
		case '〖': return back = '〗'
		case '〔': return back = '〕'
		case '［': return back = '］'
		case '<': return back = '>'
		case '《': return back = '》'
		case '〈': return back = '〉'
	}
	return false
}

/*
 * 恢复按键正确的逻辑状态（和物理状态一致）
 * 参数：
 *   key (string) 按键名称
 */
reKeyState(key) {
	if GetKeyState(key, "P") {
		Send "{" key " down}"
		; Sleep 50
	}
}

/*
 * 检测光标前的内容是否在西文字符集中
 * 返回值：
 *   true / false
 */
isPrevEN() {
/* 	if Debug {
		ToolTip "是否应该输入西文标点是“" FormatString(Prev) "”"
		Pause
	}
 */
	; 返回前一个字符是否在西文字符集中的判断结果
	if Ord(Prev) < 0x2000
		return true
	else
		return false
}

/*
 * 通过检测光标后的内容来判断是否应该输入配对的标点符号
 * 参数：
 *   front (string)(可选) 提供前标点以便做相应处理
 * 返回值：
 *   true / false
 */
shouldPair(front?) {
	next := getNext()  ; （※此处不能用SubStr只获取1个字符）
/*	if Debug {
		ToolTip "是否应该输入配对标点是“" FormatString(next) "”"
		Pause
	}
*/
	; 如果后一个字符是空字符 或 空格 或 换行符
	if next = '' or next = ' ' or next ~= '`a)\R$'
		return true
	; 如果给定前标点 并且 前标点是‘'’、‘"’、‘‘’或‘“’
	if isSet(front) and InStr("`"'“‘", front)
		return false
	; 如果后一个字符是下列字符之一
	switch next {
		case ',', '.', ':', ';', ')', ']', '}', '>', '?', '!': return true
		case '，', '。', '：', '；', '？', '！', '）', '］', '】', '〗', '〕', '〙', '｝', '》', '〉': return true
	}
	return false
}

/*
 * 显示提示信息
 * 参数：
 *   info (string) 提示信息内容
 *   sec (float) 提示信息显示时长，以秒为单位
 */
showTip(info, sec) {
	if CaretGetPos2(&x, &y)  ; 如果能通过加强版函数获取到光标位置，则……
		ToolTip info, x, y-25
	else {  ; 否则，重新激活一下顶部程序窗口
		WinActivate("ahk_class A)Shell_TrayWnd$")  ; 激活任务栏
		WinActivate  ; 重新激活顶部窗口
		if CaretGetPos2(&x, &y)
			ToolTip "A " info, x, y-25
		else if CaretGetPos(&x, &y)
			ToolTip info, x, y-25
		else {
			MouseGetPos &x, &y
			ToolTip "M " info, x, y-25
		}
/*		else {
			WinGetPos &x, &y, &w, &h  ; 获取当前程序窗口位置信息
			ToolTip info, x + w/2, y + h/2  ; 在当前程序窗口中央显示提示信息
		}
*/
	}
	SetTimer ToolTip, -sec*1000  ; 负数表示提示信息会在显示sec秒后清除
}

/*
 * 智能选择要上屏英文标点还是中文标点
 * 参数：
 *   en (string) 按键对应的英文标点符号
 *   cn (string) 按键对应的中文标点符号
 * 返回值：
 *   en / cn (string) 根据情况选择要上屏英文还是中文标点
 */
smartChoice(en, cn) {
	if en = cn
		return en
	if AI  ; 智慧模式
		; 如果*不是* 当前程序是中文语境软件 并且 前一个内容是西文
		if not WinActive("ahk_group CN") and isPrevEN()
			Return en
		; 否则（是中文语境软件，或者应该输入中文标点），如果按键是“.”、“:”或“~” 并且 前一个字符是数字，则应是英文标点
		else if (en = '.' or en = ':' or en = '~') and IsInteger(Prev)
			Return en
		else  ; 否则，应是中文标点
			Return cn
	else {  ; 操控模式
		; 如果*不是* （（前一个内容是换行符 或 空）并且 当前程序是中文语境软件） 并且 前一个内容是西文
		if not ((Prev ~= '`a)\R$' or Prev = '') and WinActive("ahk_group CN")) and isPrevEN()
			Return en
		else  ; 否则，应是中文标点
			Return cn
	}
}

/*
 * 根据按键方式和是否有提供中文标点参数来选择处理方式。
 * **短按**时如果没有提供中文标点，则直接上屏英文标点，否则用smartChoice函数判断应该上屏英文标点还是中文标点；
 * **妙按**时的输入逻辑和短按时反转；
 * **长按**时删除妙按时上屏的标点，然后连续上屏短按时应该上屏的标点。
 * 参数：
 *   en (string) 按键名称，对应英文标点符号
 *   cn (string) （可选）按键对应的中文标点符号
 */
smartType(en, cn?) {  ; （※ Send函数中[^+!#]标点须用{}包裹。）
	if not isSet(cn)
		cn := en
	if KeyWait(en, "T" String(Interval)) {  ; ### 短按
		global Prev := getPrev()  ; （※ 不能放在if语句之前，否则可能导致检测是短按还是长按不正确）
		choice := smartChoice(en, cn), commit := ''
		if choice = en {  ; 如果 应该输入英文标点
			SendText en
			if (InStr("([{", en) or ((en = '"' or en = "'") and (Prev = ' ' or Prev ~= '`a)\R$' or Prev = '`t' or Prev = ''))) and not WinActive("ahk_group AutoPair") and shouldPair(en) {  ; 如果 是英文前标点 并且 *不是*自动配对功能程序组 并且 应该输入配对的后标点
				SendText getPair(en)  ; 输入对应的后标点
				Send "{Left}"  ; 光标回到配对标点中间
			}
		}
		else {  ; 应该输入中文标点
			switch cn {
				case '“', '‘':
					Send en  ; ⚠注意此处是交给输入法处理
					commit := getPrev()
					if commit = '“' or commit = '‘' {  ; 如果 刚输入的是中文引号前标点
						if Tip
							showTip("前", 1)
						if shouldPair(commit) {  ; 如果 应该自动配对，则……
							if Tip
								showTip("配对", 1)
							Send en "{Left}"  ; ⚠再次交给输入法处理
						}
					}
					else  ; 刚输入的是中文引号后标点
						if Tip
							showTip("后", 1)
				case '（', '【', '「', '《':
					SendText cn
					if Tip and cn = '（'
						showTip("前", 1)
					if shouldPair() {
						SendText getPair(cn)
						if Tip and cn = '（'
							showTip("配对", 1)
						Send "{Left}"
					}
				case '）', '】', '」', '》':
					SendText cn
					if Tip and cn = '）'
						showTip("后", 1)
				default:  ; 其他中文单标点
					if Tip and InStr("，：；？！｜～", cn)
						showTip("中", 1)
					SendText cn
			}
		}
	}
	else {  ; 妙按 和 长按
		Critical "Off"
		Thread "Priority", 1  ; 提高线程优先级，使此线程不会被后面的低优先级线程中断，并丢弃未处理的按键
		; ### 妙按
		global Prev := getPrev()
		choice := smartChoice(en, cn), commit := ''
		if AI  ; 智慧模式
			if choice = en {  ; 本来应该输入英文标点，变成输入中文标点
				(en = '!' or en = '^' or en = '{' or en = '}') ? Send("{" en "}") : Send(en)  ; 先交给输入法处理（Rime输入法时妙按弹出候选窗口）
				Sleep 100
				if not WinExist("ahk_group IME") {
					if en = '.' or en = "~"  ; or en = ',' or en = ':'
						Send("{BS}{Text}" cn)  ; (※ 必须删除上一步输入的标点，因为中文输入法在数字后可能会输入英文标点)
				}
			}
			else {  ; 本来应该输入中文标点，变成输入英文标点
				if en != '"' and en != "'"
					(en = '!' or en = '^' or en = '{' or en = '}') ? Send("{" en "}") : Send(en)  ; 先交给输入法处理（Rime输入法时妙按弹出候选窗口）
				else
					SendText en
				Sleep 100
				if en != '"' and en != "'" and not WinExist("ahk_group IME")
					(en = '^' or en = '_') ? Send("{BS 2}{Text}" en) : Send("{BS}{Text}" en)
			}
		else {  ; 操控模式
			if choice = en  ; 本来应该输入英文标点，变成输入中文标点
				if InStr("/^$|", en) {  ; 如果是Rime功能触发键
					en = '^' ? Send("{" en "}") : Send(en)  ; 交给输入法处理
					Sleep 100
					if en != '/' and not WinExist("ahk_group IME")
						en = '^' ? Send("{BS 2}{Text}……") : Send("{BS}{Text}" cn)
				}
				else {  ; 不是Rime功能触发键
					switch cn {
						case '“', "‘":
							Send en  ; ⚠注意此处是交给输入法处理
							commit := getPrev()
							if commit = '“' or commit = '‘'  ; 如果 刚输入的是中文引号前标点
								if Tip
									showTip("前", 1)
							else  ; 否则 刚输入的是中文引号后标点
								if Tip
									showTip("后", 1)
						case '（', '）', '【', '】', '「', '」', '《', '》':
							SendText cn
							if Tip
								if cn = '（'
									showTip("前", 1)
								else if cn = '）'
									showTip("后", 1)
						default:  ; 其他中文单标点
							if Tip and InStr("，：；？！｜～", cn)
								showTip("中", 1)
							SendText cn
					}
				}
			else  ; 本来应该输入中文标点，变成输入英文标点
				if InStr("/^$|", en) {  ; 如果是Rime功能触发键
					en = '^' ? Send("{" en "}") : Send(en)  ; 交给输入法处理
					Sleep 100
					if en != '/' and not WinExist("ahk_group IME")
						en = '^' ? Send("{BS 2}{Text}^") : Send("{BS}{Text}" en)
				}
				else  ; 否则（不是Rime功能触发键）
					SendText en
		}
		Sleep 1000 * Interval
		; ### 长按的第1次输入
		if GetKeyState(en, "P") {  ; 如果按键未弹起
			if choice = en {  ; 如果应该输入英文标点
				if (en = '^' or en = '_') and not WinExist("ahk_group IME")  ; 如果妙按输入的是“……”或“——”，并且没有输入法候选窗口（有则表示未上屏）
					Send "{BS}"  ; 多输入1个退格键
				Send "{BS}{Text}" en  ; 删除妙按输入的中文标点，并输入1个英文标点
			}
			else {  ; 如果应该输入中文
				Send "{BS}"  ; 删除妙按时输入的英文标点（或者关闭输入法候选窗口）（※ 此操作统一不同中文输入法的行为）
				switch cn {
					case '“', '‘':
						Send en  ; ⚠注意此处是交给输入法处理
						commit := getPrev()
						if commit = '“' or commit = '‘'  ; 如果 刚输入的是中文引号前标点
							if Tip
								showTip("前", 1)
						else  ; 否则 刚输入的是中文引号后标点
							if Tip
								showTip("后", 1)
					case '（', '）', '【', '】', '「', '」', '《', '》':
						SendText cn
						if Tip
							if cn = '（'
								showTip("前", 1)
							else if cn = '）'
								showTip("后", 1)
					default:  ; 其他中文单标点
						if Tip and InStr("，：；？！｜～", cn)
							showTip("中", 1)
						SendText cn
				}
			}
			Sleep 1000 * Interval
		}
		else {  ; 妙按后没有长按
			if choice = en and InStr("“‘（【「《", cn) and shouldPair(cn) {  ; 如果妙按时输入中文前标点 并且 应该输入配对的后标点
				if (commit = '“' or commit = '‘') {  ;
					Send en  ; ⚠注意此处是交给输入法处理
					if Tip
						showTip("配对", 1)
					Send "{Left}"
				}
				else if InStr("（【「《", cn)  {
					SendText getPair(cn)
					if Tip and cn = '（'
						showTip("配对", 1)
					Send "{Left}"
				}
			}
			else if choice = cn  ; 否则 如果妙按时输入英文前标点
				if (InStr("([{", en) or ((en = '"' or en = "'") and (Prev = ' ' or Prev ~= '`a)\R$' or Prev = '`t' or Prev = ''))) and not WinActive("ahk_group AutoPair") and shouldPair(en) {  ; 如果是英文前标点 并且 *不是*自动配对功能程序组 并且 应该输入配对的后标点
					SendText getPair(en)  ; 输入对应的后标点
					Send "{Left}"  ; 光标回到配对标点中间
				}
			return
		}
		; ### 长按的后续输入
		while GetKeyState(en, "P") {  ; 当按键未弹起时
			if choice = en  ; 如果 应该输入英文标点
				SendText en
			else if cn = '“' or cn = '‘'  ; 否则 如果 是中文引号
				Send en  ; ⚠注意此处是交给输入法处理
			else  ; 否则 是其它中文标点
				SendText cn
			Sleep 1000 * Interval
		}
	}
}

/*
 * 错误处理函数
 * 参数：
 *   ex (object) 错误对象
 *   mode 错误的模式
 * 返回值：
 *   1 抑制默认错误对话框和任何剩余的错误回调
 */
handleError(ex, mode) {
	return true
}

/*
 * 基本的按键处理函数，直接将按键发送给系统处理
 * 参数：
 *   thisHotkey (string) 触发的热键名称
 */
keyHandler(thisHotkey) {
	; key := SubStr(thisHotkey, -1)  ; 提取热键的最后1个键名
	Send "{Blind}" thisHotkey  ;
}

/*
 * 基本的特殊按键处理函数，直接将按键发送给系统处理
 * 参数：
 *   thisHotkey (string) 触发的热键名称
 */
xkeyhandler(thisHotkey) {
	Send "{Blind}{" thisHotkey "}"
}

; ~~~~~~ Optional Hotkeys Begin ~~~~~~
; 这部分热键为非必须热键，如果和你使用的其它AHK脚本有冲突，可以将这部分代码注释或删除。但这将失去按键按顺序执行的功能，当输入太快时顺序可能会出现错乱。
nums := "0123456789"
Loop Parse, nums  ;添加数字热键，使按键可以按顺序执行
	Hotkey A_LoopField, keyHandler
letters := "abcdefghijklmnopqrstuvwxyz"
Loop Parse, letters  ;添加小写字母热键，使按键可以按顺序执行
	Hotkey A_LoopField, keyHandler
Loop Parse, letters  ;添加大写字母热键，使按键可以按顺序执行
	Hotkey '+' A_LoopField, keyHandler
; ~~~~~~ Optional Hotkeys End ~~~~~~

; 如果 聪明标点开关打开，并且不是（存在输入法候选窗口 或 当前软件是 不支持聪明标点输入和自动配对功能的应用程序组 或 不适用须要排除的应用程序组） 并且 在中文输入状态。
#HotIf Smart and not (WinExist("ahk_group IME") or WinActive("ahk_group UnSmart") or WinActive("ahk_group Exclude")) and IsCNInputMode()
.:: smartType('.', '。')
,:: smartType(',', '，')
(:: smartType('(', '（')
):: smartType(')', '）')
_:: {  ; （连按键）
	; Send "{Blind}{- up}{LShift up}"
	SendText smartType('_', '——')
	; reKeyState "LShift"  ; 可自动重复
}
::: {
	; Send "{Blind}{; up}{LShift up}"
	smartType(':', '：')  ; 长按输入中文标点
	; reKeyState "LShift"  ; 可自动重复
}
":: smartType('"', '“')
/:: smartType(ThisHotkey)
=:: SendText ThisHotkey  ; （连按键）
<:: smartType('<', '《')
>:: smartType('>', '》')
`;:: smartType(';', '；')
-:: SendText ThisHotkey  ; （连按键）
{:: smartType('{', '「')
}:: smartType('}', '」')
':: smartType("'", '‘')
*:: SendText ThisHotkey  ; （连按键）
#:: SendText ThisHotkey  ; （连按键）
[:: smartType('[', '【')
]:: smartType(']', '】')
`:: smartType(ThisHotkey)
+:: SendText ThisHotkey  ; （连按键）
&:: smartType(ThisHotkey)
?:: {
	; Send "{Blind}{/ up}{LShift up}"
	smartType('?', '？')
}
!:: {
	; Send "{Blind}{1 up}{RShift up}"
	smartType('!', '！')
}
\:: smartType('\', '、')
|:: {
	; Send "{Blind}{\ up}{LShift up}"
	smartType('|', '｜')
}
@:: {
	smartType(ThisHotkey)
}
%:: {
	smartType(ThisHotkey)
}
^:: {
	; Send "{Blind}{6 up}{LShift up}"
	smartType('^', '……')
}
~:: {  ; （连按键）
	; Send "{Blind}{`` up}{RShift up}"
	smartType('~', '～')
}
$:: {
	; Send "{Blind}{4 up}{RShift up}"
	smartType('$', '￥')
}

; 如果*不是*（存在输入法候选窗口 或 当前软件是 不适用须要排除的应用程序组 或 文件管理器且活动控件*不是*输入框）
#HotIf not (WinExist("ahk_group IME") or WinActive("ahk_group Exclude") or (WinActive("ahk_group FileManager") and not InStr(ControlGetClassNN(ControlGetFocus("A")), "edit")))  ; or hasMS_IMEWindow()
; 英/中常用标点变换，处理有配对标点符号时按情况变换单个或者成对标点。
~LShift up:: {  ; 当左Shift键弹起并且之前没有按过其它键时触发
	if HolyShift and A_PriorKey = "LShift"
		switch origin := getPrev() {  ; 获取光标前一个内容（将要被变换的标点）
			case '。', '.', '℃', '°', '℉': drift(origin, '。', '.')

			case '，', ',', '∈', '⊆', '⊂': drift(origin, '，', ',')

			case '(', '〔', '〘': driftPair(origin, '（')
			case '（': driftPair('（', '(')

			case ')', '〕', '〙': Send "{BS}{Text}）"
				if Tip
					showTip("后", 1)
			case '）': SendText("!"), Send("{Left}{BS}{Text})"), Send("{Del}")

			case '_', '—', '∪', '∩': drift(origin, '_', '——')

			case '：', ':', '∵', '∴', '∷': drift(origin, '：', ':')

			case '"': driftPair('"', '“')
			case '“': driftPair('“', '"')
			case '”': SendText("!"), Send("{Left}{BS}{Text}`""), Send("{Del}")

			case '/', '÷', '／', '≠', '√': drift(origin, '/', '÷')

			case '=', '≈', '⇒', '⇔', '≡', '≌': drift(origin, '=', '≈')

			case '<', '〈': driftPair(origin, '《')
			case '《': driftPair('《', '<')
			case '≤', '«', '‹': Send "{BS}{Text}《"

			case '》', '>', '〉', '≥', '»', '›': drift(origin, '》', '>')

			case '；', ';', '☐', '☑', '☒': drift(origin, '；', ';')

			case '-', '¬', '∨', '∧': drift(origin, '-', '¬')

			case '{', '『', '｛': driftPair(origin, '「')
			case '「': driftPair('「', '{')

			case '}', '』', '｝': Send "{BS}{Text}」"
			case '」': SendText("!"), Send("{Left}{BS}{Text}}"), Send("{Del}")

			case "'": driftPair("'", '‘')
			case "‘": driftPair('‘', "'")
			case "’": SendText("!"), Send("{Left}{BS}{Text}'"), Send("{Del}")

			case '*', '×', '·', '＊', '∏': drift(origin, '*', '×')

			case '#', '■', '◆', '◇', '□': drift(origin, '#', '■')

			case '[': driftPair('[', '【')
			case '【', '〖', '［': driftPair(origin, '[')

			case ']': Send "{BS}{Text}】"
			case '】', '〗', '］': SendText("!"), Send("{Left}{BS}{Text}]"), Send("{Del}")

			case '``', 'π', 'α', 'β', 'γ', 'λ', 'μ': drift(origin, '``', 'π')

			case '+', '±', '∑', '∫', '∮': drift(origin, '+', '±')

			case '&', '※', '§', '∞', '∝': drift(origin, '&', '※')

			case '？', '?', '✔', '❌', '✘', '⭕': drift(origin, '？', '?')

			case '！', '!', '▲', '⚠', '△': drift(origin, '！', '!')

			case '\', '、', '→', '↔', '←', '＼': drift(origin, '\', '、')

			case '｜', '|', '↑', '↕', '↓', '‖': drift(origin, '｜', '|')

			case '@', '©', '●', '®', '™', '○': drift(origin, '@', '©')

			case '%', '‰', '★', '☆', '✪': drift(origin, '%', '‰')

			case '^', '…', '⌘', '⌥', '⇧', '↩': drift(origin, '^', '……')

			case '~', '～', 'Δ', 'Ω', 'Θ', 'Λ', 'Φ': drift(origin, '~', '～')

			case '$', '￥', '＄', '¥', '€', '£', '¢', '¤': drift(origin, '$', '￥')
		}
}
; 扩展标点变换。处理有配对标点符号时可快速变换单个或者成对标点。
~RShift up:: {  ; 当右Shift键弹起并且之前没有按过其它键时触发
	if HolyShift and A_PriorKey = "RShift"
		switch origin := getPrev() {  ; 获取光标前一个内容（将要被变换的标点）
			case '。', '.', '℃', '°', '℉': drift(origin, '℃', '°', '℉')

			case '，', ',', '∈', '⊆', '⊂': drift(origin, '∈', '⊆', '⊂')

			case '(', '（', '〘': driftPair(origin, '〔')
			case '〔': driftPair('〔', '〘')

			case ')', '）', '〕', '〙': drift(origin, '〕', '〙')

			case '_', '—', '∪', '∩': drift(origin, '∪', '∩')

			case '：', ':', '∵', '∴', '∷': drift(origin, '∵', '∴', '∷')

			case '"': Send "{Left}{Del}{Text}“"
				if Tip
					showTip("前", 1)
			case '“': Send "{BS}{Text}”"
				if Tip
					showTip("后", 1)
			case '”': SendText("!"), Send('{Left}{BS}{Text}"'), Send("{Del}")

			case '/', '÷', '／', '≠', '√': drift(origin, '／', '≠', '√')

			case '=', '≈', '⇒', '⇔', '≡', '≌': drift(origin, '⇒', '⇔', '≡', '≌')

			case '<', '《': driftPair(origin, '〈')
			case '〈': driftPair('〈', '≤')
			case '≤', '«', '‹': drift(origin, '〈', '≤', '«', '‹')

			case '》', '>', '〉', '≥', '»', '›': drift(origin, '〉', '≥', '»', '›')

			case '；', ';', '☐', '☑', '☒': drift(origin, '☐', '☑', '☒')

			case '-', '¬', '∨', '∧': drift(origin, '∨', '∧')

			case '{', '「', '｛': driftPair(origin, '『')
			case '『': driftPair('『', '｛')

			case '}', '」', '』', '｝': drift(origin, '』', '｝')

			case "'": Send "{Left}{Del}{Text}‘"
				if Tip
					showTip("前", 1)
			case "‘": Send "{BS}{Text}’"
				if Tip
					showTip("后", 1)
			case "’": SendText("!"), Send("{Left}{BS}{Text}'"), Send("{Del}")

			case '*', '×', '·', '＊', '∏': drift(origin, '·', '＊', '∏')

			case '#', '■', '◆', '◇', '□': drift(origin, '◆', '◇', '□')

			case '[', '【', '［': driftPair(origin, '〖')
			case '〖': driftPair('〖', '［')

			case ']', '】', '〗', '］': drift(origin, '〗', '］')

			case '``', 'π', 'α', 'β', 'γ', 'λ', 'μ': drift(origin, 'α', 'β', 'γ', 'λ', 'μ')

			case '+', '±', '∑', '∫', '∮': drift(origin, '∑', '∫', '∮')

			case '&', '※', '§', '∞', '∝': drift(origin, '§', '∞', '∝')

			case '？', '?', '✔', '❌', '✘', '⭕': drift(origin, '✔', '❌', '✘', '⭕')

			case '！', '!', '▲', '⚠', '△': drift(origin, '▲', '⚠', '△')

			case '\', '、', '→', '↔', '←', '＼': drift(origin, '→', '↔', '←', '＼')

			case '｜', '|', '↑', '↕', '↓', '‖': drift(origin, '↑', '↕', '↓', '‖')

			case '@', '©', '●', '®', '™', '○': drift(origin, '●', '®', '™', '○')

			case '%', '‰', '★', '☆', '✪': drift(origin, '★', '☆', '✪')

			case '^', '…', '⌘', '⌥', '⇧', '↩': drift(origin, '⌘', '⌥', '⇧', '↩')

			case '~', '～', 'Δ', 'Ω', 'Θ', 'Λ', 'Φ': drift(origin, 'Δ', 'Ω', 'Θ', 'Λ', 'Φ')

			case '$', '￥', '＄', '¥', '€', '£', '¢', '¤': drift(origin, '＄', '¥', '€', '£', '¢', '¤')
		}
}

#HotIf
; ~~~~~~ Optional Hotkeys Begin ~~~~~~
; 这部分热键为非必须热键，如果和你使用的其它AHK脚本有冲突，可以将这部分代码注释或删除。但这将失去按键按顺序执行的功能，当输入太快时顺序可能会出现错乱。
Enter::
Space:: Send "{Blind}{" thisHotkey "}"
~+MButton::
~+XButton1::
~+XButton2::
~+WheelLeft::
~+WheelRight::
; ~~~~~~ Optional Hotkeys End ~~~~~~
~+LButton::
~+RButton::
~+WheelDown::
~+WheelUp::  ; 以上为Shift键+任何鼠标键
~*Shift:: {  ; 防止仅按下 Shift键+任何鼠标键 或 其它的修饰键+Shift键 时，最后释放Shift键会触发漂移的问题。
	Critical "Off"
	Thread "Priority", 1  ; 须要提高此线程的优先级，丢弃长按产生的重复Shift按键事件，否则如果最后释放Shift键，会触发Shift热键使HolyShift变成true
	global HolyShift := false
	if GetKeyState("Ctrl", "P") or GetKeyState("Alt", "P")
		KeyWait "Shift"  ; （※ KeyWait函数在等待时可通过热键等启动新线程，因此要提高此线程的优先级）
}
~LShift::
~RShift:: {  ; 如果只按下Shift键，则HolyShift为true
	global HolyShift := true
}
