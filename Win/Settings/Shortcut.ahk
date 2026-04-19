/*
 * 版本：v4.8（v版本号.修订号，如果版本号不同，则表示有重大更新，须要根据下面的【重大更新说明】比较合并更新。修订号为不影响功能的修改，可以不管。）
 * 更新：2026/4/16
 * 重大更新说明：
 * v4.x：增加全局变量Interval方便调整连按间隔时间。适配主程序版本 v5.67.180 ~ 待定
 * v3.x：将部分和自定义设置有关的全局变量从主程序移动到此程序；将原来全键盘漂移功能替换为字母箭头键功能。适配主程序版本 v5.66.178
 * v2.x：因对代码进行重构，将getQ1Word_X函数改名为getWordBeforeI_X；最后添加 左Win+左Shift 和 左Win+右Shift 热键功能。适配主程序版本 v5.63.169 ~ v5.65.176
 * v1.x：将各个快捷键功能从FinalD.ahk分离出来的首个版本。适配主程序版本 v5.61.162 ~ v5.62.167
 */
global Arrow := true  ; 字母箭头键 功能开关 的默认状态
global BetterCN := true  ; 中文语境应用程序优化 功能开关 的默认状态
global Debug := false  ; 调试程序的总开关 的默认状态
global Interval := 0.2  ; 重复按键的间隔时间，以秒为单位
global Smart := true  ; 智能中/英标点输入和自动配对 功能开关 的默认状态（涉及表格兼容模式）
global Tip := false  ; 中文标点提示信息 功能开关 的默认状态

#SuspendExempt  ; 此程序处于挂起状态时依然可用的功能。
<#!.:: {  ; 左Win+Alt+. 显示此程序的版本信息以及各项功能的状态信息。
	msg := "　　　　　　 FinalD/终点 输入法插件 " Version " 由喵喵侠为你呕💔沥血打磨呈献。`n　　　https://github.com/Lantaio/IME-booster-FinalD`n`n　　　　　　　　　快捷键及各项功能的状态：`n"
	if A_IsSuspended
		msg .= "　　　　左Win+. 启用/停用 此插件，当前 已停用⛔"
	else {
		msg .= "　　　　左Win+. 启用/停用 此插件，当前 已启用🚀"
		msg .= "`n左Shift+左Win 字母箭头键"
		if Arrow
			msg .= "✔"
		else
			msg .= "❌"
		msg .= "，右Shift+左Win 中文语境软件优化"
		if BetterCN
			msg .= "✔"
		else
			msg .= "❌"
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
	MsgBox msg, "关于 终点 输入法插件", "Iconi"
}
<#.:: {  ; 左Win+. 启用/停用 此程序。
	Suspend
	if A_IsSuspended
		MsgBox "终点 输入法插件 全部功能 已停用⛔", "终点 输入法插件", "Iconx T1"
	else {
		msg := "终点 输入法插件 已启用🚀`n`n左Win+Alt+. 查看各项功能的状态：`n"
		msg .= "`n字母箭头键 "
		if Arrow
			msg .= "✔"
		else
			msg .= "❌"
		msg .= "`n中文语境软件优化 "
		if BetterCN
			msg .= "✔"
		else
			msg .= "❌"
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
		MsgBox msg, "终点 输入法插件", "Iconi T3"
	}
}
#SuspendExempt False

#HotIf GetKeyState("CapsLock", "T")  ; CapsLock键处于打开状态时启用的热键。
<+CapsLock:: {  ; 左Shift+CapsLock 将光标前1个英文单词转换为小写。
	SetCapsLockState "Off"
	SendText StrLower(getWordBeforeI_X())
	KeyWait "CapsLock"
	KeyWait "LShift"
}
>+CapsLock:: {  ; 右Shift+CapsLock 将光标前1个英文单词转换为小写输入码（发送给中文输入法）。
	SetCapsLockState "Off"
	Send StrLower(getWordBeforeI_X())
	KeyWait "CapsLock"
	KeyWait "RShift"
}

#HotIf  ; 无任何前置条件的热键。
<+CapsLock:: {  ; 左Shift+CapsLock 将光标前1个英文单词转换为大写。
	SendText StrUpper(getWordBeforeI_X())
	KeyWait "CapsLock"
	KeyWait "LShift"
}
>+CapsLock:: {  ; 右Shift+CapsLock 将光标前1个英文单词转换为首字母大写。
	SendText StrTitle(getWordBeforeI_X())
	KeyWait "CapsLock"
	KeyWait "RShift"
}
<^LWin:: {  ; 左Ctrl+左Win 开/关（表格）兼容模式。
	global Smart
	if Smart {
		Smart := false
		MsgBox "终点插件（表格）兼容模式 已开启。`n即 智能标点和自动配对功能 已关闭！", "终点 输入法插件", "Icon! T5"
	}
	else {
		Smart := true
		MsgBox "终点插件 表格兼容模式 已关闭。`n即 智能标点和自动配对功能 已开启。", "终点 输入法插件", "Iconi T5"
	}
}
>^LWin:: {  ; 右Ctrl+左Win 开/关 中文标点提示功能。
	global Tip
	if Tip {
		Tip := false
		MsgBox "终点插件 中文标点提示 已关闭。", "终点 输入法插件", "Iconi T2"
	}
	else {
		Tip := true
		MsgBox "终点插件 中文标点提示 已开启。", "终点 输入法插件", "Iconi T2"
	}
}
<+LWin:: {  ; 左Shift+左Win 开/关 字母箭头键功能。另外，Shift键作为前缀键时，可使得Shift键单独作为热键时只在弹起，并且没有按过其它键时触发。
	global Arrow
	if Arrow {
		Arrow := false
		MsgBox "终点插件 字母箭头键功能 已关闭。", "终点 输入法插件", "Iconi T2"
	}
	else {
		Arrow := true
		MsgBox "终点插件 字母箭头键功能 已开启。", "终点 输入法插件", "Iconi T2"
	}
}
>+LWin:: {  ; 右Shift+左Win 开/关 中文语境应用程序优化功能。
	global BetterCN
	if BetterCN {
		BetterCN := false
		MsgBox "终点插件 在所有应用程序上的体验一致。", "终点 输入法插件", "Iconi T2"
	}
	else {
		BetterCN := true
		MsgBox "终点插件 针对中文语境应用程序优化。", "终点 输入法插件", "Iconi T2"
	}
}
<#LShift up:: {  ; 左Win+左Shift 将光标前面的希腊字母变换为对应的英文字母；数字变换为上下标数字形式。
	if A_PriorKey = "LShift"
		driftToENG(getBeforeI())
}
<#RShift up:: {  ; 左Win+右Shift 将光标前面的英文字母变换为对应的希腊字母；数字变换为对应的罗马数字形式。
	if A_PriorKey = "RShift"
		driftToGRC(getBeforeI())
}
+Pause:: {  ; 通常用于在调试时让程序继续运行。
	ToolTip  ; 清除提示信息
	Pause -1  ; 切换暂停状态
}
