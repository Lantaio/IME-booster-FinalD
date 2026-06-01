/*
 * 说明：FinalD/终点 输入法插件，标点及扩展符号快速输入/变换程序。
 * 注意：⚠编辑此文件后必须保存为UTF-8 with BOM编码格式！
 * 网址：https://github.com/Lantaio/IME-booster-FinalD
 * 作者：Lantaio Joy
 * 版本：见下面的全局变量Version，或运行此程序后按 左Win+Alt+. 查看。
 * 更新：2026/6/1
 */
#Requires AutoHotkey >=v2.0.26  ; 此程序只能在 >=v2.0.26版的AutoHotkey正常运行
#SingleInstance  ; 只允许运行1个实例
#UseHook  ; 使用键盘钩子，相当于在每个热键前面使用$前缀，以避免Send函数触发它自己
CoordMode "Caret", "Screen"  ; 设置CaretGetPos函数的坐标模式为相对于屏幕
CoordMode "Mouse", "Screen"  ; 设置MouseGetPos函数的坐标模式为相对于屏幕
CoordMode "ToolTip", "Screen"  ; 设置ToolTip函数的坐标模式为相对于屏幕
SetTitleMatchMode "RegEx"  ; 设置窗口标题的匹配模式为正则模式（※ 此模式默认区分大小写）
; KeyHistory 60
; OnError handleError  ; 指定错误处理函数（避免不存在当前窗口时会弹出错误信息的问题）

global Version := "v7.69.195`n　　　 © 2024~2026"  ; 此程序的版本号

#Include <Caret>  ; 和光标有关的函数
#Include <Debugger>  ; 和调试有关的函数
#Include <IME>  ; 和输入法有关的函数
#Include <Selection>  ; 和选择有关的函数
#Include "MySettings\AppGroup.ahk"  ; 引入用户自定义的程序组信息
#Include "MySettings\Shortcut.ahk"  ; 引入用户自定义的快捷键信息

/*
 * 借助剪贴板获取光标前一个内容（字符）
 * 返回值：
 *   (string) 通过 Shift+← 键选取的光标前一个内容（字符）
 */
getBeforeI() {
	clipCache := ClipboardAll(), A_Clipboard := ''  ; 临时寄存剪贴板内容，清空剪贴板
	Send "+{Left}^c"  ; 选取当前光标前一个字符并复制
	ClipWait 0.7, 1  ; 等待剪贴板更新
	; 获取剪贴板中的字符（一般是光标前一个字符），计算它的长度
	clip := A_Clipboard, clipLen := StrLen(clip)
	if Debug {
		ToolTip "前1个字符是“" FormatString(clip) "”，长度：" clipLen "，编码：" Ord(clip) "`r`n最后1个字符是“" FormatString(SubStr(clip, -1)) "”"
		; ListVars  ; 调试时查看变量值
		Pause
	}
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
		if Debug {
			ToolTip "Office前2个字符是“" FormatString(clip2) "”，长度：" clipLen "，编码：" Ord(clip2) "`r`n最后1个字符是“" FormatString(SubStr(clip2, -1)) "”"
			; ListVars  ; 调试时查看变量值
			Pause
		}
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
 *   (string) 通过Shift+→键选取的光标后一个内容（字符）
 */
getAfterI() {
	clipCache := ClipboardAll(), A_Clipboard := ''  ; 临时寄存剪贴板内容，清空剪贴板
	Send "+{Right}^c"  ; 选取当前光标后一个字符并复制
	ClipWait 0.4, 1  ; 等待剪贴板更新
	; 获取剪贴板中的字符，即光标后一个字符，计算它的长度，然后恢复原来的剪贴板内容
	clip := A_Clipboard, clipLen := StrLen(clip), A_Clipboard := clipCache, clipCache := ''
	if Debug {
		ToolTip "后1个字符是“" FormatString(clip) "”，长度：" clipLen "，编码：" Ord(clip) "`r`n最后1个字符是“" FormatString(SubStr(clip, -1)) "”"
		; ListVars  ; 调试时查看变量值
		Pause
	}
	; 如果复制的字符长度为1 或 是回车換行符（行末）或 是emoji
	if clipLen = 1 or clip ~= '`a)^\R$' or IsEmoji(clip)  ;chrLen > 1 and chrLen < 6 and not c1ip ~= '`a)\R$'
		Send "{Left}"  ; 光标回到原来的位置
	if WinActive("ahk_group Slow")  ; 如果是阿里旺旺，暂停一下以等待光标完成向左移动
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
	Send "{BS}{Text}" pList[i]  ; 转换标点符号
	if Tip
		if pList[i] ~= "，|：|；|？|！|｜|～|＄|／|＼|〈"
			showTip("中", 1)
		else if pList[i] ~= '｝|］|〉'
			showTip("后", 1)
}

/*
 * 转换可能有配对标点的标点
 * 参数：
 *   origin (string) 将要被转换的标点
 *   target (string) 转换成的目标标点
 */
driftPair(origin, target) {
	SendText "!"
	Send "{Left}{BS}"
	SendText target
	if Tip and target ~= '（|“|‘|｛|［|〈'
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
		if Tip and target ~= "（|“|‘|｛|［|〈"
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
 * 检测front标点是否有配对的后标点
 * 参数：
 *   front (string) 检测这个前标点是否有相配对的后标点
 * 返回值：
 *   true / false
 */
hasPair(front) {
	back := getAfterI()  ; 获取光标后1个内容
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
 * 通过检测光标前的内容是否在西文字符集中来判断是否应该输入西文标点符号
 * 参数：
 *   before (string)(可选) 光标前一个内容
 * 返回值：
 *   true / false
 */
shouldEN(before?) {
	if not isSet(before)
		before := getBeforeI()  ; 如果没有提供则获取光标前一个内容
	if Debug {
		ToolTip "是否应该输入西文标点是“" FormatString(before) "”"
		Pause
	}
	; 返回前一个字符是否在西文字符集中的判断结果
	if Ord(before) < 0x2000
		return true
	else
		return false
}

/*
 * 通过检测光标后的内容来判断是否应该输入配对的标点符号
 * 参数：
 *   punctuator (string)(可选) 提供引号类标点以便做相应处理
 * 返回值：
 *   true / false
 */
shouldPair(punctuator?) {
	after := getAfterI()  ; （※此处不能用SubStr只获取1个字符）
	if Debug {
		ToolTip "是否应该输入配对标点是“" FormatString(after) "”"
		Pause
	}
	; 如果后一个字符是空字符 或 空格 或 换行符
	if after = '' or after = ' ' or after ~= '`a)\R$'
		return true
	; 如果给定起始标点 并且 起始标点是‘'’、‘"’、‘‘’或‘“’
	if isSet(punctuator) and punctuator ~= "'|`"|‘|“"
		return false
	; 如果后一个字符是下列字符之一
	switch after {
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
 *   before (string)（可选）光标前一个内容，提供以提高性能
 * 返回值：
 *   (string) 根据情况选择要上屏英文还是中文标点
 */
smartChoice(en, cn, before?) {
	if not isSet(before)
		before := getBeforeI()
	; 如果*不是*（对中文语境应用程序优化开关打开 并且 当前程序是中文语境软件）并且 应该输入英文标点
	if not (BetterCN and WinActive("ahk_group CN")) and shouldEN(before)
		Return en
	; 否则（是中文语境软件，或者应该输入中文标点），如果按键是“.”、“:”或“~” 并且 前一个字符是数字，则应是英文标点
	else if en ~= "\.|:|~" and IsInteger(before)
		Return en
	; 否则，应是中文标点
	else {
		if Tip and cn ~= "，|：|；|？|！|｜|～"
			showTip("中", 1)
		Return cn
	}
}

/*
 * 根据按键方式和所传递的参数数量来选择处理方式
 * 参数：
 *   enKey (string) 按键名称，通常对应英文标点符号
 *   cn (string) （可选）按键对应的中文标点符号
 */
smartType(enKey, cn?) {  ;（※ 由于并非每个调用都会提供cn参数，所以此函数中所有输入cn的情况须进行检查；Send函数中部分标点须用{}包裹。）
	if KeyWait(enKey, "T" String(Interval)) {  ; 短按
		before := getBeforeI()  ; 获取光标前一个内容（※ 不能放在if语句之前，否则可能会导致 KeyWait检测有问题！）
		isSet(cn) ? SendText(smartChoice(enKey, cn, before)) : SendText(enKey)  ; 根据是否有提供中文标点进行输入
	}
	else {  ; 长按
		before := getBeforeI()  ; 获取光标前一个内容
		shouldEN_ := shouldEN(before)
		; ### 长按的第1次输入
		if enKey ~= "\.|,|:"  ; 在英文或数字后可以通过长按这些标点直接输入中文标点
			SendText cn
		else
			(enKey = "!" or enKey = "^") ? Send("{" enKey "}") : Send(enKey)  ; 交给输入法处理（※ 如果出现输入法候选窗口，则后续想通过KeyWait来等待按键弹起是无效的）
		Sleep 1000 * Interval
		; ### 长按的第2次输入
		if GetKeyState(enKey, "P") {  ; 如果按键未弹起
			if shouldEN_ {  ; 如果应该输入英文标点
				if (enKey = '^' or enKey = '_') and not WinExist("ahk_group IME")  ; 如果长按1输入的是“……”或“——”，并且没有输入法候选窗口（有则表示未上屏）
					Send "{BS}"  ; 多输入1个退格键
				Send "{BS}{Text}" enKey  ; 删除长按1时输入的中文标点，并输入1个英文标点
			}
			else {
				Send "{BS}"  ; 删除长按1时输入的中文标点（为了统一不同中文输入法的行为），并输入1个中文标点
				isSet(cn) ? SendText(cn) : SendText(enKey)
			}
			Sleep 1000 * Interval
		}
		; ### 长按的后续输入
		while GetKeyState(enKey, "P") {  ; 当按键未弹起时……
			if shouldEN_
				SendText enKey
			else
				isSet(cn) ? SendText(cn) : SendText(enKey)
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

; 如果 智能标点开关打开，并且不是（存在输入法候选窗口 或 当前软件是 不支持智能标点输入和自动配对功能的应用程序组 或 不适用须要排除的应用程序组） 并且 在中文输入状态。
#HotIf Smart and not (WinExist("ahk_group IME") or WinActive("ahk_group UnSmart") or WinActive("ahk_group Exclude")) and IsCNInputMode()  ; HasIMEWindow()
.:: smartType('.', '。')  ; 长按输入中文标点
,:: smartType(',', '，')  ; 长按输入中文标点
(:: {
	; Send "{Blind}{9 up}{LShift up}"  ; 优化虚拟按键，避免Shift键不释放问题
	if KeyWait(ThisHotkey, "T" String(Interval))  ; 短按
		; 如果不是（中文语境应用程序优化开关打开 并且 当前程序是中文语境软件）并且 应该输入英文标点
		if not (BetterCN and WinActive("ahk_group CN")) and shouldEN() {
			SendText "("
			if not WinActive("ahk_group AutoPair") and shouldPair() {
				SendText ")"
				Send "{Left}"
			}
		}
		else {
			SendText "（"
			if Tip and not (BetterCN and WinActive("ahk_group CN"))
				showTip("前", 1)
			if shouldPair() {
				SendText "）"
				if Tip and not (BetterCN and WinActive("ahk_group CN"))
					showTip("配对", 1)
				Send "{Left}"
			}
		}
	else  ; 长按
		Send ThisHotkey  ; 交给输入法处理
	; reKeyState "LShift"  ; 可自动重复
}
):: {
	; Send "{Blind}{0 up}{LShift up}"
	before := getBeforeI()
	if KeyWait(ThisHotkey, "T" String(Interval)) {  ; 短按
		commit := smartChoice(')', '）', before)
		SendText commit
		if Tip and commit = '）' and not (BetterCN and WinActive("ahk_group CN"))
			showTip("后", 1)
		if isPair(before, commit)  ; 如果 （在不是自动配对的情况下）前一个标点和本次输入的标点是配对标点，则光标回到配对标点中间
			Send "{Left}"
	}
	else {  ; 长按
		if before = '('
			SendText ')'
		else
			Send ThisHotkey  ; 交给输入法处理
	}
	; reKeyState "LShift"
}
_:: {  ; ※ 连按键（为了精简smartType函数的代码，此按键不使用smartType函数）
	; Send "{Blind}{- up}{LShift up}"
	SendText smartType('_', '——')
	; reKeyState "LShift"  ; 可自动重复
}
::: {
	; Send "{Blind}{; up}{LShift up}"
	smartType(':', '：')  ; 长按输入中文标点
	; reKeyState "LShift"  ; 可自动重复
}
":: {
	; Send "{Blind}{' up}{LShift up}"
	before := getBeforeI()
	if KeyWait('"', "T" String(Interval)) {  ; 短按
		; 如果应该输入英文
		if not (BetterCN and WinActive("ahk_group CN")) and shouldEN(before) {
			SendText '"'
			if not WinActive("ahk_group AutoPair") and (before = ' ' or before ~= '`a)\R$' or before = '`t' or before = '') and shouldPair('"') {  ; 如果 应该自动配对，则……
				SendText '"'
				Send "{Left}"
			}
			else if before = '"'  ; 如果 （在不是自动配对的情况下）前一个字符和本次输入的标点是配对标点，则光标回到配对标点中间
				Send "{Left}"
		}
		else {  ; 如果应该输入中文
			Send '"'
			commit := getBeforeI()
			if commit = '“' {
				if Tip
					showTip("前", 1)
				if shouldPair('“') {  ; 如果 应该自动配对，则……
					if Tip
						showTip("配对", 1)
					Send '"{Left}'
				}
			}
			else {
				if Tip
					showTip("后", 1)
				if before = '“'  ; 如果 （在不是自动配对的情况下）前一个字符和本次输入的标点是配对标点，则光标回到配对标点中间
					Send "{Left}"
			}
		}
	}
	else {  ; 长按
		if not (BetterCN and WinActive("ahk_group CN")) and (before = '"' or before = ' ' or before ~= '`a)\R$' or before = '`t' or before = '')
			SendText '"'
		else
			Send ThisHotkey  ; 交给输入法处理
	}
	; reKeyState "LShift"  ; 可自动重复
}
/:: smartType(ThisHotkey)
=:: SendText ThisHotkey  ; ※ 连按键
<:: {
	; Send "{Blind}{, up}{LShift up}"
	if KeyWait(ThisHotkey, "T" String(Interval)) {  ; 短按
		; 如果应该输入英文
		if not (BetterCN and WinActive("ahk_group CN")) and shouldEN()
			SendText "<"
		else {
			SendText "《"
			if shouldPair() {
				SendText "》"
				Send "{Left}"
			}
		}
	}
	else  ; 长按
		Send ThisHotkey  ; 交给输入法处理
	; reKeyState "LShift"  ; 可自动重复
}
>:: {
	; Send "{Blind}{. up}{LShift up}"
	if KeyWait(ThisHotkey, "T" String(Interval)) {  ; 短按
		before := getBeforeI()
		commit := smartChoice('>', '》', before)
		SendText commit
		if commit = '》' and isPair(before, commit)  ; 如果 （在不是自动配对的情况下）前一个字符和本次输入的标点是配对标点，则光标回到配对标点中间
			Send "{Left}"
	}
	else  ; 长按
		Send ThisHotkey  ; 交给输入法处理
	; reKeyState "LShift"  ; 可自动重复
}
`;:: smartType(';', '；')
-:: SendText ThisHotkey  ; ※ 连按键
{:: {
	; Send "{Blind}{[ up}{LShift up}"
	if KeyWait(ThisHotkey, "T" String(Interval)) {  ; 短按
		if not (BetterCN and WinActive("ahk_group CN")) and shouldEN() {
			SendText "{"
			if not WinActive("ahk_group AutoPair") and shouldPair() {
				SendText "}"
				Send "{Left}"
			}
		}
		else {
			SendText "「"
			if shouldPair() {
				SendText "」"
				Send "{Left}"
			}
		}
	}
	else  ; 长按
		Send "{{}"  ; 交给输入法处理
	; reKeyState "LShift"
}
}:: {
	; Send "{Blind}{] up}{LShift up}"
	before := getBeforeI()
	if KeyWait(ThisHotkey, "T" String(Interval)) {  ; 短按
		commit := smartChoice('}', '」', before)
		SendText commit
		if isPair(before, commit)  ; 如果 （在不是自动配对的情况下）前一个标点和本次输入的标点是配对标点，则光标回到配对标点中间
			Send "{Left}"
	}
	else  ; 长按
		if before = '{'
			SendText '}'
		else
		Send "{}}"  ; 交给输入法处理
	; reKeyState "LShift"
}
':: {
	before := getBeforeI()
	if KeyWait('"', "T" String(Interval)) {  ; 短按
		if not (BetterCN and WinActive("ahk_group CN")) and shouldEN(before) {
			SendText "'"
			if not WinActive("ahk_group AutoPair") and (before = ' ' or before ~= '`a)\R$' or before = '`t' or before = '') and shouldPair(ThisHotkey) {  ; 如果 应该自动配对，则……
				SendText "'"
				Send "{Left}"
			}
			else if before = "'"  ; 如果 （在不是自动配对的情况下）前一个字符和本次输入的标点是配对标点，则光标回到成对标点中间
				Send "{Left}"
		}
		else {
			Send "'"
			commit := getBeforeI()
			if commit = "‘" {
				if Tip
					showTip("前", 1)
				if shouldPair('‘') {  ; 如果 应该自动配对，则……
					if Tip
						showTip("配对", 1)
					Send "'{Left}"
				}
			}
			else {
				if Tip
					showTip("后", 1)
				if before = '‘'  ; 如果 （在不是自动配对的情况下）前一个字符和本次输入的标点是配对标点，则光标回到配对标点中间
					Send "{Left}"
			}
		}
	}
	else {  ; 长按
		if not (BetterCN and WinActive("ahk_group CN")) and (before = "'" or before = ' ' or before ~= '`a)\R$' or before = '`t' or before = '')  ; 为了编程时方便连按而设置
			SendText "'"
		else
			Send ThisHotkey  ; 交给输入法处理
	}
}
*:: SendText ThisHotkey  ; ※ 连按键
#:: SendText ThisHotkey  ; ※ 连按键
[:: {  ; ※ 为Markdown优化，英文优先，和“{”键逻辑不同！
	if KeyWait(ThisHotkey, "T" String(Interval)) {  ; 短按
		; 如果不是（中文语境应用程序优化开关打开 并且 当前程序是中文语境软件）
		if not (BetterCN and WinActive("ahk_group CN")) {
			SendText "["  ; 为Markdown优化，英、中文都直接上屏[’
			if not WinActive("ahk_group AutoPair") and shouldPair() {
				SendText "]"
				Send "{Left}"
			}
		}
		else {  ; 否则（中文语境应用程序优化开关打开 并且 当前程序是中文语境软件）
			SendText "【"
			if shouldPair() {
				SendText "】"
				Send "{Left}"
			}
		}
	}
	else  ; 长按
		Send ThisHotkey  ; 交给输入法处理
}
]:: {
	before := getBeforeI()
	if KeyWait(ThisHotkey, "T" String(Interval)) {  ; 短按
		; 如果不是（前一个字符是'【' 或者 中文语境应用程序优化开关打开 并且 当前程序是中文语境软件）
		if not (before = '【' or BetterCN and WinActive("ahk_group CN")) {
			SendText "]"
			if before = '['  ; 如果 （在不是自动配对的情况下）前一个字符和本次输入的标点是配对标点，则光标回到配对标点中间
				Send "{Left}"
		}
		else {
			SendText "】"
			if before = '【'  ; 如果 （在不是自动配对的情况下）前一个字符和本次输入的标点是配对标点，则光标回到配对标点中间
				Send "{Left}"
		}
	}
	else {  ; 长按
		if before = '['
			SendText ']'
		else
			Send ThisHotkey  ; 交给输入法处理
	}
}
`:: smartType(ThisHotkey)
+:: SendText ThisHotkey  ; ※ 连按键
&:: smartType(ThisHotkey)
?:: {
	; Send "{Blind}{/ up}{LShift up}"
	smartType('?', '？')  ; 长按可通过输入法出中文标点
}
!:: {
	; Send "{Blind}{1 up}{RShift up}"
	smartType('!', '！')  ; 长按可通过输入法出中文标点
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
	smartType(ThisHotkey, '……')
}
~:: {  ; ※ 连按键
	; Send "{Blind}{`` up}{RShift up}"
	smartType('~', '～')
}
$:: {
	; Send "{Blind}{4 up}{RShift up}"
	smartType('$', '￥')
}

global HolyShift := true  ; 标记是否只按下了Shift键，是则为 true

; 如果不存在输入法候选窗口，并且当前软件不是 不适用须要排除的应用程序组 或 文件管理器且活动控件不是输入框（※必须全部条件包含在not里面）
#HotIf not (WinExist("ahk_group IME") or WinActive("ahk_group Exclude") or (WinActive("ahk_group FileManager") and not ControlGetClassNN(ControlGetFocus("A")) ~= "Ai)Edit"))  ; or hasMS_IMEWindow()
~+LButton::
~+RButton::
~+MButton::
~+XButton1::
~+XButton2::
~+WheelDown::
~+WheelUp::
~+WheelLeft::
~+WheelRight::  ; 以上为Shift键+任何鼠标键
~*Shift:: {  ; 防止仅按下 Shift键+任何鼠标键 或 其它的修饰键+Shift键 时，最后释放Shift键会触发漂移的问题。
	Thread "Priority", 1  ; 须要提高此线程的优先级，丢弃长按产生的重复Shift按键事件，否则如果最后释放Shift键，会触发Shift热键使HolyShift变成true
	global HolyShift := false
	if GetKeyState("Ctrl", "P") or GetKeyState("Alt", "P")
		KeyWait "Shift"  ; （KeyWait函数在等待时可通过热键等启动新线程）
}
~LShift::
~RShift:: {  ; 如果只按下Shift键，则HolyShift为true
	global HolyShift := true
}
; 英/中常用标点变换，处理有配对标点符号时按情况变换单个或者成对标点。
~LShift up:: {  ; 当左Shift键弹起并且之前没有按过其它键时触发
	if HolyShift and A_PriorKey = "LShift"
		switch origin := getBeforeI() {  ; 获取光标前一个内容（将要被变换的标点）
			case '。', '.', '℃', '°', '℉': drift(origin, '。', '.')

			case '，', ',', '∈', '⊆', '⊂': drift(origin, '，', ',')

			case '(', '〔', '〘': driftPair(origin, '（')
			case '（': driftPair('（', '(')

			case ')', '〕', '〙': Send "{BS}{Text}）"
				if Tip
					showTip("后", 1)
			case '）': SendText("!"), Send("{Left}{BS}{Text})"), Send("{Del}")

			case '_': Send "{BS}{Text}——"
			case '—': Send "{BS 2}{Text}_"
			case '∪', '∩': Send "{BS}{Text}_"

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

			case '^': Send "{BS}{Text}……"
			case '…': Send "{BS 2}{Text}^"
			case '⌘', '⌥', '⇧', '↩': Send "{BS}{Text}^"

			case '~', '～', 'Δ', 'Ω', 'Θ', 'Λ', 'Φ': drift(origin, '~', '～')

			case '$', '￥', '＄', '¥', '€', '£', '¢', '¤': drift(origin, '$', '￥')
		}
}
; 扩展标点变换。处理有配对标点符号时可快速变换单个或者成对标点。
~RShift up:: {  ; 当右Shift键弹起并且之前没有按过其它键时触发
	if HolyShift and A_PriorKey = "RShift"
		switch origin := getBeforeI() {  ; 获取光标前一个内容（将要被变换的标点）
			case '。', '.', '℃', '°', '℉': drift(origin, '℃', '°', '℉')

			case '，', ',', '∈', '⊆', '⊂': drift(origin, '∈', '⊆', '⊂')

			case '(', '（', '〘': driftPair(origin, '〔')
			case '〔': driftPair('〔', '〘')

			case ')', '）', '〕', '〙': drift(origin, '〕', '〙')

			case '_', '∪', '∩': drift(origin, '∪', '∩')
			case '—': Send "{BS 2}{Text}∪"

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

			case '^', '⌘', '⌥', '⇧', '↩': drift(origin, '⌘', '⌥', '⇧', '↩')
			case '…': Send "{BS 2}{Text}⌘"

			case '~', '～', 'Δ', 'Ω', 'Θ', 'Λ', 'Φ': drift(origin, 'Δ', 'Ω', 'Θ', 'Λ', 'Φ')

			case '$', '￥', '＄', '¥', '€', '£', '¢', '¤': drift(origin, '＄', '¥', '€', '£', '¢', '¤')
		}
}
