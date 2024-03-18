#Requires AutoHotkey v2.0
global lastChar := "" ; 声明全局变量以存储上一次输入的字符
; 监听热键 Win + Alt
#Alt:: {
	global lastChar
	Send lastChar
	; 检查是否是小数点
	if (lastChar = ".") {
		; 如果是小数点，则发送中文句号
		Send "{Backspace}。"
	}
	return
}
; 捕获所有按键输入
~*:: {
	global lastChar := A_ThisHotkey ; 将当前按键存储在 lastChar 变量中
	return
}