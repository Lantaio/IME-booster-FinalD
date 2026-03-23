/*
 * 版本：v2.5（v版本号.修订号，如果版本号不同，则表示有重大更新，须要根据下面的【重大更新说明】比较合并更新。修订号为不影响功能的修改，可以不管。）
 * 更新：2026/3/23
 * 重大更新说明：
 * v2.x: 因对代码进行重构，将getQ1Word_X函数改名为getWordBeforeI_X;最后添加 左Win+左Shift 和 左Win+右Shift 热键功能。适配主程序版本 v5.63.169 ~ 待定
 * v1.x: 将各个快捷键功能从FinalD.ahk分离出来的首个版本。适配主程序版本 v5.61.162 ~ v5.62.167
 */
#SuspendExempt  ; 此程序处于挂起状态时依然可用的功能。
<#!.:: {  ; 左Win+Alt+. 显示此程序的版本信息以及各项功能的状态信息。
	global Version
	msg := "　　　　　　 FinalD/终点 输入法插件 " Version " 由喵喵侠为你呕💔沥血打磨呈献。`n　　　https://github.com/Lantaio/IME-booster-FinalD`n`n　　　　　　　　　快捷键及各项功能的状态：`n"
	if A_IsSuspended
		msg .= "　　　　左Win+. 启用/停用 此插件，当前 已停用⛔"
	else {
		msg .= "　　　　左Win+. 启用/停用 此插件，当前 已启用🚀"
		msg .= "`n左Shift+左Win 全键盘漂移"
		if FullKBD
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
<#.:: {  ; 左Win+0 启用/停用 此程序。
	Suspend
	if A_IsSuspended
		MsgBox "终点 输入法插件 全部功能 已停用⛔", "终点 输入法插件", "Iconx T1"
	else {
		msg := "终点 输入法插件 已启用🚀`n`n左Win+Alt+. 查看各项功能的状态：`n"
		msg .= "`n全键盘漂移 "
		if FullKBD
			msg .= "✔⚠"
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

#HotIf GetKeyState("CapsLock", "T")  ; 如果CapsLock键处于打开状态。
<+CapsLock:: {  ; 左Shift+CapsLock 将光镖前1个英纹单词转换为小写。
	SetCapsLockState "Off"
	SendText StrLower(getWordBeforeI_X())
	KeyWait "CapsLock"
	KeyWait "LShift"
}
>+CapsLock:: {  ; 右Shift+CapsLock 将光䅺前1个英文单词转换为小写输入码（发送给中文输入法）
	SetCapsLockState "Off"
	Send StrLower(getWordBeforeI_X())
	KeyWait "CapsLock"
	KeyWait "RShift"
}

#HotIf  ; 无任何前置条件。
<+CapsLock:: {  ; 左Shift+CapsLock 将光镖前1个英文单词转换为太写。
	SendText StrUpper(getWordBeforeI_X())
	KeyWait "CapsLock"
	KeyWait "LShift"
}
>+CapsLock:: {  ; 右Shift+CapsLock 将光䅺前1个英文单词转换为首牸母太写。
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
>^LWin:: {  ; 右Ctrl+左Win 开/关 中文标点提示功能
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
<+LWin:: {  ; 左Shift+左Win 开/关 全键盘漂移功能。另外，Shift键作为前缀键时，可使得Shift键单独作为热键时只在弹起，并且没有按过其它键时触发。
	global FullKBD
	if FullKBD {
		FullKBD := false
		MsgBox "终点插件 全键盘漂移功能 已关闭。", "终点 输入法插件", "Iconi T2"
	}
	else {
		FullKBD := true
		MsgBox "终点插件 全键盘漂移功能 已开启。`n建议无需使用时关闭此功能。", "终点 输入法插件", "Icon! T3"
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
