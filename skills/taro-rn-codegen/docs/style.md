# 样式规范（Style）

## 1. 文件结构

- 每个组件目录下创建 `index.less`
- 在 `index.tsx` 中通过 `import './index.less'` 引入
- 不使用 CSS Modules（除非有严格隔离需求）

## 2. BEM 命名规范

```less
// Block
.car-price {
}

// Element
.car-price__title {
}
.car-price__price-line {
}

// Modifier
.car-price__price-line--second {
}
.car-price--highlight {
}
```

规则：

- Block 用 kebab-case：`.car-price`
- Element 用 `&__element`
- Modifier 用 `&--modifier`
- 嵌套层级建议 ≤ 5 层

## 3. 单位

- 统一使用 `px`，基于 828px 设计稿，Taro 自动转换
- 不混用 `rpx` 和 `px`（小程序特定场景除外）

```less
.my-comp {
  font-size: 28px;
  padding: 20px;
  width: 100%;
  height: 80px;
}
```

## 4. 字体 mixin

项目提供全局字体 mixin，必须使用：

```less
.font-regular()   // 常规字重
.font-medium()    // 中等字重
.font-bold()      // 粗体
.font-number()    // 数字专用字体;
```

示例：

```less
.price {
  font-size: 50px;
  color: #ff3600;
  .font-number();
}

.label {
  font-size: 28px;
  color: #333;
  .font-regular();
}
```

## 5. RN 不支持的属性

| 不支持                     | 替代方案                      |
| -------------------------- | ----------------------------- |
| `white-space: nowrap`      | 移除（RN Text 默认不换行）    |
| `text-overflow: ellipsis`  | 用 `<Text numberOfLines={1}>` |
| `overflow: hidden/scroll`  | 用 `<ScrollView>` 组件        |
| `position: fixed`          | 用 `<CoverView>` 或页面级组件 |
| `box-shadow`               | 用 RN shadow 属性             |
| `::before` / `::after`     | 用额外 `<View>` 替代          |
| `:hover` / `:focus`        | 用状态变量模拟                |
| `background-image`         | 用 `<Image>` 绝对定位替代     |
| `linear-gradient`          | 用 `LinearGradient` 组件      |
| `transform: translateZ(0)` | 移除，不做硬件加速            |

## 6. flex 布局

RN 默认 `flex-direction: column`，需要横向排列时必须显式声明：

```less
.row-layout {
  display: flex;
  flex-direction: row; // 必须显式声明
  align-items: center;
}
```

## 7. 条件编译

```less
.container {
  padding: 20px;

  /*  #ifdef  h5  */
  padding-top: 108px; // H5 有导航栏
  /*  #endif  */

  /*  #ifndef  rn  */
  &::-webkit-scrollbar {
    display: none;
  }
  /*  #endif  */
}
```

- `#ifdef rn` / `#ifdef h5` / `#ifdef weapp`：仅在指定平台生效
- `#ifndef rn`：除 RN 外的平台生效
- 注释要简短，说明"为什么有差异"

## 8. 典型组件样式模板

```less
// 组件根 Block
.my-component {
  display: flex;
  flex-direction: column;
  background-color: #fff;
  padding: 20px;

  // Header 区域
  &__header {
    display: flex;
    flex-direction: row;
    align-items: center;
    margin-bottom: 16px;
  }

  // 标题
  &__title {
    font-size: 32px;
    color: #1a1a1a;
    .font-bold();
  }

  // 副标题
  &__subtitle {
    font-size: 24px;
    color: #8f96a0;
    margin-top: 8px;
    .font-regular();
  }

  // 内容区
  &__content {
    flex: 1;
  }

  // 激活状态
  &--active {
    background-color: #fff5f0;
  }
}
```

## 9. 颜色规范

项目常用颜色（直接使用色值，不定义变量）：

| 用途          | 色值                  |
| ------------- | --------------------- |
| 主色（红/橙） | `#ff3600` / `#ff4d18` |
| 主文字        | `#1a1a1a`             |
| 次要文字      | `#5f6670`             |
| 辅助文字      | `#8f96a0`             |
| 分割线/边框   | `#e8eaed`             |
| 页面背景      | `#f6f7fa`             |
| 白色背景      | `#fff`                |
| 成功绿        | `#00b578`             |

## 10. 自检清单

- [ ] 命名是否完全符合 BEM
- [ ] 是否统一使用 `&`，无重复选择器
- [ ] 嵌套层级是否 ≤ 5 层
- [ ] 横向 flex 是否显式声明 `flex-direction: row`
- [ ] 是否使用了项目字体 mixin（`.font-regular()` 等）
- [ ] 是否排查了 RN 不支持的属性
- [ ] 是否先写 RN 基础样式，再用条件编译补充其他平台
