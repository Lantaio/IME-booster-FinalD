# AGENTS

## 项目概述
这是一个基于 AutoHotkey v2 的 Windows 脚本项目。项目核心代码位于 `Win/FinalD.ahk`，并引用了 `Win/Lib/` 目录下的辅助库。用户可配置项存放在 `Win/MySettings/`，模板和默认配置在 `Win/Settings/`。

## 关键事实
- 只支持 Windows + AutoHotkey v2.0.26 及以上版本。
- 此项目使用 AutoHotkey v2 版脚本语言。
- 所有`.ahk`文件必须保存为 UTF-8 with BOM 编码，尤其是 `Win/FinalD.ahk`、`Win/MySettings/*.ahk` 和 `Win/Settings/*.ahk`。
- `Win/FinalD.ahk` 通过 `#Include "MySettings\AppGroup.ahk"` 和 `#Include "MySettings\Shortcut.ahk"` 加载自定义配置。
- `Win/Settings/` 是默认配置模板，`Win/MySettings/` 是实际运行时的用户自定义配置。

## 主要功能点
- 智能中/英标点输入与配对输入
- 三体按键：短按 / 妙按 / 长按 不同输入行为
- 用 左Shift键 进行常用中/英标点变换，用 右Shift键 进行扩展标点符号变换
- 左Win+左Shift键 将希腊字母转换为对应的英文字母，将罗马数字转换为对应的阿拉伯数字和上、下标数字形式；左Win+右Shift键 将英文字母转换为对应的希腊字母，将阿拉伯数字转换为对应的大、小写罗马数字形式。
- 字母方向键、智慧模式/操控模式、表格兼容模式、中文标点提示等可切换的扩展功能

## 开发建议
- 修改脚本前，优先检查 `Win/MySettings/` 是否有自定义内容，避免覆盖用户设置。
- 若需要新增功能或修复行为，应优先在 `Win/FinalD.ahk` 中搜索已有相似逻辑，保持项目内部风格一致。
- 代码中已有大量中文注释，可直接参考原注释理解设计意图。
- 对于输入法识别和窗口分组，优先使用 `GroupAdd` 语法，并遵循现有 `AppGroup.ahk` 中的命名与分组规则。

## 运行与验证
- 该项目无构建系统，直接使用 AutoHotkey 运行 `Win/FinalD.ahk`。
- 手动测试时，需确认当前环境为 AutoHotkey v2.0.26+，并检查是否正确加载 `Win/MySettings` 配置。
- 主要运行入口：`Win/FinalD.ahk`。

## 参考文档
- 项目 README：`README.md`
- 运行和安装说明：`README.md#安装步骤`
- 项目 ChangeLog：`Joy/ChangeLog.md`
- 免责声明：`Win/免责声明Disclaimer.md`

## AI 代理工作方式
- 处理任务时，用简体中文与项目术语对齐。
- 避免在 `Win/Settings/` 中直接改动默认模板；优先在 `Win/MySettings/` 中修改用户配置。
- 若需要补充说明，优先引用现有 `README.md` 中的安装与功能说明。
- 不要试图将此项目迁移至其他语言或平台。
