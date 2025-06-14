# 更新日志
## v5.59.151
*2025/6/8*

### 新增功能
* 🐣️大部分标点通过新增的drift函数来实现循环变换，使代码更简洁直观，并且更方便自定制（2025/2/10~11）
* 🐣️增加Debug全局变量来控制所有调试语句的开关（2025/4/6）
* 🐣️为容易和英文标点混淆的中文标点符号添加提示信息，并可开/关（此功能默认关闭）（2025/5/13）
* 🐣️增加有自动配对标点功能的编程软件组，在这些软件中禁用本程序的自动配对功能（2025/5/14）

### 优化更改
* 🐱‍🏍加入exit命令不执行后面无谓的代码（2025/2/10）
* 🔧调整右Shift键变换数字的逻辑（2025/2/11）
* ✨️利用Switch语句的特性无需exit命令，精简代码（2025/2/11~12）
* ✨优化检测回车换行符的方法（2025/5/1）
* ✨️增加加强版获取光标坐标位置函数以便更好地显示提示信息（2025/5/1）
* ✨️将阿里旺旺添加到中文语境应用程序组（2025/5/1）
* 🔧️调整‘\’和‘$’的右<kbd>Shift</kbd>键扩展标点符号列表（2025/5/13）
* 🛠️在输入标点时，处于中文输入法的中文输入状态时此插件才生效（2025/6/8）

### 缺陷修复
* 🛠️修复获取光标前一个英文片段函数的缺陷，并优化循环语句体（2025/2/16）
* 🛠️修复‘!’键右<kbd>Shift</kbd>键标点漂移列表的错误（2025/2/19）
* 🛠️修复微软Office Word和PowerPoint的VBA编程窗口都归类为中文语境的问题（2025/5/1）
* 🛠️修复showTip显示提示信息函数在某些应用程序（Chrome）中的问题（2025/5/22）

## v5.55.133
*2025/2/8*

### 新增功能
* 🐣️为中文‘‘’和‘“’这些容易混淆的标点添加提示信息（2025/1/21）
* 🐣️加入检测击键方式函数，并通过长按调出Rime标点候选窗口（2025/1/29）
* 🐣️长按<kbd>;</kbd>键光标向右移动1格。<kbd>Alt</kbd>+<kbd>Del</kbd>剪切咣标后1个字符，用于过度自动配对标点的后续操作。<kbd>Alt</kbd>+<kbd>Backspace</kbd>剪切咣标前1个字符（2025/1/31）
* 🐣️在非自动的配对时，短按后标点光标回到配对标点中间，长按（超过0.2秒）光标*不会*回到配对标点中间（2025/2/4）

### 优化更改
* ✨将通用版和Rime定制版合并成1个程序文件（2025/1/19）
* ✨️将hasPeiDviBD函数拆分为hasPeiDviBD和isPeiDviBD 2个函数（2025/1/22）
* ✨️添加了一些输入法到输入法组（2025/1/27）
* ✨️⚠在全键盘漂移时调换左/右<kbd>Shift</kbd>键的功能，左<kbd>Shift</kbd>键将希腊字母变换为英文字母，右<kbd>Shift</kbd>键将英文字母变换为希腊字母。这样使得左<kbd>Shift</kbd>键主要用于变换回常用（普通）符号，而右<kbd>Shift</kbd>键主要用于变换到特殊符号，方便记忆（2025/1/27）
* ⚙因新版AutoHotkey修复了修饰键状态偶然不正确的问题，所以不再需要优化代码（2025/2/2）
* ✨️将‘`’和‘~’不常用扩展符号更换为常用大小写希腊字母（2025/2/4）
* 🐱‍🏍不通过函数检测按键模式，减少不必要的函数调用（2025/2/6）
* ✨️为各个函数注释中的参数和返回值添加类型信息（2025/2/6）

### 缺陷修复
* 🛠️修复‘‘’和‘“’的输入和变换的缺陷（2025/1/21）
* 🛠️修复部分标点在中文语境软件中的缺陷（2025/2/7）

## un5.50.116 & rm5.50.115
*2025/1/18*

### 新增功能
* 🐣️新增[大小写漂移](../README.md#大小写漂移)功能，使得当<kbd>CapsLock</kbd>在不正确的状态时可以快速变换为期望输入的内容。不需要在意<kbd>CapsLock</kbd>的状态，也不需要按<kbd>Backspace</kbd>键啦。（2025/1/10）
* 🐣️在不是自动配对的情况下，输入成对的标点时光标会回到成对标点中间（2025/1/12）

### 优化更改
* 🔧️修改smartType函数为smartChoice，修改hasPeiDviBD函数以提高复用率（2025/1/12）
* ✨️调整switch语句块的缩进样式（2025/1/12）
* 🐱‍🏍Rime定制版中按<kbd>^</kbd>键改为智能输入‘^’号或‘……’号，改用<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>^</kbd>触发输入扩展标点符号。另外，用<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>$</kbd>触发输入大写数字和大写金额（2025/1/16）
* 🔧改用左<kbd>Win</kbd>+<kbd>0</kbd>为启用/停用此程序的快捷键，改用左<kbd>Win</kbd>+<kbd>Alt</kbd>+<kbd>0</kbd>为显示程序版本信息的快捷键，以避免和Windows系统的快捷键冲突（2025/1/18）

### 缺陷修复
* 🛠️重写获取光标前一个英文片段的函数，原来的函数功能上有问题（2025/1/11）

## un5.48.109 & rm5.48.107
*2025/1/6*

### 新增功能
* 🐣️从挂起状态切换到运行状态时显示各项功能的状态信息（2024/12/19）
* 🐣️在此程序的“关于信息”中加入快捷键及各项功能的状态信息，并使“关于信息”在此插件停用时也可以显示（2024/12/19）

### 优化更改
* ✨将运行/暂停 此插件的快捷键从 左<kbd>Win</kbd>+<kbd>Alt</kbd>+<kbd>h</kbd>更改为 左<kbd>Win</kbd>+<kbd>c</kbd>，能省则省（2024/12/19）
* ✨优化数字漂移的逻辑，使得在变换期间可以随时变换到另一边（2024/12/20）
* 🔧删除因为错误理解全局变量的使用方法而导致的冗余代码（2024/12/24）
* ✨️统一‘■’、‘◆’、‘▲’、‘●’和‘★’的输入逻辑以便于记忆，设计方案图增加助记说明（2025/1/5）

### 缺陷修复
* 🛠️修复不存在当前窗口时会弹出错误信息的问题（2024/12/20）

## un5.45.101 & rm5.45.99
*2024/12/16*

### 新增功能
* 🎊新增（表格）[兼容模式](../README.md#兼容模式)（即关闭智能标点输入和自动配对功能），以及添加相应的应用程序组，使得在各种软件的表格中可以正常输入，并可用<kbd>Shift</kbd>键变换标点（2024/12/12）

### 优化更改
* ✨增加“须要排除的应用程序组”（2024/12/6）
* ✨简化各程序组的命名（2024/12/6）
* ✨增加“文件管理器应用程序组”（使得在文件管理器中可以正常用<kbd>Shift</kbd>键连续选取多个文件）（2024/12/14）

### 缺陷修复
* 🛠️修复排除Excel程序的缺陷（2024/12/6）
* 🛠️修复仅按下多个功能键时，最后才释放<kbd>Shift</kbd>键会触发标点变换的缺陷（2024/12/14）
* 🛠️修复开启兼容模式时自动配对标点的缺陷（2024/12/16）

## un4.42.92 & rm4.42.90
*2024/11/5*

### 新增功能
* 🎊比方便快捷地变换标点符号更爽的是一击即中，因此新增[中文语境软件优化](../README.md#中文语境软件优化)，优化偏中文语境软件的标点输入体验（2024/10/20）

### 优化更改
* 🔧调整‘'’、‘"’、‘‘’和‘“’的配对逻辑（2024/11/2~4）
* 🔧因应中文语境程序组功能调整‘\[’和‘\]’的输入逻辑（2024/11/5）

## un3.40.87 & rm3.40.85
*2024/9/25*

### 优化更改
* 🔧️按‘~’键时改回根据前面字符的中英文情况上屏相应的中英文标点（2024/9/22）
* 🔧️将显示程序信息的快捷键从右<kbd>Shift</kbd>+左<kbd>Win</kbd>键修改为右<kbd>Shift</kbd>+<kbd>Esc</kbd>键（2024/9/25）

### 缺陷修复
* 🛠️修复在文件管理器中用<kbd>Shift</kbd>键选择连续多个文件时的问题（[#7](https://github.com/Lantaio/IME-booster-FinalD/issues/7)）（2024/9/21）
* 🛠️修复部分功能开关在被屏蔽软件中也被屏蔽的问题（2024/9/23）

## un3.40.83 & rm3.40.81
*2024/9/17*

### 新增功能
* 🎊以**更好记、更快速地输入标点符号**为目标重新设计左、右<kbd>Shift</kbd>键标点漂移方案（2024/8/25~9/7）

### 优化更改
* 🐣️通用版通过程序组功能排除所有常用的输入法候选框，无需用户设置（2024/8/25）
* ✨增加函数精简冗余代码（2024/9/7~8）
* ✨优化英文引号的配对逻辑（2024/9/7）
* 🔧️输入‘~’标点时默认输入英文标点（2024/9/9）
* 🐱‍🏍用AI优化各扩展标点符号的排序（2024/9/12）

## un2.36.75 & rm2.37.74
*2024/8/18*

### 新增功能
* 🎊新增[全键盘漂移](../README.md#全键盘漂移)功能。大、小写英文字母可变换为对应的大、小写希腊字母，数字可变换为上、下标数字、希腊数字和数字序号（2024/8/10~17）

### 优化更改
* 🎊再次突破思想的桎梏，完全以“**更少的按键、更人性化的设计、更方便快捷的方式输入标点符号**”为核心理念，重新设计此插件的标点符号漂移方案（2024/6/18~8/9）
* 🛠️优化‘‘’和‘“’号的输入逻辑（2024/8/10~13）
* ✍🏻️完善各函数的注释（2024/8/18）

### 缺陷修复
* 🛠️明确排除微软拼音的候选窗口，以防止可能存在的问题（2024/6/17）
* 🛠️修复仅按下Shift+Ctrl键的情况时，先释放Ctrl键再释放Shift键会触发变换光标前标点的问题（2024/7/13）

## v1.32.66
*2024/6/16*

### 新增功能
* 🎊摒弃形式主义，回归“**以更少的按键、更人性化的设计、更舒服的方式输入标点符号**”这个初心，重新设计此插件的功能（2024/6/7~16）
* 🐣️单引号和双引号手动配对时，光标移动到配对标点中间（2024/6/15）

### 优化更改
* 🔧️适当增加等待剪贴板更新的最大等待时间，以进一步减少前一个或后一个字符被删除的问题（2024/6/6）
* ✨️重命名部分函数名称，更简洁（2024/6/11）

### 缺陷修复
* 修复用<kbd>Shift</kbd>键+鼠标滚轮来左右移动屏幕会触发替换光标前的标点符号的bug（[#10](https://github.com/Lantaio/IME-booster-FinalD/issues/10)）（2024/6/7）
* 修复个别临时标点没有修改的bug（2024/6/10）
* 修复各个须要排除的软件的正则表达式问题，并提高性能（2024/6/15）

[早期的更新历史](ChangeHistory.md)