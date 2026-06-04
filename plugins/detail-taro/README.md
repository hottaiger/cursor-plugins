# detail-taro

在 **detail-taro3** 仓库中开发 Taro 商详页（RN / H5 / 小程序）的 Cursor 插件。

## 组件

| 类型 | 名称 | 说明 |
|:-----|:-----|:-----|
| Rule | `detail-taro-conventions` | 商详页目录、命名与多端开发基线约束 |
| Skill | `detail-taro-page-dev` | 新增/重构商详 feature、组件、store、service 的工作流 |

## 使用

- 在商详相关任务中，Agent 会自动应用规则并选用 skill。
- 也可在对话中直接说明：「按 detail-taro 规范实现某某 feature」。

## 本地安装

插件目录同步至：

```text
~/.cursor/plugins/local/detail-taro/
```

或在 marketplace 仓库根目录通过 Cursor 加载本仓库。

## 扩展

可在 `skills/` 下继续添加专项 skill（样式、Store、Native API、图片资源等），并在 `plugin.json` 中保持 `./skills/` 发现路径。
