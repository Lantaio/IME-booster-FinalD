; #Requires AutoHotkey v2.0

/**
 * @description 将调试字符串中的转义换行符和实际换行符转换为可显示的文本。
 * @param {String} str 需要格式化的字符串。
 * @returns {String} 格式化后的字符串。
 */
FormatString(str) {
	return RegExReplace(StrReplace(StrReplace(str, '`r', 'r'), '`n', 'n'), '`a)\R', 'ρ')
}