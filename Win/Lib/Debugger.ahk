FormatString(str) {
	return RegExReplace(StrReplace(StrReplace(str, '`r', 'r'), '`n', 'n'), '`a)\R', 'ρ')
}