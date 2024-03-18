#Persistent

Input, UserInput, L1 T1
if (RegExMatch(UserInput, "^\d+\.$"))
{
	Input, NextInput, L1 T1
	if (NextInput = "。")
	{
		MsgBox, 您输入了中文句号
	}
}



#Persistent  ; 使脚本在关闭编辑器后继续运行

; 初始化变量
isListening := False

; 监听任意键输入
~*:*:Input::
	; 如果当前正在监听并且输入是小数点
	if (isListening and A_ThisHotkey == ".")
	{
		; 等待下一个按键
		KeyWait, Any  ; 等待任意键被按下

		; 检查是否按下的是中文句号
		if (A_TimeSincePriorHotkey < 100 && StrGetKeyState("VK_CONTROL", "P") && StrGetKeyState("VK_SHIFT", "P") && StrGetKeyState("0xBA", "P"))
		{
			; 显示信息
			MsgBox, 检测到中文句号。
		}

		; 重置监听状态
		isListening := False
	}
	else if (isDigit(A_ThisHotkey))  ; 如果输入的是数字
	{
		; 设置监听状态为True并等待下一个键
		isListening := True
		KeyWait, .  ; 等待小数点被按下
	}
return



global lastChar ; 声明全局变量以存储上一次输入的字符
~*:: ; 捕获所有按键输入
SendInput, %A_ThisHotkey% ; 发送按下的键（如果需要的话）
lastChar := A_ThisHotkey ; 将当前按键存储在 lastChar 变量中
return



; 定义一个热键，例如F1，当按下F1时执行以下操作
F1::
; 获取当前光标位置并保存
Send, ^{LEFT}^c
; 等待剪贴板更新
ClipWait
; 获取剪贴板中的文本，即光标前一个字符
prevChar := Clipboard
; 如果剪贴板为空，则没有前一个字符
if (prevChar = "")
{
	MsgBox, 没有前一个字符
}
else
{
	MsgBox, 光标前一个字符是: %prevChar%
}  
return



安装键盘钩子
#HotIf A_PriorKey是小数点 and 
.::
{
	输出退格键+。
}