/**
 * @description 存放FinalD项目的各种功能开关（全局变量）及其初始状态，还有自定义快捷键设置。
* @author Lantaio Joy
 * @version v13.33 （v版本号.修订号，如果版本号不同，则表示有重大更新，须要根据下面的【重大更新说明】比较合并更新，或查找文件中有“✨”符号的地方。修订号为不影响功能的修改，可以不管。）
 * @modified 2026/9/5
 * 重大更新说明：
 * v13.x: 尽量将不是可修改的快捷键代码移到FinalD.ahk主程序，使得日后修改程序功能时可以尽量少修改此程序。适配主程序版本 v9.79.267 ~  最新版
 * v12.x: 将字母漂移列表和数字漂移列表放到映射表中，方便自定制；优化getPrevWord_X函数；修复checkIME函数检测输入法的问题。适配主程序版本 v9.79.261 ~ v9.79.266
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

; 无任何前置条件的热键。
#HotIf
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
+Pause:: {  ; 通常用于在调试时让程序继续运行。
	ToolTip  ; 清除提示信息
	Pause -1  ; 切换暂停状态
}
