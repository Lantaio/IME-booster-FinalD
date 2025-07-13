/*
 * (注意：⚠此函数由AI提供，且未经审查！)
 * 检测字符串是不是emoji
 * 参数：
 *   str (string) 待检测的字符串
 * 返回值：
 *   如果待检测的字符串是emoji返回true，否则返回false
 */
IsEmoji(str) {
	; 空字符串或太长肯定不是
	if (str == "" || StrLen(str) > 8)  ; 8是经验值，大多数Emoji不超过这个长度
		return false

	; 获取字符的Unicode码点
	codePoint := Ord(str)

	; 主要Emoji范围
	return (codePoint >= 0x1F600 && codePoint <= 0x1F64F) ; 表情符号
	|| (codePoint >= 0x1F300 && codePoint <= 0x1F5FF) ; 杂项符号和象形文字
	|| (codePoint >= 0x1F680 && codePoint <= 0x1F6FF) ; 交通和地图符号
	|| (codePoint >= 0x1F700 && codePoint <= 0x1F77F) ; 炼金术符号
	|| (codePoint >= 0x1F780 && codePoint <= 0x1F7FF) ; 几何图形扩展
	|| (codePoint >= 0x1F800 && codePoint <= 0x1F8FF) ; 补充箭头-C
	|| (codePoint >= 0x1F900 && codePoint <= 0x1F9FF) ; 补充符号和象形文字
	|| (codePoint >= 0x2600 && codePoint <= 0x26FF)   ; 杂项符号
	|| (codePoint >= 0x2700 && codePoint <= 0x27BF)   ; 装饰符号
	|| (codePoint >= 0xFE00 && codePoint <= 0xFE0F)   ; 变体选择符
	|| (codePoint >= 0x1F1E6 && codePoint <= 0x1F1FF) ; 国旗符号
	|| (codePoint >= 0xE0020 && codePoint <= 0xE007F) ; 标签
}
