/**
 * @description FinalD/终点 输入法插件——中英文标点及扩展符号智能输入和快速变换程序。
 * @attention 编辑此文件后必须保存为 UTF-8 with BOM 编码格式。
 * @see https://github.com/Lantaio/IME-booster-FinalD
 * @author Lantaio Joy
 * @version 见下面的全局变量 Version，或运行此程序后按左 Win+Alt+. 查看。
 * @modified 2026/9/4
 */
#Requires AutoHotkey >=v2.0.26  ; 此程序只能在 >=v2.0.26版的AutoHotkey正常运行
#SingleInstance  ; 只允许运行1个实例
#UseHook  ; 使用键盘钩子，相当于在每个热键前面使用$前缀，以避免Send函数触发它自己
Critical "On"  ; 将所有线程默认设置为关键线程（不可中断），使短按按键可以按顺序执行，并缓存未处理的按键
ProcessSetPriority "High"  ; 将此程序的进程优先级设置为高
CoordMode "Caret", "Screen"  ; 设置CaretGetPos函数的坐标模式为相对于屏幕
CoordMode "Mouse", "Screen"  ; 设置MouseGetPos函数的坐标模式为相对于屏幕
CoordMode "ToolTip", "Screen"  ; 设置ToolTip函数的坐标模式为相对于屏幕
SetTitleMatchMode "RegEx"  ; 设置窗口标题的匹配模式为正则模式（此模式默认区分大小写）
KeyHistory 100
; OnError errorHandler  ; 指定错误处理函数（避免不存在当前窗口时会弹出错误信息的问题）

Global Version := "v9.79.266`n　　　 © 2024~2026"  ; 此程序的版本号
A_ScriptName := "FinalD/终点 输入法插件"  ; 此程序的名称

#Include <Caret>  ; 和光标有关的函数
; #Include <Debugger>  ; 和调试有关的函数
#Include <IME>  ; 和输入法有关的函数
#Include <Selection>  ; 和选择有关的函数
; #Include <YAML>  ; 处理YAML数据文件的类
#Include "MySettings\AppGroup.ahk"  ; 引入用户自定义的程序组信息
#Include "MySettings\Shortcut.ahk"  ; 引入用户自定义的快捷键信息

/**
 * @description 错误处理函数。
 * @param {Object} ex 错误对象。
 * @param {Integer} mode 错误的模式。
 * @returns {Boolean} `true`，抑制默认错误对话框和任何剩余的错误回调。
 */
errorHandler(ex, mode) {
	return true
}

/**
 * @description 基本的热键回调函数，直接将按键发送给系统处理。
 * @param {String} key 热键名称。
 */
keySender(key) {
	Send "{Blind}" key
}
/**
 * @description 基本的特殊热键回调函数，直接将按键发送给系统处理。
 * @param {String} key 热键名称。
 */
xkeySender(key) {
	Send "{Blind}{" key "}"
}
; ~~~~~~ Optional Hotkeys Begin ~~~~~~
; 这部分热键为非必须热键，如果和你使用的其它AHK脚本有冲突，可以将这部分代码注释或删除。但这将失去按键按顺序执行的功能，当输入太快时顺序可能会出现错乱。
nums := "0123456789"
Loop Parse, nums  ;添加数字热键，使按键可以按顺序执行
	Hotkey A_LoopField, keySender
letters := "abcdefghijklmnopqrstuvwxyz"
Loop Parse, letters  ;添加小写字母热键，使按键可以按顺序执行
	Hotkey A_LoopField, keySender
Loop Parse, letters  ;添加大写字母热键，使按键可以按顺序执行
	Hotkey '+' A_LoopField, keySender
; ~~~~~~ Optional Hotkeys End ~~~~~~

Global Commit := ''  ; 刚上屏的标点
Global Prev := ''  ; 光标前1个内容
/**
 * @description 在合适的情况下输入与给定的标点（`punct`参数）配对的后标点（如果有的话）。
 * @param {String} punct 给定的标点。
 */
smartPair(punct) {
	switch punct {
		case '(', '[', '{':
			if not WinActive("ahk_group AutoPair") and shouldPair(punct) {  ; 如果 是英文前标点 并且 *不是*自动配对功能程序组 并且 应该输入配对的后标点
				if Tip
					showTip("Pair", 1)
				SendText getPair(punct)  ; 输入对应的后标点
				Send "{Left}"  ; 光标回到配对标点中间
			}
		case '"', "'":
			if not WinActive("ahk_group AutoPair") and (Prev = ' ' or Prev ~= '`a)\R$' or Prev = '`t' or Prev = '') and shouldPair(punct) {  ; 如果 是英文前标点 并且 *不是*自动配对功能程序组 并且 应该输入配对的后标点
				if Tip
					showTip("Pair", 1)
				SendText getPair(punct)  ; 输入对应的后标点
				Send "{Left}"  ; 光标回到配对标点中间
			}
		case '“', '‘':
			if Commit = '“' or Commit = '‘'  ; 如果 刚输入的是中文引号前标点
				if shouldPair(Commit) {  ; 如果 应该自动配对，则……
					if Tip
						showTip("配对", 1)
					if Commit = '“'
						Send "`"{Left}"  ; 交给输入法处理
					else
						Send "'{Left}"  ; 交给输入法处理
				}
		case '（', '【', '「', '《':  ; 此处只需要检查可通过按键直接输入的标点
			if shouldPair(punct) {
				if Tip and punct = '（'
					showTip("配对", 1)
				SendText getPair(punct)
				Send "{Left}"
			}
	}
}
/**
 * @description 借助剪贴板获取光标前一个内容（字符）。
 * @returns {String} 如果光标前有内容，返回光标前一个内容（字符），否则返回空字符。
 */
; FIXME: 需要添加检测光标前的内容是图片的情况。
getPrev() {
	clipCache := ClipboardAll(), A_Clipboard := ''  ; 临时寄存剪贴板内容，清空剪贴板
	Send "+{Left}^c"  ; 选取并复制当前光标前一个内容
	; Sleep 20  ; 暂停一下以等待反应慢的程序完成选取
	; Send "^c"  ; 复制所选内容
	ClipWait 0.5, 1  ; 等待剪贴板更新
	; 获取剪贴板中的字符（一般是光标前一个字符），计算它的长度
	clip := A_Clipboard, clipLen := StrLen(clip)
/*	if Debug {
		ToolTip "前1个字符是“" FormatString(clip) "”，长度：" clipLen "，编码：" Ord(clip) "`r`n最后1个字符是“" FormatString(SubStr(clip, -1)) "”"
		; ListVars  ; 调试时查看变量值
		Pause
	}
*/
	; 如果复制的字符长度为1 或 是回车換行符（行首）或 是emoji
	if clipLen = 1 or clip ~= '`a)^\R$' or IsEmoji(clip) {
		Send "{Right}"  ; 光标回到原来的位置
		; Sleep 20  ; 暂停一下以等待光标完成向右移动
		if WinActive("ahk_group Slow")  ; 如果是反应慢的应用，增加暂停时间
			Sleep 20
	} else if clip = '' and WinActive(" - Word$") {  ; 否则，如果当前软件是Word或PowerPoint
		A_Clipboard := ''  ; 清空剪贴板
		Send "+{Left}^c"  ; 选取并复制光标前2个内容
		; Sleep 20  ; 暂停一下以等待反应慢的程序完成选取
		; Send "^c"  ; 复制所选内容
		ClipWait 0.3, 1  ; 等待剪贴板更新
		; 获取剪贴板中的字符，即光标前2个字符
		clip2 := A_Clipboard
/*		if Debug {
			ToolTip "Office前2个字符是“" FormatString(clip2) "”，长度：" clipLen "，编码：" Ord(clip2) "`r`n最后1个字符是“" FormatString(SubStr(clip2, -1)) "”"
			; ListVars  ; 调试时查看变量值
			Pause
		}
*/
		if not clip2 = '' {
			Send "{Right}"  ; 光标回到原来的位置
			; Sleep 20  ; 暂停一下以等待光标完成向右移动
		}
	}
	; 恢复原来的剪贴板内容
	A_Clipboard := clipCache, clipCache := ''
	if clip = '…'
		clip := '……'
	else if clip = '—'
		clip := '——'
	return clip
}
/**
 * @description 借助剪贴板获取光标后一个内容（字符）。
 * @returns {String} 如果光标后有内容，返回光标后一个内容（字符），否则返回空字符。
 */
getNext() {
	clipCache := ClipboardAll(), A_Clipboard := ''  ; 临时寄存剪贴板内容，清空剪贴板
	Send "+{Right}^c"  ; 选取并复制当前光标后一个字符
	; Sleep 20  ; 暂停一下以等待反应慢的程序完成选取
	; Send "^c"  ; 复制所选内容
	ClipWait 0.3, 1  ; 等待剪贴板更新
	; 获取剪贴板中的字符，即光标后一个字符，计算它的长度，然后恢复原来的剪贴板内容
	clip := A_Clipboard, clipLen := StrLen(clip), A_Clipboard := clipCache, clipCache := ''
/*	if Debug {
		ToolTip "后1个字符是“" FormatString(clip) "”，长度：" clipLen "，编码：" Ord(clip) "`r`n最后1个字符是“" FormatString(SubStr(clip, -1)) "”"
		; ListVars  ; 调试时查看变量值
		Pause
	}
*/
	; 如果复制的字符长度为1 或 是回车換行符（行末）或 是emoji
	if clipLen = 1 or clip ~= '`a)^\R$' or IsEmoji(clip) {
		Send "{Left}"  ; 光标回到原来的位置
		; Sleep 20  ; 暂停一下以等待光标完成向左移动
		if WinActive("ahk_group Slow")  ; 如果是反应慢的软件，增加暂停时间
			Sleep 20
	}
	return clip
}
/**
 * @description 获取与给定的标点（`punct`参数）配对的后标点。也可检查给定的标点（`punct`参数）是否为有配对的后标点的前标点。
 * @param {String} punct 给定的标点，检查其是否有配对的后标点。
 * @returns {String} 与给定的标点（`punct`参数）配对的后标点。如果没有，返回空字符。
 */
getPair(punct) {
	switch punct {
		case '(': return ')'
		case '"': return '"'
		case "'": return "'"
		case '{': return '}'
		case '[': return ']'
		case '<': return '>'
		case '（': return '）'
		case '“': return '”'
		case '‘': return '’'
		case '「': return '」'
		case '『': return '』'
		case '【': return '】'
		case '〖': return '〗'
		case '《': return '》'
		case '〈': return '〉'
		case '｛': return '｝'
		case '［': return '］'
		case '〔': return '〕'
		case '〘': return '〙'
	}
	return ''
}
/**
 * @description 检测给定的前标点（`front`参数）是否已存在配对的后标点。
 * @param {String} front 给定的前标点，检测其是否已存在配对的后标点。
 * @returns {Boolean} 如果给定的前标点（`front`参数）已存在配对的后标点，返回`true`，否则返回`false`。
 */
hasPair(front) {
	back := getNext()  ; 获取光标后一个内容（字符）
	return isPair(front, back)
}
/**
 * @description 检测`front`和`back`两个参数是否是成对的标点。
 * @param {String} front 前内容（标点），检查其是否和`back`参数是成对的标点。
 * @param {String} back 后内容（标点），检查其是否和`front`参数是成对的标点。
 * @returns {Boolean} 如果`front`和`back`两个参数是成对的标点，返回`true`，否则返回`false`。
 */
isPair(front, back) {
	if getPair(front) = back
		return true
	return false
}
/**
 * @description 检测给定的字符（`char`参数）是不是拉丁字符。
 * @param {String} char 给定的字符，检测其是不是拉丁字符。
 * @returns {Boolean} 如果给定的字符（`char`参数）是拉丁字符，返回`true`，否则返回`false`。
 */
isLatin(char) {
/* 	if Debug {
		ToolTip "是否应该输入西文标点是“" FormatString(Prev) "”"
		Pause
	}
 */
	; 返回`char`参数是不是拉丁字符的判断结果
	if Ord(char) < 0x2000
		return true
	else
		return false
}
/**
 * @description 恢复指定按键（`key`参数）正确的逻辑状态，使其逻辑状态与物理状态一致。
 * @param {String} key 需要恢复逻辑状态的按键名称。
 */
reKeyState(key) {
	if GetKeyState(key, "P") {
		Send "{" key " down}"
		; Sleep 50
	}
}
/**
 * @description 将给定的标点（`punct`参数）输出到屏幕，并在必要时显示提示信息。
 * @param {String} punct 给定的标点。
 */
output(punct) {
	switch punct {
		case '“', '‘':
			if punct = '“'
				Send '"'  ; 交给输入法处理
			else
				Send "'"  ; 交给输入法处理
			Global Commit := getPrev()
			if Commit = '“' or Commit = '‘' {  ; 如果 刚输入的是中文引号前标点
				if Tip
					showTip("前", 1)
			} else if Tip  ; 否则 刚输入的是中文引号后标点
				showTip("后", 1)
		case '（', '）', '【', '】', '「', '」', '《', '》':
			if Tip
				if punct = '（'
					showTip("前", 1)
				else if punct = '）'
					showTip("后", 1)
			SendText punct
		default:  ; 其他中、英文单标点
			if Tip and InStr("(`"'[{", punct)
				showTip("En", 1)
			if Tip and InStr("，：；？！｜～", punct)
				showTip("中", 1)
			SendText punct
	}
}
/**
 * @description 根据所给定的前标点（`front`参数）和光标后的内容，判断是否应该输入配对的后标点。
 * @param {String} front 给定的前标点，用于分类处理。
 * @returns {Boolean} 如果应该输入配对的后标点，返回`true`，否则返回`false`。
 */
shouldPair(front) {
	next := getNext()  ; （⚠ 此处不能用SubStr只获取1个字符）
/*	if Debug {
		ToolTip "是否应该输入配对标点是“" FormatString(next) "”"
		Pause
	}
*/
	; 如果后一个字符是空字符 或 空格 或 换行符
	if next = '' or next = ' ' or next ~= '`a)\R$'
		return true
	; 如果前标点是‘"’、‘'’、‘“’或‘‘’
	if InStr("`"'“‘", front)
		return false
	if InStr("(`"'[{（“‘【「《", front) and isPair(front, next)  ; 如果前标点和后一个字符是配对标点
		return false
	; 如果后一个字符是下列字符之一
	switch next {
		case ',', '.', ':', ';', ')', ']', '}', '>', '?', '!': return true
		case '，', '。', '：', '；', '？', '！', '）', '］', '】', '〗', '〕', '〙', '｝', '》', '〉': return true
	}
	return false
}
/**
 * @description 根据当前的智能模式和具体情况，确定要上屏按键所对应的英文标点还是中文标点。
 * @param {String} en 按键所对应的英文标点。
 * @param {String} cn 按键所对应的中文标点。
 * @returns {String} 如果应该上屏英文标点，返回`en`参数，否则返回`cn`参数。
 */
smartChoice(en, cn) {
	if en = cn
		return en
	Global Prev := getPrev()
	if AI {  ; 智慧模式
		; 如果*不是* 当前程序是中文语境软件 并且 前一个内容是拉丁字符，则应是英文标点
		if not WinActive("ahk_group CN") and isLatin(Prev)
			Return en
		; 否则（是中文语境软件，或者应该输入中文标点），如果按键是“.”、“:”或“~” 并且 前一个字符是数字，则应是英文标点
		else if (en = '.' or en = ':' or en = '~') and IsInteger(Prev)
			Return en
		else  ; 否则，应是中文标点
			Return cn
	} else {  ; 操控模式
		; 如果*不是* （（前一个内容是换行符 或 空）并且 当前程序是中文语境软件） 并且 前一个内容是拉丁字符
		if not ((Prev ~= '`a)\R$' or Prev = '') and WinActive("ahk_group CN")) and isLatin(Prev)
			Return en
		else  ; 否则，应是中文标点
			Return cn
	}
}
/**
 * @description 根据按键方式和是否有提供中文标点参数来智能输入中/英文标点符号。
 * * 短按 根据光标前的内容智能上屏中文标点或者英文标点；
 * * 妙按 反转短按时的输入逻辑，例如：如果短按时会上屏英文标点，则妙按时上屏中文标点；
 * * 长按 输入逻辑再次反转，删除妙按时上屏的标点，然后连续上屏短按时上屏的标点。
 * 然后连续上屏短按时应输入的标点。
 * @param {String} en 按键名称，也是此按键所对应的英文标点。
 * @param {String} [cn] （可选）按键所对应的中文标点。
 */
; FIXME: 将妙按的输出推迟到检测是否长按之后，以避免有自动配对功能的软件的问题。
smartType(en, cn?) {  ; （Send函数中[^+!#{}]标点须用{}包裹。）
	if not isSet(cn)
		cn := en
	if KeyWait(en, "T" String(Interval)) {  ; # 短按
		if en = cn  ; 如果英文标点和中文标点相同，直接输出
			SendText en
		else {  ; 英文标点和中文标点不同
			choice := smartChoice(en, cn)  ; （⚠ 由于getPrev函数的执行时间可能会超过0.5秒，因此不能放在if语句之前，否则不能正确检测是短按还是长按）
			if choice = en {  ; 如果 应该输入英文标点
				SendText en
				smartPair(en)  ; 自动配对英文标点
			} else {  ; 应该输入中文标点
				output(cn)
				smartPair(cn)  ; 自动配对中文标点
			}
		}
	} else {  ; 妙按 和 长按
		Thread "Priority", 1  ; 提高线程优先级，使此线程不会被后面的低优先级线程中断，并丢弃未处理的按键
		Critical "Off"
		; # 妙按
		choice := smartChoice(en, cn)
		if Rime {  ; 如果是Rime输入法
			if choice = en {  ; 本来应该输入英文标点，变成输入中文标点
				if InStr("/&|@%^$", en)  ; 如果是Rime功能触发键
					en = '^' ? Send("{" en "}") : Send(en)  ; 交给输入法处理
				else  ; 不是Rime功能触发键
					output(cn)  ; （后面#1再作配对处理）
			} else {  ; 本来应该输入中文标点，变成输入英文标点
				if InStr("/&|@%^$", en)  ; 如果是Rime功能触发键
					en = '^' ? Send("{" en "}") : Send(en)  ; 交给输入法处理
				else  ; 否则（不是Rime功能触发键）
					SendText en  ; （后面#1再作配对处理）
			}
		} else {  ; 非Rime输入法
			if en = cn  ; 如果英文标点和中文标点相同，直接输出
				SendText en
			else if choice = en  ; 本来应该输入英文标点，变成输入中文标点
				output(cn)
			else  ; 本来应该输入中文标点，变成输入英文标点
				SendText en
		}
		Sleep 1000 * Interval
		; # 长按的第1次输入
		if GetKeyState(en, "P") {  ; 如果按键未弹起
			if en = cn {  ; 如果英文标点和中文标点相同，直接输出
				Send "{BS}{Text}" en
			} else if choice = en {  ; 如果应该输入英文标点
				if (en = '^' or en = '_') and not WinExist("ahk_group IME")  ; 如果妙按输入的是“……”或“——”，并且没有输入法候选窗口（有则表示未上屏）
					Send "{BS}"  ; 多输入1个退格键
				Send "{BS}{Text}" en  ; 删除妙按输入的中文标点（或者关闭输入法候选窗口），并输入1个英文标点（此操作统一不同中文输入法的行为）
			} else {  ; 如果应该输入中文
				Send "{BS}"  ; 删除妙按时输入的英文标点（或者关闭输入法候选窗口）（此操作统一不同中文输入法的行为）
				output(cn)
			}
			Sleep 1000 * Interval
		} else {  ; # 妙按后没有长按（#1）
			if en = cn  ; 如果英文标点和中文标点相同，直接返回（⚠ 此处假设中英文相同标点不存在配对标点）
				return
			else if choice = en  ; ⚠ 如果妙按时输入中文
				smartPair(cn)  ; 自动配对中文标点
			else  ; 否则 如果妙按时输入英文
				smartPair(en)  ; 自动配对英文标点
			return
		}
		; # 长按的后续输入
		while GetKeyState(en, "P") {  ; 当按键未弹起时
			if choice = en  ; 如果 应该输入英文标点
				SendText en
			else if cn = '“' or cn = '‘'  ; 否则 如果 是中文引号
				Send en  ; 交给输入法处理
			else  ; 否则 是其它中文标点
				SendText cn
			Sleep 1000 * Interval
		}
	}
}
/**
 * @description 显示给定的提示信息（`info`参数），并在持续一段时间（`sec`参数）后关闭此提示信息。
 * @param {String} info 要显示的提示信息。
 * @param {Float} sec 持续此时长后关闭（单位为秒）。
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
; 如果 聪明标点开关打开，并且不是（存在输入法候选窗口 或 当前软件是 不支持聪明标点输入和自动配对功能的应用程序组 或 不适用须要排除的应用程序组）  ; 并且 在中文输入状态。
#HotIf Smart and not (WinExist("ahk_group IME") or WinActive("ahk_group UnSmart") or WinActive("ahk_group Exclude"))  ; and IsCNInputMode()
.:: smartType('.', '。')
,:: smartType(',', '，')
(:: {
	Send "{Blind}{9 up}{LShift up}"
	smartType('(', '（')
	reKeyState "LShift"  ; 恢复Shift键的物理状态
}
):: {
	Send "{Blind}{0 up}{LShift up}"
	smartType(')', '）')
	reKeyState "LShift"  ; 恢复Shift键的物理状态
}
_:: {  ; （连按键）
	Send "{Blind}{- up}{LShift up}"
	smartType('_', '——')
	reKeyState "LShift"  ; 恢复Shift键的物理状态
}
::: {
	; Send "{Blind}{; up}{LShift up}"
	smartType(':', '：')  ; 长按输入中文标点
}
":: {
	Send "{Blind}{' up}{LShift up}"
	smartType('"', '“')
	reKeyState "LShift"  ; 恢复Shift键的物理状态
}
/:: smartType(ThisHotkey)
=:: SendText ThisHotkey  ; （连按键）
<:: {
	Send "{Blind}{, up}{LShift up}"
	smartType('<', '《')
	reKeyState "LShift"  ; 恢复Shift键的物理状态
}
>:: {
	Send "{Blind}{. up}{LShift up}"
	smartType('>', '》')
	reKeyState "LShift"  ; 恢复Shift键的物理状态
}
`;:: smartType(';', '；')
-:: SendText ThisHotkey  ; （连按键）
{:: {
	Send "{Blind}{[ up}{LShift up}"
	smartType('{', '「')
	reKeyState "LShift"  ; 恢复Shift键的物理状态
}
}:: {
	Send "{Blind}{] up}{LShift up}"
	smartType('}', '」')
	reKeyState "LShift"  ; 恢复Shift键的物理状态
}
':: smartType("'", '‘')
*:: SendText ThisHotkey  ; （连按键）
#:: SendText ThisHotkey  ; （连按键）
[:: smartType('[', '【')
]:: smartType(']', '】')
`:: smartType(ThisHotkey)
+:: SendText ThisHotkey  ; （连按键）
&:: {
	Send "{Blind}{7 up}{LShift up}"
	smartType(ThisHotkey)
	reKeyState "LShift"  ; 恢复Shift键的物理状态
}
?:: {
	Send "{Blind}{/ up}{LShift up}"
	smartType('?', '？')
	reKeyState "LShift"  ; 恢复Shift键的物理状态
}
!:: {
	Send "{Blind}{1 up}{RShift up}"
	smartType('!', '！')
	reKeyState "RShift"  ; 恢复Shift键的物理状态
}
\:: smartType('\', '、')
|:: {
	Send "{Blind}{\ up}{LShift up}"
	smartType('|', '｜')
	reKeyState "LShift"  ; 恢复Shift键的物理状态
}
@:: {
	Send "{Blind}{2 up}{RShift up}"
	smartType(ThisHotkey)
	reKeyState "RShift"  ; 恢复Shift键的物理状态
}
%:: {
	Send "{Blind}{5 up}{RShift up}"
	smartType(ThisHotkey)
	reKeyState "RShift"  ; 恢复Shift键的物理状态
}
^:: {
	Send "{Blind}{6 up}{LShift up}"
	smartType('^', '……')
	reKeyState "LShift"  ; 恢复Shift键的物理状态
}
~:: {  ; （连按键）
	Send "{Blind}{`` up}{RShift up}"
	smartType('~', '～')
	reKeyState "RShift"  ; 恢复Shift键的物理状态
}
$:: {
	Send "{Blind}{4 up}{RShift up}"
	smartType('$', '￥')
	reKeyState "RShift"  ; 恢复Shift键的物理状态
}

Global ENG_GRC_MAP := getDriftMap(A_ScriptDir "\MySettings\ENG_GRC.yaml")  ; 获取英文字母↔希腊字母对应关系映射表
Global NUMBER_MAP := getDriftMap(A_ScriptDir "\MySettings\Number.yaml")  ; 获取数字漂移配置表
Global SYMBOL_MAP := getDriftMap(A_ScriptDir "\MySettings\Symbol.yaml")  ; 获取标点符号漂移配置表
/**
 * @description 标点符号循环漂移函数。
 * 删除光标前原来的标点符号（`origin`参数），并输入漂移数组中（`list`参数）排在`origin`后面的标点符号。如果`origin`不在数组中 或者 是数组中最后1个标点符号，则输入数组中第1个标点符号。
 * @param {String} origin 原来的标点符号。
 * @param {Array} list 标点符号漂移数组。
 */
; TODO: 尝试通过output函数和smartPair函数精简此函数。
; TODO: 漂移多个字符。
drift(origin, list*) {
	i := 0
	loop list.length
		if origin = list[A_Index] {  ; 如果原来的标点符号在漂移数组中
			i := A_Index
			break
		}
	if i = 0 or i = list.length  ; 如果`origin`不在数组中 或者 是数组中最后1个标点符号
		i := 1  ; 定位数组中第1个标点符号
	else
		i += 1  ; 定位数组中`origin`的下1个标点符号
	if origin = '……' or origin = '——'  ; 如果原来的标点是‘……’或‘——’
		Send "{BS}"  ; 多输入1个退格键
	if Smart and getPair(origin) and hasPair(origin) {  ; 如果（表格）兼容模式*没有*开启 并且 原来的标点是成对标点的前标点 并且 原来的标点已有配对的后标点
		Send "{Del}{Text}!"  ; 先删除后标点，并输入感叹号防止软件过度自动化
		Send "{Left}{BS}{Text}" list[i]  ; 光标归位，删除原来的前标点，输入漂移标点
		newPair := getPair(list[i])  ; 获取漂移标点的配对标点（如果有的话）
		if newPair {  ; 如果新标点有配对标点
			if Tip and InStr("”’）］｝〉", newPair)
				showTip("配对", 1)
			SendText newPair  ; 输入配对标点
			Send "{Del}{Left}"  ; 删除之前用于防止软件过度自动化的感叹号，光标回到配对标点中间
		} else {  ; 否则（新标点没有配对标点）
			Send "{Del}"  ; 删除之前用于防止软件过度自动化的感叹号
		}
	} else {  ; 否则（原来的标点没有配对的后标点）
		if Tip
			switch list[i] {
				case '，', '：', '；', '？', '！', '｜', '～', '＄', '／', '＼': showTip("中", 1)
				case '“', '‘', '（', '［', '｛', '〈': showTip("前", 1)
				case '”', '’', '）', '］', '｝', '〉': showTip("后", 1)
			}
			; FIXME: 优化防止软件过度自动化的处理范围。
		if InStr("`"')]}", list[i]) {	; 如果新标点是英文后标点
			SendText "!"  ; 输入感叹号防止软件过度自动化
			Send "{Left}{BS}{Text}" list[i]  ; 光标归位，漂移标点符号
			Send "{Del}"  ; 删除之前用于防止软件过度自动化的感叹号
		} else  ; 否则（新标点不是英文后标点，可能是中英文标点符号，甚至是扩展符号）
			Send "{BS}{Text}" list[i]  ; 漂移标点符号
	}
}
/**
 * @description 解析 YAML 中的字符串，去除外层引号。
 * YAML 中键和值通常写成 '。' 或 "." 的形式；这里去掉外层引号，避免后续把实际符号当作带引号文本处理。
 * @param {String} value 需要处理的字符串。
 * @returns {String} 去除引号后的原始字符内容。
 */
parseYAMLScalar(value) {
	value := Trim(value)  ; 去掉行首行尾空白，使得像 "  '。'  " 这种格式也能正常处理
	if value = ''  ; 空字符串直接返回，避免后面索引出错
		return ''
	if (SubStr(value, 1, 1) = "'" and SubStr(value, -1) = "'") or (SubStr(value, 1, 1) = '"' and SubStr(value, -1) = '"')
		return SubStr(value, 2, StrLen(value) - 2)  ; 去掉外层的一对引号，保留真实标点字符本身
	return value  ; 如果本来就不是带引号的值，就直接返回原始内容
}
/**
 * @description 读取并反序列化给定的 YAML 配置文件。
 * 它会逐行扫描 YAML，识别 LShift/RShift 章节和其后的键值列表，
 * 然后将每个键映射到字符串数组，用于实际的字符漂移循环。
 * @param {String} filePath 配置文件路径。
 * @returns {Map} 由左右 Shift 配置组成的漂移映射。
 */
getDriftMap(filePath) {
	driftMap := Map("LShift", Map(), "RShift", Map())  ; 初始化两套映射：左右Shift分别保存各自的漂移列表
	if !FileExist(filePath)  ; 如果文件不存在，就返回空配置，不影响其它功能
		return driftMap
	text := FileRead(filePath, "UTF-8")  ; 把 YAML 全部读成字符串
	; if text = ''  ; 空文件直接返回空配置
	; 	return driftMap
	section := ''  ; 当前处于哪个分组：LShift / RShift
	for line in StrSplit(text, "`n", "`r") {  ; 逐行扫描，兼容 Windows 的 CRLF 和 LF 两种换行方式
		line := Trim(line)  ; 去掉首尾空白，方便判断注释和章节头
		if line = '' or RegExMatch(line, '^\s*#')  ; 跳过空行和注释行
			continue
		if RegExMatch(line, '^(LShift|RShift)\s*:', &m) {  ; 识别 "LShift:" / "RShift:" 章节头
			section := m[1]  ; 切换到当前章节
			continue
		}
		if section = '' || !InStr(line, ': ')  ; 只处理当前分组下的键值列表
			continue
		keyText := Trim(SubStr(line, 1, InStr(line, ': ') - 1))  ; 取出键名，例如 "." 或 "?"
		key := parseYAMLScalar(keyText)  ; 去掉键名周围引号，得到真实符号
		if !InStr(line, '[ ')
			listText := Trim(SubStr(line, InStr(line, ': ') + 1, InStr(line, ' #') ? InStr(line, ' #') - 1 : StrLen(line)))  ; 如果没有方括号，取出冒号后面至注释（如果有的话）之前的内容作为列表内容
		else
			listText := Trim(SubStr(line, InStr(line, '[ ') + 1, InStr(line, ' ]') - InStr(line, '[ ') - 1))  ; 取出列表内容，例如 "'。', '.'"
		list := []  ; 这个键对应的漂移顺序列表
		if listText != '' {  ; 如果列表不是空的才继续解析
			for item in StrSplit(listText, ', ') {  ; 按逗号拆分列表项
				value := parseYAMLScalar(Trim(item))  ; 每一项也去掉引号形成真实字符
				if value != ''  ; 跳过空项，避免把空字符串写进列表
					list.Push(value)
			}
		}
		driftMap[section].Set(key, list)  ; 把 "键 -> 列表" 保存进对应的 Map 中
	}
	return driftMap  ; 返回整个配置对象，供后续查表使用
}
/**
 * @description 根据 所触发的热键（`hotkey`参数）和 光标前的内容（`origin`参数）返回`hotkey`热键的配置表中`origin`标点符号所在的键的值列表。
 * @param {("LShift"|"RShift"|"<#LShift"|"<#RShift"|">#LShift"|">#RShift")} hotkey 触发的热键
 * @param {(String)} origin 光标前的内容（标点符号）
 * @returns {(Array)} hotkey热键的配置表中origin标点符号所在的键的值列表（如果有的话，没有则返回空数组），例如 [ '。', '.' ] 或 [ '℃', '°', '℉' ]
 * @note 关键点在于：origin 不是按键本身，而是当前光标前的内容（标点符号）。
 *   所以不能直接用 origin 去索引 YAML 的键名；需要先在所有 Shift 配置里
 *   搜索哪个按键列表包含这个字符，再根据触发的 Shift 方向选择对应的同键列表。
 * @example
 * 例如 symbol='℃' 时：
 *   - 先在 LShift 和 RShift 两张表中搜索包含 '℃' 的列表，发现是 '.' 的列表
 *   - 若触发的是 LShift up，则返回 LShift['.'] 的值列表
 *   - 若触发的是 RShift up，则返回 RShift['.'] 的值列表
 *   外层的 drift(origin, list*) 会按所选值（数组）顺序循环切换。
 */
; TODO: 合并Letter和Number漂移功能。
getDriftList(hotkey, origin) {
	driftMap := {}
	switch hotkey {
		case "LShift", "RShift":  ; 如果触发的热键是左/右Shift键，使用 Symbol.yaml 的配置表
			driftMap := SYMBOL_MAP
		case "<#LShift", "<#RShift":  ; 如果触发的热键是 左Win+左/右Shift键，则使用 Number.yaml 的配置表
			driftMap := NUMBER_MAP
			hotkey := SubStr(hotkey, 3)  ; 去掉前面的“<#”，得到“LShift”或“RShift”
		case ">#LShift", ">#RShift":  ; 如果触发的热键是 右Win+左/右Shift键，则使用 ENG_GRC.yaml 的配置表
			driftMap := ENG_GRC_MAP
			hotkey := SubStr(hotkey, 3)  ; 去掉前面的“>#”，得到“LShift”或“RShift”
		default:
			return []  ; 如果不是上述热键，直接返回空数组
	}
	if !driftMap.Has("LShift") || !driftMap.Has("RShift")  ; 若两张表都不存在，则直接返回空数组
		return []
	matchedKey := ''  ; 记录 origin 所在的键名，例如 '.'
	for _, section in ["LShift", "RShift"] {  ; 先在左右两张表中找出包含 origin 的键名
		for key, list in driftMap[section] {
			if key == origin {
				matchedKey := key
				break 2
			}
			for item in list {
				if item == origin {
					matchedKey := key
					break 2
				}
			}
		}
	}
	if matchedKey = ''  ; 如果两张表都没找到，就返回空数组
		return []
	if driftMap.Has(hotkey) && driftMap[hotkey].Has(matchedKey)  ; 只返回当前触发 Shift 方向下的同键列表
		return driftMap[hotkey][matchedKey]
	return []  ; 若当前方向不存在该键，则直接忽略，不做漂移
}
/**
 * @description 检测给定的值（value）是否存在于数组（arr）中
 * @param {(Any)} value 要检测的值
 * @param {(Array)} arr 给定的数组
 * @returns {(true|false)} 如果 value 存在于 arr 中返回 true，否则返回 false
 */
isValueInArray(value, arr*) {
	for v in arr {
		if (v == value)
			return true
	}
	return false
}
; 如果*不是*（存在输入法候选窗口 或 当前软件是 不适用须要排除的应用程序组 或 文件管理器且活动控件*不是*输入框）
#HotIf not (WinExist("ahk_group IME") or WinActive("ahk_group Exclude") or (WinActive("ahk_group FileManager") and not InStr(ControlGetClassNN(ControlGetFocus("A")), "edit")))  ; or hasMS_IMEWindow()
; 英/中常用标点变换，处理有配对标点符号时按情况变换单个或者成对标点。
~LShift up:: {  ; 当左Shift键弹起并且之前没有按过其它键时触发
	static symbolList := []
	if HolyShift and A_PriorKey = "LShift" {
		origin := getPrev()  ; 获取光标前一个内容（将要被变换的标点）
		if not symbolList.Length or not isValueInArray(origin, symbolList*)  ; 如果 symbolList 为空 或者 光标前的内容*不在* symbolList 中
			symbolList := getDriftList("LShift", origin)
		if symbolList.Length
			drift(origin, symbolList*)
	}
}
; 扩展标点变换。处理有配对标点符号时可快速变换单个或者成对标点。
~RShift up:: {  ; 当右Shift键弹起并且之前没有按过其它键时触发
	static symbolList := []
	if HolyShift and A_PriorKey = "RShift" {
		origin := getPrev()  ; 获取光标前一个内容（将要被变换的标点）
		switch origin {
			case '"': Send "{Left}{Del}{Text}“"
				if Tip
					showTip("前", 1)
			case '“': Send "{BS}{Text}”"
				if Tip
					showTip("后", 1)
			case '”': SendText("!"), Send('{Left}{BS}{Text}"'), Send("{Del}")
			case "'": Send "{Left}{Del}{Text}‘"
				if Tip
					showTip("前", 1)
			case "‘": Send "{BS}{Text}’"
				if Tip
					showTip("后", 1)
			case "’": SendText("!"), Send("{Left}{BS}{Text}'"), Send("{Del}")
			default:
				if not symbolList.Length or not isValueInArray(origin, symbolList*)  ; 如果 symbolList 为空，或者光标前的内容*不在* symbolList 中
					symbolList := getDriftList("RShift", origin)
				if symbolList.Length
					drift(origin, symbolList*)
		}
	}
}

Global HolyShift := true  ; 标记是否只按下了Shift键，是则为 true

#HotIf
; ~~~~~~ Optional Hotkeys Begin ~~~~~~
; 这部分热键为非必须热键，如果和你使用的其它AHK脚本有冲突，可以将这部分代码注释或删除。但这将失去按键按顺序执行的功能，当输入太快时顺序可能会出现错乱。
Enter::
Space:: xkeySender(ThisHotkey)
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
	Thread "Priority", 1  ; 须要提高此线程的优先级，丢弃长按产生的重复Shift按键事件，否则如果最后释放Shift键，可能会因为连按触发Shift热键使HolyShift变成true
	Critical "Off"  ; 将此线程修改为非关键线程，配合上一行代码，使未处理的排队按键会被丢弃
	Global HolyShift := false
	if GetKeyState("Ctrl", "P") or GetKeyState("Alt", "P")
		KeyWait "Shift"  ; （KeyWait函数在等待时可通过热键等启动新线程，因此要提高此线程的优先级，丢弃后面的重复按键）
}
~LShift::
~RShift:: {  ; 如果只按下Shift键，则HolyShift为true
	Global HolyShift := true
}
