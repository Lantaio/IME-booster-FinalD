# *FinalD / 终点 🏁*
*2024年5月20日*

*温馨提示：可通过此文档右上角的〔标题列表〕按钮，可快速转到某个标题。心急的朋友可以直接从[主要功能](#主要功能)开始看。*

## 项目概述
啥？标点符号也玩漂移？对，此中文输入法插件（以下简称此插件）是中/英文标点符号智能输入程序，目标是提高中英混输的速度，实现**真正意义上的中英混输**！你不需要再神经兮兮不时查看任务栏的输入法图标，看看是不是在正确的中/英文输入状态。你从来没有体验过的既丝滑又强大的输入感受。

## 项目缘起
如果你是一个程序员，那么很可能和我有同样的遭遇，就是用着一个号称是中英混输的中文输入法，却依然经常需要按<kbd>Shift</kbd>键切换中/英文输入模式。而且很有可能是当你发现输错了内容，需要按<kbd>Backspace</kbd>键之后，再去切换中/英输入模式。这算哪门子中英混输呢？
为什么会这样？问题出在哪里？标点符号，对，问题就出在标点符号。那些号称中英混输的输入法只实现了中/英文单词的混输，却没有做到中/英文标点符号的混输。
这个插件的目的就是要把这最后的一公里走完，让标点符号都实现中英混输，将所有中文输入法带进一个无需切换中/英模式的新纪元。

## 方案设计
在说明此插件的功能之前，得先上一张设计方案图，有了它再来忽悠就容易多了。

![设计方案图](joy/assets/plan.png)

呃...是不是有点复杂？不要方，你听我狡辩。这张图虽然貌似复杂，但看完下面的解析，你就会觉得它很简单。
1. 先说我的主要思路，要是可以按标点键的时候根据前一个字符是英文还是中文来上屏期望的标点符号，它不香吗？这便是上图第1列和第2列所列标点的意思。怎么样？很简单嘛。写代码的时候一般都是英文，其中的标点符号自然也是英文。中文写作的时候标点符号又自然是中文，是不是很智能？但不是说前一个字符是中文，就一律上屏中文标点，有些相对低频的中文标点符号会让位于对应的高频英文标点，例如：无论前一个字符是中文还是英文，按<kbd>[</kbd>键都是上屏英文‘[’号，而不是在中文时上屏中文的‘【’号。你可能会说这样一来会导致混乱，二来我要是想输入‘【’号怎么办？而我则认为对一个输入法而言，**速度是首要的考虑因素**，使用的时候感觉到爽才是最重要的。所以我倒是将标点符号的输入频率作为最重要的考量因素。用下来你就会明白，频率高代表命中率高。至于第二个问题，就由第2个功能来解决。
2. 可能有些看官已经想到了，第1个功能虽然可以应付大部分情况，但现实哪有这么简单，比如说有些时候我们在中文里夹杂着English，刚好后面要输入标点符号，那出来个英文标点不对呀。又比如说有时一句话刚好以数字结束8。那按照第1个功能它出来个小数点也不是我期望的啊，这不是还得按<kbd>Backspace</kbd>键吗？ \
但你有没有想过，按<kbd>Backspace</kbd>键，然后再按<kbd>Shift</kbd>键切换中/英文输入模式，再接着干什么？其实还是按刚才那个标点按键啊！也就是说其实不是我们按错了键，只是电脑上屏了不是我们期望的标点符号而已。有没有更好的方法，不是我们去做这些烦人的改正工作，而是由电脑去做？答案是肯定的，这便是上图第3列要做的事情，用左<kbd>Shift</kbd>键来告诉电脑：“你搞错了，给我改过来。” \
以前面的2个问题为例，输入English之后按<kbd>,</kbd>键，按照1的功能设计，会上屏一个英文‘,’号。这时只需要按一下左<kbd>Shift</kbd>键，它便可以将光标前面的英文逗号切换为中文‘，’号。在输入阿拉伯数字之后如果按<kbd>.</kbd>键，默认会上屏小数点。而如果你想输入的是中文句号的话，也是只需要按1下左<kbd>Shift</kbd>键来将光标前的小数点快速切换为中文‘。’号。而且这种切换不是单向的，可以中/英循环切换的。
3. 本来在1和2功能的加持下，输入标点符号已经很爽了，已经可以抛弃那个忽悠人的中/英文模式切换功能了。但可能会有老学究跳出来说：“小样，就这么点能耐好意思拿来吹牛？中华文化博大精深，就这两道板斧，连基本的中文标点符号都弄不齐全，我要是个编字典的还不一样累死。”想想也是……哎，这不还有一个右<kbd>Shift</kbd>键吗？就用它来做上图第4列『标点轮换』的功能键，每按1次就按次序切换到下一个标点符号。这回不单止可以包括所有常用的中文标点符号，甚至还可以安排一些常用的数学符号或者特殊符号咯。
4. 老学究还要找茬，说每按1次右<kbd>Shift</kbd>键才切换1个符号，那我想输入排在后面的标点符号的话，还是得按好几次啊。真是得寸进尺，适可而止啊，不能太欺负人。这样吧，如果你觉得这样还不够爽，那我忽悠你用Rime输入法，因为它在输入标点符号的时候可以像输入字词一样弹出候选框，就像上图的第5列（还可以很方便地自定制），直接选择你想要输入的标点符号就可以马上转换为那个标点了。
5. 最后补充一下，如果你和我一样，经常在做梦的时候和地外文明有接触，地球上所有的标点符号都得用上的话（！@#$×%），那么Rime输入法还是可以满足你对速度与激情的追求嘀，有需要可以瞧瞧[这个表](https://github.com/Lantaio/Rime-schema-JoySchema/blob/main/joy.symbols.yaml)

怎么样，看完上面的设计思路，再来看这张设计图，是不是简单明了？

## 主要功能
* 根据前一个字符是中文或是英文（包括数字）来上屏相应的标点符号，并且成对的标点符号在特定情况下会自动配对，主打智能化和一个爽字。
* 左<kbd>Shift</kbd>键作为中/英标点符号快速切换键。另外，当光标在成对的标点符号中间时，此功能键还可以快速切换成对的标点符号。例如：成对的`""`和`“”`互相切换,中文`【】`和英文`[]`互相切换等。如果光标不在成对的标点中间，也可以单独替换光标前的标点符号。**左<kbd>Shift</kbd>键主打中英常用标点快速切换**。
* 右<kbd>Shift</kbd>键可按设计方案图中第4列『标点轮换』的次序来轮换全部常用的中英文标点符号。另外，当光标在成对的标点符号中间时，此切换键同样可以自动切换成对的标点符号。右<kbd>Shift</kbd>键还有一个区别于左<kbd>Shift</kbd>键的功能，就是在对‘'’和‘"’的转换时，只对光标前的符号进行单个切换，而不会对成对的‘''’和‘""’进行切换，此功能在某些场景下非常有用。**右<kbd>Shift</kbd>键主打常用标点全覆盖**，以及刚说的，对左<kbd>Shift</kbd>键的功能补充。
* 使用此输入法外挂可以让大多数会自动配对和不会自动配对标点符号的编辑器都有一致的自动配对标点符号输入体验。
* 改进数字后输入小数点的体验。数字后想输入中文句号，只需要在输入小数点后按1下左（或右）<kbd>Shift</kbd>键。另外，一般的中文输入法在你想输入6.5而不小心输入了65的时候，当你按<kbd>Backspace</kbd>键后按<kbd>.</kbd>键想上屏小数点时，却一般会上屏中文‘。’号。也就是说你得再删除多一个没有输错的数字，再输一遍，才可以输入6.5，是不是很不爽？此插件无论任何时候，只要光标前面是数字，按<kbd>.</kbd>键都会上屏小数点。
* 为Markdown写作做了充分的考虑与优化。
* 此项目除了有一个适用于大多数中文输入法的uni版本之外，还有一个和Rime输入法深度整合的rime版，它借助Rime输入法输入标点符号时可以弹出候选框的功能来对右<kbd>Shift</kbd>键功能进行增强，可以更快地切换想要输入的符号。但由于是深度整合，所以须要和我的另一个开源项目配合使用。或者根据你的标点列表对此程序进行修改才可以正常使用。

## 版权许可
注意，此项目是一个保留版权的Copyright©项目，不是一个放弃版权的Copyleft项目。此版权授权你在非售卖的情况下对此项目进行任意修改，以使其更适合你的使用习惯。但如果你将此插件（包括你对其进行修改的版本）用于销售目的，则须要向我支付销售收益的一半金额。

## 收费规则
你可以*免费*将此插件用于**个人用途**以及在**非营利性组织**中使用。但如果你将此插件（包括你对其进行修改的版本）用于能获取报酬的工作或者商业用途，则需要在**3个月免费试用期**后向我支付费用购买使用权。暂定为每个操作系统（包括虚拟机系统）收取人民币￥2元，即可获得此项目的永久使用权，并可免费获得所有后续更新的使用权。注意，此收费不包括任何软件功能及其稳定性方面的承诺或保证，现阶段也无法提供技术支持服务。

其它免除费用的情形：
* 如果你在GitHub上给[此项目](https://github.com/Lantaio/IME-booster-FinalD-Win)星标⭐，并且是排名前100万名的标星用户，则可以免费获得授予给1个操作系统的此项目及所有后续更新的永久使用权，以感谢你对此项目的认可与支持🤝
* 如果你将此插件介绍给*没有听说过*此插件的朋友，则每推荐给1位朋友可以减免1元费用，上不封顶（可用于抵扣多个许可证的费用）。我敢肯定，你从来没有参加过这么有意义并且真正可以省钱的传销活动😁
* 如果你对我的项目提出有建设性的建议💡并被我采纳的话，也可以免费获得授予给1个系统的此项目及所有后续更新的永久使用权。

付款请备注“终点插件”，谢谢。

![支付宝收款码](joy/assets/AliPay.png)
![微信收款码](joy/assets/WePay.png)

## 打赏支持
除了商业用途需要购买使用许可之外，如果你觉得此插件很赞，提高了你的码字效率，让你喜出望外，也可以通过上面的付款码给我打赏支持，金额随喜。同样请备注“终点插件”，多谢支持与鼓励🤝

## 安装需求
* 由于此插件是基于AutoHotkey这个软件而写的脚本程序，而AutoHotkey这个软件只有Windows版本，也就是说**此插件只能在Windows系统使用**。
* AutoHotkey这个神器占用磁盘空间不足10MB,而且在你不运行脚本的时候不会运行占用内存。此插件运行时只占用1.5MB内存，而且CPU占用率极低，长期为0%。此插件只会在运行时接管所有标点符号按键事件，不会对原有的输入法有任何改动，并且可以随时运行、暂停和关闭，不必担心对你的系统会有。

## 安装步骤
1. **安装依赖软件**：如果未安装AutoHotkey，先去[下载](https://www.autohotkey.com/)并安装（必须安装2.0或更新的版本）。
2. **下载并运行插件文件**：此项目只有1个程序文件，`FinalD_uni.ahk`是通用版（首次运行需要做点小修改，后面会讲到），理论上可用于所有中文输入法。`FinalD_rime.ahk`是Rime输入法深度整合版，必须结合我的另一个开源项目[惊喜输入方案](https://github.com/Lantaio/Rime-schema-JoySchema)来使用。将你想使用的文件下载到你的电脑的任意位置。
3. 修改文件，**让插件识别你所用的输入法**(uni版默认设置为搜狗拼音输入法，如果你用的是搜狗拼音输入法，无需此步骤，直接做第5步。rime版已设置好，无需此步骤，直接做第5步。）：
	1. 在文件管理器中鼠标右键点击`FinalD_uni.ahk`文件，在右键菜单中点击「Edit script」编辑此脚本文件。
	2. 定位到第213行，下面几行注释列出了几种常用的输入法的`ahk_class`值。如果你用的输入法在其中，就用它的值替换第213行中的“`SoPY_Comp`”。
	3. 保存文件并关闭编辑器。（**注意：须要保存为UTF-8编码格式！**如果不懂直接保存就行）
	4. 做下面第5步。
4. 如果你所用的输入法在第3步的注释中没有列出来，可以**通过『Window Spy』获取输入法的`ahk_class`值**：
	1. 点击运行下载的文件。
	2. 运行插件后在电脑右下角任务栏处会有个绿色的H图标，鼠标右键点击此图标，在右键菜单中点击「Window Spy」打开『Window Spy for AHKv2』窗口。
	3. 在文件管理器中鼠标右键点击`FinalD_uni.ahk`文件，在右键菜单中点击「Edit script」编辑此脚本文件。
	4. 定位到第213行，先任意输入一些拼音，待出现输入法候选框之后，鼠标移动到输入法候选框上，然后查看在3.2步骤打开的『Window Spy』窗口，找到并复制第2行“ahk_class...”的内容。
	5. 用上一步复制的“ahk_class...”替换第213行中的`ahk_class SoPY_Comp`，然后保存并关闭编辑器。
	6. 最后，用鼠标右键点击电脑右下角的绿色H图标，在右键菜单中点击「Exit」。
5. 点击（或双击）运行文件。🎉🎉🎉乌拉！感受速度与激情吧！

## 后续使用
* 不要忘了还有**更强大的Rime深度整合版**哦，有兴趣的话请转到我的[惊喜输入方案](https://github.com/Lantaio/Rime-schema-JoySchema)了解。
* 如果你想将此插件**添加为开机启动项**，可以到AI网站[Kimi](https://kimi.moonshot.cn/)向它提问：“如何将AutoHotkey脚本添加为开机启动项？”
* 如果在某些情况下你需要**临时禁用此插件**的话，无须关闭此插件，只需用鼠标右键点击电脑右下角的绿色H图标，在右键菜单中点击「Suspend Hotkeys」。（**注意：点击「Pause Script」没有用！**）当你想恢复使用此插件时重复此步骤即可。

## 卸载步骤
如果你不喜欢用此插件，可以通过下面简单几个步骤来删除它：
1. 用鼠标右键点击电脑右下角的绿色H图标，在右键菜单中点击「Exit」，关闭此插件。
2. 打开系统的『文件资源管理器』，找到下载的此项目的文件并删除。
3. 打开系统的『控制面板』→『程序和功能』，卸载AutoHotkey程序。

## 已知问题
* 只支持Win系统，不支持Mac和Linux（但听说这2个系统都有类似AutoHotkey的软件）。
* 须要在输入法设置中禁用通过<kbd>Shift</kbd>键切换中/英文输入模式，建议改用<kbd>Ctrl</kbd>键。
* 不支持Excel。
* 不支持CMD命令提示符，但支持PowerShell。
* 输入标点符号时由于是通过选择光标前、后字符来决定上屏哪个标点，因此可能会出现短暂闪动，Word等反应慢的程序尤为明显。
* 部分需要按<kbd>Shift</kbd>键上屏的标点不能通过一直按着来重复发送，但你可以尝试一下，大部分常见的用作重复发送的标点符号都是可以正常使用的。
* 不能在选择了内容的情况下输入标点符号，会出现非预期的结果。但在Obsidian和Sublime Text中编辑Markdown时可以选择内容后按‘\*’键或‘`’键等来设置格式。
* 段落开头第1个字符是标点符号时统一上屏英文标点。
* Word中英文单双引号自动转换为中文单双引号的问题
* 此插件可以支持PowerPoint，但出于速度考虑默认情况下禁用了对其的支持。

