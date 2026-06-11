/*
 * 说明：存放FinalD项目的自定义程序组信息。
 * 版本：v3.7（v版本号.修订号，如果版本号不同，则表示有重大更新，须要根据下面的【重大更新说明】比较合并更新，或查找文件中有“✨”符号的地方。修订号为不影响功能的修改，可以不管。）
 * 更新：2026/6/11
 * 重大更新说明：
 * v3.x：添加Win系统打开文件窗口（ahk_class #32770）到文件管理器组。适配主程序版本 v7.70.205 ~ 待定
 * v2.x：将此项目所有ahk脚本程序的编码方式统一更改为UTF-8 with BOM格式。只需将你自己的AppGroup.ahk文件的编码格式修改为此编码格式并保存即可。适配主程序版本 v7.68.190 ~ v7.70.204
 * v1.x：将各程序组信息从FinalD.ahk分离出来的首个版本。适配主程序版本 v5.61.162 ~ v7.68.189
 *
 * GroupAdd帮助文档网址：
 * https://wyagd001.github.io/v2/docs/lib/GroupAdd.htm
 * 正则表达式快速参考网址：
 * https://wyagd001.github.io/v2/docs/misc/RegEx-QuickRef.htm
 */

; ※ ahk_class默认区分大小写（除非正则模式下使用i)选项），匹配任意位置。ahk_exe默认不区分大小写（但正则模式时默认区分大小写），匹配程序名称或完整路径。

; 以下为 有自动配对标点功能的编程软件组 定义。（在这些应用程序中禁止此程序自动配对英文标点功能）
GroupAdd "AutoPair", "ahk_class A)Notepad\+\+$"
GroupAdd "AutoPair", "ahk_class A)SunAwtFrame$"  ; JetBrains系列IDE
GroupAdd "AutoPair", "ahk_exe \\Code\.exe$"  ; VSCode
GroupAdd "AutoPair", "ahk_exe \\sublime_text\.exe$"

; 以下为 中文语境应用程序组 定义。（不建议将用于写Markdown的程序添加到此。）
GroupAdd "CN", "ahk_exe \\AliIM\.exe$"  ; 阿里旺旺
GroupAdd "CN", "ahk_exe \\notepad\.exe$"  ; 记事本
; GroupAdd "CN", "ahk_exe \\notepad\+\+\.exe$"  ; 将此软件用于编程时须将此行变成注释
GroupAdd "CN", "ahk_exe \\(QQ|WeChat)\.exe$"  ; QQ 或 微信
GroupAdd "CN", "标记文字$ ahk_exe \\TdxW\.exe$"  ; 通达信中的“标记文字”窗口
GroupAdd "CN", "ahk_exe \\(WINWORD|POWERPNT)\.EXE$", , "A)Microsoft Visual Basic"  ; 微软Office Word 或 PowerPoint（其VBA窗口除外）

; 以下为 不适用须要排除的应用程序组 定义。
GroupAdd "Exclude", "ahk_exe \\(git-)?cmd\.exe$"  ; CMD命令提示符
GroupAdd "Exclude", "ahk_exe \\mintty\.exe$"  ; git-bash终端

; 以下为 文件管理器应用程序组 定义。
GroupAdd "FileManager", "ahk_exe \\dopus\.exe$"  ; Directory Opus
GroupAdd "FileManager", "ahk_exe \\explorer\.exe$"  ; Win系统的资源管理器
GroupAdd "FileManager", "ahk_exe \\Totalcmd\.exe$"  ; Total Commander
GroupAdd "FileManager", "ahk_class #32770"  ; ✨Win系统的“打开文件”窗口

; 以下为 输入法组 定义。（※ 在所有输入法候选窗口中须禁用此程序。）
GroupAdd "IME", "ahk_class A)ATL:"  ; Rime输入法
GroupAdd "IME", "ahk_class A)Microsoft\.IME(\.UIManager)?\.CandidateWindow"  ; 新/旧微软拼音、五笔
GroupAdd "IME", "ahk_class A)So(PY|WB)_Comp"  ; 搜狗拼音、五笔
GroupAdd "IME", "ahk_class A)QQPinyinCompWnd"  ; QQ拼音
GroupAdd "IME", "ahk_class A)QQWubi(Comp|Cand)WndII"  ; QQ五笔
GroupAdd "IME", "ahk_class A)HandyPinyinCandidateWindow"  ; 手心拼音？
GroupAdd "IME", "ahk_class A)BaiduPinyinImeWnd"  ; 百度拼音？
; GroupAdd "IME", "ahk_class A)TfFrameClass"  ; 智能ABC

; 以下为 反应慢的应用程序组 定义。（在发送箭头键后须要停顿几十毫秒）
; GroupAdd "Slow", "ahk_class A)SunAwtFrame$"  ; JetBrains系列IDE
GroupAdd "Slow", "ahk_exe \\AliIM\.exe$"  ; 阿里旺旺

; 以下为 不支持智能标点输入和自动配对功能的应用程序组 定义。
GroupAdd "UnSmart", "ahk_exe \\EXCEL\.EXE", , "A)Microsoft Visual Basic"  ; 微软Excel（其VBA窗口除外）
GroupAdd "UnSmart", "ahk_exe \\SearchUI\.exe$"  ; Win搜索栏
