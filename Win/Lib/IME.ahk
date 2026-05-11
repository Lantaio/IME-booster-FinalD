; #Requires AutoHotkey v2.0

/*
 * 检测当前是否处于中文输入状态
 * 返回值：
 *   如果是中文输入状态返回true，否则返回false
 */
IsCNInputMode() {
	hWnd := WinExist("A")
	if !hWnd
		return false
	; 获取当前活动窗口的线程ID
	threadID := DllCall("GetWindowThreadProcessId", "Ptr", hWnd, "Ptr", 0, "UInt")
	; 获取该线程的键盘布局
	hKL := DllCall("GetKeyboardLayout", "UInt", threadID, "Ptr")
	; 提取键盘布局的低16位(语言ID)
	langID := hKL & 0xFFFF
	; 中文语言ID:
	; 0x0804 = 简体中文 (中国)
	; 0x0404 = 繁体中文 (台湾)
	; 0x0C04 = 繁体中文 (香港)
	; 0x1404 = 中文 (澳门)
	; 0x1004 = 中文 (新加坡)
	if (langID = 0x0804) || (langID = 0x0404) || (langID = 0x0C04) || (langID = 0x1404) || (langID = 0x1004) {
		; 获取输入法状态
		try {
			imeWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hWnd, "Ptr")
			if (!imeWnd)
				return true  ; 如果获取IME窗口失败，默认返回true(保守策略，假设是中文输入状态)
			imeStatus := SendMessage(
				0x0283,  ; Message: WM_IME_CONTROL
				5,       ; wParam: IMC_GETOPENSTATUS
				0,       ; lParam: (NoArgs)
				imeWnd)  ; Control or Window HWND
			; showTip(imeStatus, 5)
			if imeStatus  ; 0表示英文输入状态，1表示中文输入状态
				return true
			else
				return false
		} catch {
			return true  ; 如果获取输入法状态失败，默认返回true(保守策略，假设是中文输入状态)
		}
	}
	return false  ; 其他语言键盘布局或英文输入状态返回false
}
