/*
 * 版本：v1.4（v版本号.修订号，如果版本号不同，则表示有重大更新，须要根据下面的【重大更新说明】比较合并更新。修订号为不影响功能的修改，可以不管。）
 * 更新：2026/3/23
 * 重大更新说明：
 * v1.x: 将各程序组信息从FinalD.ahk分离出来的首个版本。适配主程序版本 v5.61.162 ~ 待定
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
GroupAdd "Exclude", "ahk_exe \\cmd\.exe$"  ; CMD命令提示符

; 以下为 文件管理器应用程序组 定义。
GroupAdd "FileManager", "ahk_exe \\dopus\.exe$"  ; Directory Opus
GroupAdd "FileManager", "ahk_exe \\explorer\.exe$"  ; Win系统的资源管理器
GroupAdd "FileManager", "ahk_exe \\Totalcmd\.exe$"  ; Total Commander

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
