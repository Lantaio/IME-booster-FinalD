/*
 * 说明：存放FinalD项目的各种功能开关（全局变量）及其初始状态，还有自定义快捷键设置。
 * 版本：v12.31（v版本号.修订号，如果版本号不同，则表示有重大更新，须要根据下面的【重大更新说明】比较合并更新，或查找文件中有“✨”符号的地方。修订号为不影响功能的修改，可以不管。）
 * 更新：2026/8/27
 * 重大更新说明：
 * v12.x: 将字母漂移列表和数字漂移列表放到映射表中，方便自定制；优化getPrevWord_X函数。适配主程序版本 v9.79.261 ~ 最新版
 * v11.x：增加Rime全局变量来区分Rime/非Rime输入法，并实现自动检测。适配主程序版本 v8.74.225 ~ v9.77.248
 * v10.x：将BetterCN开关升级为AI智慧模式开关。适配 v8.72.208 ~ v8.74.224
 * v9.x：适配所有热键线程默认变为关键线程。适配 v7.70.198 ~ v7.70.205
 * v8.x：为全键盘漂移的2个快捷键添加触发条件。适配 v7.69.195
 * v7.x：将getWordBeforeI_X函数从主程序移动到此程序。适配 v7.69.194
 * v6.x：将此项目所有ahk脚本程序的编码方式统一更改为UTF-8 with BOM格式。只需将你自己的Shortcut.ahk文件的编码格式修改为此编码格式并保存即可。适配 v7.68.190 ~ v7.69.193
 * v5.x：将字母方向键功能从主程序移动到此，并添加了触发条件。适配 v6.68.187 ~ v7.68.189
 * v4.x：增加全局变量Interval方便调整连按间隔时间。适配 v5.67.180 ~ v6.68.186
 * v3.x：将部分和自定义设置有关的全局变量从主程序移动到此程序；将原来全键盘漂移功能替换为字母方向键功能。适配 v5.66.178
 * v2.x：因对代码进行重构，将getQ1Word_X函数改名为getWordBeforeI_X；最后添加 左Win+左Shift 和 左Win+右Shift 热键功能。适配 v5.63.169 ~ v5.65.176
 * v1.x：将各个快捷键功能从FinalD.ahk分离出来的首个版本。适配 v5.61.162 ~ v5.62.167
 */
Global Arrow := true  ; 字母方向键 功能开关 的默认状态
Global AI := false   ; 智慧模式/操控模式 切换 的默认状态
; Global Debug := false  ; 调试程序的总开关 的默认状态
Global Interval := 0.2  ; 重复按键的间隔时间，以秒为单位
Global Rime := false  ; ✨️Rime输入法/非Rime输入法 切换 的默认状态
Global Smart := true  ; 聪明中/英标点输入和自动配对 功能开关 的默认状态（表格兼容模式）
Global Tip := false  ; 中文标点提示信息 功能开关 的默认状态
/**
 * 检测当前所使用的输入法是否为 Rime，并更新全局状态。
 *
 * @returns {Void} 直接修改全局变量 `Rime`，无返回值。
 */
checkIME() {  ; ✨️
	Global Rime
 	id := WinExist("A")
	WinActivate("ahk_class A)Shell_TrayWnd$")  ; 激活任务栏
	Send "a"
	Sleep 120  ; 等待输入法候选窗口出现
	if WinExist("ahk_class A)ATL:") {
		Rime := true
		MsgBox "当前适配 Rime输入法。", , "Iconi T2"
	} else {
		Rime := false
		MsgBox "当前适配 非Rime输入法。", , "Iconi T2"
	}
	Send "{Esc}"
	if id and WinExist("ahk_id " id)
		WinActivate "ahk_id " id  ; 重新激活检测前的活动窗口
}

checkIME()  ; 程序自动执行阶段检测当前所使用的输入法

#SuspendExempt  ; 此程序处于挂起状态时依然可用的功能。
<#!.:: {  ; 左Win+Alt+. 显示此程序的版本信息以及各项功能的状态信息。
	msg := "　　　　　　 FinalD/终点 输入法插件 " Version " 由喵喵侠为你呕💔沥血打磨呈献。`n　　　https://github.com/Lantaio/IME-booster-FinalD`n`n　　　　　　　　　快捷键及各项功能的状态：`n"
	if A_IsSuspended
		msg .= "　　　　左Win+. 启用/停用 此插件，当前 已停用⛔"
	else {
		msg .= "　　　　左Win+. 启用/停用 此插件，当前 已启用🚀"
		msg .= "`n（妙按）左Win+. 输入法检测，当前适配 "
		if Rime  ; ✨️
			msg .= "Rime输入法"
		else
			msg .= "非Rime输入法"
		msg .= "`n左Shift+左Win 字母方向键"
		if Arrow
			msg .= "✔"
		else
			msg .= "❌"
		msg .= "，右Shift+左Win "
		if AI
			msg .= "切换到 操控模式"
		else
			msg .= "切换到 智慧模式"
		msg .= "`n左Ctrl+左Win（表格）兼容模式"
		if Smart
			msg .= "❌"
		else
			msg .= "✔"
		msg .= "，右Ctrl+左Win 中文标点提示"
		if Tip
			msg .= "✔"
		else
			msg .= "❌"
	}
	MsgBox msg, , "Iconi"
}
<#.:: {  ; 左Win+.
	if KeyWait('.', "T" String(Interval)) {  ; ### ✨️短按，启用/停用 此程序
		Suspend
		if A_IsSuspended
			MsgBox "终点 输入法插件 全部功能 已停用⛔", , "Iconx T2"
		else {
			checkIME()  ; ✨️每次从休眠中恢复启用此插件时检测当前所使用的输入法
			msg := "终点 输入法插件 已启用🚀`n`n左Win+Alt+. 查看各项功能的状态：`n"
			msg .= "`n字母方向键 "
			if Arrow
				msg .= "✔"
			else
				msg .= "❌"
			msg .= "`n当前是："
			if AI
				msg .= "智慧模式"
			else
				msg .= "操控模式"
			msg .= "`n（表格）兼容模式 "
			if Smart
				msg .= "❌"
			else
				msg .= "✔"
			msg .= "`n中文标点提示 "
			if tip
				msg .= "✔"
			else
				msg .= "❌"
			MsgBox msg, , "Iconi T5"
		}
	} else {  ; ### ✨️妙按，检测当前所使用的输入法
		checkIME()
	}
}
#SuspendExempt False

; 如果*不是*（存在输入法候选窗口 或 当前软件是 不适用须要排除的应用程序组 或 文件管理器且活动控件*不是*输入框）
#HotIf not (WinExist("ahk_group IME") or WinActive("ahk_group Exclude") or (WinActive("ahk_group FileManager") and not InStr(ControlGetClassNN(ControlGetFocus("A")), "edit")))  ; or hasMS_IMEWindow()
/* 
 * 数字漂移和字母漂移功能
 * 如果更改触发快捷键，须要同时修改FinalD.ahk中getDriftList函数的对应快捷键键。
 */
<#LShift up:: {  ; ✨️左Win+左Shift 将光标前面的数字变换为上下标数字形式
	static numberList := []
	if A_PriorKey = "LShift"
		origin := getPrev()  ; 获取光标前一个内容（将要被变换的字符）
		if not numberList.Length or not isValueInArray(origin, numberList*)
			numberList := getDriftList("<#LShift", origin)
		if numberList.Length
			drift(origin, numberList*)
}
<#RShift up:: {  ; ✨️左Win+右Shift 将光标前面的数字变换为对应的罗马数字形式
	static numberList := []
	if A_PriorKey = "RShift"
		origin := getPrev()  ; 获取光标前一个内容（将要被变换的标点）
		if not numberList.Length or not isValueInArray(origin, numberList*)
			numberList := getDriftList("<#RShift", origin)
		if numberList.Length
			drift(origin, numberList*)
}
>#LShift up:: {  ; ✨️右Win+左Shift 将光标前面的希腊字母变换为对应的英文字母
	static letterList := []
	if A_PriorKey = "LShift"
		origin := getPrev()  ; 获取光标前一个内容（将要被变换的字符）
		if not letterList.Length or not isValueInArray(origin, letterList*)
			letterList := getDriftList(">#LShift", origin)
		if letterList.Length
			drift(origin, letterList*)
}
>#RShift up:: {  ; ✨️右Win+右Shift 将光标前面的英文字母变换为对应的希腊字母
	static letterList := []
	if A_PriorKey = "RShift"
		origin := getPrev()  ; 获取光标前一个内容（将要被变换的标点）
		if not letterList.Length or not isValueInArray(origin, letterList*)
			letterList := getDriftList(">#RShift", origin)
		if letterList.Length
			drift(origin, letterList*)
}

/**
 * 根据按键按下时间决定是发送原键，还是执行长按功能。
 *
 * @param {String} key 需要监听的按键名称。
 * @param {String} fn 长按时执行的功能键序列。
 * @returns {Void} 直接发送按键或功能键序列，无返回值。
 */
smartLetter(key, fn) {
	if KeyWait(key, "T" String(Interval))  ; 短按
		Send "{Blind}" key  ; 根据Shift键是否按下发送按键的相应大小写
	else {  ; 长按
		Thread "Priority", 1  ; 提高线程优先级，使此线程不会被后面的低优先级线程中断，并丢弃未处理的排队按键
		Critical "Off"  ; 将此线程修改为非关键线程，配合上一行代码，使未处理的排队按键会被丢弃
		if not WinExist("ahk_group IME")  ; 如果没有输入法候选窗口
			while GetKeyState(key, "P") {  ; 当按键未释放时重复……
				Send fn  ; 发送设定的功能
				Sleep 1000 * Interval  ; 等待重复按键时间间隔
			}
		else  ; 有输入法候选窗口
			while GetKeyState(key, "P") {  ; 当按键未释放时重复……
				if GetKeyState("Shift", "P")  ; 如果按下了Shift键
					Send "{Blind}" key  ; 发送按键的大写形式
				else
					Send fn  ; 发送设定的功能
				Sleep 1000 * Interval  ; 等待重复按键时间间隔
			}
	}
}
; 如果 字母方向键功能打开 并且 不是大写状态打开
#HotIf Arrow and not GetKeyState("CapsLock", "T")
i:: smartLetter('i', "{Up}")  ; 长按时发送‘↑’
j:: smartLetter('j', "{Left}")  ; 长按时发送‘←’
k:: smartLetter('k', "{Down}")  ; 长按时发送‘↓’
l:: smartLetter('l', "{Right}")  ; 长按时发送‘→’
+i:: smartLetter('i', "^{Home}")  ; 长按时发送‘Ctrl+Home’（光标到文件头）
+j:: smartLetter('j', "{Home}")  ; 长按时发送‘Home’（光标到行首）
+k:: smartLetter('k', "^{End}")  ; 长按时发送‘Ctrl+End’（光标到文件尾）
+l:: smartLetter('l', "{End}")  ; 长按时发送‘End’（光标到行尾）
u:: smartLetter('u', "{Esc}")  ; 长按时发送‘Esc’
o:: smartLetter('o', "{Del}")  ; 长按时发送‘Del’

/**
 * 通过剪贴板获取光标前的英文片段，并删除该片段。
 *
 * @returns {String} 光标前的英文片段；如果没有匹配内容，则返回空字符串。
 */
getPrevWord_X() {  ; ✨️
	clipCache := ClipboardAll(), A_Clipboard := ''
	Send "^+{Left}^c"  ; 选取当前光标前的片段并复制
	if !ClipWait(0.6) {  ; 如果剪贴板在0.6秒内没有内容，则返回空字符串
		A_Clipboard := clipCache
		return ''
	}
	Send "{Right}"  ; 取消选择，光标回到原位置
	prevWord := '', text := A_Clipboard, A_Clipboard := clipCache
	if RegExMatch(text, "([0-9A-Za-z_]+)$", &match) ; 取出末尾连续的英文/数字/下划线片段
		prevWord := match[1]
	if prevWord != '' {  ; 如果有匹配内容，则删除该片段
		Send "{Shift down}"
		Send "{Left " StrLen(prevWord) "}"
		Send "{Shift up}"
		Send "{Del}"
	}
	return prevWord
}
; CapsLock键处于打开状态时启用的热键。
#HotIf GetKeyState("CapsLock", "T")
<+CapsLock:: {  ; 左Shift+CapsLock 将光标前1个英文单词转换为小写。
	SetCapsLockState "Off"
	SendText StrLower(getPrevWord_X())
	KeyWait "CapsLock"
	KeyWait "LShift"
}
>+CapsLock:: {  ; 右Shift+CapsLock 将光标前1个英文单词转换为小写输入码（发送给中文输入法）。
	SetCapsLockState "Off"
	Send StrLower(getPrevWord_X())
	KeyWait "CapsLock"
	KeyWait "RShift"
}

; 无任何前置条件的热键。
#HotIf
<+CapsLock:: {  ; 左Shift+CapsLock 将光标前1个英文单词转换为大写。
	SendText StrUpper(getPrevWord_X())
	KeyWait "CapsLock"
	KeyWait "LShift"
}
>+CapsLock:: {  ; 右Shift+CapsLock 将光标前1个英文单词转换为首字母大写。
	SendText StrTitle(getPrevWord_X())
	KeyWait "CapsLock"
	KeyWait "RShift"
}
<^LWin:: {  ; 左Ctrl+左Win 开/关（表格）兼容模式。
	Global Smart
	if Smart {
		Smart := false
		MsgBox "（表格）兼容模式 已开启。`n即 聪明标点和自动配对功能 已关闭！", , "Icon! T5"
	} else {
		Smart := true
		MsgBox "（表格）兼容模式 已关闭。`n即 聪明标点和自动配对功能 已开启。", , "Iconi T5"
	}
}
>^LWin:: {  ; 右Ctrl+左Win 开/关 中文标点提示功能。
	Global Tip
	if Tip {
		Tip := false
		MsgBox "中文标点提示 已关闭。", , "Iconi T2"
	} else {
		Tip := true
		MsgBox "中文标点提示 已开启。", , "Iconi T2"
	}
}
<+LWin:: {  ; 左Shift+左Win 开/关 字母方向键功能。
	Global Arrow
	if Arrow {
		Arrow := false
		MsgBox "字母方向键功能 已关闭。", , "Iconi T2"
	} else {
		Arrow := true
		MsgBox "字母方向键功能 已开启。", , "Iconi T2"
	}
}
>+LWin:: {  ; 右Shift+左Win 开/关 中文语境应用程序优化功能。
	Global AI
	if AI {
		AI := false
		MsgBox "操控模式开启，在所有应用程序上的体验一致。", , "Iconi T2"
	} else {
		AI := true
		MsgBox "智慧模式开启，针对中文语境应用程序优化。", , "Iconi T2"
	}
}
~#Space up:: {  ; ✨️Win+Space 切换适配Rime/非Rime输入法
	if A_PriorKey = "Space" {
		Thread "Priority", 1  ; 提高线程优先级，使此线程不会被后面的低优先级线程中断，并丢弃未处理的排队按键
		Critical "Off"  ; 将此线程修改为非关键线程，配合上一行代码，使未处理的排队按键会被丢弃
		if GetKeyState("LWin", "P")  ; 如果Win键仍然按下，等待Win
			KeyWait	"LWin"
		else
			KeyWait	"RWin"
		Sleep 20  ; 等待输入法切换完成
		checkIME()
	}
}
+Pause:: {  ; 通常用于在调试时让程序继续运行。
	ToolTip  ; 清除提示信息
	Pause -1  ; 切换暂停状态
}
