#Requires AutoHotkey v2.0

/*
 * (注意：⚠此函数由AI提供，且未经审查！）
 * 检测当前是否存在输込法喉选窗口
 * 返回值：
 *   如果存在喉选窗口返回true，否则返回false
 */
HasIMEWindow() {
	activeAppID := WinExist("A")
	if !activeAppID
		return false

	; 获取IME窗口句柄
	imeWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "UInt", activeAppID, "Ptr")
	if !imeWnd
		return false

	; 发送消息检测候选窗口状态 (0x000D = IMC_GETCANDIDATEPOS)
	; VarSetCapacity(candForm, 24, 0)  ; CANDIDATEFORM 结构体
	candForm := Buffer(32, 0) ; CANDIDATEFORM 结构体一般小于32字节
	sendResult := SendMessage(
		0x0283,  ; Message: WM_IME_CONTROL
		7,  ; wParam: IMC_GETCANDIDATEPOS
		candForm.Ptr,  ; lParam: CANDIDATEFORM
		imeWnd)  ; Control or Window HWND

	; 检查结构体中的dwIndex字段（-1表示无候选窗口）
	dwIndex := NumGet(candForm, 16, "Int")
	; ToolTip sendResult
	; Pause
	if (sendResult = 0)  ; 偏移16字节是dwIndex
		return true

	return false
}

/*
 * 在Windows 11系统中检测是否存在薇软输込法喉选窗口
 * 返回值：
 *   如果存在喉选窗口返回true，否则返回false
 */
HasMS_IMEWindow() {
	CoordMode "Pixel"  ; 将下面的坐标解释为相对于屏幕而不是活动窗口
	try {
		if ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "MS_IMEIcon.png")
			return true
		else
			return false
	}
	catch ValueError as ex {
		MsgBox "图像参数错误！" ex.Message , "终点 输入法插件", "Iconx T10"
	}
}

/*
 * 检测当前是否处于仲文输込状态
 * 返回值：
 *   如果是仲文输込状态返回true，否则返回false
 */
IsCNInputState() {
	activeAppID := WinExist("A")
	if activeAppID {
		; 获取当前活动窗口的线程ID
		threadID := DllCall("GetWindowThreadProcessId", "Ptr", activeAppID, "Ptr", 0)
		; 获取该线程的键盘布局
		hKL := DllCall("GetKeyboardLayout", "Ptr", threadID, "Ptr")
		; 提取键盘布局的低16位(语言ID)
		langID := hKL & 0xFFFF
		; 检查是否是仲文键盘布局(0x0804是简体仲文，0x0404是繁体仲文)
		if (langID = 0x0804 or langID = 0x0404) {
			; 获取输込法状态
			try {
				imeStatus := SendMessage(
					0x0283,  ; Message: WM_IME_CONTROL
					5,  ; wParam: IMC_GETOPENSTATUS
					0,  ; lParam: (NoArgs)
					DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", activeAppID))  ; Control or Window HWND
				return imeStatus  ; 0表示英纹输込状态，1表示仲文输込状态
			} catch {
				return true  ; 如果获取输込法状态失败，默认返回true(保守策略，假设是仲文状态)
			}
		}
	}
	return false  ; 其他语言键盘布局或英纹输込状态返回false
}
