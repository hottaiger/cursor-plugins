# cursor-plugins

个人 Cursor 插件市场仓库。

## 插件

| 插件 | 说明 |
|:-----|:-----|
| [create-plugin](./plugins/create-plugin/) | 脚手架与上架前校验，用于编写新插件 |
| [bdd-requirement-generator](./plugins/bdd-requirement-generator/) | 将产品需求转为 BDD（Given/When/Then）文档 |
| [detail-taro](./plugins/detail-taro/) | Taro 商详页（detail-taro3）开发规范与工作流 |

## 安装

在 Cursor 中安装 **create-plugin** 元插件：

```text
/add-plugin create-plugin
```

本地开发时，插件也会同步到 `~/.cursor/plugins/local/create-plugin/`。

## 参考

- https://cursor.directory/plugins/new
- https://open-plugins.com/plugin-builders
- https://github.com/cursor/plugin-template/tree/main
