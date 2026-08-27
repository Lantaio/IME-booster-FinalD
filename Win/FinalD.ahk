/*
 * 说明：FinalD/终点 输入法插件——中/英标点及扩展符号智能输入和快速变换程序。
 * 注意：⚠编辑此文件后必须保存为UTF-8 with BOM编码格式！
 * 网址：https://github.com/Lantaio/IME-booster-FinalD
 * 作者：Lantaio Joy
 * 版本：见下面的全局变量Version，或运行此程序后按 左Win+Alt+. 查看。
 * 更新：2026/8/26
 */
#Requires AutoHotkey >=v2.0.26  ; 此程序只能在 >=v2.0.26版的AutoHotkey正常运行
#SingleInstance  ; 只允许运行1个实例
#UseHook  ; 使用键盘钩子，相当于在每个热键前面使用$前缀，以避免Send函数触发它自己
Critical "On"  ; 将所有线程默认设置为关键线程（不可中断），使短按按键可以按顺序执行，并缓存未处理的按键
ProcessSetPriority "High"  ; 将此程序的进程优先级设置为高
CoordMode "Caret", "Screen"  ; 设置CaretGetPos函数的坐标模式为相对于屏幕
CoordMode "Mouse", "Screen"  ; 设置MouseGetPos函数的坐标模式为相对于屏幕
CoordMode "ToolTip", "Screen"  ; 设置ToolTip函数的坐标模式为相对于屏幕
SetTitleMatchMode "RegEx"  ; 设置窗口标题的匹配模式为正则模式（※ 此模式默认区分大小写）
; KeyHistory 60
; OnError errorHandler  ; 指定错误处理函数（避免不存在当前窗口时会弹出错误信息的问题）

Global Version := "v9.79.261`n　　　 © 2024~2026"  ; 此程序的版本号
A_ScriptName := "FinalD/终点 输入法插件"  ; 此程序的名称

#Include <Caret>  ; 和光标有关的函数
; #Include <Debugger>  ; 和调试有关的函数
#Include <IME>  ; 和输入法有关的函数
#Include <Selection>  ; 和选择有关的函数
; #Include <YAML>  ; 处理YAML数据文件的类
#Include "MySettings\AppGroup.ahk"  ; 引入用户自定义的程序组信息
#Include "MySettings\Shortcut.ahk"  ; 引入用户自定义的快捷键信息

/*
 * 错误处理函数
 * 参数：
 *   ex (object) 错误对象
 *   mode 错误的模式
 * 返回值：
 *   1 抑制默认错误对话框和任何剩余的错误回调
 */
errorHandler(ex, mode) {
	return true
}

/*
 * 基本的按键处理函数，直接将按键发送给系统处理
 * 参数：
 *   thisHotkey (string) 触发的热键名称
 */
keySender(thisHotkey) {
	Send "{Blind}" thisHotkey
}
/*
 * 基本的特殊按键处理函数，直接将按键发送给系统处理
 * 参数：
 *   thisHotkey (string) 触发的热键名称
 */
xkeySender(thisHotkey) {
	Send "{Blind}{" thisHotkey "}"
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
/*
 * 根据所提供的 front（前标点）参数 输入对应的后标点
 * 参数：
 *   front (string) 前标点
 */
autoPair(front) {
	switch front {
		case '(', '[', '{':
			if not WinActive("ahk_group AutoPair") and shouldPair(front) {  ; 如果 是英文前标点 并且 *不是*自动配对功能程序组 并且 应该输入配对的后标点
				if Tip
					showTip("Pair", 1)
				SendText getPair(front)  ; 输入对应的后标点
				Send "{Left}"  ; 光标回到配对标点中间
			}
		case '"', "'":
			if not WinActive("ahk_group AutoPair") and (Prev = ' ' or Prev ~= '`a)\R$' or Prev = '`t' or Prev = '') and shouldPair(front) {  ; 如果 是英文前标点 并且 *不是*自动配对功能程序组 并且 应该输入配对的后标点
				if Tip
					showTip("Pair", 1)
				SendText getPair(front)  ; 输入对应的后标点
				Send "{Left}"  ; 光标回到配对标点中间
			}
		case '“', '‘':
			if Commit = '“' or Commit = '‘'  ; 如果 刚输入的是中文引号前标点
				if shouldPair(Commit) {  ; 如果 应该自动配对，则……
					if Tip
						showTip("配对", 1)
					if Commit = '“'
						Send "`"{Left}"  ; ※ 交给输入法处理
					else
						Send "'{Left}"  ; ※ 交给输入法处理
				}
		case '（', '【', '「', '《':
			if shouldPair(front) {
				if Tip and front = '（'
					showTip("配对", 1)
				SendText getPair(front)
				Send "{Left}"
			}
	}
}
/*
 * 借助剪贴板获取光标前的内容（字符）
 * 返回值：
 *   clip (string) 通过 Shift+← 键选取的光标前的内容（字符）
 */
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
/*
 * 借助剪贴板获取光标后一个内容（字符）
 * 返回值：
 *   clip (string) 通过Shift+→键选取的光标后一个内容（字符）
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
/*
 * 获取 front前标点参数 对应的后标点，如果不存在配对标点，则返回空字符。
 * 参数：
 *   front (string) 前标点
 * 返回值：
 *   (string) front标点对应的后标点 或 空字符
 */
getPair(front) {
	switch front {
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
		default: return ''
	}
}
/*
 * 检测front标点是否有配对的后标点
 * 参数：
 *   front (string) 检测这个前标点后是否有配对的后标点
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
	if getPair(front) = back
		return true
	return false
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
 * 将提供的 punct（标点）参数 输出到屏幕
 * 参数：
 *   punct (string) 标点
 */
output(punct) {
	switch punct {
		case '“', '‘':
			if punct = '“'
				Send '"'  ; ※ 交给输入法处理
			else
				Send "'"  ; ※ 交给输入法处理
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
/*
 * 通过所提供的 前标点参数 和检测光标后的内容来判断是否应该输入配对的后标点符号
 * 参数：
 *   front (string) 前标点 以便做针对性处理
 * 返回值：
 *   true / false
 */
shouldPair(front) {
	next := getNext()  ; （※ 此处不能用SubStr只获取1个字符）
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
/*
 * 智能选择要上屏英文标点还是中文标点（※ 调用此函数前可能需要先调用getPrev函数更新全局变量Prev的值。）
 * 参数：
 *   en (string) 按键对应的英文标点符号
 *   cn (string) 按键对应的中文标点符号
 * 返回值：
 *   en / cn (string) 根据情况选择要上屏英文还是中文标点
 */
smartChoice(en, cn) {
	if en = cn
		return en
	Global Prev := getPrev()
	if AI {  ; 智慧模式
		; 如果*不是* 当前程序是中文语境软件 并且 前一个内容是西文
		if not WinActive("ahk_group CN") and isPrevEN()
			Return en
		; 否则（是中文语境软件，或者应该输入中文标点），如果按键是“.”、“:”或“~” 并且 前一个字符是数字，则应是英文标点
		else if (en = '.' or en = ':' or en = '~') and IsInteger(Prev)
			Return en
		else  ; 否则，应是中文标点
			Return cn
	} else {  ; 操控模式
		; 如果*不是* （（前一个内容是换行符 或 空）并且 当前程序是中文语境软件） 并且 前一个内容是西文
		if not ((Prev ~= '`a)\R$' or Prev = '') and WinActive("ahk_group CN")) and isPrevEN()
			Return en
		else  ; 否则，应是中文标点
			Return cn
	}
}
/*
 * 根据按键方式和是否有提供 中文标点参数 来输入中/英标点符号
 * **短按**时如果没有提供中文标点，则直接上屏英文标点，否则用smartChoice函数判断应该上屏英文标点还是中文标点；
 * **妙按**时的输入逻辑和短按时反转；
 * **长按**时删除妙按时上屏的标点，然后连续上屏短按时应该上屏的标点。
 * 参数：
 *   en (string) 按键名称，对应英文标点符号
 *   cn (string) （可选）中文标点
 */
smartType(en, cn?) {  ; （※ Send函数中[^+!#]标点须用{}包裹。）
	if not isSet(cn)
		cn := en
	if KeyWait(en, "T" String(Interval)) {  ; ### 短按
		if en = cn  ; 如果英文标点和中文标点相同，直接输出
			SendText en
		else {  ; 英文标点和中文标点不同
			choice := smartChoice(en, cn)  ; （⚠ 由于getPrev函数的执行时间可能会超过0.5秒，因此不能放在if语句之前，否则不能正确检测是短按还是长按）
			if choice = en {  ; 如果 应该输入英文标点
				SendText en
				autoPair(en)  ; 自动配对英文标点
			} else {  ; 应该输入中文标点
				output(cn)
				autoPair(cn)  ; 自动配对中文标点
			}
		}
	} else {  ; 妙按 和 长按
		Thread "Priority", 1  ; 提高线程优先级，使此线程不会被后面的低优先级线程中断，并丢弃未处理的按键
		Critical "Off"
		; ### 妙按
		choice := smartChoice(en, cn)
		if Rime {  ; 如果是Rime输入法
			if choice = en {  ; 本来应该输入英文标点，变成输入中文标点
				if InStr("/&|@%^$", en)  ; 如果是Rime功能触发键
					en = '^' ? Send("{" en "}") : Send(en)  ; 交给输入法处理
				else  ; 不是Rime功能触发键
					output(cn)  ; （※ 后面#1再作配对处理）
			} else {  ; 本来应该输入中文标点，变成输入英文标点
				if InStr("/&|@%^$", en)  ; 如果是Rime功能触发键
					en = '^' ? Send("{" en "}") : Send(en)  ; 交给输入法处理
				else  ; 否则（不是Rime功能触发键）
					SendText en  ; （※ 后面#1再作配对处理）
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
		; ### 长按的第1次输入
		if GetKeyState(en, "P") {  ; 如果按键未弹起
			if en = cn {  ; 如果英文标点和中文标点相同，直接输出
				Send "{BS}{Text}" en
			} else if choice = en {  ; 如果应该输入英文标点
				if (en = '^' or en = '_') and not WinExist("ahk_group IME")  ; 如果妙按输入的是“……”或“——”，并且没有输入法候选窗口（有则表示未上屏）
					Send "{BS}"  ; 多输入1个退格键
				Send "{BS}{Text}" en  ; 删除妙按输入的中文标点（或者关闭输入法候选窗口），并输入1个英文标点（※ 此操作统一不同中文输入法的行为）
			} else {  ; 如果应该输入中文
				Send "{BS}"  ; 删除妙按时输入的英文标点（或者关闭输入法候选窗口）（※ 此操作统一不同中文输入法的行为）
				output(cn)
			}
			Sleep 1000 * Interval
		} else {  ; ### 妙按后没有长按（#1）
			if en = cn  ; 如果英文标点和中文标点相同，直接返回（⚠ 此处假设中英文相同标点不存在配对标点）
				return
			else if choice = en  ; ⚠ 如果妙按时输入中文
				autoPair(cn)  ; 自动配对中文标点
			else  ; 否则 如果妙按时输入英文
				autoPair(en)  ; 自动配对英文标点
			return
		}
		; ### 长按的后续输入
		while GetKeyState(en, "P") {  ; 当按键未弹起时
			if choice = en  ; 如果 应该输入英文标点
				SendText en
			else if cn = '“' or cn = '‘'  ; 否则 如果 是中文引号
				Send en  ; ※ 交给输入法处理
			else  ; 否则 是其它中文标点
				SendText cn
			Sleep 1000 * Interval
		}
	}
}
/*
 * 根据所提供的 提示信息参数 和 时长参数 来显示提示信息
 * 参数：
 *   info (string) 提示信息
 *   sec (float) 时长 提示信息显示时长，以秒为单位
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
; 如果 聪明标点开关打开，并且不是（存在输入法候选窗口 或 当前软件是 不支持聪明标点输入和自动配对功能的应用程序组 或 不适用须要排除的应用程序组） 并且 在中文输入状态。
#HotIf Smart and not (WinExist("ahk_group IME") or WinActive("ahk_group UnSmart") or WinActive("ahk_group Exclude")) and IsCNInputMode()
.:: smartType('.', '。')
,:: smartType(',', '，')
(:: {
	; Send "{Blind}{9 up}{LShift up}"
	smartType('(', '（')
	; reKeyState "LShift"  ; 恢复Shift键的物理状态
}
):: {
	; Send "{Blind}{0 up}{LShift up}"
	smartType(')', '）')
}
_:: {  ; （连按键）
	; Send "{Blind}{- up}{LShift up}"
	smartType('_', '——')
}
::: {
	; Send "{Blind}{; up}{LShift up}"
	smartType(':', '：')  ; 长按输入中文标点
}
":: {
	Send "{Blind}{' up}{LShift up}"
	smartType('"', '“')
}
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
&:: {
	; Send "{Blind}{7 up}{LShift up}"
	smartType(ThisHotkey)
}
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

Global ENG_GRC_MAP := getDriftMap(A_ScriptDir "\MySettings\ENG_GRC.yaml")  ; 获取英文字母↔希腊字母对应关系映射表
Global NUMBER_MAP := getDriftMap(A_ScriptDir "\MySettings\Number.yaml")  ; 获取数字漂移配置表
Global SYMBOL_MAP := getDriftMap(A_ScriptDir "\MySettings\Symbol.yaml")  ; 获取标点符号漂移配置表
/*
 * 标点符号循环漂移
 * 参数：
 *   origin (string) 将要被转换的标点符号
 *   list* (string array)(可变) 标点符号循环漂移列表（数组）
 */
drift(origin, list*) {
	i := 0
	loop list.length
		if origin = list[A_Index] {  ; 如果将要被转换的标点符号在漂移列表中
			i := A_Index
			break
		}
	if i = 0 or i = list.length  ; 如果在漂移列表中不存在这个标点符号 或者 是列表中最后1个标点符号
		i := 1  ; 定位列表中第1个标点符号
	else
		i += 1  ; 定位列表中所找到的标点符号的下1个标点符号
	if origin = '……' or origin = '——'  ; 如果原来的标点是‘……’或‘——’
		Send "{BS}"  ; 多输入1个退格键
	if Smart and getPair(origin) and hasPair(origin) {  ; 如果（表格）兼容模式*没有*开启 并且 原来的标点是成对标点的前标点 并且 原来的标点有配对的后标点
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
		if InStr("`"')]}", list[i]) {	; 如果新标点是英文后标点
			SendText "!"  ; 输入感叹号防止软件过度自动化
			Send "{Left}{BS}{Text}" list[i]  ; 光标归位，漂移标点符号
			Send "{Del}"  ; 删除之前用于防止软件过度自动化的感叹号
		} else  ; 否则（新标点不是英文后标点，可能是中英文标点符号，甚至是扩展符号）
			Send "{BS}{Text}" list[i]  ; 漂移标点符号
	}
}
/*
 * 解析YAML中的单值字符串，去除外层引号。
 * 参数：
 *   value (string) 需要处理的字符串
 * 返回值：
 *   (string) 去除引号后的原始字符内容
 * 说明：
 *   YAML中键和值通常写成 '。' 或 "." 这样的形式；
 *   这里需要把外层的单/双引号去掉，避免后续把实际符号当作带引号文本处理。
 */
parseYAMLScalar(value) {
	value := Trim(value)  ; 去掉行首行尾空白，否则像 "  '。'  " 这种格式也能正常处理
	if value = ''  ; 空字符串直接返回，避免后面索引出错
		return ''
	if (SubStr(value, 1, 1) = "'" and SubStr(value, -1) = "'") or (SubStr(value, 1, 1) = '"' and SubStr(value, -1) = '"')
		return SubStr(value, 2, StrLen(value) - 2)  ; 去掉外层的一对引号，保留真实标点字符本身
	return value  ; 如果本来就不是带引号的值，就直接返回原始内容
}
/*
 * 读取并反序列化给定的yaml配置文件。
 * 参数：
 *   filePath (string) 配置文件路径
 * 返回值：
 *   (Map) 结构类似：
 *       {
 *           "LShift": Map(".", ["。", "."]),
 *           "RShift": Map(".", ["℃", "°", "℉"])
 *       }
 * 说明：
 *   它会逐行扫描 YAML，识别 LShift/RShift 章节和其后面的键值列表，
 *   然后将每个键映射到一个字符串数组，用于真正的字符漂移循环。
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
			listText := Trim(SubStr(line, InStr(line, ': ') + 1, InStr(line, '#') ? InStr(line, '# ') - 1 : StrLen(line)))  ; 如果没有方括号，取出冒号后面至注释（如果有的话）之前的内容作为列表内容
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
 * @description 根据 所触发的热键（hotkey）和 光标前的内容（origin）返回hotkey热键的配置表中origin标点符号所在的键的值列表。
 * @param {("LShift"|"RShift"|"<#LShift"|"<#RShift"|">#LShift"|">#RShift")} hotkey 所触发的热键
 * @param {(String)} origin 光标前的内容（标点符号）
 * @return {(Array)} hotkey热键的配置表中origin标点符号所在的键的值列表（如果有的话，没有则返回空数组），例如 [ '。', '.' ] 或 [ '℃', '°', '℉' ]
 * @abstract 关键点在于：origin 不是按键本身，而是当前光标前的内容（标点符号）。
 *   所以不能直接用 origin 去索引 YAML 的键名；需要先在所有 Shift 配置里
 *   搜索哪个按键列表包含这个字符，再根据触发的 Shift 方向选择对应的同键列表。
 * @example
 * 例如 symbol='℃' 时：
 *   - 先在 LShift 和 RShift 两张表中搜索包含 '℃' 的列表，发现是 '.' 的列表
 *   - 若触发的是 LShift up，则返回 LShift['.'] 的值列表
 *   - 若触发的是 RShift up，则返回 RShift['.'] 的值列表
 *   外层的 drift(origin, list*) 会按所选值（数组）顺序循环切换。
 */
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
		if (v = value)
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
	Thread "Priority", 1  ; 须要提高此线程的优先级，丢弃长按产生的重复Shift按键事件，否则如果最后释放Shift键，可能会因为连按触发Shift热键使HolyShift变成true
	Critical "Off"
	Global HolyShift := false
	if GetKeyState("Ctrl", "P") or GetKeyState("Alt", "P")
		KeyWait "Shift"  ; （※ KeyWait函数在等待时可通过热键等启动新线程，因此要提高此线程的优先级）
}
~LShift::
~RShift:: {  ; 如果只按下Shift键，则HolyShift为true
	Global HolyShift := true
}
