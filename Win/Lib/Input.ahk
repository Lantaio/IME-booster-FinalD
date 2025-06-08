/*
 * 检测当前是否处于中文输入状态
 * 返回值：
 *   如果是中文输入状态返回true，否则返回false
 */
IsCNInputState() {
	; 获取当前活动窗口的线程ID
	threadID := DllCall("GetWindowThreadProcessId", "Ptr", WinExist("A"), "Ptr", 0)
	; 获取该线程的键盘布局
	hKL := DllCall("GetKeyboardLayout", "UInt", threadID, "Ptr")
	; 提取键盘布局的低16位(语言ID)
	langID := hKL & 0xFFFF
	; 检查是否是中文键盘布局(0x0804是简体中文，0x0404是繁体中文)
	if (langID == 0x0804 or langID == 0x0404) {
		; 获取输入法状态
		try {
			imeStatus := DllCall("SendMessage", "UInt", DllCall("imm32\ImmGetDefaultIMEWnd", "UInt", WinExist("A")), "UInt", 0x0283, "Int", 0x0005, "Int", 0, "Int")
			return (imeStatus == 1)  ; 0表示英文输入状态，1表示中文输入状态
		} catch {
			return true  ; 如果获取输入法状态失败，默认返回true(保守策略，假设是中文状态)
		}
	}
	return false  ; 其他语言键盘布局或英文输入状态返回false
}