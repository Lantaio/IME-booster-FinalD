; #Requires AutoHotkey v2.0
/**
 * @description 解析 YAML 中的字符串，去除外层引号。
 * YAML 中键和值通常写成 '。' 或 "." 的形式；这里去掉外层引号，避免后续把实际符号当作带引号文本处理。
 * @param {String} value 需要处理的字符串。
 * @returns {String} 去除引号后的原始字符内容。
 */
parseYAMLScalar(value) {
	value := Trim(value)  ; 去掉行首行尾空白，使得像 "  '。'  " 这种格式也能正常处理
	if value = ''  ; 空字符串直接返回，避免后面索引出错
		return ''
	if (SubStr(value, 1, 1) = "'" and SubStr(value, -1) = "'") or (SubStr(value, 1, 1) = '"' and SubStr(value, -1) = '"')
		return SubStr(value, 2, StrLen(value) - 2)  ; 去掉外层的一对引号，保留真实标点字符本身
	return value  ; 如果本来就不是带引号的值，就直接返回原始内容
}
/**
 * @description 读取并反序列化给定的 YAML 配置文件。
 * 它会逐行扫描 YAML，识别 Left/Right 章节和其后的键值列表，
 * 然后将每个键映射到字符串数组，用于字符漂移。
 * @param {String} filePath 要反序列化的配置文件路径。
 * @returns {Map} 由左、右章节组成的漂移映射表。
 */
getDriftMap(filePath) {
	buildMap := Map("Left", Map(), "Right", Map())  ; 初始化两套映射：左右Shift分别保存各自的漂移列表
	if !FileExist(filePath)  ; 如果文件不存在，就返回空配置，不影响其它功能
		return buildMap
	text := FileRead(filePath, "UTF-8")  ; 把 YAML 全部读成字符串
	; if text = ''  ; 空文件直接返回空配置
	; 	return driftMap
	section := ''  ; 当前处于哪个分组：Left / Right
	for line in StrSplit(text, "`n", "`r") {  ; 逐行扫描，兼容 Windows 的 CRLF 和 LF 两种换行方式
		line := Trim(line)  ; 去掉首尾空白，方便判断注释和章节头
		if line = '' or RegExMatch(line, '^\s*#')  ; 跳过空行和注释行
			continue
		if RegExMatch(line, '^(Left|Right)\s*:', &match) {  ; 识别 "Left:" / "Right:" 章节头
			section := match[1]  ; 切换到当前章节
			continue
		}
		if section = '' || !InStr(line, ': ')  ; 只处理当前分组下的键值列表
			continue
		keyText := Trim(SubStr(line, 1, InStr(line, ': ') - 1))  ; 取出键名，例如 "." 或 "?"
		key := parseYAMLScalar(keyText)  ; 去掉键名周围引号，得到真实符号
		if !InStr(line, '[ ')
			listText := Trim(SubStr(line, InStr(line, ': ') + 1, InStr(line, ' #') ? InStr(line, ' #') - InStr(line, ': ') : StrLen(line) - InStr(line, ': ')))  ; 如果没有方括号，取出冒号后面至注释（如果有的话）之前的内容作为列表内容
		else
			listText := Trim(SubStr(line, InStr(line, '[ ') + 1, InStr(line, ' ]') - InStr(line, '[ ')))  ; 取出列表内容，例如 "'。', '.'"
		list := []  ; 这个键对应的漂移顺序列表
		if listText != '' {  ; 如果列表不是空的才继续解析
			for item in StrSplit(listText, ', ') {  ; 按逗号拆分列表项
				value := parseYAMLScalar(Trim(item))  ; 每一项也去掉引号形成真实字符
				if value != ''  ; 跳过空项，避免把空字符串写进列表
					list.Push(value)
			}
		}
		buildMap[section].Set(key, list)  ; 把 "键 -> 列表" 保存进对应的 Map 中
	}
	return buildMap  ; 返回整个配置对象，供后续查表使用
}
/**
 * @description 读取并合并多个漂移配置文件。
 * 配置文件按照参数顺序读取，第一个配置作为基础映射表，后续配置依次合并；
 * 如果多个配置包含相同的触发键，则按顺序追加其漂移列表。
 * @param {String*} driftMapList 漂移配置文件名列表，例如："Number", "English", "Greek"。
 * @returns {Map} 合并后的、由 Left 和 Right 两个章节组成的漂移映射表。
 */
assembleMaps(driftMapList*) {
	; 按参数顺序读取用户自定义配置文件夹中的漂移映射表
	assembleMapList := []
	for driftMap in driftMapList
		assembleMapList.Push(getDriftMap(A_ScriptDir "\MySettings\" driftMap ".yaml"))  ; 将参数列表中的映射表文件名转换成真实文件路径，并通过getDriftMap函数将文件转换为映射表，然后添加到assembleMapList数组中，下面再按先后顺序进行合并。
	; 没有提供配置名称时返回空映射，避免后续访问不存在的基础映射
	if assembleMapList.Length = 0
		return Map("Left", Map(), "Right", Map())
	; 第一个映射作为基础，后续映射都合并到它后面
	assembledMap := assembleMapList[1]
	if assembleMapList.Length = 1
		return assembledMap
	for mapIndex, extendMap in assembleMapList {
		if mapIndex = 1
			continue
		; 分别合并 Left 和 Right 章节中的键—值
		for section in ["Left", "Right"] {
			for key, list in extendMap[section] {
				if assembledMap[section].Has(key)  ; 如果basicMap中已经存在同名键
					assembledMap[section][key].Push(list*)  ; 将当前映射表中的值列表追加到基础表同名键的值列表后
				; for value in list  ; 如果须要进一步对每个value值进行处理，就用for循环
				; 	basicMap[section][key].Push(value)
				else  ; 否则（当前映射表中的键名在basicMap中不存在），则直接将该键值对添加到basicMap中。
					assembledMap[section].Set(key, list)
			}
		}
	}
	return assembledMap
}
